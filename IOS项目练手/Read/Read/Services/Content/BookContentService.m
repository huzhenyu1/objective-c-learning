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

@implementation BookContentService

+ (instancetype)sharedService {
    static BookContentService *service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[BookContentService alloc] init];
    });
    return service;
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

    NSLog(@"🔍 BookContentService.fetchChapterList");
    NSLog(@"   bookUrl: %@", bookUrl);
    NSLog(@"   bookSource: %@", bookSource.bookSourceName);

    // 1. 先请求书籍详情页（bookUrl）
    NSString *fullBookUrl = [self buildFullURL:bookUrl baseURL:bookSource.bookSourceUrl];
    NSLog(@"   完整URL: %@", fullBookUrl);

    // 解析自定义 header
    NSDictionary *headers = [self parseHeaders:bookSource.header];

    [[NetworkManager sharedManager] GET:fullBookUrl
                                headers:headers
                               encoding:nil
                                success:^(NSData *data, NSString *html) {
        NSLog(@"✅ 书籍详情页请求成功，长度: %ld", (long)html.length);
        // 2. 从详情页解析出目录URL
        [self parseTocUrl:html
               bookUrl:fullBookUrl
            bookSource:bookSource
               success:success
               failure:failure];
    } failure:^(NSError *error) {
        NSLog(@"❌ 书籍详情页请求失败: %@", error.localizedDescription);
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
    NSLog(@"🔍 解析目录URL，规则: %@", bookInfoRule.tocUrl);

    NSString *tocUrl = nil;

    // 检查规则是否包含模板变量（如 {{$.novelId}}）
    if ([bookInfoRule.tocUrl containsString:@"{{"]) {
        // 包含模板，需要先解析 JSON，然后应用模板
        NSLog(@"   检测到模板规则，开始解析 JSON");
        NSLog(@"   baseRule: %@", bookInfoRule.baseRule ?: @"(nil)");

        // 先将 HTML 解析为 JSON
        NSData *jsonData = [html dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];

        if (!error && jsonObject) {
            NSLog(@"   ✅ JSON 解析成功，类型: %@", NSStringFromClass([jsonObject class]));

            // 如果有 baseRule 规则，先提取初始数据
            if (bookInfoRule.baseRule && bookInfoRule.baseRule.length > 0) {
                NSLog(@"   应用 baseRule 规则: %@", bookInfoRule.baseRule);
                id extractedData = [RuleParser extractFromJSON:jsonObject withRule:bookInfoRule.baseRule];
                NSLog(@"   提取结果类型: %@", NSStringFromClass([extractedData class]));
                if (extractedData) {
                    jsonObject = extractedData;
                    NSLog(@"   ✅ baseRule 提取成功");
                } else {
                    NSLog(@"   ⚠️ baseRule 提取结果为 nil");
                }
            } else {
                NSLog(@"   ⚠️ 没有 baseRule，直接使用原始 JSON");
            }

            // 应用模板
            NSLog(@"   JSON 对象内容: %@", jsonObject);
            tocUrl = [RuleParser applyTemplate:bookInfoRule.tocUrl withData:jsonObject];
            NSLog(@"   模板替换结果: %@", tocUrl);
        } else {
            NSLog(@"   ❌ JSON 解析失败: %@", error);
        }
    } else {
        // 普通规则，直接提取
        id tocUrlResult = [RuleParser extractFromContent:html withRule:bookInfoRule.tocUrl];
        NSLog(@"   解析结果类型: %@", NSStringFromClass([tocUrlResult class]));

        if ([tocUrlResult isKindOfClass:[NSString class]]) {
            tocUrl = tocUrlResult;
        } else if ([tocUrlResult isKindOfClass:[NSArray class]] && [tocUrlResult count] > 0) {
            tocUrl = [tocUrlResult firstObject];
        }
    }

    if (!tocUrl || tocUrl.length == 0) {
        // 如果没有找到目录URL，尝试使用当前页面作为目录页
        NSLog(@"⚠️ 未找到目录URL，使用当前页面");
        tocUrl = bookUrl;
    } else {
        NSLog(@"✅ 找到目录URL: %@", tocUrl);
    }

    // 构建完整的目录URL
    NSString *fullTocUrl = [self buildFullURL:tocUrl baseURL:bookSource.bookSourceUrl];
    NSLog(@"   完整目录URL: %@", fullTocUrl);

    // 3. 请求目录页
    NSDictionary *headers = [self parseHeaders:bookSource.header];
    [[NetworkManager sharedManager] GET:fullTocUrl
                                headers:headers
                               encoding:nil
                                success:^(NSData *data, NSString *tocHtml) {
        NSLog(@"✅ 目录页请求成功，长度: %ld", (long)tocHtml.length);
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
        NSLog(@"❌ 目录页请求失败: %@", error.localizedDescription);
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

        NSLog(@"   解析结果类型: %@", NSStringFromClass([chapterListResult class]));

        NSArray *chapterElements = nil;
        if ([chapterListResult isKindOfClass:[NSArray class]]) {
            chapterElements = chapterListResult;
        } else {
            chapterElements = @[];
        }

        NSMutableArray<ChapterModel *> *chapters = [NSMutableArray array];

        for (NSInteger i = 0; i < chapterElements.count; i++) {
            id element = chapterElements[i];

            NSLog(@"🔍 解析第 %ld 章", (long)(i + 1));
            NSLog(@"   元素类型: %@", NSStringFromClass([element class]));
            if (i == 0) {
                NSLog(@"   元素内容: %@", element);
            }

            // 解析章节名称
            NSString *chapterName = nil;
            if (tocRule.chapterName) {
                NSLog(@"   chapterName 规则: %@", tocRule.chapterName);

                // 判断元素类型
                if ([element isKindOfClass:[NSDictionary class]]) {
                    // JSON 对象，直接提取字段
                    id nameResult = [RuleParser extractFromJSON:element withRule:tocRule.chapterName];
                    chapterName = [self stringFromResult:nameResult];
                    NSLog(@"   提取章节名: %@", chapterName ?: @"(nil)");
                } else if ([element isKindOfClass:[NSString class]]) {
                    // HTML 字符串，使用 HTML 解析
                    id nameResult = [RuleParser extractFromContent:element withRule:tocRule.chapterName];
                    chapterName = [self stringFromResult:nameResult];
                    NSLog(@"   提取章节名: %@", chapterName ?: @"(nil)");
                } else {
                    // 其他类型，尝试转字符串
                    chapterName = [element description];
                    NSLog(@"   章节名(直接转换): %@", chapterName);
                }
            }

            // 解析章节URL
            NSString *chapterUrl = nil;
            if (tocRule.chapterUrl) {
                NSLog(@"   chapterUrl 规则: %@", tocRule.chapterUrl);

                // 检查是否包含 JavaScript 代码
                if ([JSScriptEngine containsJavaScript:tocRule.chapterUrl]) {
                    NSLog(@"   ⚠️ 检测到 @js 脚本");

                    // 先提取普通规则部分
                    NSString *normalRule = [JSScriptEngine extractNormalRuleFromRule:tocRule.chapterUrl];
                    NSString *jsScript = [JSScriptEngine extractJavaScriptFromRule:tocRule.chapterUrl];

                    NSLog(@"   普通规则: %@", normalRule ?: @"(nil)");
                    NSLog(@"   JS脚本: %@", [jsScript substringToIndex:MIN(50, jsScript.length)]);

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
                    NSLog(@"   提取的原始值: %@", extractedValue ?: @"(nil)");

                    // 执行 JavaScript 脚本
                    if (jsScript && extractedValue) {
                        NSDictionary *context = @{@"result": extractedValue};
                        id jsResult = [JSScriptEngine executeScript:jsScript withContext:context];
                        chapterUrl = [self stringFromResult:jsResult];
                        NSLog(@"   JS执行结果: %@", chapterUrl ?: @"(nil)");
                    }
                } else {
                    // 普通规则，直接提取
                    if ([element isKindOfClass:[NSDictionary class]]) {
                        // JSON 对象，直接提取字段
                        id urlResult = [RuleParser extractFromJSON:element withRule:tocRule.chapterUrl];
                        chapterUrl = [self stringFromResult:urlResult];
                        NSLog(@"   提取URL: %@", chapterUrl ?: @"(nil)");
                    } else if ([element isKindOfClass:[NSString class]]) {
                        // HTML 字符串，使用 HTML 解析
                        id urlResult = [RuleParser extractFromContent:element withRule:tocRule.chapterUrl];
                        chapterUrl = [self stringFromResult:urlResult];
                        NSLog(@"   提取URL: %@", chapterUrl ?: @"(nil)");
                    } else {
                        // 其他类型，尝试转字符串
                        chapterUrl = [element description];
                        NSLog(@"   URL(直接转换): %@", chapterUrl);
                    }
                }
            }

            if (i == 0) {
                NSLog(@"   ⚠️ 第一章解析完成: name=%@, url=%@", chapterName ?: @"(nil)", chapterUrl ?: @"(nil)");
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

@end

