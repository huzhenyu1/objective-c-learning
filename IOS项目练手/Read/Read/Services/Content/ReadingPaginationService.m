//
//  ReadingPaginationService.m
//  Read
//
//  阅读分页服务实现
//

#import "ReadingPaginationService.h"

#pragma mark - PageModel 实现

@implementation PageModel
@end

#pragma mark - ReadingPaginationService 实现

@interface ReadingPaginationService ()
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSArray<PageModel *> *> *pagesCache;  // {chapterIndex: pages}
@end

@implementation ReadingPaginationService

- (instancetype)init {
    self = [super init];
    if (self) {
        _pagesCache = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - 文本分页

- (NSArray<PageModel *> *)paginateContent:(NSString *)content
                                  chapter:(ChapterModel *)chapter
                                    width:(CGFloat)width
                                   height:(CGFloat)height
                                 fontSize:(CGFloat)fontSize {

    if (!content || content.length == 0) {
        return @[];
    }

    NSMutableArray<PageModel *> *pages = [NSMutableArray array];
    NSInteger totalLength = content.length;
    NSInteger currentIndex = 0;
    NSInteger pageIndex = 0;

    UIFont *font = [UIFont systemFontOfSize:fontSize];
    CGSize constraintSize = CGSizeMake(width, height);

    while (currentIndex < totalLength) {
        // ⭐ 使用二分查找确定当前页能容纳的最大字符数
        NSInteger pageLength = [self binarySearchPageLengthFrom:currentIndex
                                                      totalText:content
                                                           font:font
                                                 constraintSize:constraintSize];

        if (pageLength == 0) {
            // 特殊情况：单个字符都放不下（理论上不会发生）
            pageLength = 1;
        }

        // 提取页面内容
        NSInteger endIndex = MIN(currentIndex + pageLength, totalLength);
        NSString *pageContent = [content substringWithRange:NSMakeRange(currentIndex, endIndex - currentIndex)];

        // 创建页面模型
        PageModel *page = [[PageModel alloc] init];
        page.chapter = chapter;
        page.pageIndex = pageIndex;
        page.pageContent = pageContent;

        [pages addObject:page];

        // 移动到下一页
        currentIndex = endIndex;
        pageIndex++;
    }

    // 设置总页数
    for (PageModel *page in pages) {
        page.totalPages = pages.count;
    }

    return pages;
}

/**
 * ⭐ 二分查找：查找能容纳在指定尺寸内的最大字符数
 *
 * @param startIndex 起始位置
 * @param text 全文
 * @param font 字体
 * @param size 容器尺寸
 * @return 能容纳的最大字符数
 */
- (NSInteger)binarySearchPageLengthFrom:(NSInteger)startIndex
                              totalText:(NSString *)text
                                   font:(UIFont *)font
                         constraintSize:(CGSize)size {

    NSInteger remainingLength = text.length - startIndex;
    if (remainingLength == 0) {
        return 0;
    }

    NSInteger left = 1;
    NSInteger right = remainingLength;
    NSInteger result = 1;

    while (left <= right) {
        NSInteger mid = (left + right) / 2;

        // 提取子串
        NSString *substring = [text substringWithRange:NSMakeRange(startIndex, mid)];

        // 计算高度
        CGRect boundingRect = [substring boundingRectWithSize:size
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{NSFontAttributeName: font}
                                                      context:nil];

        CGFloat textHeight = ceil(boundingRect.size.height);

        if (textHeight <= size.height) {
            // 能容纳，尝试更多
            result = mid;
            left = mid + 1;
        } else {
            // 容纳不下，减少
            right = mid - 1;
        }
    }

    return result;
}

#pragma mark - 分页缓存

- (nullable NSArray<PageModel *> *)getCachedPagesForChapter:(NSInteger)chapterIndex {
    return self.pagesCache[@(chapterIndex)];
}

- (void)cachePages:(NSArray<PageModel *> *)pages forChapter:(NSInteger)chapterIndex {
    if (pages && pages.count > 0) {
        self.pagesCache[@(chapterIndex)] = pages;
    }
}

- (void)clearCache {
    [self.pagesCache removeAllObjects];
}

- (void)clearCacheForChapter:(NSInteger)chapterIndex {
    [self.pagesCache removeObjectForKey:@(chapterIndex)];
}

#pragma mark - 页面导航

- (nullable PageModel *)findPage:(NSInteger)pageIndex inChapter:(NSInteger)chapterIndex {
    NSArray<PageModel *> *pages = [self getCachedPagesForChapter:chapterIndex];
    if (!pages || pageIndex < 0 || pageIndex >= pages.count) {
        return nil;
    }
    return pages[pageIndex];
}

- (NSArray<PageModel *> *)allPages {
    NSMutableArray<PageModel *> *allPages = [NSMutableArray array];

    // 按章节索引排序
    NSArray *sortedKeys = [self.pagesCache.allKeys sortedArrayUsingSelector:@selector(compare:)];

    for (NSNumber *chapterIndexNumber in sortedKeys) {
        NSArray<PageModel *> *pages = self.pagesCache[chapterIndexNumber];
        [allPages addObjectsFromArray:pages];
    }

    return allPages;
}

- (NSArray<PageModel *> *)buildAllPagesFromChapters:(NSArray<NSNumber *> *)chapterIndexes {
    NSMutableArray<PageModel *> *allPages = [NSMutableArray array];

    for (NSNumber *chapterIndexNumber in chapterIndexes) {
        NSArray<PageModel *> *pages = [self getCachedPagesForChapter:chapterIndexNumber.integerValue];
        if (pages) {
            [allPages addObjectsFromArray:pages];
        }
    }

    return allPages;
}

@end

