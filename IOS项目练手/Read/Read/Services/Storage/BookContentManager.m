//
//  BookContentManager.m
//  Read
//
//  书籍内容管理器实现
//

#import "BookContentManager.h"

@implementation Chapter
@end

@interface BookContentManager ()
@property (copy, nonatomic) NSString *cacheDirectory;
@end

@implementation BookContentManager

+ (instancetype)sharedManager {
    static BookContentManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[BookContentManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 设置缓存目录：Documents/BookCache
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        _cacheDirectory = [docPath stringByAppendingPathComponent:@"BookCache"];

        // 创建缓存目录
        NSFileManager *fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:_cacheDirectory]) {
            [fm createDirectoryAtPath:_cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
            // NSLog(@"📁 创建缓存目录: %@", _cacheDirectory);
        }
    }
    return self;
}

#pragma mark - 路径生成

// 获取书籍目录路径
- (NSString *)directoryForBookId:(NSString *)bookId {
    return [self.cacheDirectory stringByAppendingPathComponent:bookId];
}

// 获取章节文件路径
- (NSString *)filePathForBookId:(NSString *)bookId chapterId:(NSString *)chapterId {
    NSString *bookDir = [self directoryForBookId:bookId];
    NSString *fileName = [NSString stringWithFormat:@"%@.json", chapterId];
    return [bookDir stringByAppendingPathComponent:fileName];
}

#pragma mark - 章节内容管理

- (BOOL)saveChapter:(Chapter *)chapter {
    if (!chapter || !chapter.bookId || !chapter.chapterId) {
        // NSLog(@"❌ 章节信息不完整");
        return NO;
    }

    // 确保书籍目录存在
    NSString *bookDir = [self directoryForBookId:chapter.bookId];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:bookDir]) {
        NSError *error = nil;
        [fm createDirectoryAtPath:bookDir withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            // NSLog(@"❌ 创建书籍目录失败: %@", error);
            return NO;
        }
    }

    // 构建 JSON 数据
    NSDictionary *chapterData = @{
        @"bookId": chapter.bookId,
        @"chapterId": chapter.chapterId,
        @"chapterName": chapter.chapterName ?: @"",
        @"chapterUrl": chapter.chapterUrl ?: @"",
        @"content": chapter.content ?: @"",
        @"isDownloaded": @(chapter.isDownloaded),
        @"downloadDate": @(chapter.downloadDate ? [chapter.downloadDate timeIntervalSince1970] : [[NSDate date] timeIntervalSince1970])
    };

    // 保存到文件
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:chapterData options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        // NSLog(@"❌ 章节 JSON 序列化失败: %@", error);
        return NO;
    }

    NSString *filePath = [self filePathForBookId:chapter.bookId chapterId:chapter.chapterId];
    BOOL success = [jsonData writeToFile:filePath atomically:YES];

    if (success) {
        // NSLog(@"💾 章节已保存: %@ - %@", chapter.chapterName, filePath);
    } else {
        // NSLog(@"❌ 章节保存失败: %@", chapter.chapterName);
    }

    return success;
}

- (nullable Chapter *)loadChapterWithBookId:(NSString *)bookId chapterId:(NSString *)chapterId {
    NSString *filePath = [self filePathForBookId:bookId chapterId:chapterId];

    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return nil;
    }

    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    if (!jsonData) {
        return nil;
    }

    NSError *error = nil;
    NSDictionary *chapterData = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (error || ![chapterData isKindOfClass:[NSDictionary class]]) {
        // NSLog(@"❌ 章节 JSON 解析失败: %@", error);
        return nil;
    }

    // 构建 Chapter 对象
    Chapter *chapter = [[Chapter alloc] init];
    chapter.bookId = chapterData[@"bookId"];
    chapter.chapterId = chapterData[@"chapterId"];
    chapter.chapterName = chapterData[@"chapterName"];
    chapter.chapterUrl = chapterData[@"chapterUrl"];
    chapter.content = chapterData[@"content"];
    chapter.isDownloaded = [chapterData[@"isDownloaded"] boolValue];

    NSTimeInterval timestamp = [chapterData[@"downloadDate"] doubleValue];
    if (timestamp > 0) {
        chapter.downloadDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
    }

    // NSLog(@"📖 章节已加载: %@", chapter.chapterName);
    return chapter;
}

