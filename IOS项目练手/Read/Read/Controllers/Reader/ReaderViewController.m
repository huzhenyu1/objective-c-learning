//
//  ReaderViewController.m
//  Read
//
//  阅读器实现 - 支持上下/左右翻页、底部工具栏、预加载缓存
//

#import "ReaderViewController.h"
#import "BookContentService.h"
#import "BookshelfManager.h"
#import "ChapterListViewController.h"
#import <QuartzCore/QuartzCore.h>

// 页面模型（用于横向翻页分页）
@interface PageModel : NSObject
@property (strong, nonatomic) ChapterModel *chapter;  // 所属章节
@property (assign, nonatomic) NSInteger pageIndex;    // 页码（从0开始）
@property (copy, nonatomic) NSString *pageContent;    // 页面内容
@property (assign, nonatomic) NSInteger totalPages;   // 该章节总页数
@end

@implementation PageModel
@end

// 内容页面视图控制器
@interface ContentPageViewController : UIViewController
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UITextView *contentTextView;  // ⭐ 改为 UITextView（性能更好）
@property (strong, nonatomic) UILabel *chapterTitleLabel;
@property (strong, nonatomic) UILabel *pageInfoLabel;  // 页码信息（横向模式）
@property (strong, nonatomic) UIActivityIndicatorView *loadingIndicator;
@property (strong, nonatomic) ChapterModel *chapter;
@property (copy, nonatomic) NSString *content;
@property (assign, nonatomic) BOOL scrollEnabled;  // 控制是否可以滚动
@property (strong, nonatomic) PageModel *pageModel;  // 页面模型（横向模式）
@property (assign, nonatomic) CGFloat currentContentHeight;  // ⭐ 缓存当前内容高度，避免重复计算
@end

@implementation ContentPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    [self setupUI];
}

- (void)setupUI {
    // 章节标题
    self.chapterTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, self.view.bounds.size.width - 30, 30)];
    self.chapterTitleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.chapterTitleLabel.textColor = [UIColor labelColor];
    self.chapterTitleLabel.textAlignment = NSTextAlignmentCenter;
    if (self.pageModel) {
        self.chapterTitleLabel.text = self.pageModel.chapter.chapterName;
    } else if (self.chapter) {
        self.chapterTitleLabel.text = self.chapter.chapterName;
    }
    [self.view addSubview:self.chapterTitleLabel];

    // 滚动视图
    CGFloat scrollY = 50;
    CGFloat scrollHeight = self.view.bounds.size.height - scrollY - 30;  // 底部留30用于显示页码

    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, scrollY, self.view.bounds.size.width, scrollHeight)];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.scrollEnabled = self.scrollEnabled;  // 根据模式控制是否可滚动
    [self.view addSubview:self.scrollView];

    self.contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(15, 10, self.view.bounds.size.width - 30, 100)];
    self.contentTextView.font = [UIFont systemFontOfSize:17];
    self.contentTextView.textColor = [UIColor labelColor];
    self.contentTextView.backgroundColor = [UIColor clearColor];
    self.contentTextView.editable = NO;  // 不可编辑
    self.contentTextView.selectable = YES;  // 可选择文本
    self.contentTextView.scrollEnabled = NO;  // 禁止内部滚动，由外层 ScrollView 控制
    self.contentTextView.textContainerInset = UIEdgeInsetsZero;  // 去除内边距
    self.contentTextView.textContainer.lineFragmentPadding = 0;  // 去除行间距
    [self.scrollView addSubview:self.contentTextView];

    self.currentContentHeight = 0;  // 初始化高度

    // 页码标签（横向模式显示）
    if (!self.scrollEnabled && self.pageModel) {
        self.pageInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 30, self.view.bounds.size.width, 30)];
        self.pageInfoLabel.font = [UIFont systemFontOfSize:14];
        self.pageInfoLabel.textColor = [UIColor secondaryLabelColor];
        self.pageInfoLabel.textAlignment = NSTextAlignmentCenter;
        self.pageInfoLabel.text = [NSString stringWithFormat:@"%ld / %ld",
                                   (long)(self.pageModel.pageIndex + 1),
                                   (long)self.pageModel.totalPages];
        [self.view addSubview:self.pageInfoLabel];
    }

    // 加载指示器
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.loadingIndicator.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
    self.loadingIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                             UIViewAutoresizingFlexibleRightMargin |
                                             UIViewAutoresizingFlexibleTopMargin |
                                             UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.loadingIndicator];

    // 如果有内容就显示
    if (self.pageModel) {
        [self displayContent:self.pageModel.pageContent];
    } else if (self.content) {
        [self displayContent:self.content];
    }
}

