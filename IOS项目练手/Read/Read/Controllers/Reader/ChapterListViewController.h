//
//  ChapterListViewController.h
//  Read
//
//  章节列表页面
//

#import <UIKit/UIKit.h>
#import "BookModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChapterListViewController : UIViewController

// 初始化方法
- (instancetype)initWithBook:(BookModel *)book;

@end

NS_ASSUME_NONNULL_END