- (BOOL)deleteChapterWithBookId:(NSString *)bookId chapterId:(NSString *)chapterId {
    NSString *filePath = [self filePathForBookId:bookId chapterId:chapterId];
    NSFileManager *fm = [NSFileManager defaultManager];

    if (![fm fileExistsAtPath:filePath]) {
        return YES; // 文件不存在，视为删除成功
    }

    NSError *error = nil;
    BOOL success = [fm removeItemAtPath:filePath error:&error];

    if (success) {
        // NSLog(@"🗑 章节已删除: %@ - %@", bookId, chapterId);
    } else {
        // NSLog(@"❌ 章节删除失败: %@", error);
    }

    return success;
}

- (BOOL)deleteAllChaptersForBookId:(NSString *)bookId {
    NSString *bookDir = [self directoryForBookId:bookId];
    NSFileManager *fm = [NSFileManager defaultManager];

    if (![fm fileExistsAtPath:bookDir]) {
        return YES; // 目录不存在，视为删除成功
    }

    NSError *error = nil;
    BOOL success = [fm removeItemAtPath:bookDir error:&error];

    if (success) {
        // NSLog(@"🗑 书籍所有章节已删除: %@", bookId);
    } else {
        // NSLog(@"❌ 删除书籍章节失败: %@", error);
    }

    return success;
}

- (BOOL)isChapterDownloadedWithBookId:(NSString *)bookId chapterId:(NSString *)chapterId {
    NSString *filePath = [self filePathForBookId:bookId chapterId:chapterId];
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

- (NSArray<Chapter *> *)downloadedChaptersForBookId:(NSString *)bookId {
    NSString *bookDir = [self directoryForBookId:bookId];
    NSFileManager *fm = [NSFileManager defaultManager];

    if (![fm fileExistsAtPath:bookDir]) {
        return @[];
    }

    NSError *error = nil;
    NSArray<NSString *> *files = [fm contentsOfDirectoryAtPath:bookDir error:&error];
    if (error) {
        // NSLog(@"❌ 读取书籍目录失败: %@", error);
        return @[];
    }

    NSMutableArray<Chapter *> *chapters = [NSMutableArray array];
    for (NSString *fileName in files) {
        if ([fileName hasSuffix:@".json"]) {
            NSString *chapterId = [fileName stringByReplacingOccurrencesOfString:@".json" withString:@""];
            Chapter *chapter = [self loadChapterWithBookId:bookId chapterId:chapterId];
            if (chapter) {
                [chapters addObject:chapter];
            }
        }
    }

    return chapters;
}

#pragma mark - 缓存管理

- (unsigned long long)getCacheSize {
    NSFileManager *fm = [NSFileManager defaultManager];

    if (![fm fileExistsAtPath:self.cacheDirectory]) {
        return 0;
    }

    NSError *error = nil;
    NSArray<NSString *> *files = [fm subpathsOfDirectoryAtPath:self.cacheDirectory error:&error];
    if (error) {
        // NSLog(@"❌ 读取缓存目录失败: %@", error);
        return 0;
    }

    unsigned long long totalSize = 0;
    for (NSString *file in files) {
        NSString *filePath = [self.cacheDirectory stringByAppendingPathComponent:file];
        NSDictionary *attrs = [fm attributesOfItemAtPath:filePath error:nil];
        if (attrs) {
            totalSize += [attrs fileSize];
        }
    }

    return totalSize;
}

- (BOOL)clearAllCache {
    NSFileManager *fm = [NSFileManager defaultManager];

    if (![fm fileExistsAtPath:self.cacheDirectory]) {
        return YES;
    }

    NSError *error = nil;
    BOOL success = [fm removeItemAtPath:self.cacheDirectory error:&error];

    if (success) {
        // 重新创建缓存目录
        [fm createDirectoryAtPath:self.cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        // NSLog(@"🗑 缓存已清空");
    } else {
        // NSLog(@"❌ 清空缓存失败: %@", error);
    }

    return success;
}

- (BOOL)clearCacheForBookId:(NSString *)bookId {
    return [self deleteAllChaptersForBookId:bookId];
}

// 格式化缓存大小
+ (NSString *)formatCacheSize:(unsigned long long)size {
    if (size < 1024) {
        return [NSString stringWithFormat:@"%llu B", size];
    } else if (size < 1024 * 1024) {
        return [NSString stringWithFormat:@"%.2f KB", size / 1024.0];
    } else if (size < 1024 * 1024 * 1024) {
        return [NSString stringWithFormat:@"%.2f MB", size / (1024.0 * 1024.0)];
    } else {
        return [NSString stringWithFormat:@"%.2f GB", size / (1024.0 * 1024.0 * 1024.0)];
    }
}

@end

