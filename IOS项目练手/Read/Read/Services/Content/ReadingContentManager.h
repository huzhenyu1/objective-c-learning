//
//  ReadingContentManager.h
//  Read
//
//  阅读内容管理器 - 负责章节加载、缓存管理、预加载
//

#import <Foundation/Foundation.h>
#import "BookModel.h"
#import "ChapterModel.h"
#import "BookSource.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 阅读内容管理器
 *
 * 职责：
 *   1. 章节内容加载（网络 + 本地缓存）
 *   2. LRU 内存缓存管理
 *   3. 预加载策略
 *   4. 请求去重
 *
 * 使用示例：
 *   ReadingContentManager *manager = [[ReadingContentManager alloc] initWithBook:book
 *                                                                        chapters:chapters
 *                                                                      bookSource:bookSource];
 *   [manager loadChapter:0 completion:^(NSString *content, NSError *error) {
 *       // 处理内容
 *   }];
 */
@interface ReadingContentManager : NSObject

#pragma mark - 初始化

/**
 * 初始化内容管理器
 * @param book 书籍模型
 * @param chapters 章节列表
 * @param bookSource 书源
 */
- (instancetype)initWithBook:(BookModel *)book
                    chapters:(NSArray<ChapterModel *> *)chapters
                  bookSource:(BookSource *)bookSource;

#pragma mark - 章节加载

/**
 * 加载指定章节内容
 * @param chapterIndex 章节索引
 * @param completion 完成回调（content: 章节内容, error: 错误信息）
 */
- (void)loadChapter:(NSInteger)chapterIndex
         completion:(void(^)(NSString * _Nullable content, NSError * _Nullable error))completion;

/**
 * 预加载多个章节（后台加载）
 * @param chapterIndexes 章节索引数组
 */
- (void)preloadChapters:(NSArray<NSNumber *> *)chapterIndexes;

/**
 * 预加载后续N章（从指定章节开始）
 * @param startIndex 起始章节索引
 * @param count 预加载数量
 */
- (void)preloadNextChaptersFrom:(NSInteger)startIndex count:(NSInteger)count;

#pragma mark - 缓存管理

/**
 * 获取缓存的章节内容
 * @param chapterIndex 章节索引
 * @return 缓存的内容，如果没有则返回 nil
 */
- (nullable NSString *)getCachedContent:(NSInteger)chapterIndex;

/**
 * 判断章节是否已缓存
 * @param chapterIndex 章节索引
 * @return 是否已缓存
 */
- (BOOL)isChapterCached:(NSInteger)chapterIndex;

/**
 * 清除所有缓存
 */
- (void)clearCache;

/**
 * 清除指定章节缓存
 * @param chapterIndex 章节索引
 */
- (void)clearCacheForChapter:(NSInteger)chapterIndex;

#pragma mark - 缓存统计

/**
 * 当前缓存的章节数量
 */
@property (nonatomic, readonly) NSInteger cachedChapterCount;

/**
 * 最大缓存章节数量（默认10章）
 */
@property (assign, nonatomic) NSInteger maxCacheCount;

#pragma mark - 书籍信息

/**
 * 书籍模型
 */
@property (strong, nonatomic, readonly) BookModel *book;

/**
 * 章节列表
 */
@property (strong, nonatomic, readonly) NSArray<ChapterModel *> *chapters;

/**
 * 书源
 */
@property (strong, nonatomic, readonly) BookSource *bookSource;

@end

NS_ASSUME_NONNULL_END

