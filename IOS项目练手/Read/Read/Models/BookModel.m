//
//  BookModel.m
//  Read
//
//  书籍数据模型
//

#import "BookModel.h"

@implementation BookModel

+ (instancetype)bookWithTitle:(NSString *)title
                       author:(NSString *)author
                      chapter:(NSInteger)chapter
                        total:(NSInteger)total
                         type:(BookType)type {
    BookModel *model = [[BookModel alloc] init];
    model.bookId = [[NSUUID UUID] UUIDString];
    model.title = title;
    model.author = author;
    model.currentChapter = chapter;
    model.totalChapters = total;
    model.bookType = type;
    model.lastReadTime = @"2025-01-01";
    model.fileSize = 1.5;
    model.unreadCount = total - chapter;
    return model;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<BookModel: %@ by %@, %ld/%ld>",
            self.title, self.author, (long)self.currentChapter, (long)self.totalChapters];
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.bookId forKey:@"bookId"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.author forKey:@"author"];
    [coder encodeObject:self.coverImageURL forKey:@"coverImageURL"];
    [coder encodeInteger:self.currentChapter forKey:@"currentChapter"];
    [coder encodeObject:self.currentChapterName forKey:@"currentChapterName"];  // ⭐ 新增
    [coder encodeInteger:self.totalChapters forKey:@"totalChapters"];
    [coder encodeObject:self.latestChapterName forKey:@"latestChapterName"];  // ⭐ 新增
    [coder encodeObject:self.lastReadTime forKey:@"lastReadTime"];
    [coder encodeInteger:self.bookType forKey:@"bookType"];
    [coder encodeDouble:self.fileSize forKey:@"fileSize"];
    [coder encodeInteger:self.unreadCount forKey:@"unreadCount"];
    [coder encodeObject:self.bookUrl forKey:@"bookUrl"];
    [coder encodeObject:self.bookSourceName forKey:@"bookSourceName"];
    [coder encodeObject:self.intro forKey:@"intro"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _bookId = [coder decodeObjectOfClass:[NSString class] forKey:@"bookId"];
        _title = [coder decodeObjectOfClass:[NSString class] forKey:@"title"];
        _author = [coder decodeObjectOfClass:[NSString class] forKey:@"author"];
        _coverImageURL = [coder decodeObjectOfClass:[NSString class] forKey:@"coverImageURL"];
        _currentChapter = [coder decodeIntegerForKey:@"currentChapter"];
        _currentChapterName = [coder decodeObjectOfClass:[NSString class] forKey:@"currentChapterName"];  // ⭐ 新增
        _totalChapters = [coder decodeIntegerForKey:@"totalChapters"];
        _latestChapterName = [coder decodeObjectOfClass:[NSString class] forKey:@"latestChapterName"];  // ⭐ 新增
        _lastReadTime = [coder decodeObjectOfClass:[NSString class] forKey:@"lastReadTime"];
        _bookType = [coder decodeIntegerForKey:@"bookType"];
        _fileSize = [coder decodeDoubleForKey:@"fileSize"];
        _unreadCount = [coder decodeIntegerForKey:@"unreadCount"];
        _bookUrl = [coder decodeObjectOfClass:[NSString class] forKey:@"bookUrl"];
        _bookSourceName = [coder decodeObjectOfClass:[NSString class] forKey:@"bookSourceName"];
        _intro = [coder decodeObjectOfClass:[NSString class] forKey:@"intro"];
    }
    return self;
}

@end

