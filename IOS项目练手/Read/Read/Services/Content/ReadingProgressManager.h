//
//  ReadingProgressManager.h
//  Read
//
//  阅读进度管理器 - 负责进度保存、恢复、章节偏移管理
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BookModel.h"
#import "ChapterModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 阅读进度信息
 */
@interface ReadingProgress : NSObject
@property (assign, nonatomic) NSInteger chapterIndex;  // 章节索引
@property (assign, nonatomic) CGFloat scrollOffset;    // 滚动偏移量
@property (strong, nonatomic) NSDate *lastReadTime;    // 最后阅读时间
@end

/**
 * 阅读进度管理器
 *
 * 职责：
 *   1. 保存和恢复阅读进度（章节索引 + 滚动位置）
 *   2. 管理章节偏移量映射（用于垂直滚动模式）
 *   3. 提供线程安全的进度保存
 *
 * 使用示例：
 *   ReadingProgressManager *manager = [[ReadingProgressManager alloc] initWithBook:book];
 *   [manager saveProgress:500.0 chapterIndex:5];
 *   ReadingProgress *progress = [manager restoreProgress];
 */
@interface ReadingProgressManager : NSObject

#pragma mark - 初始化

/**
 * 初始化进度管理器
 * @param book 书籍模型
 */
- (instancetype)initWithBook:(BookModel *)book;

#pragma mark - 进度保存与恢复

/**
 * 保存阅读进度（线程安全）
 * @param scrollOffset 滚动偏移量
 * @param chapterIndex 章节索引
 */
- (void)saveProgress:(CGFloat)scrollOffset chapterIndex:(NSInteger)chapterIndex;

/**
 * 异步保存阅读进度（后台线程）
 * @param scrollOffset 滚动偏移量
 * @param chapterIndex 章节索引
 */
- (void)saveProgressAsync:(CGFloat)scrollOffset chapterIndex:(NSInteger)chapterIndex;

/**
 * 恢复阅读进度
 * @return 保存的进度信息，如果没有则返回 nil
 */
- (nullable ReadingProgress *)restoreProgress;

#pragma mark - 章节偏移量管理（垂直模式）

/**
 * 记录章节在滚动视图中的偏移量
 * @param offset Y 偏移量
 * @param chapterIndex 章节索引
 */
- (void)setChapterOffset:(CGFloat)offset forChapter:(NSInteger)chapterIndex;

/**
 * 获取章节的偏移量
 * @param chapterIndex 章节索引
 * @return 偏移量，如果没有记录则返回 0
 */
- (CGFloat)getChapterOffset:(NSInteger)chapterIndex;

/**
 * 查找指定偏移量对应的章节
 * @param offset 滚动偏移量
 * @return 章节索引，如果找不到则返回 -1
 */
- (NSInteger)findChapterAtOffset:(CGFloat)offset;

/**
 * 获取所有章节偏移量
 * @return {chapterIndex: offset}
 */
- (NSDictionary<NSNumber *, NSNumber *> *)allChapterOffsets;

/**
 * 清除所有章节偏移量
 */
- (void)clearChapterOffsets;

#pragma mark - 批量保存（防抖）

/**
 * 开始防抖保存（1秒后自动保存）
 * @param scrollOffset 滚动偏移量
 * @param chapterIndex 章节索引
 */
- (void)scheduleDebouncedSave:(CGFloat)scrollOffset chapterIndex:(NSInteger)chapterIndex;

/**
 * 立即保存（取消防抖）
 */
- (void)saveImmediately;

@end

NS_ASSUME_NONNULL_END

