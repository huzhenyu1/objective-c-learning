//
//  BookSearchService.m
//  Read
//
//  书籍搜索服务实现
//

#import "BookSearchService.h"
#import "NetworkManager.h"
#import "HTMLParser.h"
#import "RuleParser.h"

@implementation SearchResultBook
@end

@interface BookSearchService ()
@property (strong, nonatomic) NSOperationQueue *searchQueue;
@property (strong, nonatomic) NSCache *searchCache;  // 🚀 搜索结果缓存
@end

@implementation BookSearchService

+ (instancetype)sharedService {
    static BookSearchService *service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[BookSearchService alloc] init];
    });
    return service;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _searchQueue = [[NSOperationQueue alloc] init];
        _searchQueue.maxConcurrentOperationCount = 3; // 最多3个并发搜索

        // 🚀 初始化缓存
        _searchCache = [[NSCache alloc] init];
        _searchCache.countLimit = 50; // 最多缓存50个搜索结果
    }
    return self;
}

#pragma mark - 单书源搜索

- (void)searchBooks:(NSString *)keyword
         bookSource:(BookSource *)bookSource
            success:(void(^)(NSArray<SearchResultBook *> *books))success
            failure:(void(^)(NSError *error))failure {

    if (!keyword || keyword.length == 0) {
        NSError *error = [NSError errorWithDomain:@"BookSearchService"
                                           code:-1001
                                       userInfo:@{NSLocalizedDescriptionKey: @"搜索关键词不能为空"}];
        if (failure) {
            failure(error);
        }
        return;
    }

    if (!bookSource || !bookSource.enabled) {
        NSError *error = [NSError errorWithDomain:@"BookSearchService"
                                           code:-1002
                                       userInfo:@{NSLocalizedDescriptionKey: @"书源未启用"}];
        if (failure) {
            failure(error);
        }
        return;
    }

    // 🚀 检查缓存
    NSString *cacheKey = [NSString stringWithFormat:@"%@_%@", keyword, bookSource.bookSourceName];
    NSArray *cachedResults = [self.searchCache objectForKey:cacheKey];
    if (cachedResults) {
        // 缓存命中，直接返回
        if (success) {
            success(cachedResults);
        }
        return;
    }

    // 解析搜索 URL
    NSString *searchUrl = [self parseSearchURL:bookSource.searchUrl withKeyword:keyword];
    if (!searchUrl) {
        NSError *error = [NSError errorWithDomain:@"BookSearchService"
                                           code:-1003
                                       userInfo:@{NSLocalizedDescriptionKey: @"搜索URL解析失败"}];
        if (failure) {
            failure(error);
        }
        return;
    }

    // 解析自定义 header
    NSDictionary *headers = [self parseHeaders:bookSource.header];

    // 判断是 GET 还是 POST
    BOOL isPost = [bookSource.searchUrl containsString:@"method"];

    if (isPost) {
        // POST 请求
        NSDictionary *postInfo = [self parsePostSearchURL:bookSource.searchUrl withKeyword:keyword];
        NSString *url = postInfo[@"url"];
        NSString *body = postInfo[@"body"];
        NSString *charset = postInfo[@"charset"];

        [[NetworkManager sharedManager] POST:url
                                        body:body
                                    encoding:charset
                                     success:^(NSData *data, NSString *html) {
            [self parseSearchResults:html bookSource:bookSource success:^(NSArray<SearchResultBook *> *books) {
                // 🚀 缓存搜索结果
                [self.searchCache setObject:books forKey:cacheKey];
                if (success) {
                    success(books);
                }
            } failure:failure];
        } failure:failure];
    } else {
        // GET 请求
        [[NetworkManager sharedManager] GET:searchUrl
                                    headers:headers
                                   encoding:nil
                                    success:^(NSData *data, NSString *html) {
            [self parseSearchResults:html bookSource:bookSource success:^(NSArray<SearchResultBook *> *books) {
                // 🚀 缓存搜索结果
                [self.searchCache setObject:books forKey:cacheKey];
                if (success) {
                    success(books);
                }
            } failure:failure];
        } failure:failure];
    }
}

#pragma mark - 多书源搜索

