//
//  BookSearchService.h
//  Read
//
//  书籍搜索服务 - 整合网络请求、HTML解析和书源规则
//

#import <Foundation/Foundation.h>
#import "BookSource.h"

NS_ASSUME_NONNULL_BEGIN

// 搜索结果书籍模型
@interface SearchResultBook : NSObject
@property (copy, nonatomic) NSString *name;           // 书名
@property (copy, nonatomic) NSString *author;         // 作者
@property (copy, nonatomic) NSString *bookUrl;        // 书籍详情URL
@property (copy, nonatomic) NSString *intro;          // 简介
@property (copy, nonatomic) NSString *lastChapter;    // 最新章节
@property (copy, nonatomic) NSString *coverUrl;       // 封面URL
@property (strong, nonatomic) BookSource *bookSource; // 来源书源
@end

// 搜索服务
@interface BookSearchService : NSObject

// 单例
+ (instancetype)sharedService;

// 清除搜索缓存
- (void)clearCache;

/**
 * 搜索书籍
 * @param keyword 搜索关键词
 * @param bookSource 书源
 * @param success 成功回调
 * @param failure 失败回调
 */
- (void)searchBooks:(NSString *)keyword
         bookSource:(BookSource *)bookSource
            success:(void(^)(NSArray<SearchResultBook *> *books))success
            failure:(void(^)(NSError *error))failure;

/**
 * 在多个书源中搜索
 * @param keyword 搜索关键词
 * @param bookSources 书源数组
 * @param progress 进度回调（每完成一个书源）
 * @param completion 完成回调（所有书源搜索完成）
 */
- (void)searchBooks:(NSString *)keyword
        inBookSources:(NSArray<BookSource *> *)bookSources
             progress:(void(^)(BookSource *source, NSArray<SearchResultBook *> *books))progress
           completion:(void(^)(NSArray<SearchResultBook *> *allBooks))completion;

/**
 * 取消所有搜索
 */
- (void)cancelAllSearches;

@end

NS_ASSUME_NONNULL_END

