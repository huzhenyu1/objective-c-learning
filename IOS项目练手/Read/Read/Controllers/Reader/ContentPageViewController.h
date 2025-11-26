//
//  ContentPageViewController.h
//  Read
//
//  内容页面视图控制器 - 显示章节内容（支持垂直滚动和横向翻页两种模式）
//

#import <UIKit/UIKit.h>
#import "ChapterModel.h"

NS_ASSUME_NONNULL_BEGIN

// 前向声明
@class PageModel;

/**
 * 内容页面视图控制器
 *
 * 职责：
 *   1. 显示章节内容
 *   2. 支持垂直滚动模式（scrollEnabled = YES）
 *   3. 支持横向翻页模式（scrollEnabled = NO）
 *   4. 自适应内容高度
 *
 * 使用示例：
 *   // 垂直模式
 *   ContentPageViewController *pageVC = [[ContentPageViewController alloc] init];
 *   pageVC.scrollEnabled = YES;
 *   pageVC.content = chapterContent;
 *
 *   // 横向模式
 *   ContentPageViewController *pageVC = [[ContentPageViewController alloc] init];
 *   pageVC.scrollEnabled = NO;
 *   pageVC.pageModel = pageModel;
 */
@interface ContentPageViewController : UIViewController

#pragma mark - UI组件

/**
 * 滚动视图（外层容器）
 */
@property (strong, nonatomic) UIScrollView *scrollView;

/**
 * 文本视图（显示内容）
 */
@property (strong, nonatomic) UITextView *contentTextView;

/**
 * 章节标题标签（仅横向模式显示）
 */
@property (strong, nonatomic, nullable) UILabel *chapterTitleLabel;

/**
 * 页码信息标签（仅横向模式显示）
 */
@property (strong, nonatomic, nullable) UILabel *pageInfoLabel;

/**
 * 加载指示器
 */
@property (strong, nonatomic) UIActivityIndicatorView *loadingIndicator;

#pragma mark - 数据模型

/**
 * 章节模型
 */
@property (strong, nonatomic, nullable) ChapterModel *chapter;

/**
 * 章节内容
 */
@property (copy, nonatomic, nullable) NSString *content;

/**
 * 页面模型（仅横向模式使用）
 */
@property (strong, nonatomic, nullable) PageModel *pageModel;

#pragma mark - 配置

/**
 * 是否允许滚动（YES: 垂直模式, NO: 横向模式）
 */
@property (assign, nonatomic) BOOL scrollEnabled;

/**
 * 当前内容高度（缓存，避免重复计算）
 */
@property (assign, nonatomic) CGFloat currentContentHeight;

#pragma mark - 方法

/**
 * 显示内容
 * @param content 章节内容
 */
- (void)displayContent:(NSString *)content;

/**
 * 显示加载中状态
 */
- (void)showLoading;

/**
 * 隐藏加载中状态
 */
- (void)hideLoading;

@end

NS_ASSUME_NONNULL_END

