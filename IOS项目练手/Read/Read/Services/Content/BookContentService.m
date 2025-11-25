//
//  BookContentService.m
//  Read
//
//  书籍内容服务实现
//

#import "BookContentService.h"
#import "NetworkManager.h"
#import "RuleParser.h"
#import "JSScriptEngine.h"

@implementation ChapterContent
@end

@interface BookContentService ()
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSArray<ChapterModel *> *> *chapterListCache;  // 章节列表缓存 {bookId: chapters}
@end

@implementation BookContentService

+ (instancetype)sharedService {
    static BookContentService *service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[BookContentService alloc] init];
    });
    return service;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _chapterListCache = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - 获取章节列表

- (void)fetchChapterList:(NSString *)bookUrl
              bookSource:(BookSource *)bookSource
                 success:(void(^)(NSString *tocUrl, NSArray<ChapterModel *> *chapters))success
                 failure:(void(^)(NSError *error))failure {

    if (!bookUrl || !bookSource) {
        NSError *error = [NSError errorWithDomain:@"BookContentService"
                                           code:-1001
                                       userInfo:@{NSLocalizedDescriptionKey: @"参数不能为空"}];
        if (failure) failure(error);
        return;
    }

    // 1. 先请求书籍详情页（bookUrl）
    NSString *fullBookUrl = [self buildFullURL:bookUrl baseURL:bookSource.bookSourceUrl];

    // 解析自定义 header
    NSDictionary *headers = [self parseHeaders:bookSource.header];

    [[NetworkManager sharedManager] GET:fullBookUrl
                                headers:headers
                               encoding:nil
                                success:^(NSData *data, NSString *html) {
        // 2. 从详情页解析出目录URL
        [self parseTocUrl:html
               bookUrl:fullBookUrl
            bookSource:bookSource
               success:^(NSString *tocUrl, NSArray<ChapterModel *> *chapters) {
            // ⭐ 缓存章节列表（使用bookUrl作为key）
            if (chapters && chapters.count > 0) {
                self.chapterListCache[bookUrl] = chapters;
            }

            // 调用原始success回调
            if (success) {
                success(tocUrl, chapters);
            }
        }
               failure:failure];
    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

- (void)parseTocUrl:(NSString *)html
            bookUrl:(NSString *)bookUrl
         bookSource:(BookSource *)bookSource
            success:(void(^)(NSString *tocUrl, NSArray<ChapterModel *> *chapters))success
            failure:(void(^)(NSError *error))failure {

    RuleBookInfo *bookInfoRule = bookSource.ruleBookInfo;
    if (!bookInfoRule || !bookInfoRule.tocUrl) {
        NSError *error = [NSError errorWithDomain:@"BookContentService"
                                           code:-1002
                                       userInfo:@{NSLocalizedDescriptionKey: @"书源缺少目录规则"}];
        if (failure) failure(error);
        return;
    }

    // 解析目录URL
    NSString *tocUrl = nil;

    // 检查规则是否包含模板变量（如 {{$.novelId}}）
    if ([bookInfoRule.tocUrl containsString:@"{{"]) {
        // 包含模板，需要先解析 JSON，然后应用模板
        // 先将 HTML 解析为 JSON
        NSData *jsonData = [html dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];

        if (!error && jsonObject) {
            // 如果有 baseRule 规则，先提取初始数据
            if (bookInfoRule.baseRule && bookInfoRule.baseRule.length > 0) {
                id extractedData = [RuleParser extractFromJSON:jsonObject withRule:bookInfoRule.baseRule];
                if (extractedData) {
                    jsonObject = extractedData;
                }
            }

            // 应用模板
            tocUrl = [RuleParser applyTemplate:bookInfoRule.tocUrl withData:jsonObject];
        }
    } else {
        // 普通规则，直接提取
        id tocUrlResult = [RuleParser extractFromContent:html withRule:bookInfoRule.tocUrl];

        if ([tocUrlResult isKindOfClass:[NSString class]]) {
            tocUrl = tocUrlResult;
        } else if ([tocUrlResult isKindOfClass:[NSArray class]] && [tocUrlResult count] > 0) {
            tocUrl = [tocUrlResult firstObject];
        }
    }

    if (!tocUrl || tocUrl.length == 0) {
        // 如果没有找到目录URL，尝试使用当前页面作为目录页
        tocUrl = bookUrl;
    }

    // 构建完整的目录URL
    NSString *fullTocUrl = [self buildFullURL:tocUrl baseURL:bookSource.bookSourceUrl];

    // 3. 请求目录页
    NSDictionary *headers = [self parseHeaders:bookSource.header];
    [[NetworkManager sharedManager] GET:fullTocUrl
                                headers:headers
                               encoding:nil
                                success:^(NSData *data, NSString *tocHtml) {
        // 4. 解析章节列表
        [self parseChapterList:tocHtml
                    bookSource:bookSource
                       baseURL:fullTocUrl
                       success:^(NSArray<ChapterModel *> *chapters) {
            if (success) {
                success(fullTocUrl, chapters);
            }
        }
                       failure:failure];
    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

- (void)parseChapterList:(NSString *)html
              bookSource:(BookSource *)bookSource
                 baseURL:(NSString *)baseURL
                 success:(void(^)(NSArray<ChapterModel *> *chapters))success
                 failure:(void(^)(NSError *error))failure {

    RuleToc *tocRule = bookSource.ruleToc;
    if (!tocRule || !tocRule.chapterList) {
        NSError *error = [NSError errorWithDomain:@"BookContentService"
                                           code:-1003
                                       userInfo:@{NSLocalizedDescriptionKey: @"书源缺少章节列表规则"}];
        if (failure) failure(error);
        return;
    }

    // 在后台线程解析
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        // 解析章节元素列表
        id chapterListResult = [RuleParser extractFromContent:html withRule:tocRule.chapterList];

        NSArray *chapterElements = nil;
        if ([chapterListResult isKindOfClass:[NSArray class]]) {
            chapterElements = chapterListResult;
        } else {
            chapterElements = @[];
        }

        NSMutableArray<ChapterModel *> *chapters = [NSMutableArray array];

        for (NSInteger i = 0; i < chapterElements.count; i++) {
            id element = chapterElements[i];

            // 解析章节名称
            NSString *chapterName = nil;
            if (tocRule.chapterName) {
                // 判断元素类型
                if ([element isKindOfClass:[NSDictionary class]]) {
                    // JSON 对象，直接提取字段
                    id nameResult = [RuleParser extractFromJSON:element withRule:tocRule.chapterName];
                    chapterName = [self stringFromResult:nameResult];
                } else if ([element isKindOfClass:[NSString class]]) {
                    // HTML 字符串，使用 HTML 解析
                    id nameResult = [RuleParser extractFromContent:element withRule:tocRule.chapterName];
                    chapterName = [self stringFromResult:nameResult];
                } else {
                    // 其他类型，尝试转字符串
                    chapterName = [element description];
                }
            }

            // 解析章节URL
            NSString *chapterUrl = nil;
            if (tocRule.chapterUrl) {
                // 检查是否包含 JavaScript 代码
                if ([JSScriptEngine containsJavaScript:tocRule.chapterUrl]) {
                    // 先提取普通规则部分
                    NSString *normalRule = [JSScriptEngine extractNormalRuleFromRule:tocRule.chapterUrl];
                    NSString *jsScript = [JSScriptEngine extractJavaScriptFromRule:tocRule.chapterUrl];

                    // 先用普通规则提取数据
                    id urlResult = nil;
                    if (normalRule) {
                        if ([element isKindOfClass:[NSDictionary class]]) {
                            urlResult = [RuleParser extractFromJSON:element withRule:normalRule];
                        } else if ([element isKindOfClass:[NSString class]]) {
                            urlResult = [RuleParser extractFromContent:element withRule:normalRule];
                        }
                    }

                    NSString *extractedValue = [self stringFromResult:urlResult];

                    // 执行 JavaScript 脚本
                    if (jsScript && extractedValue) {
                        NSDictionary *context = @{@"result": extractedValue};
                        id jsResult = [JSScriptEngine executeScript:jsScript withContext:context];
                        chapterUrl = [self stringFromResult:jsResult];
                    }
                } else {
                    // 普通规则，直接提取
                    if ([element isKindOfClass:[NSDictionary class]]) {
                        // JSON 对象，直接提取字段
                        id urlResult = [RuleParser extractFromJSON:element withRule:tocRule.chapterUrl];
                        chapterUrl = [self stringFromResult:urlResult];
                    } else if ([element isKindOfClass:[NSString class]]) {
                        // HTML 字符串，使用 HTML 解析
                        id urlResult = [RuleParser extractFromContent:element withRule:tocRule.chapterUrl];
                        chapterUrl = [self stringFromResult:urlResult];
                    } else {
                        // 其他类型，尝试转字符串
                        chapterUrl = [element description];
                    }
                }
            }

            if (chapterName && chapterUrl) {
                // 构建完整URL
                NSString *fullChapterUrl = [self buildFullURL:chapterUrl baseURL:baseURL];

                ChapterModel *chapter = [ChapterModel chapterWithName:chapterName
                                                                  url:fullChapterUrl
                                                                index:i];
                [chapters addObject:chapter];
            }
        }

        // 回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            if (chapters.count > 0) {
                if (success) success(chapters);
            } else {
                NSError *error = [NSError errorWithDomain:@"BookContentService"
                                                   code:-1004
                                               userInfo:@{NSLocalizedDescriptionKey: @"未找到章节"}];
                if (failure) failure(error);
            }
        });
    });
}

#pragma mark - 获取章节内容

- (void)fetchChapterContent:(NSString *)chapterUrl
                 bookSource:(BookSource *)bookSource
                    success:(void(^)(ChapterContent *content))success
                    failure:(void(^)(NSError *error))failure {

    if (!chapterUrl || !bookSource) {
        NSError *error = [NSError errorWithDomain:@"BookContentService"
                                           code:-1005
                                       userInfo:@{NSLocalizedDescriptionKey: @"参数不能为空"}];
        if (failure) failure(error);
        return;
    }

    NSDictionary *headers = [self parseHeaders:bookSource.header];

    [[NetworkManager sharedManager] GET:chapterUrl
                                headers:headers
                               encoding:nil
                                success:^(NSData *data, NSString *html) {
        // 在后台线程解析内容
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self parseChapterContent:html
                           bookSource:bookSource
                              baseURL:chapterUrl
                              success:success
                              failure:failure];
        });
    } failure:failure];
}

