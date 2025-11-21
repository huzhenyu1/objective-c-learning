//
//  BookContentManager.h
//  Read
//
//  书籍内容管理器 - 负责章节内容的本地存储和读取
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 章节模型
@interface Chapter : NSObject
@property (copy, nonatomic) NSString *bookId;        // 书籍ID
@property (copy, nonatomic) NSString *chapterId;     // 章节ID
@property (copy, nonatomic) NSString *chapterName;   // 章节名称
@property (copy, nonatomic) NSString *chapterUrl;    // 章节URL
@property (copy, nonatomic) NSString *content;       // 章节内容
@property (assign, nonatomic) BOOL isDownloaded;     // 是否已下载
@property (strong, nonatomic) NSDate *downloadDate;  // 下载时间
@end

// 书籍内容管理器
@interface BookContentManager : NSObject

// 单例
+ (instancetype)sharedManager;

#pragma mark - 章节内容管理

// 保存章节内容到本地
- (BOOL)saveChapter:(Chapter *)chapter;

// 从本地读取章节内容
- (nullable Chapter *)loadChapterWithBookId:(NSString *)bookId chapterId:(NSString *)chapterId;

// 删除章节内容
- (BOOL)deleteChapterWithBookId:(NSString *)bookId chapterId:(NSString *)chapterId;

// 删除整本书的所有章节
- (BOOL)deleteAllChaptersForBookId:(NSString *)bookId;

// 检查章节是否已下载
- (BOOL)isChapterDownloadedWithBookId:(NSString *)bookId chapterId:(NSString *)chapterId;

// 获取书籍的所有已下载章节
- (NSArray<Chapter *> *)downloadedChaptersForBookId:(NSString *)bookId;

#pragma mark - 缓存管理

// 获取缓存大小（字节）
- (unsigned long long)getCacheSize;

// 清理所有缓存
- (BOOL)clearAllCache;

// 清理指定书籍的缓存
- (BOOL)clearCacheForBookId:(NSString *)bookId;

// 获取缓存路径
- (NSString *)cacheDirectory;

#pragma mark - Utility

// 格式化缓存大小（类方法）
+ (NSString *)formatCacheSize:(unsigned long long)size;

@end

NS_ASSUME_NONNULL_END