- (void)searchBooks:(NSString *)keyword
       inBookSources:(NSArray<BookSource *> *)bookSources
            progress:(void(^)(BookSource *source, NSArray<SearchResultBook *> *books))progress
          completion:(void(^)(NSArray<SearchResultBook *> *allBooks))completion {

    if (!keyword || keyword.length == 0 || !bookSources || bookSources.count == 0) {
        if (completion) {
            completion(@[]);
        }
        return;
    }

    // NSLog(@"🔍 多书源搜索 \"%@\"，共 %ld 个书源", keyword, (long)bookSources.count);

    NSMutableArray<SearchResultBook *> *allBooks = [NSMutableArray array];
    dispatch_group_t group = dispatch_group_create();

    for (BookSource *source in bookSources) {
        if (!source.enabled) {
            continue;
        }

        dispatch_group_enter(group);

        [self searchBooks:keyword
               bookSource:source
                  success:^(NSArray<SearchResultBook *> *books) {
            @synchronized (allBooks) {
                [allBooks addObjectsFromArray:books];
            }

            if (progress) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    progress(source, books);
                });
            }

            dispatch_group_leave(group);
        } failure:^(NSError *error) {
            // NSLog(@"❌ 书源 %@ 搜索失败: %@", source.bookSourceName, error.localizedDescription);

            if (progress) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    progress(source, @[]);
                });
            }

            dispatch_group_leave(group);
        }];
    }

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // NSLog(@"✅ 多书源搜索完成，共找到 %ld 本书", (long)allBooks.count);
        if (completion) {
            completion(allBooks);
        }
    });
}

#pragma mark - 解析搜索结果

- (void)parseSearchResults:(NSString *)html
                bookSource:(BookSource *)bookSource
                   success:(void(^)(NSArray<SearchResultBook *> *books))success
                   failure:(void(^)(NSError *error))failure {

    // 🚀 性能优化：在后台线程解析 HTML/JSON
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray<SearchResultBook *> *books = [self parseHTML:html bookSource:bookSource];

        // 回到主线程返回结果
        dispatch_async(dispatch_get_main_queue(), ^{
            if (books) {
                if (success) {
                    success(books);
                }
            } else {
                if (failure) {
                    NSError *error = [NSError errorWithDomain:@"BookSearchService"
                                                       code:-1006
                                                   userInfo:@{NSLocalizedDescriptionKey: @"解析失败"}];
                    failure(error);
                }
            }
        });
    });
}

// 实际的解析逻辑（在后台线程执行）
- (NSArray<SearchResultBook *> *)parseHTML:(NSString *)html bookSource:(BookSource *)bookSource {

    if (!html || html.length == 0) {
        return nil;
    }

    RuleSearch *searchRule = bookSource.ruleSearch;
    if (!searchRule) {
        return nil;
    }

    // 使用 RuleParser 提取书籍列表（自动检测 JSON 或 HTML）
    id bookListResult = [RuleParser extractFromContent:html withRule:searchRule.bookList];
    NSArray *bookElements = nil;

    if ([bookListResult isKindOfClass:[NSArray class]]) {
        bookElements = bookListResult;
    } else if ([bookListResult isKindOfClass:[NSDictionary class]]) {
        bookElements = @[bookListResult];
    } else if ([bookListResult isKindOfClass:[NSString class]]) {
        bookElements = @[bookListResult];
    } else {
        return @[];
    }

    // 解析每本书的信息
    NSMutableArray<SearchResultBook *> *books = [NSMutableArray array];

    for (id bookElement in bookElements) {
        SearchResultBook *book = [[SearchResultBook alloc] init];
        book.bookSource = bookSource;

        // 根据元素类型选择解析方式
        if ([bookElement isKindOfClass:[NSDictionary class]]) {
            // JSON 对象，直接提取字段
            NSDictionary *bookDict = (NSDictionary *)bookElement;
            book.name = [RuleParser extractFromJSON:bookDict withRule:searchRule.name];
            book.author = [RuleParser extractFromJSON:bookDict withRule:searchRule.author];

            // 提取书籍URL（可能需要模板替换）
            NSString *bookUrlRule = searchRule.bookUrl;
            if ([bookUrlRule containsString:@"{{$."]) {
                book.bookUrl = [RuleParser applyTemplate:bookUrlRule withData:bookDict];
            } else {
                book.bookUrl = [RuleParser extractFromJSON:bookDict withRule:bookUrlRule];
            }

            book.intro = [RuleParser extractFromJSON:bookDict withRule:searchRule.intro];
            book.lastChapter = [RuleParser extractFromJSON:bookDict withRule:searchRule.lastChapter];

            // 封面URL（如果有）
            if (searchRule.coverUrl) {
                book.coverUrl = [RuleParser extractFromJSON:bookDict withRule:searchRule.coverUrl];
            }
        } else if ([bookElement isKindOfClass:[NSString class]]) {
            // HTML 字符串，使用 HTMLParser
            NSString *html = (NSString *)bookElement;
            book.name = [HTMLParser extractFromHTML:html withRule:searchRule.name];
            book.author = [HTMLParser extractFromHTML:html withRule:searchRule.author];
            book.bookUrl = [HTMLParser extractFromHTML:html withRule:searchRule.bookUrl];
            book.intro = [HTMLParser extractFromHTML:html withRule:searchRule.intro];
            book.lastChapter = [HTMLParser extractFromHTML:html withRule:searchRule.lastChapter];
        }

        // 处理相对URL
        if (book.bookUrl && ![book.bookUrl hasPrefix:@"http"]) {
            book.bookUrl = [self absoluteURL:book.bookUrl baseURL:bookSource.bookSourceUrl];
        }

        // 如果书名不为空，添加到结果
        if (book.name && book.name.length > 0) {
            [books addObject:book];
        }
    }

    return books;
}

