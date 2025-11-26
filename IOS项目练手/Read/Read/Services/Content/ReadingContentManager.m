//
//  ReadingContentManager.m
//  Read
//
//  阅读内容管理器实现
//

#import "ReadingContentManager.h"
#import "BookContentService.h"
#import "BookContentManager.h"

// 默认配置
static const NSInteger kDefaultMaxCacheCount = 10;  // 默认最大缓存10章

@interface ReadingContentManager ()

// 书籍信息
@property (strong, nonatomic, readwrite) BookModel *book;
@property (strong, nonatomic, readwrite) NSArray<ChapterModel *> *chapters;
@property (strong, nonatomic, readwrite) BookSource *bookSource;

// 缓存管理
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSString *> *contentCache;  // 内容缓存 {chapterIndex: content}
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSDate *> *cacheAccessTime;  // 访问时间 {chapterIndex: time}
@property (strong, nonatomic) NSMutableSet<NSNumber *> *pendingRequests;  // 正在请求的章节（去重）

// 服务
@property (strong, nonatomic) BookContentService *contentService;
@property (strong, nonatomic) BookContentManager *storageManager;

@end

@implementation ReadingContentManager

#pragma mark - 初始化

- (instancetype)initWithBook:(BookModel *)book
                    chapters:(NSArray<ChapterModel *> *)chapters
                  bookSource:(BookSource *)bookSource {
    self = [super init];
    if (self) {
        _book = book;
        _chapters = chapters;
        _bookSource = bookSource;

        _contentCache = [NSMutableDictionary dictionary];
        _cacheAccessTime = [NSMutableDictionary dictionary];
        _pendingRequests = [NSMutableSet set];

        _maxCacheCount = kDefaultMaxCacheCount;

        _contentService = [BookContentService sharedService];
        _storageManager = [BookContentManager sharedManager];
    }
    return self;
}

#pragma mark - 章节加载

- (void)loadChapter:(NSInteger)chapterIndex
         completion:(void(^)(NSString * _Nullable content, NSError * _Nullable error))completion {

    // 参数校验
    if (chapterIndex < 0 || chapterIndex >= self.chapters.count) {
        NSError *error = [NSError errorWithDomain:@"ReadingContentManager"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey: @"章节索引越界"}];
        if (completion) {
            completion(nil, error);
        }
        return;
    }

    // 1. 先检查内存缓存
    NSString *cachedContent = self.contentCache[@(chapterIndex)];
    if (cachedContent) {
        // 更新访问时间（LRU）
        self.cacheAccessTime[@(chapterIndex)] = [NSDate date];
        if (completion) {
            completion(cachedContent, nil);
        }
        return;
    }

    // 2. 检查是否正在请求（去重）
    if ([self.pendingRequests containsObject:@(chapterIndex)]) {
        // 已在请求中，不重复请求
        return;
    }

    // 3. 标记为正在请求
    [self.pendingRequests addObject:@(chapterIndex)];

    ChapterModel *chapter = self.chapters[chapterIndex];

    // 4. 尝试加载本地缓存
    Chapter *cachedChapter = [self.storageManager loadChapterWithBookId:self.book.bookUrl
                                                               chapterId:[@(chapterIndex) stringValue]];
    if (cachedChapter && cachedChapter.content.length > 0) {
        // 本地缓存命中
        [self cacheContent:cachedChapter.content forChapter:chapterIndex];
        [self.pendingRequests removeObject:@(chapterIndex)];

        if (completion) {
            completion(cachedChapter.content, nil);
        }
        return;
    }

    // 5. 从网络加载
    __weak typeof(self) weakSelf = self;
    [self.contentService fetchChapterContent:chapter.chapterUrl
                                  bookSource:self.bookSource
                                     success:^(ChapterContent *chapterContent) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;

        // 缓存到内存
        [self cacheContent:chapterContent.content forChapter:chapterIndex];

        // 保存到本地
        Chapter *chapterToSave = [[Chapter alloc] init];
        chapterToSave.bookId = self.book.bookUrl;
        chapterToSave.chapterId = [@(chapterIndex) stringValue];
        chapterToSave.chapterName = chapter.chapterName;
        chapterToSave.chapterUrl = chapter.chapterUrl;
        chapterToSave.content = chapterContent.content;
        chapterToSave.isDownloaded = YES;
        chapterToSave.downloadDate = [NSDate date];
        [self.storageManager saveChapter:chapterToSave];

        // 移除请求标记
        [self.pendingRequests removeObject:@(chapterIndex)];

        // 回调
        if (completion) {
            completion(chapterContent.content, nil);
        }

    } failure:^(NSError *error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;

        // 移除请求标记
        [self.pendingRequests removeObject:@(chapterIndex)];

        // 回调
        if (completion) {
            completion(nil, error);
        }
    }];
}