- (void)parseChapterContent:(NSString *)html
                 bookSource:(BookSource *)bookSource
                    baseURL:(NSString *)baseURL
                    success:(void(^)(ChapterContent *content))success
                    failure:(void(^)(NSError *error))failure {

    RuleContent *contentRule = bookSource.ruleContent;
    if (!contentRule || !contentRule.content) {
        NSError *error = [NSError errorWithDomain:@"BookContentService"
                                           code:-1006
                                       userInfo:@{NSLocalizedDescriptionKey: @"书源缺少正文规则"}];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure) failure(error);
        });
        return;
    }

    // 解析正文内容
    id contentResult = [RuleParser extractFromContent:html withRule:contentRule.content];
    NSString *contentText = [self stringFromResult:contentResult];

    // 解析下一章URL（如果有）
    NSString *nextChapterUrl = nil;
    if (contentRule.nextContentUrl) {
        id nextUrlResult = [RuleParser extractFromContent:html withRule:contentRule.nextContentUrl];
        nextChapterUrl = [self stringFromResult:nextUrlResult];
        if (nextChapterUrl) {
            nextChapterUrl = [self buildFullURL:nextChapterUrl baseURL:baseURL];
        }
    }

    // 创建内容对象
    ChapterContent *content = [[ChapterContent alloc] init];
    content.content = contentText ?: @"";
    content.nextChapterUrl = nextChapterUrl;

    // 回到主线程
    dispatch_async(dispatch_get_main_queue(), ^{
        if (content.content.length > 0) {
            if (success) success(content);
        } else {
            NSError *error = [NSError errorWithDomain:@"BookContentService"
                                               code:-1007
                                           userInfo:@{NSLocalizedDescriptionKey: @"正文内容为空"}];
            if (failure) failure(error);
        }
    });
}

