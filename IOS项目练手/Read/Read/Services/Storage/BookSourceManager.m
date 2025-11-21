//
//  BookSourceManager.m
//  Read
//
//  书源管理器实现
//

#import "BookSourceManager.h"

@interface BookSourceManager ()
@property (strong, nonatomic) NSMutableArray<BookSource *> *bookSources;
@property (copy, nonatomic) NSString *dataFilePath;
@end

@implementation BookSourceManager

+ (instancetype)sharedManager {
    static BookSourceManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[BookSourceManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _bookSources = [NSMutableArray array];

        // 设置数据文件路径
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        _dataFilePath = [docPath stringByAppendingPathComponent:@"book_sources.json"];

        // 加载数据
        [self loadFromLocal];
    }
    return self;
}

#pragma mark - 查询

- (NSArray<BookSource *> *)allBookSources {
    return [self.bookSources copy];
}

- (NSArray<BookSource *> *)enabledBookSources {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"enabled == YES"];
    return [self.bookSources filteredArrayUsingPredicate:predicate];
}

- (NSArray<BookSource *> *)bookSourcesInGroup:(NSString *)group {
    // 手动过滤，避免 NSNull 问题
    NSMutableArray *result = [NSMutableArray array];
    for (BookSource *source in self.bookSources) {
        NSString *sourceGroup = source.bookSourceGroup;
        // 安全地比较，过滤 NSNull
        if (sourceGroup &&
            ![sourceGroup isKindOfClass:[NSNull class]] &&
            [sourceGroup isEqualToString:group]) {
            [result addObject:source];
        }
    }
    return result;
}

- (BookSource *)getBookSourceByName:(NSString *)name {
    if (!name || name.length == 0) {
        return nil;
    }

    for (BookSource *source in self.bookSources) {
        if ([source.bookSourceName isEqualToString:name]) {
            return source;
        }
    }
    return nil;
}

#pragma mark - 增删改

- (BOOL)addBookSource:(BookSource *)source {
    if (!source || !source.bookSourceName) {
        return NO;
    }

    [self.bookSources addObject:source];
    return [self saveToLocal];
}

- (BOOL)removeBookSource:(BookSource *)source {
    if (!source) {
        return NO;
    }

    [self.bookSources removeObject:source];
    return [self saveToLocal];
}

- (BOOL)updateBookSource:(BookSource *)source {
    if (!source) {
        return NO;
    }

    // 直接保存，因为 source 是引用类型，已经被修改了
    return [self saveToLocal];
}

#pragma mark - 导入导出

- (BOOL)importBookSourcesFromJSONArray:(NSArray *)jsonArray {
    if (!jsonArray || jsonArray.count == 0) {
        return NO;
    }

    for (NSDictionary *json in jsonArray) {
        BookSource *source = [BookSource bookSourceFromJSON:json];
        if (source) {
            [self.bookSources addObject:source];
        }
    }

    return [self saveToLocal];
}

- (BOOL)importBookSourcesFromFile:(NSString *)filePath {
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (!data) {
        return NO;
    }

    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error || ![jsonArray isKindOfClass:[NSArray class]]) {
        // NSLog(@"导入书源失败: %@", error);
        return NO;
    }

    return [self importBookSourcesFromJSONArray:jsonArray];
}

- (NSArray *)exportBookSourcesToJSONArray {
    NSMutableArray *jsonArray = [NSMutableArray array];

    for (BookSource *source in self.bookSources) {
        NSDictionary *json = [source toJSON];
        if (json) {
            [jsonArray addObject:json];
        }
    }

    return jsonArray;
}

#pragma mark - 持久化

- (BOOL)saveToLocal {
    NSArray *jsonArray = [self exportBookSourcesToJSONArray];

    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        // NSLog(@"❌ 保存书源失败: %@", error);
        return NO;
    }

    BOOL success = [data writeToFile:self.dataFilePath atomically:YES];
    // NSLog(@"💾 保存书源%@: %@", success ? @"成功" : @"失败", self.dataFilePath);
    return success;
}