- (void)displayContent:(NSString *)content {
    self.content = content;

    if (!self.contentTextView) {
        return;
    }

    // ⭐ 不再替换换行符，保持原文格式
    self.contentTextView.text = content;

    if (self.scrollEnabled) {
        // 竖向模式：允许滚动，使用 UITextView 的自动布局（性能更好）
        CGFloat width = self.view.bounds.size.width - 30;
        CGSize size = [self.contentTextView sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];

        self.contentTextView.frame = CGRectMake(15, 10, width, size.height);
        self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, size.height + 20);
        self.currentContentHeight = size.height;  // 缓存高度
    } else {
        // 横向模式：禁止滚动，内容限制在一个页面内
        CGFloat maxHeight = self.scrollView.bounds.size.height - 20;  // 预留上下间距
        self.contentTextView.frame = CGRectMake(15, 10, self.view.bounds.size.width - 30, maxHeight);
        self.scrollView.contentSize = self.scrollView.bounds.size;  // contentSize 等于 scrollView 大小，不可滚动
    }

    // 滚动到顶部
    [self.scrollView setContentOffset:CGPointZero animated:NO];
}

@end

// 主阅读器
@interface ReaderViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate>

// 书籍信息
@property (strong, nonatomic) BookModel *book;
@property (strong, nonatomic) NSArray<ChapterModel *> *chapters;
@property (strong, nonatomic) BookSource *bookSource;
@property (strong, nonatomic) ChapterModel *currentChapter;

// UI组件
@property (strong, nonatomic) UIPageViewController *pageViewController;  // 左右翻页
@property (strong, nonatomic) ContentPageViewController *currentPageVC;  // 当前页面
@property (strong, nonatomic) UIView *toolbar;                           // 底部工具栏
@property (strong, nonatomic) UIButton *catalogButton;                   // 目录按钮
@property (strong, nonatomic) UIButton *pageModeButton;                  // 翻页模式按钮

// 状态
@property (assign, nonatomic) PageTurnMode pageTurnMode;                 // 翻页模式
@property (assign, nonatomic) BOOL isToolbarVisible;                     // 工具栏是否可见
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSString *> *contentCache;  // 内容缓存
@property (assign, nonatomic) BOOL isLoadingNextChapter;                 // 是否正在加载下一章（防止重复触发）

// 竖向滚动相关
@property (strong, nonatomic) NSMutableArray<ChapterModel *> *loadedChapters;  // 已加载到 ScrollView 的章节
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSNumber *> *chapterOffsets;  // 每章在 ScrollView 中的 Y 偏移 {chapterIndex: offsetY}
@property (strong, nonatomic) UILabel *floatingTitleLabel;  // 浮动标题（动态显示当前章节）

// 分页相关（横向模式）
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSArray<PageModel *> *> *pagesCache;  // 章节分页缓存 {chapterIndex: [pages]}
@property (strong, nonatomic) NSArray<PageModel *> *allPages;            // 所有页面的数组（当前加载的）
@property (assign, nonatomic) NSInteger currentPageIndex;                // 当前页面索引（在allPages中）

@end

@implementation ReaderViewController

