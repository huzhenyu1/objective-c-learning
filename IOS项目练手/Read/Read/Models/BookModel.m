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

@end

