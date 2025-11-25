//
//  ChapterListViewController.h
//  Read
//
//  章节列表页面
//

#import <UIKit/UIKit.h>
#import "BookModel.h"
#import "ChapterModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChapterListViewController : UIViewController

// 章节列表（从阅读器传入时可以直接使用，避免重复加载）
@property (strong, nonatomic, nullable) NSArray<ChapterModel *> *chapters;

// 初始化方法
- (instancetype)initWithBook:(BookModel *)book;

@end

NS_ASSUME_NONNULL_END