- (BOOL)loadFromLocal {
    // 优先从 Documents 目录加载
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.dataFilePath]) {
        // NSLog(@"📂 从 Documents 加载书源");
        return [self loadFromDocuments];
    }

    // Documents 不存在，从 Bundle 加载默认书源
    // NSLog(@"📦 从 Bundle 加载默认书源");
    return [self loadFromBundle];
}

// 从 Documents 目录加载
- (BOOL)loadFromDocuments {
    NSData *data = [NSData dataWithContentsOfFile:self.dataFilePath];
    if (!data) {
        // NSLog(@"❌ 无法读取 Documents 中的书源文件");
        return NO;
    }

    return [self parseJSONData:data];
}

// 从 Bundle 加载默认书源
- (BOOL)loadFromBundle {
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"book_sources" ofType:@"json"];
    if (!bundlePath) {
        // NSLog(@"⚠️ Bundle 中未找到 book_sources.json，使用硬编码默认书源");
        [self addDefaultBookSource];
        return YES;
    }

    NSData *data = [NSData dataWithContentsOfFile:bundlePath];
    if (!data) {
        // NSLog(@"❌ 无法读取 Bundle 中的书源文件");
        return NO;
    }

    BOOL success = [self parseJSONData:data];

    // 从 Bundle 加载后，立即保存到 Documents
    if (success) {
        [self saveToLocal];
        // NSLog(@"✅ 已将默认书源保存到 Documents");
    }

    return success;
}

// 解析 JSON 数据
- (BOOL)parseJSONData:(NSData *)data {
    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error || ![jsonArray isKindOfClass:[NSArray class]]) {
        // NSLog(@"❌ JSON 解析失败: %@", error);
        return NO;
    }

    [self.bookSources removeAllObjects];
    for (NSDictionary *json in jsonArray) {
        BookSource *source = [BookSource bookSourceFromJSON:json];
        if (source) {
            [self.bookSources addObject:source];
        }
    }

    // NSLog(@"✅ 加载 %ld 个书源", (long)self.bookSources.count);
    return YES;
}

// 重置为默认书源
- (BOOL)resetToDefaultBookSources {
    // NSLog(@"🔄 重置为默认书源");

    // 删除 Documents 中的文件
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.dataFilePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.dataFilePath error:nil];
    }

    // 从 Bundle 重新加载
    return [self loadFromBundle];
}

#pragma mark - 默认书源

- (void)addDefaultBookSource {
    // 添加你提供的示例书源
    NSDictionary *json = @{
        @"bookSourceComment": @"➠搜索三字以上",
        @"bookSourceGroup": @"常用",
        @"bookSourceName": @"五二零同人°",
        @"bookSourceType": @0,
        @"bookSourceUrl": @"http://www.txt520.com",
        @"customOrder": @57,
        @"enabled": @YES,
        @"enabledCookieJar": @NO,
        @"enabledExplore": @YES,
        @"exploreUrl": @"玄幻::http://www.txt520.com/xuanhuan/index<,_{{page}}>.html\n修真::http://www.txt520.com/xiuzhen/index<,_{{page}}>.html\n都市::http://www.txt520.com/ds/index<,_{{page}}>.html",
        @"lastUpdateTime": @1760290853191,
        @"respondTime": @3627,
        @"ruleBookInfo": @{
            @"intro": @"class.desc@textNodes",
            @"kind": @"class.nav_time@textNodes",
            @"tocUrl": @"text.在线阅读@href"
        },
        @"ruleContent": @{
            @"content": @"class.content@p@textNodes",
            @"nextContentUrl": @"text.下一页@href||text.下一节@href"
        },
        @"ruleSearch": @{
            @"author": @"tag.span.0@text",
            @"bookList": @"class.list@li",
            @"bookUrl": @"a@href",
            @"checkKeyWord": @"四合院",
            @"intro": @"class.desc@textNodes",
            @"lastChapter": @"class.pubdate@text",
            @"name": @"b@text##\\[.*\\]"
        },
        @"ruleToc": @{
            @"chapterList": @"class.list@li@a",
            @"chapterName": @"text",
            @"chapterUrl": @"href"
        },
        @"searchUrl": @"http://www.txt520.com/e/search/index.php",
        @"weight": @0
    };

    BookSource *source = [BookSource bookSourceFromJSON:json];
    [self.bookSources addObject:source];
    [self saveToLocal];
}

@end

