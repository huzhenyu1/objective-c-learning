//
//  BookshelfManager.h
//  Read
//
//  书架管理器 - 负责书架数据的增删改查和持久化
//

#import <Foundation/Foundation.h>
#import "BookModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BookshelfManager : NSObject

// 单例
+ (instancetype)sharedManager;

#pragma mark - 书籍管理

/**
 * 添加书籍到书架
 * @param book 书籍模型
 * @return YES 成功, NO 失败（已存在）
 */
- (BOOL)addBook:(BookModel *)book;

/**
 * 删除书籍
 * @param bookId 书籍ID
 */
- (void)removeBookWithId:(NSString *)bookId;

/**
 * 更新书籍信息
 * @param book 书籍模型
 */
- (void)updateBook:(BookModel *)book;

/**
 * 检查书籍是否已在书架
 * @param bookId 书籍ID
 */
- (BOOL)containsBookWithId:(NSString *)bookId;

/**
 * 获取指定类型的书籍列表
 * @param type 书籍类型
 */
- (NSArray<BookModel *> *)getBooksWithType:(BookType)type;

/**
 * 获取所有书籍
 */
- (NSArray<BookModel *> *)getAllBooks;

/**
 * 清空指定类型的书架
 * @param type 书籍类型
 */
- (void)clearBooksWithType:(BookType)type;

@end

NS_ASSUME_NONNULL_END

