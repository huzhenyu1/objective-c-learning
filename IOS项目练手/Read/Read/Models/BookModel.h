//
//  BookModel.h
//  Read
//
//  书籍数据模型
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BookType) {
    BookTypeNetwork,   // 网络书籍
    BookTypeLocal,     // 本地书籍
    BookTypeFollow     // 关注书籍
};

@interface BookModel : NSObject <NSSecureCoding>

@property (copy, nonatomic) NSString *bookId;          // 书籍 ID
@property (copy, nonatomic) NSString *title;           // 书名
@property (copy, nonatomic) NSString *author;          // 作者
@property (copy, nonatomic) NSString *coverImageURL;   // 封面图片 URL
@property (assign, nonatomic) NSInteger currentChapter; // 当前章节索引
@property (copy, nonatomic) NSString *currentChapterName;  // ⭐ 当前章节名称
@property (assign, nonatomic) NSInteger totalChapters;  // 总章节数
@property (copy, nonatomic) NSString *latestChapterName;   // ⭐ 最新章节名称
@property (copy, nonatomic) NSString *lastReadTime;    // 最后阅读时间
@property (assign, nonatomic) BookType bookType;       // 书籍类型
@property (assign, nonatomic) CGFloat fileSize;        // 文件大小（MB）
@property (assign, nonatomic) NSInteger unreadCount;   // 未读章节数

// 📚 网络书籍额外信息
@property (copy, nonatomic) NSString *bookUrl;         // 书籍详情页 URL
@property (copy, nonatomic) NSString *bookSourceName;  // 书源名称
@property (copy, nonatomic) NSString *intro;           // 书籍简介

// 便捷初始化
+ (instancetype)bookWithTitle:(NSString *)title
                       author:(NSString *)author
                      chapter:(NSInteger)chapter
                        total:(NSInteger)total
                         type:(BookType)type;

@end

