//
//  BookshelfManager.m
//  Read
//
//  书架管理器实现
//

#import "BookshelfManager.h"

@interface BookshelfManager ()
@property (strong, nonatomic) NSMutableArray<BookModel *> *books;
@property (copy, nonatomic) NSString *dataFilePath;
@end

@implementation BookshelfManager

+ (instancetype)sharedManager {
    static BookshelfManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[BookshelfManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 初始化存储路径
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        _dataFilePath = [documentPath stringByAppendingPathComponent:@"bookshelf.plist"];

        // 加载数据
        [self loadData];
    }
    return self;
}

#pragma mark - 数据加载与保存

- (void)loadData {
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.dataFilePath]) {
        NSArray *data = [NSArray arrayWithContentsOfFile:self.dataFilePath];
        if (data) {
            self.books = [NSMutableArray array];
            for (NSDictionary *dict in data) {
                BookModel *book = [self bookFromDictionary:dict];
                if (book) {
                    [self.books addObject:book];
                }
            }
            return;
        }
    }

    // 如果文件不存在或加载失败，初始化空数组
    self.books = [NSMutableArray array];
}

- (void)saveData {
    NSMutableArray *data = [NSMutableArray array];
    for (BookModel *book in self.books) {
        [data addObject:[self dictionaryFromBook:book]];
    }

    BOOL success = [data writeToFile:self.dataFilePath atomically:YES];
    if (!success) {
        // // NSLog(@"⚠️ 保存书架数据失败");
    }
}

- (void)saveDataAsync {
    // 异步保存（避免阻塞主线程）
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self saveData];
    });
}

#pragma mark - 数据转换

- (NSDictionary *)dictionaryFromBook:(BookModel *)book {
    return @{
        @"bookId": book.bookId ?: @"",
        @"title": book.title ?: @"",
        @"author": book.author ?: @"",
        @"coverImageURL": book.coverImageURL ?: @"",
        @"currentChapter": @(book.currentChapter),
        @"totalChapters": @(book.totalChapters),
        @"lastReadTime": book.lastReadTime ?: @"",
        @"bookType": @(book.bookType),
        @"fileSize": @(book.fileSize),
        @"unreadCount": @(book.unreadCount),
        @"bookUrl": book.bookUrl ?: @"",
        @"bookSourceName": book.bookSourceName ?: @"",
        @"intro": book.intro ?: @""
    };
}

// 🛡️ 安全地从字典中获取字符串
- (NSString *)safeStringFromDict:(NSDictionary *)dict key:(NSString *)key defaultValue:(NSString *)defaultValue {
    id value = dict[key];
    if (!value || [value isKindOfClass:[NSNull class]]) {
        return defaultValue;
    }
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    }
    return [NSString stringWithFormat:@"%@", value];
}

- (BookModel *)bookFromDictionary:(NSDictionary *)dict {
    BookModel *book = [[BookModel alloc] init];

    // 🛡️ 安全地从字典中取值，避免 NSNull 崩溃
    book.bookId = [self safeStringFromDict:dict key:@"bookId" defaultValue:@""];
    book.title = [self safeStringFromDict:dict key:@"title" defaultValue:@"未知书名"];
    book.author = [self safeStringFromDict:dict key:@"author" defaultValue:@"未知作者"];
    book.coverImageURL = [self safeStringFromDict:dict key:@"coverImageURL" defaultValue:@""];
    book.lastReadTime = [self safeStringFromDict:dict key:@"lastReadTime" defaultValue:@""];
    book.bookUrl = [self safeStringFromDict:dict key:@"bookUrl" defaultValue:@""];
    book.bookSourceName = [self safeStringFromDict:dict key:@"bookSourceName" defaultValue:@""];
    book.intro = [self safeStringFromDict:dict key:@"intro" defaultValue:@""];

    // 数值类型不会有 NSNull 问题
    book.currentChapter = [dict[@"currentChapter"] integerValue];
    book.totalChapters = [dict[@"totalChapters"] integerValue];
    book.bookType = [dict[@"bookType"] integerValue];
    book.fileSize = [dict[@"fileSize"] floatValue];
    book.unreadCount = [dict[@"unreadCount"] integerValue];

    return book;
}

#pragma mark - 书籍管理

- (BOOL)addBook:(BookModel *)book {
    if (!book || !book.bookId) {
        return NO;
    }

    // 检查是否已存在
    if ([self containsBookWithId:book.bookId]) {
        return NO;
    }

    [self.books addObject:book];
    [self saveDataAsync]; // 异步保存
    return YES;
}

- (void)removeBookWithId:(NSString *)bookId {
    if (!bookId) return;

    NSInteger index = [self indexOfBookWithId:bookId];
    if (index != NSNotFound) {
        [self.books removeObjectAtIndex:index];
        [self saveDataAsync]; // 异步保存
    }
}

- (void)updateBook:(BookModel *)book {
    if (!book || !book.bookId) return;

    NSInteger index = [self indexOfBookWithId:book.bookId];
    if (index != NSNotFound) {
        self.books[index] = book;
        [self saveDataAsync]; // 异步保存
    }
}

- (BOOL)containsBookWithId:(NSString *)bookId {
    return [self indexOfBookWithId:bookId] != NSNotFound;
}

- (NSArray<BookModel *> *)getBooksWithType:(BookType)type {
    NSMutableArray *result = [NSMutableArray array];
    for (BookModel *book in self.books) {
        if (book.bookType == type) {
            [result addObject:book];
        }
    }
    return result;
}

- (NSArray<BookModel *> *)getAllBooks {
    return [self.books copy];
}

- (void)clearBooksWithType:(BookType)type {
    NSMutableArray *toRemove = [NSMutableArray array];
    for (BookModel *book in self.books) {
        if (book.bookType == type) {
            [toRemove addObject:book];
        }
    }
    [self.books removeObjectsInArray:toRemove];
    [self saveDataAsync]; // 异步保存
}

#pragma mark - 辅助方法

- (NSInteger)indexOfBookWithId:(NSString *)bookId {
    if (!bookId) return NSNotFound;

    for (NSInteger i = 0; i < self.books.count; i++) {
        if ([self.books[i].bookId isEqualToString:bookId]) {
            return i;
        }
    }
    return NSNotFound;
}

@end