- (instancetype)initWithBook:(BookModel *)book
                     chapter:(ChapterModel *)chapter
                    chapters:(NSArray<ChapterModel *> *)chapters
                  bookSource:(BookSource *)bookSource {
    self = [super init];
    if (self) {
        _book = book;
        _currentChapter = chapter;
        _chapters = chapters;
        _bookSource = bookSource;
        _pageTurnMode = PageTurnModeVertical;  // 默认上下滑动
        _isToolbarVisible = NO;
        _isLoadingNextChapter = NO;  // 初始化加载标志
        _contentCache = [NSMutableDictionary dictionary];
        _pagesCache = [NSMutableDictionary dictionary];  // 分页缓存
        _allPages = @[];
        _currentPageIndex = 0;

        // 竖向滚动初始化
        _loadedChapters = [NSMutableArray array];
        _chapterOffsets = [NSMutableDictionary dictionary];

        // 隐藏底部 TabBar
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupUI];
    [self loadCurrentChapterContent];
    [self preloadNext3Chapters];  // 预加载接下来的3章
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // 不隐藏导航栏，保留返回按钮
    // 用户可以通过返回按钮或侧滑手势返回
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - UI Setup

- (void)setupUI {
    if (self.pageTurnMode == PageTurnModeVertical) {
        [self setupVerticalMode];
    } else {
        [self setupHorizontalMode];
    }

    [self setupToolbar];
    [self setupTapGesture];
}

- (void)setupVerticalMode {
    // 上下滑动模式：使用单个 ContentPageViewController
    self.currentPageVC = [[ContentPageViewController alloc] init];
    self.currentPageVC.chapter = self.currentChapter;
    self.currentPageVC.scrollEnabled = YES;  // 竖向模式允许滚动
    self.currentPageVC.view.frame = self.view.bounds;

    [self addChildViewController:self.currentPageVC];
    [self.view addSubview:self.currentPageVC.view];
    [self.currentPageVC didMoveToParentViewController:self];

    // 监听滚动事件，用于动态标题和预加载
    self.currentPageVC.scrollView.delegate = self;

    // 添加浮动标题（动态显示当前章节）
    [self setupFloatingTitle];
}

- (void)setupHorizontalMode {
    // 左右翻页模式：使用 UIPageViewController（按页翻页）
    NSDictionary *options = @{UIPageViewControllerOptionInterPageSpacingKey: @(20)};
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:options];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;

    // 构建分页数据
    NSString *content = self.contentCache[@(self.currentChapter.chapterIndex)];
    if (content) {
        [self buildAllPagesFromChapter:self.currentChapter];
    }

    // 创建第一个页面
    ContentPageViewController *startVC = [[ContentPageViewController alloc] init];
    startVC.scrollEnabled = NO;  // 横向模式禁止滚动

    if (self.allPages.count > 0) {
        PageModel *firstPage = self.allPages[self.currentPageIndex];
        startVC.pageModel = firstPage;
    } else {
        startVC.chapter = self.currentChapter;
    }

    self.currentPageVC = startVC;

    [self.pageViewController setViewControllers:@[startVC]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];

    [self addChildViewController:self.pageViewController];
    self.pageViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (void)setupToolbar {
    // 底部工具栏（初始隐藏）
    CGFloat toolbarHeight = 60;
    self.toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, toolbarHeight)];
    self.toolbar.backgroundColor = [UIColor whiteColor];  // 白色背景
    self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

    // 目录按钮
    self.catalogButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.catalogButton.frame = CGRectMake(20, 10, 100, 40);
    [self.catalogButton setTitle:@"📚 目录" forState:UIControlStateNormal];
    self.catalogButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.catalogButton addTarget:self action:@selector(showCatalog) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbar addSubview:self.catalogButton];

    // 翻页模式按钮
    self.pageModeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.pageModeButton.frame = CGRectMake(self.view.bounds.size.width - 140, 10, 120, 40);
    self.pageModeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self updatePageModeButtonTitle];
    self.pageModeButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.pageModeButton addTarget:self action:@selector(togglePageMode) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbar addSubview:self.pageModeButton];

    [self.view addSubview:self.toolbar];
}

- (void)setupTapGesture {
    // 点击正文显示/隐藏工具栏
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
}

- (void)updatePageModeButtonTitle {
    NSString *title = self.pageTurnMode == PageTurnModeVertical ? @"📄 上下滑动" : @"📖 左右翻页";
    [self.pageModeButton setTitle:title forState:UIControlStateNormal];
}

#pragma mark - Gesture Handling

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    [self toggleToolbar];
}

- (void)toggleToolbar {
    self.isToolbarVisible = !self.isToolbarVisible;

    CGFloat toolbarY = self.isToolbarVisible ? (self.view.bounds.size.height - 60) : self.view.bounds.size.height;

    [UIView animateWithDuration:0.3 animations:^{
        self.toolbar.frame = CGRectMake(0, toolbarY, self.view.bounds.size.width, 60);
    }];
}

#pragma mark - Actions

- (void)showCatalog {
    [self toggleToolbar];  // 隐藏工具栏

    // 跳转到章节列表
    ChapterListViewController *catalogVC = [[ChapterListViewController alloc] initWithBook:self.book];
    catalogVC.chapters = self.chapters;
    [self.navigationController pushViewController:catalogVC animated:YES];
}

- (void)togglePageMode {
    // 切换翻页模式
    self.pageTurnMode = (self.pageTurnMode == PageTurnModeVertical) ? PageTurnModeHorizontal : PageTurnModeVertical;
    [self updatePageModeButtonTitle];

    // 重建UI
    [self rebuildUIForNewPageMode];

    // 重新加载当前章节内容
    [self loadCurrentChapterContent];
}