- (void)preloadChapters:(NSArray<NSNumber *> *)chapterIndexes {
    // 后台预加载，不阻塞主线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        for (NSNumber *indexNumber in chapterIndexes) {
            NSInteger index = indexNumber.integerValue;

            // 如果已缓存或正在请求，跳过
            if ([self isChapterCached:index] || [self.pendingRequests containsObject:@(index)]) {
                continue;
            }

            // 加载章节（无回调）
            [self loadChapter:index completion:nil];

            // 适当延迟，避免网络拥堵
            [NSThread sleepForTimeInterval:0.5];
        }
    });
}

- (void)preloadNextChaptersFrom:(NSInteger)startIndex count:(NSInteger)count {
    NSMutableArray *indexes = [NSMutableArray array];

    for (NSInteger i = 0; i < count; i++) {
        NSInteger index = startIndex + i;
        if (index >= 0 && index < self.chapters.count) {
            [indexes addObject:@(index)];
        }
    }

    [self preloadChapters:indexes];
}

#pragma mark - 缓存管理

- (void)cacheContent:(NSString *)content forChapter:(NSInteger)chapterIndex {
    if (!content || content.length == 0) {
        return;
    }

    // 存入缓存
    self.contentCache[@(chapterIndex)] = content;
    self.cacheAccessTime[@(chapterIndex)] = [NSDate date];

    // LRU清理
    [self trimCacheIfNeeded];
}

- (nullable NSString *)getCachedContent:(NSInteger)chapterIndex {
    NSString *content = self.contentCache[@(chapterIndex)];
    if (content) {
        // 更新访问时间
        self.cacheAccessTime[@(chapterIndex)] = [NSDate date];
    }
    return content;
}

- (BOOL)isChapterCached:(NSInteger)chapterIndex {
    return self.contentCache[@(chapterIndex)] != nil;
}

- (void)clearCache {
    [self.contentCache removeAllObjects];
    [self.cacheAccessTime removeAllObjects];
}

- (void)clearCacheForChapter:(NSInteger)chapterIndex {
    [self.contentCache removeObjectForKey:@(chapterIndex)];
    [self.cacheAccessTime removeObjectForKey:@(chapterIndex)];
}

#pragma mark - LRU 缓存清理

/**
 * LRU 缓存清理：当缓存数量超过限制时，移除最久未访问的章节
 */
- (void)trimCacheIfNeeded {
    if (self.contentCache.count <= self.maxCacheCount) {
        return;
    }

    // 按访问时间排序（最早访问的在前）
    NSArray *sortedKeys = [self.cacheAccessTime keysSortedByValueUsingComparator:^NSComparisonResult(NSDate *time1, NSDate *time2) {
        return [time1 compare:time2];
    }];

    // 移除最早访问的章节
    NSInteger removeCount = self.contentCache.count - self.maxCacheCount;
    for (NSInteger i = 0; i < removeCount && i < sortedKeys.count; i++) {
        NSNumber *key = sortedKeys[i];
        [self.contentCache removeObjectForKey:key];
        [self.cacheAccessTime removeObjectForKey:key];
    }
}

#pragma mark - 缓存统计

- (NSInteger)cachedChapterCount {
    return self.contentCache.count;
}

@end

