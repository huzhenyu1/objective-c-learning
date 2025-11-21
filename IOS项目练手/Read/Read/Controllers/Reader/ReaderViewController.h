//
//  ReaderViewController.h
//  Read
//
//  阅读页面
//

#import <UIKit/UIKit.h>
#import "BookModel.h"
#import "ChapterModel.h"
#import "BookSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface ReaderViewController : UIViewController

// 初始化方法
- (instancetype)initWithBook:(BookModel *)book
                     chapter:(ChapterModel *)chapter
                    chapters:(NSArray<ChapterModel *> *)chapters
                  bookSource:(BookSource *)bookSource;

@end

NS_ASSUME_NONNULL_END