- (void)rebuildUIForNewPageMode {
    // 移除旧的视图
    if (self.pageViewController) {
        [self.pageViewController.view removeFromSuperview];
        [self.pageViewController removeFromParentViewController];
        self.pageViewController = nil;
    }

    if (self.currentPageVC && self.pageTurnMode == PageTurnModeHorizontal) {
        [self.currentPageVC.view removeFromSuperview];
        [self.currentPageVC removeFromParentViewController];
    }

    // 重新设置UI
    if (self.pageTurnMode == PageTurnModeVertical) {
        [self setupVerticalMode];
    } else {
        [self setupHorizontalMode];
    }

    // 确保工具栏在最上层
    [self.view bringSubviewToFront:self.toolbar];
}

#pragma mark - Floating Title

- (void)setupFloatingTitle {
    // 浮动标题标签（半透明背景）
    self.floatingTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    self.floatingTitleLabel.backgroundColor = [[UIColor systemBackgroundColor] colorWithAlphaComponent:0.95];
    self.floatingTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.floatingTitleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.floatingTitleLabel.text = self.currentChapter.chapterName;
    self.floatingTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    // 添加底部分隔线
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 43, self.view.bounds.size.width, 1)];
    separator.backgroundColor = [UIColor separatorColor];
    separator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.floatingTitleLabel addSubview:separator];

    [self.view addSubview:self.floatingTitleLabel];
    [self.view bringSubviewToFront:self.floatingTitleLabel];
}

- (void)updateFloatingTitleWithOffset:(CGFloat)offset {
    // 根据滚动位置找到当前显示的章节
    for (ChapterModel *chapter in self.loadedChapters) {
        NSNumber *chapterOffset = self.chapterOffsets[@(chapter.chapterIndex)];
        if (chapterOffset && offset >= chapterOffset.floatValue) {
            // 检查是否到下一章
            NSInteger nextIndex = chapter.chapterIndex + 1;
            NSNumber *nextOffset = self.chapterOffsets[@(nextIndex)];

            if (!nextOffset || offset < nextOffset.floatValue) {
                // 当前在这一章
                if (![self.floatingTitleLabel.text isEqualToString:chapter.chapterName]) {
                    self.floatingTitleLabel.text = chapter.chapterName;

                    // 更新当前章节
                    if (self.currentChapter.chapterIndex != chapter.chapterIndex) {
                        NSInteger oldChapterIndex = self.currentChapter.chapterIndex;
                        self.currentChapter = chapter;
                        self.book.currentChapter = chapter.chapterIndex;
                        [[BookshelfManager sharedManager] updateBook:self.book];

                        // ⭐ 章节变化时，触发后台加载更多章节
                        [self onChapterChangedFrom:oldChapterIndex to:chapter.chapterIndex];
                    }
                }
                break;
            }
        }
    }
}

// 章节变化回调：自动加载下一章
- (void)onChapterChangedFrom:(NSInteger)oldIndex to:(NSInteger)newIndex {
    // 获取最后已加载的章节
    ChapterModel *lastLoadedChapter = self.loadedChapters.lastObject;
    if (!lastLoadedChapter) return;

    NSInteger lastLoadedIndex = lastLoadedChapter.chapterIndex;
    NSInteger distanceToEnd = lastLoadedIndex - newIndex;  // 距离最后章节的距离

    // ⭐ 如果离最后已加载章节只有1章，立即后台加载下一章
    if (distanceToEnd <= 1) {
        [self startBackgroundLoadingNextChapter];
    }
}

#pragma mark - Content Loading (竖向模式：一次性加载3章)

- (void)loadCurrentChapterContent {
    if (self.pageTurnMode == PageTurnModeHorizontal) {
        // 横向模式：单章加载+分页
        [self loadSingleChapterForHorizontalMode];
    } else {
        // 竖向模式：一次性加载3章（当前+后2章）
        [self loadMultipleChaptersForVerticalMode];
    }
}

// 横向模式：单章加载
- (void)loadSingleChapterForHorizontalMode {
    NSInteger chapterIndex = self.currentChapter.chapterIndex;
    NSString *cachedContent = self.contentCache[@(chapterIndex)];

    if (cachedContent) {
        [self buildAllPagesFromChapter:self.currentChapter];
        if (self.allPages.count > 0 && self.currentPageVC) {
            self.currentPageVC.pageModel = self.allPages[self.currentPageIndex];
            [self.currentPageVC.view setNeedsLayout];
        }
        return;
    }

    [self.currentPageVC.loadingIndicator startAnimating];
    [[BookContentService sharedService] fetchChapterContent:self.currentChapter.chapterUrl
                                                 bookSource:self.bookSource
                                                    success:^(ChapterContent *content) {
        self.contentCache[@(chapterIndex)] = content.content;
        [self.currentPageVC.loadingIndicator stopAnimating];
        [self buildAllPagesFromChapter:self.currentChapter];
        if (self.allPages.count > 0 && self.currentPageVC) {
            self.currentPageVC.pageModel = self.allPages[self.currentPageIndex];
            [self.currentPageVC.view setNeedsLayout];
        }
        [self preloadNext3Chapters];
    } failure:^(NSError *error) {
        [self.currentPageVC.loadingIndicator stopAnimating];
        NSString *errorMsg = [NSString stringWithFormat:@"加载失败\n\n%@", error.localizedDescription];
        [self displayContent:errorMsg];
    }];
}

