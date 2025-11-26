//
//  ReadingProgressManager.m
//  Read
//
//  阅读进度管理器实现
//

#import "ReadingProgressManager.h"

#pragma mark - ReadingProgress 实现

@implementation ReadingProgress
@end

#pragma mark - ReadingProgressManager 实现

@interface ReadingProgressManager ()
@property (strong, nonatomic) BookModel *book;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSNumber *> *chapterOffsets;  // {chapterIndex: offset}
@property (strong, nonatomic) NSTimer *debounceSaveTimer;  // 防抖定时器
@property (assign, nonatomic) CGFloat pendingScrollOffset;  // 待保存的滚动偏移
@property (assign, nonatomic) NSInteger pendingChapterIndex;  // 待保存的章节索引
@property (strong, nonatomic) dispatch_queue_t saveQueue;  // 保存队列
@end

@implementation ReadingProgressManager

#pragma mark - 初始化

- (instancetype)initWithBook:(BookModel *)book {
    self = [super init];
    if (self) {
        _book = book;
        _chapterOffsets = [NSMutableDictionary dictionary];
        _saveQueue = dispatch_queue_create("com.read.progress.save", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)dealloc {
    [self.debounceSaveTimer invalidate];
}

#pragma mark - 进度保存与恢复

- (void)saveProgress:(CGFloat)scrollOffset chapterIndex:(NSInteger)chapterIndex {
    if (!self.book.bookUrl) {
        return;
    }

    NSString *progressKey = [NSString stringWithFormat:@"ReadProgress_%@", self.book.bookUrl];
    NSDictionary *progress = @{
        @"chapterIndex": @(chapterIndex),
        @"scrollOffset": @(scrollOffset),
        @"lastReadTime": [NSDate date]
    };

    [[NSUserDefaults standardUserDefaults] setObject:progress forKey:progressKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveProgressAsync:(CGFloat)scrollOffset chapterIndex:(NSInteger)chapterIndex {
    // 后台线程保存
    dispatch_async(self.saveQueue, ^{
        [self saveProgress:scrollOffset chapterIndex:chapterIndex];
    });
}

- (nullable ReadingProgress *)restoreProgress {
    if (!self.book.bookUrl) {
        return nil;
    }

    NSString *progressKey = [NSString stringWithFormat:@"ReadProgress_%@", self.book.bookUrl];
    NSDictionary *progress = [[NSUserDefaults standardUserDefaults] objectForKey:progressKey];

    if (!progress) {
        return nil;
    }

    ReadingProgress *result = [[ReadingProgress alloc] init];
    result.chapterIndex = [progress[@"chapterIndex"] integerValue];
    result.scrollOffset = [progress[@"scrollOffset"] floatValue];
    result.lastReadTime = progress[@"lastReadTime"];

    return result;
}

#pragma mark - 章节偏移量管理

- (void)setChapterOffset:(CGFloat)offset forChapter:(NSInteger)chapterIndex {
    self.chapterOffsets[@(chapterIndex)] = @(offset);
}

- (CGFloat)getChapterOffset:(NSInteger)chapterIndex {
    NSNumber *offset = self.chapterOffsets[@(chapterIndex)];
    return offset ? offset.floatValue : 0;
}

- (NSInteger)findChapterAtOffset:(CGFloat)offset {
    // ⭐ 使用二分查找（性能优化）
    NSArray *sortedKeys = [self.chapterOffsets.allKeys sortedArrayUsingSelector:@selector(compare:)];

    if (sortedKeys.count == 0) {
        return -1;
    }

    // 二分查找
    NSInteger left = 0;
    NSInteger right = sortedKeys.count - 1;
    NSInteger result = -1;

    while (left <= right) {
        NSInteger mid = (left + right) / 2;
        NSNumber *chapterIndexNumber = sortedKeys[mid];
        CGFloat chapterOffset = [self.chapterOffsets[chapterIndexNumber] floatValue];

        if (chapterOffset <= offset) {
            result = chapterIndexNumber.integerValue;
            left = mid + 1;
        } else {
            right = mid - 1;
        }
    }

    return result;
}

- (NSDictionary<NSNumber *, NSNumber *> *)allChapterOffsets {
    return [self.chapterOffsets copy];
}

- (void)clearChapterOffsets {
    [self.chapterOffsets removeAllObjects];
}

#pragma mark - 防抖保存

- (void)scheduleDebouncedSave:(CGFloat)scrollOffset chapterIndex:(NSInteger)chapterIndex {
    // 保存待保存的值
    self.pendingScrollOffset = scrollOffset;
    self.pendingChapterIndex = chapterIndex;

    // 取消之前的定时器
    [self.debounceSaveTimer invalidate];

    // 1秒后保存
    self.debounceSaveTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                              target:self
                                                            selector:@selector(executeDebouncedSave)
                                                            userInfo:nil
                                                             repeats:NO];
}

- (void)executeDebouncedSave {
    [self saveProgressAsync:self.pendingScrollOffset chapterIndex:self.pendingChapterIndex];
}

- (void)saveImmediately {
    // 取消防抖定时器
    [self.debounceSaveTimer invalidate];

    // 立即保存
    if (self.pendingScrollOffset >= 0 && self.pendingChapterIndex >= 0) {
        [self saveProgress:self.pendingScrollOffset chapterIndex:self.pendingChapterIndex];
    }
}

@end