#pragma mark - URL 处理

- (NSString *)parseSearchURL:(NSString *)searchUrl withKeyword:(NSString *)keyword {
    if (!searchUrl || searchUrl.length == 0) {
        return nil;
    }

    // 处理 POST 请求（包含 JSON 配置）
    if ([searchUrl containsString:@",{"]) {
        NSArray *parts = [searchUrl componentsSeparatedByString:@",{"];
        searchUrl = parts[0];
    }

    // 替换关键词占位符 {{key}}
    searchUrl = [searchUrl stringByReplacingOccurrencesOfString:@"{{key}}" withString:keyword];

    // 替换页码占位符 {{page}}（默认为第1页）
    searchUrl = [searchUrl stringByReplacingOccurrencesOfString:@"{{page}}" withString:@"1"];

    // URL 编码关键词
    NSString *encodedKeyword = [keyword stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    searchUrl = [searchUrl stringByReplacingOccurrencesOfString:keyword withString:encodedKeyword];

    return searchUrl;
}

- (NSDictionary *)parsePostSearchURL:(NSString *)searchUrl withKeyword:(NSString *)keyword {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];

    // 分离 URL 和 JSON 配置
    NSArray *parts = [searchUrl componentsSeparatedByString:@",{"];
    if (parts.count != 2) {
        return result;
    }

    result[@"url"] = parts[0];

    // 解析 JSON 配置
    NSString *jsonString = [@"{" stringByAppendingString:parts[1]];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *config = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];

    if (!error && config) {
        result[@"charset"] = config[@"charset"];

        // 替换 body 中的占位符
        NSString *body = config[@"body"];
        body = [body stringByReplacingOccurrencesOfString:@"{{key}}" withString:keyword];
        result[@"body"] = body;
    }

    return result;
}

- (NSString *)absoluteURL:(NSString *)relativeURL baseURL:(NSString *)baseURL {
    if ([relativeURL hasPrefix:@"http"]) {
        return relativeURL;
    }

    // 移除 baseURL 末尾的斜杠和 # 符号
    if ([baseURL hasSuffix:@"#"]) {
        baseURL = [baseURL substringToIndex:baseURL.length - 1];
    }
    if ([baseURL hasSuffix:@"/"]) {
        baseURL = [baseURL substringToIndex:baseURL.length - 1];
    }

    // 处理相对路径
    if ([relativeURL hasPrefix:@"/"]) {
        return [baseURL stringByAppendingString:relativeURL];
    } else {
        return [baseURL stringByAppendingFormat:@"/%@", relativeURL];
    }
}

- (NSDictionary<NSString *, NSString *> *)parseHeaders:(NSString *)headerString {
    if (!headerString || headerString.length == 0) {
        // NSLog(@"⚠️ headerString 为空");
        return nil;
    }

    // NSLog(@"🔍 原始 header 字符串: %@", headerString);

    // 解析 JSON 格式的 header
    NSData *jsonData = [headerString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *headerDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];

    if (error) {
        // NSLog(@"⚠️ 解析 header 失败: %@", error.localizedDescription);
        // NSLog(@"⚠️ JSON 数据: %@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
        return nil;
    }

    if (![headerDict isKindOfClass:[NSDictionary class]]) {
        // NSLog(@"⚠️ header 不是字典类型: %@", NSStringFromClass([headerDict class]));
        return nil;
    }
    return headerDict;
}

#pragma mark - 取消搜索

- (void)cancelAllSearches {
    [[NetworkManager sharedManager] cancelAllRequests];
    [self.searchQueue cancelAllOperations];
    // NSLog(@"🚫 取消所有搜索");
}

- (void)clearCache {
    [self.searchCache removeAllObjects];
}

@end