// 竖向模式：流式加载（先显示当前章，预加载后3章）
- (void)loadMultipleChaptersForVerticalMode {
    NSInteger startIndex = self.currentChapter.chapterIndex;

    [self.currentPageVC.loadingIndicator startAnimating];
    [self.loadedChapters removeAllObjects];
    [self.chapterOffsets removeAllObjects];

    // 1. 先加载并显示当前章（快速显示）
    [self loadAndDisplayChapter:startIndex isFirst:YES completion:^(BOOL success) {
        [self.currentPageVC.loadingIndicator stopAnimating];

        // ⭐ 2. 初始加载完成后，预加载接下来的3章
        if (success) {
            [self preloadNext3Chapters];
        }
    }];
}

// 加载并显示单章
- (void)loadAndDisplayChapter:(NSInteger)chapterIndex
                      isFirst:(BOOL)isFirst
                   completion:(void(^)(BOOL success))completion {

    if (chapterIndex >= self.chapters.count) {
        if (completion) completion(NO);
        return;
    }

    ChapterModel *chapter = self.chapters[chapterIndex];

    // 先检查缓存
    NSString *cachedContent = self.contentCache[@(chapterIndex)];
    if (cachedContent) {

        if (isFirst) {
            [self displayFirstChapter:chapter content:cachedContent];
        } else {
            [self appendChapterToScrollView:chapter content:cachedContent];
        }

        if (completion) completion(YES);
        return;
    }

    // 从网络加载

    [[BookContentService sharedService] fetchChapterContent:chapter.chapterUrl
                                                 bookSource:self.bookSource
                                                    success:^(ChapterContent *content) {

        // 缓存内容
        self.contentCache[@(chapterIndex)] = content.content;

        dispatch_async(dispatch_get_main_queue(), ^{
            if (isFirst) {
                [self displayFirstChapter:chapter content:content.content];
            } else {
                [self appendChapterToScrollView:chapter content:content.content];
            }

            if (completion) completion(YES);
        });

    } failure:^(NSError *error) {
        if (completion) completion(NO);
    }];
}

// 后台加载下一章（单章）
- (void)startBackgroundLoadingNextChapter {
    if (self.loadedChapters.count == 0) return;

    ChapterModel *lastLoadedChapter = self.loadedChapters.lastObject;
    NSInteger nextIndex = lastLoadedChapter.chapterIndex + 1;

    if (nextIndex >= self.chapters.count) {
        return;
    }

    if (self.isLoadingNextChapter) {
        return;
    }

    self.isLoadingNextChapter = YES;

    // ⭐ 在后台线程加载
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ChapterModel *nextChapter = self.chapters[nextIndex];

        // 先检查缓存
        NSString *cachedContent = self.contentCache[@(nextIndex)];
        if (cachedContent) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self appendChapterToScrollView:nextChapter content:cachedContent];
                self.isLoadingNextChapter = NO;

                // ⭐ 显示完下一章后，预加载后续3章
                [self preloadNext3Chapters];
            });
            return;
        }

        // 从网络加载（网络请求已经是异步的）

        [[BookContentService sharedService] fetchChapterContent:nextChapter.chapterUrl
                                                     bookSource:self.bookSource
                                                        success:^(ChapterContent *content) {

            // 缓存内容
            self.contentCache[@(nextIndex)] = content.content;

            // 在主线程追加到UI
            dispatch_async(dispatch_get_main_queue(), ^{
                [self appendChapterToScrollView:nextChapter content:content.content];
                self.isLoadingNextChapter = NO;

                // ⭐ 显示完下一章后，预加载后续3章
                [self preloadNext3Chapters];
            });

        } failure:^(NSError *error) {
            self.isLoadingNextChapter = NO;
        }];
    });
}

- (void)displayContent:(NSString *)content {
    [self.currentPageVC displayContent:content];
}

