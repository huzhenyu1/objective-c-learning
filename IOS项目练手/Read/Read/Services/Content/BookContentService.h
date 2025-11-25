//
//  BookContentService.h
//  Read
//
//  书籍内容服务 - 获取目录和正文
//

#import <Foundation/Foundation.h>
#import "BookSource.h"
#import "BookModel.h"
#import "ChapterModel.h"

NS_ASSUME_NONNULL_BEGIN

// 章节内容模型
@interface ChapterContent : NSObject
@property (copy, nonatomic) NSString *chapterName;    // 章节名称
@property (copy, nonatomic) NSString *content;        // 正文内容
@property (copy, nonatomic) NSString *nextChapterUrl; // 下一章URL（如果有）
@end

@interface BookContentService : NSObject

// 单例
+ (instancetype)sharedService;

/**
 * 获取书籍目录（章节列表）
 * @param bookUrl 书籍详情页URL（来自搜索结果）
 * @param bookSource 书源
 * @param success 成功回调，返回章节列表和目录URL
 * @param failure 失败回调
 */
- (void)fetchChapterList:(NSString *)bookUrl
              bookSource:(BookSource *)bookSource
                 success:(void(^)(NSString *tocUrl, NSArray<ChapterModel *> *chapters))success
                 failure:(void(^)(NSError *error))failure;

/**
 * 获取章节内容
 * @param chapterUrl 章节URL
 * @param bookSource 书源
 * @param success 成功回调
 * @param failure 失败回调
 */
- (void)fetchChapterContent:(NSString *)chapterUrl
                 bookSource:(BookSource *)bookSource
                    success:(void(^)(ChapterContent *content))success
                    failure:(void(^)(NSError *error))failure;

/**
 * 获取缓存的章节列表（用于快速打开）
 * @param book 书籍模型
 * @return 缓存的章节列表，如果没有缓存则返回 nil
 */
- (nullable NSArray<ChapterModel *> *)getCachedChapterListForBook:(BookModel *)book;

@end

NS_ASSUME_NONNULL_END

