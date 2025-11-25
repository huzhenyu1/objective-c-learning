//
//  ReaderViewController.h
//  Read
//
//  阅读器主界面 - 支持上下/左右翻页、底部工具栏、预加载缓存
//

#import <UIKit/UIKit.h>
#import "BookModel.h"
#import "ChapterModel.h"
#import "BookSource.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PageTurnMode) {
    PageTurnModeVertical,    // 上下滑动（默认）
    PageTurnModeHorizontal   // 左右翻页
};

@interface ReaderViewController : UIViewController

// 初始化方法
- (instancetype)initWithBook:(BookModel *)book
                     chapter:(ChapterModel *)chapter
                    chapters:(NSArray<ChapterModel *> *)chapters
                  bookSource:(BookSource *)bookSource;

@end

NS_ASSUME_NONNULL_END