// 显示第一章（初始化）
- (void)displayFirstChapter:(ChapterModel *)chapter content:(NSString *)content {

    [self.loadedChapters addObject:chapter];

    // 构建内容
    NSString *chapterTitle = [NSString stringWithFormat:@"【 %@ 】\n\n", chapter.chapterName];
    NSString *fullContent = [NSString stringWithFormat:@"%@%@\n\n━━━━━━━━━━━━━━━━━━━━\n\n", chapterTitle, content];


    // 记录章节起始位置
    self.chapterOffsets[@(chapter.chapterIndex)] = @(10);  // 初始偏移10

    // ⭐ 直接在主线程显示（第一章不需要后台处理）
    [self.currentPageVC displayContent:fullContent];

    // 更新阅读进度
    self.book.currentChapter = chapter.chapterIndex;
    [[BookshelfManager sharedManager] updateBook:self.book];

}

// 追加章节到 ScrollView 底部（后台加载完成后调用）
- (void)appendChapterToScrollView:(ChapterModel *)chapter content:(NSString *)content {
    [self.loadedChapters addObject:chapter];


    // ⭐ 在后台线程计算新章节高度（增量计算，不需要重新计算整个文本）
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 构建新章节内容
        NSString *chapterTitle = [NSString stringWithFormat:@"【 %@ 】\n\n", chapter.chapterName];
        NSString *newContent = [NSString stringWithFormat:@"%@%@\n\n━━━━━━━━━━━━━━━━━━━━\n\n", chapterTitle, content];


        // ⭐ 只计算新章节的高度（增量计算）
        CGFloat width = self.view.bounds.size.width - 30;
        UIFont *contentFont = [UIFont systemFontOfSize:17];

        CGSize newChapterSize = [newContent boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName: contentFont}
                                                          context:nil].size;

        // 回到主线程更新UI
        dispatch_async(dispatch_get_main_queue(), ^{

            // 记录新章节的起始偏移（使用缓存的当前高度）
            self.chapterOffsets[@(chapter.chapterIndex)] = @(self.currentPageVC.currentContentHeight);

            [CATransaction begin];
            [CATransaction setDisableActions:YES];

            // ⭐ 使用 NSMutableAttributedString 增量追加（避免重新渲染整个文本）
            UIFont *font = [UIFont systemFontOfSize:17];
            NSDictionary *attributes = @{NSFontAttributeName: font};

            NSMutableAttributedString *attributedString;
            if (self.currentPageVC.contentTextView.attributedText.length > 0) {
                attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.currentPageVC.contentTextView.attributedText];
            } else {
                attributedString = [[NSMutableAttributedString alloc] init];
            }

            NSAttributedString *newAttributedContent = [[NSAttributedString alloc] initWithString:newContent attributes:attributes];
            [attributedString appendAttributedString:newAttributedContent];

            self.currentPageVC.contentTextView.attributedText = attributedString;

            // ⭐ 使用增量计算更新高度
            CGFloat newTotalHeight = self.currentPageVC.currentContentHeight + newChapterSize.height;
            self.currentPageVC.contentTextView.frame = CGRectMake(15, 10, width, newTotalHeight);
            self.currentPageVC.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, newTotalHeight + 20);
            self.currentPageVC.currentContentHeight = newTotalHeight;  // 更新缓存的高度

            [CATransaction commit];

            // ⭐ 修复：不再自动连续加载！由滚动事件触发
            // 移除自动触发逻辑，改为由 scrollViewDidScroll 根据滚动位置判断是否需要加载
            self.isLoadingNextChapter = NO;  // 标记加载完成
        });
    });
}

#pragma mark - Preloading

// ⭐ 预加载接下来的3章（基于最后已加载的章节）
- (void)preloadNext3Chapters {
    if (self.loadedChapters.count == 0) return;

    ChapterModel *lastLoadedChapter = self.loadedChapters.lastObject;
    NSInteger lastLoadedIndex = lastLoadedChapter.chapterIndex;


    // 预加载接下来的3章
    for (NSInteger i = 1; i <= 3; i++) {
        NSInteger targetIndex = lastLoadedIndex + i;
        if (targetIndex < self.chapters.count) {
            // 检查缓存中是否已有
            if (!self.contentCache[@(targetIndex)]) {
                [self preloadChapterAtIndex:targetIndex];
            } else {
            }
        }
    }
}

- (void)preloadChapterAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.chapters.count) {
        return;
    }

    ChapterModel *chapter = self.chapters[index];

    [[BookContentService sharedService] fetchChapterContent:chapter.chapterUrl
                                                 bookSource:self.bookSource
                                                    success:^(ChapterContent *content) {
        self.contentCache[@(index)] = content.content;

        // 如果是横向模式，同时缓存分页结果
        if (self.pageTurnMode == PageTurnModeHorizontal) {
            [self paginateChapter:chapter content:content.content];
        }
    } failure:^(NSError *error) {
    }];
}

