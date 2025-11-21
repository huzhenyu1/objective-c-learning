//
//  BookSourceManager.h
//  Read
//
//  书源管理器 - 负责书源的增删改查和持久化
//

#import <Foundation/Foundation.h>
#import "BookSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface BookSourceManager : NSObject

// 单例
+ (instancetype)sharedManager;

// 获取所有书源
- (NSArray<BookSource *> *)allBookSources;

// 获取启用的书源
- (NSArray<BookSource *> *)enabledBookSources;

// 根据书源名称获取书源
- (nullable BookSource *)getBookSourceByName:(NSString *)name;

// 根据分组获取书源
- (NSArray<BookSource *> *)bookSourcesInGroup:(NSString *)group;

// 添加书源
- (BOOL)addBookSource:(BookSource *)source;

// 删除书源
- (BOOL)removeBookSource:(BookSource *)source;

// 更新书源
- (BOOL)updateBookSource:(BookSource *)source;

// 从 JSON 数组导入书源
- (BOOL)importBookSourcesFromJSONArray:(NSArray *)jsonArray;

// 从 JSON 文件导入书源
- (BOOL)importBookSourcesFromFile:(NSString *)filePath;

// 导出所有书源为 JSON 数组
- (NSArray *)exportBookSourcesToJSONArray;

// 保存到本地
- (BOOL)saveToLocal;

// 从本地加载（优先从 Documents 读取，不存在则从 Bundle 读取）
- (BOOL)loadFromLocal;

// 重置为默认书源（从 Bundle 重新加载）
- (BOOL)resetToDefaultBookSources;

@end

NS_ASSUME_NONNULL_END

