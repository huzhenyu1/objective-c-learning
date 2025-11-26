//
//  ReadingPaginationService.h
//  Read
//
//  阅读分页服务 - 负责文本分页算法（横向翻页模式）
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ChapterModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 页面模型
 */
@interface PageModel : NSObject
@property (strong, nonatomic) ChapterModel *chapter;  // 所属章节
@property (assign, nonatomic) NSInteger pageIndex;    // 页码（从0开始）
@property (copy, nonatomic) NSString *pageContent;    // 页面内容
@property (assign, nonatomic) NSInteger totalPages;   // 该章节总页数
@end

/**
 * 阅读分页服务
 *
 * 职责：
 *   1. 将章节内容分页（基于屏幕尺寸和字体）
 *   2. 提供页面导航（上一页/下一页）
 *   3. 缓存分页结果
 *
 * 算法：
 *   使用二分查找 + boundingRectWithSize 精确计算每页容纳的文本量
 *
 * 使用示例：
 *   ReadingPaginationService *service = [[ReadingPaginationService alloc] init];
 *   NSArray *pages = [service paginateContent:content
 *                                      chapter:chapter
 *                                        width:300
 *                                       height:600
 *                                     fontSize:17.0];
 */
@interface ReadingPaginationService : NSObject

#pragma mark - 文本分页

/**
 * 将章节内容分页
 * @param content 章节内容
 * @param chapter 章节模型
 * @param width 页面宽度
 * @param height 页面高度
 * @param fontSize 字体大小
 * @return 页面模型数组
 */
- (NSArray<PageModel *> *)paginateContent:(NSString *)content
                                  chapter:(ChapterModel *)chapter
                                    width:(CGFloat)width
                                   height:(CGFloat)height
                                 fontSize:(CGFloat)fontSize;

#pragma mark - 分页缓存

/**
 * 获取缓存的分页结果
 * @param chapterIndex 章节索引
 * @return 缓存的页面数组，如果没有则返回 nil
 */
- (nullable NSArray<PageModel *> *)getCachedPagesForChapter:(NSInteger)chapterIndex;

/**
 * 缓存分页结果
 * @param pages 页面数组
 * @param chapterIndex 章节索引
 */
- (void)cachePages:(NSArray<PageModel *> *)pages forChapter:(NSInteger)chapterIndex;

/**
 * 清除所有分页缓存
 */
- (void)clearCache;

/**
 * 清除指定章节的分页缓存
 * @param chapterIndex 章节索引
 */
- (void)clearCacheForChapter:(NSInteger)chapterIndex;

#pragma mark - 页面导航

/**
 * 查找指定章节的指定页
 * @param chapterIndex 章节索引
 * @param pageIndex 页码
 * @return 页面模型，如果找不到则返回 nil
 */
- (nullable PageModel *)findPage:(NSInteger)pageIndex inChapter:(NSInteger)chapterIndex;

/**
 * 获取所有页面（当前加载的所有章节）
 * @return 所有页面的数组
 */
- (NSArray<PageModel *> *)allPages;

/**
 * 构建所有页面数组（从多个章节的分页结果合并）
 * @param chapterIndexes 章节索引数组
 * @return 合并后的页面数组
 */
- (NSArray<PageModel *> *)buildAllPagesFromChapters:(NSArray<NSNumber *> *)chapterIndexes;

@end

NS_ASSUME_NONNULL_END