#pragma mark - Pagination (横向模式分页)

// 对章节内容进行分页
- (NSArray<PageModel *> *)paginateChapter:(ChapterModel *)chapter content:(NSString *)content {
    // 先检查分页缓存
    NSNumber *chapterKey = @(chapter.chapterIndex);
    NSArray<PageModel *> *cachedPages = self.pagesCache[chapterKey];
    if (cachedPages) {
        return cachedPages;
    }

    // 计算一页能显示的内容
    CGFloat pageWidth = self.view.bounds.size.width - 30;  // 左右各留15
    CGFloat pageHeight = self.view.bounds.size.height - 50 - 30 - 30 - 60;  // 标题50 + 上边距30 + 页码30 + 工具栏60

    UIFont *font = [UIFont systemFontOfSize:17];
    NSDictionary *attributes = @{NSFontAttributeName: font};

    // 格式化内容（加行间距）
    NSString *formattedContent = [content stringByReplacingOccurrencesOfString:@"\n" withString:@"\n\n"];

    // 分页算法：逐字符累加，直到超出一页高度
    NSMutableArray<PageModel *> *pages = [NSMutableArray array];
    NSInteger contentLength = formattedContent.length;
    NSInteger startIndex = 0;
    NSInteger pageIndex = 0;

    while (startIndex < contentLength) {
        // 二分查找：找到能放入一页的最大字符数
        NSInteger left = 1;
        NSInteger right = contentLength - startIndex;
        NSInteger bestEnd = left;

        while (left <= right) {
            NSInteger mid = (left + right) / 2;
            NSInteger endIndex = MIN(startIndex + mid, contentLength);
            NSString *testContent = [formattedContent substringWithRange:NSMakeRange(startIndex, endIndex - startIndex)];

            CGSize size = [testContent boundingRectWithSize:CGSizeMake(pageWidth, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:attributes
                                                    context:nil].size;

            if (size.height <= pageHeight) {
                bestEnd = mid;
                left = mid + 1;
            } else {
                right = mid - 1;
            }
        }

        // 创建页面
        NSInteger endIndex = MIN(startIndex + bestEnd, contentLength);
        NSString *pageContent = [formattedContent substringWithRange:NSMakeRange(startIndex, endIndex - startIndex)];

        PageModel *page = [[PageModel alloc] init];
        page.chapter = chapter;
        page.pageIndex = pageIndex;
        page.pageContent = pageContent;
        [pages addObject:page];

        startIndex = endIndex;
        pageIndex++;
    }

    // 设置总页数
    NSInteger totalPages = pages.count;
    for (PageModel *page in pages) {
        page.totalPages = totalPages;
    }

    // 缓存分页结果
    self.pagesCache[chapterKey] = pages;


    return pages;
}

// 构建当前章节及前后章节的所有页面数组
- (void)buildAllPagesFromChapter:(ChapterModel *)chapter {
    NSMutableArray<PageModel *> *allPages = [NSMutableArray array];

    NSInteger startChapter = MAX(0, chapter.chapterIndex - 1);
    NSInteger endChapter = MIN(self.chapters.count - 1, chapter.chapterIndex + 3);

    for (NSInteger i = startChapter; i <= endChapter; i++) {
        ChapterModel *ch = self.chapters[i];
        NSString *content = self.contentCache[@(i)];

        if (content) {
            NSArray<PageModel *> *pages = [self paginateChapter:ch content:content];
            [allPages addObjectsFromArray:pages];
        }
    }

    self.allPages = allPages;

    // 找到当前页面索引
    self.currentPageIndex = 0;
    for (NSInteger i = 0; i < allPages.count; i++) {
        PageModel *page = allPages[i];
        if (page.chapter.chapterIndex == chapter.chapterIndex && page.pageIndex == 0) {
            self.currentPageIndex = i;
            break;
        }
    }
}

#pragma mark - UIScrollViewDelegate (上下滑动模式)

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.pageTurnMode != PageTurnModeVertical) {
        return;
    }

    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat contentHeight = scrollView.contentSize.height;
    CGFloat scrollViewHeight = scrollView.frame.size.height;

    // 1. 更新浮动标题（动态显示当前章节）
    [self updateFloatingTitleWithOffset:offsetY];

    // 2. ⭐ 智能加载：当用户阅读到最后已显示章节的80%位置时，显示下一章
    if (self.loadedChapters.count > 0 && !self.isLoadingNextChapter) {
        ChapterModel *lastLoadedChapter = self.loadedChapters.lastObject;
        NSInteger lastLoadedIndex = lastLoadedChapter.chapterIndex;

        // 获取最后一章的起始偏移
        NSNumber *lastChapterOffsetNum = self.chapterOffsets[@(lastLoadedIndex)];
        if (lastChapterOffsetNum) {
            CGFloat lastChapterOffset = [lastChapterOffsetNum floatValue];
            CGFloat lastChapterHeight = contentHeight - lastChapterOffset;

            // 当用户阅读到最后一章的80%位置时，显示下一章并预加载后3章
            CGFloat triggerOffset = lastChapterOffset + lastChapterHeight * 0.8;

            if (offsetY + scrollViewHeight >= triggerOffset) {
                NSInteger nextIndex = lastLoadedIndex + 1;
                if (nextIndex < self.chapters.count) {
                    [self startBackgroundLoadingNextChapter];
                }
            }
        }
    }
}

