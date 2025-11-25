//
//  ReadingStatsManager.h
//  Read
//
//  阅读统计管理器 - 记录用户的阅读数据
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 阅读记录模型
@interface ReadingRecord : NSObject <NSCoding>
@property (copy, nonatomic) NSString *bookUrl;        // 书籍URL
@property (copy, nonatomic) NSString *bookTitle;      // 书籍标题
@property (copy, nonatomic) NSString *chapterName;    // 章节名称
@property (assign, nonatomic) NSInteger chapterIndex; // 章节索引
@property (strong, nonatomic) NSDate *readTime;       // 阅读时间
@property (assign, nonatomic) NSInteger duration;     // 阅读时长（秒）
@end

// 阅读统计管理器
@interface ReadingStatsManager : NSObject

// 单例
+ (instancetype)sharedManager;

#pragma mark - 阅读时长统计

/**
 * 开始记录阅读时长
 * @param bookUrl 书籍URL
 * @param bookTitle 书籍标题
 */
- (void)startReadingSession:(NSString *)bookUrl bookTitle:(NSString *)bookTitle;

/**
 * 结束记录阅读时长
 */
- (void)endReadingSession;

/**
 * 获取今日阅读时长（秒）
 */
- (NSInteger)getTodayReadingDuration;

/**
 * 获取本周阅读时长（秒）
 */
- (NSInteger)getThisWeekReadingDuration;

/**
 * 获取总阅读时长（秒）
 */
- (NSInteger)getTotalReadingDuration;

#pragma mark - 阅读记录

/**
 * 添加阅读记录
 */
- (void)addReadingRecord:(NSString *)bookUrl
               bookTitle:(NSString *)bookTitle
             chapterName:(NSString *)chapterName
            chapterIndex:(NSInteger)chapterIndex;

/**
 * 获取最近阅读记录（最多20条）
 */
- (NSArray<ReadingRecord *> *)getRecentReadingRecords;

#pragma mark - 阅读统计

/**
 * 获取已读书籍数量
 */
- (NSInteger)getReadBooksCount;

/**
 * 获取已读章节数量
 */
- (NSInteger)getReadChaptersCount;

/**
 * 获取今日阅读字数
 */
- (NSInteger)getTodayReadingWords;

/**
 * 增加阅读字数
 */
- (void)addReadingWords:(NSInteger)words;

#pragma mark - 数据清理

/**
 * 清空所有统计数据
 */
- (void)clearAllStats;

@end

NS_ASSUME_NONNULL_END

