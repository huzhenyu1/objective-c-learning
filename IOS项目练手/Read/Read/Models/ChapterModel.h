//
//  ChapterModel.h
//  Read
//
//  章节数据模型
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChapterModel : NSObject

@property (copy, nonatomic) NSString *chapterName;  // 章节名称
@property (copy, nonatomic) NSString *chapterUrl;   // 章节URL
@property (assign, nonatomic) NSInteger chapterIndex; // 章节索引（从0开始）
@property (assign, nonatomic) BOOL isDownloaded;    // 是否已下载

// 便捷初始化
+ (instancetype)chapterWithName:(NSString *)name
                            url:(NSString *)url
                          index:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END