// 追加下一批3章内容（竖向模式）
// （已废弃，改用流式加载）

#pragma mark - UIPageViewControllerDataSource (左右翻页模式 - 按页翻页)

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController {

    ContentPageViewController *currentVC = (ContentPageViewController *)viewController;

    if (!currentVC.pageModel || self.allPages.count == 0) {
        return nil;
    }

    // 找到当前页面在 allPages 中的索引
    NSInteger currentIndex = -1;
    for (NSInteger i = 0; i < self.allPages.count; i++) {
        PageModel *page = self.allPages[i];
        if (page.chapter.chapterIndex == currentVC.pageModel.chapter.chapterIndex &&
            page.pageIndex == currentVC.pageModel.pageIndex) {
            currentIndex = i;
            break;
        }
    }

    if (currentIndex <= 0) {
        return nil;  // 已经是第一页
    }

    // 创建上一页
    PageModel *prevPage = self.allPages[currentIndex - 1];
    ContentPageViewController *prevVC = [[ContentPageViewController alloc] init];
    prevVC.scrollEnabled = NO;
    prevVC.pageModel = prevPage;

    return prevVC;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController {

    ContentPageViewController *currentVC = (ContentPageViewController *)viewController;

    if (!currentVC.pageModel || self.allPages.count == 0) {
        return nil;
    }

    // 找到当前页面在 allPages 中的索引
    NSInteger currentIndex = -1;
    for (NSInteger i = 0; i < self.allPages.count; i++) {
        PageModel *page = self.allPages[i];
        if (page.chapter.chapterIndex == currentVC.pageModel.chapter.chapterIndex &&
            page.pageIndex == currentVC.pageModel.pageIndex) {
            currentIndex = i;
            break;
        }
    }

    if (currentIndex < 0 || currentIndex >= self.allPages.count - 1) {
        // 如果是最后一页，尝试加载下一章
        ChapterModel *currentChapter = currentVC.pageModel.chapter;
        if (currentChapter.chapterIndex + 1 < self.chapters.count) {
            [self preloadChapterAtIndex:currentChapter.chapterIndex + 1];
        }
        return nil;
    }

    // 创建下一页
    PageModel *nextPage = self.allPages[currentIndex + 1];
    ContentPageViewController *nextVC = [[ContentPageViewController alloc] init];
    nextVC.scrollEnabled = NO;
    nextVC.pageModel = nextPage;

    return nextVC;
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers
       transitionCompleted:(BOOL)completed {

    if (completed) {
        ContentPageViewController *currentVC = (ContentPageViewController *)pageViewController.viewControllers.firstObject;
        self.currentPageVC = currentVC;

        if (currentVC.pageModel) {
            // 横向翻页模式：更新当前章节和页面索引
            self.currentChapter = currentVC.pageModel.chapter;

            // 找到当前页面索引
            for (NSInteger i = 0; i < self.allPages.count; i++) {
                PageModel *page = self.allPages[i];
                if (page.chapter.chapterIndex == currentVC.pageModel.chapter.chapterIndex &&
                    page.pageIndex == currentVC.pageModel.pageIndex) {
                    self.currentPageIndex = i;
                    break;
                }
            }

            // 更新阅读进度
            self.book.currentChapter = self.currentChapter.chapterIndex;
            [[BookshelfManager sharedManager] updateBook:self.book];

            // 如果翻到新章节，预加载后续章节
            static NSInteger lastChapterIndex = -1;
            if (lastChapterIndex != self.currentChapter.chapterIndex) {
                [self preloadNext3Chapters];
                lastChapterIndex = self.currentChapter.chapterIndex;
            }
        } else {
            // 竖向滚动模式（不应该走到这里）
            self.currentChapter = currentVC.chapter;
        }
    }
}

- (void)dealloc {
    // 返回时通知书架刷新
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BookReadProgressUpdated" object:nil];
}

@end
