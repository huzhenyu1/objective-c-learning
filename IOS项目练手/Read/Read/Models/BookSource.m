//
//  BookSource.m
//  Read
//
//  书源数据模型实现
//

#import "BookSource.h"

@implementation RuleBookInfo
@end

@implementation RuleContent
@end

@implementation RuleSearch
@end

@implementation RuleToc
@end

@implementation BookSource

+ (instancetype)bookSourceFromJSON:(NSDictionary *)json {
    BookSource *source = [[BookSource alloc] init];

    // 辅助函数：安全地获取字符串，过滤 NSNull
    NSString* (^safeString)(id) = ^(id value) {
        if (value && ![value isKindOfClass:[NSNull class]] && [value isKindOfClass:[NSString class]]) {
            return (NSString *)value;
        }
        return (NSString *)nil;
    };

    // 基本信息
    source.bookSourceComment = safeString(json[@"bookSourceComment"]);
    source.bookSourceGroup = safeString(json[@"bookSourceGroup"]) ?: @"默认";  // 默认分组
    source.bookSourceName = safeString(json[@"bookSourceName"]);
    source.bookSourceType = [json[@"bookSourceType"] integerValue];
    source.bookSourceUrl = safeString(json[@"bookSourceUrl"]);
    source.customOrder = [json[@"customOrder"] integerValue];
    source.enabled = [json[@"enabled"] boolValue];
    source.enabledCookieJar = [json[@"enabledCookieJar"] boolValue];
    source.enabledExplore = [json[@"enabledExplore"] boolValue];
    source.exploreUrl = safeString(json[@"exploreUrl"]);
    source.header = safeString(json[@"header"]);
    source.lastUpdateTime = [json[@"lastUpdateTime"] longLongValue];
    source.respondTime = [json[@"respondTime"] integerValue];
    source.searchUrl = safeString(json[@"searchUrl"]);
    source.weight = [json[@"weight"] integerValue];

    // 解析规则
    NSDictionary *bookInfoDict = json[@"ruleBookInfo"];
    if (bookInfoDict) {
        RuleBookInfo *bookInfo = [[RuleBookInfo alloc] init];
        bookInfo.baseRule = bookInfoDict[@"init"];
        bookInfo.intro = bookInfoDict[@"intro"];
        bookInfo.kind = bookInfoDict[@"kind"];
        bookInfo.tocUrl = bookInfoDict[@"tocUrl"];
        source.ruleBookInfo = bookInfo;
    }

    NSDictionary *contentDict = json[@"ruleContent"];
    if (contentDict) {
        RuleContent *content = [[RuleContent alloc] init];
        content.content = contentDict[@"content"];
        content.nextContentUrl = contentDict[@"nextContentUrl"];
        source.ruleContent = content;
    }

    NSDictionary *searchDict = json[@"ruleSearch"];
    if (searchDict) {
        RuleSearch *search = [[RuleSearch alloc] init];
        search.author = searchDict[@"author"];
        search.bookList = searchDict[@"bookList"];
        search.bookUrl = searchDict[@"bookUrl"];
        search.checkKeyWord = searchDict[@"checkKeyWord"];
        search.intro = searchDict[@"intro"];
        search.lastChapter = searchDict[@"lastChapter"];
        search.name = searchDict[@"name"];
        search.coverUrl = searchDict[@"coverUrl"];
        search.kind = searchDict[@"kind"];
        search.wordCount = searchDict[@"wordCount"];
        source.ruleSearch = search;
    }

    NSDictionary *tocDict = json[@"ruleToc"];
    if (tocDict) {
        RuleToc *toc = [[RuleToc alloc] init];
        toc.chapterList = tocDict[@"chapterList"];
        toc.chapterName = tocDict[@"chapterName"];
        toc.chapterUrl = tocDict[@"chapterUrl"];
        source.ruleToc = toc;
    }

    return source;
}

- (NSDictionary *)toJSON {
    NSMutableDictionary *json = [NSMutableDictionary dictionary];

    // 基本信息
    if (self.bookSourceComment) json[@"bookSourceComment"] = self.bookSourceComment;
    if (self.bookSourceGroup) json[@"bookSourceGroup"] = self.bookSourceGroup;
    if (self.bookSourceName) json[@"bookSourceName"] = self.bookSourceName;
    json[@"bookSourceType"] = @(self.bookSourceType);
    if (self.bookSourceUrl) json[@"bookSourceUrl"] = self.bookSourceUrl;
    json[@"customOrder"] = @(self.customOrder);
    json[@"enabled"] = @(self.enabled);
    json[@"enabledCookieJar"] = @(self.enabledCookieJar);
    json[@"enabledExplore"] = @(self.enabledExplore);
    if (self.exploreUrl) json[@"exploreUrl"] = self.exploreUrl;
    if (self.header) json[@"header"] = self.header;
    json[@"lastUpdateTime"] = @(self.lastUpdateTime);
    json[@"respondTime"] = @(self.respondTime);
    if (self.searchUrl) json[@"searchUrl"] = self.searchUrl;
    json[@"weight"] = @(self.weight);

    // 规则
    if (self.ruleBookInfo) {
        json[@"ruleBookInfo"] = @{
            @"init": self.ruleBookInfo.baseRule ?: @"",
            @"intro": self.ruleBookInfo.intro ?: @"",
            @"kind": self.ruleBookInfo.kind ?: @"",
            @"tocUrl": self.ruleBookInfo.tocUrl ?: @""
        };
    }

    if (self.ruleContent) {
        json[@"ruleContent"] = @{
            @"content": self.ruleContent.content ?: @"",
            @"nextContentUrl": self.ruleContent.nextContentUrl ?: @""
        };
    }

    if (self.ruleSearch) {
        json[@"ruleSearch"] = @{
            @"author": self.ruleSearch.author ?: @"",
            @"bookList": self.ruleSearch.bookList ?: @"",
            @"bookUrl": self.ruleSearch.bookUrl ?: @"",
            @"checkKeyWord": self.ruleSearch.checkKeyWord ?: @"",
            @"intro": self.ruleSearch.intro ?: @"",
            @"lastChapter": self.ruleSearch.lastChapter ?: @"",
            @"name": self.ruleSearch.name ?: @""
        };
    }

    if (self.ruleToc) {
        json[@"ruleToc"] = @{
            @"chapterList": self.ruleToc.chapterList ?: @"",
            @"chapterName": self.ruleToc.chapterName ?: @"",
            @"chapterUrl": self.ruleToc.chapterUrl ?: @""
        };
    }

    return json;
}

@end