#pragma mark - 辅助方法

- (NSString *)stringFromResult:(id)result {
    if (!result || [result isKindOfClass:[NSNull class]]) {
        return nil;
    }

    if ([result isKindOfClass:[NSString class]]) {
        return result;
    }

    if ([result isKindOfClass:[NSArray class]]) {
        NSArray *array = result;
        if (array.count > 0) {
            return [self stringFromResult:array[0]];
        }
        return nil;
    }

    return [NSString stringWithFormat:@"%@", result];
}

- (NSString *)buildFullURL:(NSString *)url baseURL:(NSString *)baseURL {
    if (!url || url.length == 0) {
        return baseURL;
    }

    // 如果已经是完整URL
    if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) {
        return url;
    }

    // 如果是相对路径
    if ([url hasPrefix:@"/"]) {
        // 提取baseURL的scheme和host
        NSURL *base = [NSURL URLWithString:baseURL];
        if (base) {
            return [NSString stringWithFormat:@"%@://%@%@", base.scheme, base.host, url];
        }
    }

    // 相对于当前页面的路径
    NSURL *base = [NSURL URLWithString:baseURL];
    if (base) {
        NSURL *full = [NSURL URLWithString:url relativeToURL:base];
        return full.absoluteString;
    }

    return url;
}

- (NSDictionary *)parseHeaders:(NSString *)headerString {
    if (!headerString || headerString.length == 0) {
        return nil;
    }

    NSData *jsonData = [headerString dataUsingEncoding:NSUTF8StringEncoding];
    if (!jsonData) {
        return nil;
    }

    NSError *error = nil;
    NSDictionary *headers = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];

    if (error || ![headers isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    return headers;
}

#pragma mark - 缓存管理

- (NSArray<ChapterModel *> *)getCachedChapterListForBook:(BookModel *)book {
    if (!book || !book.bookUrl) {
        return nil;
    }

    return self.chapterListCache[book.bookUrl];
}

@end



