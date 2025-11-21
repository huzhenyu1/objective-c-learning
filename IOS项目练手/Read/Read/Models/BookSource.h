//
//  BookSource.h
//  Read
//
//  书源数据模型
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 书籍信息规则
@interface RuleBookInfo : NSObject
@property (copy, nonatomic) NSString *baseRule;   // 基础规则（用于提取根数据，如 "data"）
@property (copy, nonatomic) NSString *intro;      // 简介规则
@property (copy, nonatomic) NSString *kind;       // 分类规则
@property (copy, nonatomic) NSString *tocUrl;     // 目录URL规则
@end

// 内容规则
@interface RuleContent : NSObject
@property (copy, nonatomic) NSString *content;         // 正文规则
@property (copy, nonatomic) NSString *nextContentUrl;  // 下一页规则
@end

// 搜索规则
@interface RuleSearch : NSObject
@property (copy, nonatomic) NSString *author;          // 作者规则
@property (copy, nonatomic) NSString *bookList;        // 书籍列表规则
@property (copy, nonatomic) NSString *bookUrl;         // 书籍URL规则
@property (copy, nonatomic) NSString *checkKeyWord;    // 检查关键词
@property (copy, nonatomic) NSString *intro;           // 简介规则
@property (copy, nonatomic) NSString *lastChapter;     // 最新章节规则
@property (copy, nonatomic) NSString *name;            // 书名规则
@property (copy, nonatomic) NSString *coverUrl;        // 封面URL规则
@property (copy, nonatomic) NSString *kind;            // 分类规则
@property (copy, nonatomic) NSString *wordCount;       // 字数规则
@end

// 目录规则
@interface RuleToc : NSObject
@property (copy, nonatomic) NSString *chapterList;     // 章节列表规则
@property (copy, nonatomic) NSString *chapterName;     // 章节名规则
@property (copy, nonatomic) NSString *chapterUrl;      // 章节URL规则
@end

// 书源主模型
@interface BookSource : NSObject

// 基本信息
@property (copy, nonatomic) NSString *bookSourceComment;   // 备注
@property (copy, nonatomic) NSString *bookSourceGroup;     // 分组
@property (copy, nonatomic) NSString *bookSourceName;      // 名称
@property (assign, nonatomic) NSInteger bookSourceType;    // 类型
@property (copy, nonatomic) NSString *bookSourceUrl;       // URL
@property (assign, nonatomic) NSInteger customOrder;       // 自定义排序
@property (assign, nonatomic) BOOL enabled;                // 是否启用
@property (assign, nonatomic) BOOL enabledCookieJar;       // 启用Cookie
@property (assign, nonatomic) BOOL enabledExplore;         // 启用发现
@property (copy, nonatomic) NSString *exploreUrl;          // 发现URL
@property (copy, nonatomic) NSString *header;              // 自定义请求头（JSON格式）
@property (assign, nonatomic) long long lastUpdateTime;    // 最后更新时间
@property (assign, nonatomic) NSInteger respondTime;       // 响应时间
@property (copy, nonatomic) NSString *searchUrl;           // 搜索URL
@property (assign, nonatomic) NSInteger weight;            // 权重

// 规则
@property (strong, nonatomic) RuleBookInfo *ruleBookInfo;
@property (strong, nonatomic) RuleContent *ruleContent;
@property (strong, nonatomic) RuleSearch *ruleSearch;
@property (strong, nonatomic) RuleToc *ruleToc;

// 从 JSON 创建书源
+ (instancetype)bookSourceFromJSON:(NSDictionary *)json;

// 转换为 JSON
- (NSDictionary *)toJSON;

@end

NS_ASSUME_NONNULL_END

