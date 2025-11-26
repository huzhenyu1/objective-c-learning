//
//  ReaderViewController.m
//  Read
//
//  阅读器实现 - 支持上下/左右翻页、底部工具栏、预加载缓存
//

#import "ReaderViewController.h"
#import "ContentPageViewController.h"  // ⭐ 使用独立的文件
#import "ChapterListViewController.h"
#import "BookshelfManager.h"
#import "ReadingStatsManager.h"
#import "BookContentService.h"
#import "BookContentManager.h"
#import "ScreenAdapter.h"  // ⭐ 屏幕适配工具

// ⭐ 引入新的管理器
#import "ReadingContentManager.h"
#import "ReadingProgressManager.h"
#import "ReadingSettingsManager.h"
#import "ReadingPaginationService.h"
#import "ErrorHandler.h"
#import "UIViewController+Alert.h"
#import "AppConfig.h"

#import <QuartzCore/QuartzCore.h>

// ⭐ 常量定义
static const NSInteger MAX_CACHE_COUNT = 10;
static const CGFloat FLOATING_TITLE_UPDATE_INTERVAL = 0.1;

// ⭐ 阅读设置常量（映射到 ReadingSettingsManager）
static NSString * const kReadingFontSizeKey = @"ReadingFontSize";
static NSString * const kReadingBackgroundColorKey = @"ReadingBackgroundColor";
static NSString * const kReadingNightModeKey = @"ReadingNightMode";
static const CGFloat kDefaultFontSize = 17.0;
static const CGFloat kMinFontSize = 12.0;
static const CGFloat kMaxFontSize = 30.0;

// 主阅读器
@interface ReaderViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate>

// ⭐ 书籍信息
@property (strong, nonatomic) BookModel *book;
@property (strong, nonatomic) NSArray<ChapterModel *> *chapters;
@property (strong, nonatomic) BookSource *bookSource;
@property (strong, nonatomic) ChapterModel *currentChapter;

// ⭐ 新的管理器（替代原有分散的逻辑）
@property (strong, nonatomic) ReadingContentManager *contentManager;      // 内容加载和缓存
@property (strong, nonatomic) ReadingProgressManager *progressManager;    // 进度保存和恢复
@property (strong, nonatomic) ReadingSettingsManager *settingsManager;    // 阅读设置
@property (strong, nonatomic) ReadingPaginationService *paginationService; // 分页服务

// ⭐ UI组件
@property (strong, nonatomic) UIPageViewController *pageViewController;  // 左右翻页
@property (strong, nonatomic) ContentPageViewController *currentPageVC;  // 当前页面
@property (strong, nonatomic) UIView *toolbar;                           // 底部工具栏
@property (strong, nonatomic) UIButton *catalogButton;                   // 目录按钮
@property (strong, nonatomic) UIButton *pageModeButton;                  // 翻页模式按钮
@property (strong, nonatomic) UIButton *settingsButton;                  // 设置按钮

// ⭐ 状态标志
@property (assign, nonatomic) BOOL isUIInitialized;                      // UI是否已初始化完成
@property (strong, nonatomic) UIButton *readAloudButton;                 // 朗读按钮
@property (strong, nonatomic) UIButton *interfaceButton;                 // 界面按钮
@property (strong, nonatomic) UILabel *floatingTitleLabel;               // 浮动标题

// ⭐ 状态
@property (assign, nonatomic) PageTurnMode pageTurnMode;                 // 翻页模式
@property (assign, nonatomic) BOOL isToolbarVisible;                     // 工具栏是否可见
@property (assign, nonatomic) BOOL isLoadingNextChapter;                 // 是否正在加载下一章
@property (assign, nonatomic) NSTimeInterval lastTitleUpdateTime;        // 上次更新标题的时间
@property (assign, nonatomic) CGFloat lastSavedScrollOffset;             // 上次保存的滚动位置

// ⭐ 垂直模式相关
@property (strong, nonatomic) NSMutableArray<ChapterModel *> *loadedChapters;  // 已加载的章节

// ⭐ 横向模式相关
@property (strong, nonatomic) NSMutableArray<PageModel *> *allPages;     // 所有页面（可变）
@property (assign, nonatomic) NSInteger currentPageIndex;                // 当前页面索引

// ⭐ 临时兼容性属性（用于快速修复编译错误，后续逐步迁移到新管理器）
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSString *> *contentCache;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSDate *> *cacheAccessTime;
@property (strong, nonatomic) NSMutableSet<NSNumber *> *pendingRequests;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSNumber *> *chapterOffsets;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSArray<PageModel *> *> *pagesCache;

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
        _isLoadingNextChapter = NO;
        _lastTitleUpdateTime = 0;
        _lastSavedScrollOffset = 0;

        // ⭐ 初始化新的管理器
        _contentManager = [[ReadingContentManager alloc] initWithBook:book
                                                              chapters:chapters
                                                            bookSource:bookSource];
        _progressManager = [[ReadingProgressManager alloc] initWithBook:book];
        _settingsManager = [ReadingSettingsManager sharedManager];
        _paginationService = [[ReadingPaginationService alloc] init];

        // 垂直模式相关
        _loadedChapters = [NSMutableArray array];

        // 横向模式相关
        _allPages = @[];
        _currentPageIndex = 0;

        // ⭐ 临时兼容性属性初始化（用于快速修复编译错误）
        _contentCache = [NSMutableDictionary dictionary];
        _cacheAccessTime = [NSMutableDictionary dictionary];
        _pendingRequests = [NSMutableSet set];
        _chapterOffsets = [NSMutableDictionary dictionary];
        _pagesCache = [NSMutableDictionary dictionary];

        // 隐藏底部 TabBar
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    // ⭐ 配置导航栏样式
    [self setupNavigationBar];

    [self setupUI];
    [self loadCurrentChapterContent];
    [self preloadNext3Chapters];  // 预加载接下来的3章

    // ⭐ 应用保存的阅读设置
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self applyReadingSettings];
    });

    // ⭐ 监听屏幕旋转
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleOrientationChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];

    // ⭐ 标记 UI 已初始化完成
    self.isUIInitialized = YES;
}

#pragma mark - Navigation Bar

- (void)setupNavigationBar {
    // ⭐ 设置导航栏样式（与书架一致）
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor colorWithRed:0.55 green:0.27 blue:0.22 alpha:1.0];  // 棕红色背景
        appearance.titleTextAttributes = @{
            NSForegroundColorAttributeName: [UIColor whiteColor],
            NSFontAttributeName: [UIFont boldSystemFontOfSize:18]
        };
        appearance.shadowColor = nil;  // 去除阴影

        // ⭐ 自定义返回按钮样式（简洁的白色箭头）
        UIImage *backImage = [UIImage systemImageNamed:@"chevron.left"];
        [appearance setBackIndicatorImage:backImage transitionMaskImage:backImage];

        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];  // 返回按钮颜色
    } else {
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.55 green:0.27 blue:0.22 alpha:1.0];
        self.navigationController.navigationBar.titleTextAttributes = @{
            NSForegroundColorAttributeName: [UIColor whiteColor],
            NSFontAttributeName: [UIFont boldSystemFontOfSize:18]
        };
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.translucent = NO;
    }

    // ⭐ 设置标题
    self.navigationItem.title = self.book.title;

    // ⭐ 隐藏系统返回按钮的文字，只保留箭头
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // ⭐ 默认隐藏导航栏（沉浸式阅读）
    [self.navigationController setNavigationBarHidden:YES animated:YES];

    // ⭐ 开始记录阅读会话
    [[ReadingStatsManager sharedManager] startReadingSession:self.book.bookUrl bookTitle:self.book.title];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // ⭐ 离开时显示导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    // ⭐ 结束记录阅读会话
    [[ReadingStatsManager sharedManager] endReadingSession];

    // ⭐ 恢复导航栏默认样式
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor colorWithRed:0.55 green:0.27 blue:0.22 alpha:1.0];  // 保持书架的棕红色
        appearance.titleTextAttributes = @{
            NSForegroundColorAttributeName: [UIColor whiteColor],
            NSFontAttributeName: [UIFont boldSystemFontOfSize:18]
        };
        appearance.shadowColor = nil;

        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
    }
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
    // ⭐ 底部工具栏（初始隐藏）- 仿阅文风格，4个按钮
    CGFloat toolbarHeight = 60;
    self.toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, toolbarHeight)];
    self.toolbar.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1.0];  // 浅灰白背景
    self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

    // 添加顶部分隔线
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0.5)];
    separator.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.3];
    separator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.toolbar addSubview:separator];

    // ⭐ 4个按钮均分宽度
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat buttonWidth = screenWidth / 4;

    // ⭐ 1. 目录按钮
    UIButton *catalogBtn = [self createToolbarButton:@"☰\n目录" tag:1 action:@selector(showCatalog)];
    catalogBtn.frame = CGRectMake(0, 0, buttonWidth, toolbarHeight);
    [self.toolbar addSubview:catalogBtn];

    // ⭐ 2. 朗读按钮
    UIButton *readAloudBtn = [self createToolbarButton:@"♫\n朗读" tag:2 action:@selector(showReadAloud)];
    readAloudBtn.frame = CGRectMake(buttonWidth, 0, buttonWidth, toolbarHeight);
    [self.toolbar addSubview:readAloudBtn];

    // ⭐ 3. 界面按钮（设置）
    self.settingsButton = [self createToolbarButton:@"Aa\n界面" tag:3 action:@selector(showSettings)];
    self.settingsButton.frame = CGRectMake(buttonWidth * 2, 0, buttonWidth, toolbarHeight);
    [self.toolbar addSubview:self.settingsButton];

    // ⭐ 4. 设置按钮（更多）
    UIButton *moreBtn = [self createToolbarButton:@"⚙\n设置" tag:4 action:@selector(showMoreSettings)];
    moreBtn.frame = CGRectMake(buttonWidth * 3, 0, buttonWidth, toolbarHeight);
    [self.toolbar addSubview:moreBtn];

    [self.view addSubview:self.toolbar];
}

// ⭐ 创建工具栏按钮
- (UIButton *)createToolbarButton:(NSString *)title tag:(NSInteger)tag action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.tag = tag;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:13];
    button.titleLabel.numberOfLines = 2;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)setupTapGesture {
    // 点击正文显示/隐藏工具栏
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
}


#pragma mark - Gesture Handling

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    [self toggleToolbar];
}

- (void)toggleToolbar {
    self.isToolbarVisible = !self.isToolbarVisible;

    // ⭐ 同时切换导航栏和工具栏的显示状态
    [self.navigationController setNavigationBarHidden:!self.isToolbarVisible animated:YES];

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

// ⭐ 朗读功能
- (void)showReadAloud {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"朗读功能"
                                                                   message:@"功能开发中...\n\n将支持：\n- 自动朗读\n- 语速调节\n- 音色选择"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

// ⭐ 更多设置
- (void)showMoreSettings {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"更多设置"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    // 翻页模式
    NSString *pageModeTit = self.pageTurnMode == PageTurnModeVertical ? @"✓ 上下滑动" : @"✓ 左右翻页";
    UIAlertAction *pageModeAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"翻页模式：%@", pageModeTit]
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
        [self togglePageMode];
    }];
    [alert addAction:pageModeAction];

    // 亮度调节
    UIAlertAction *brightnessAction = [UIAlertAction actionWithTitle:@"亮度调节" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showBrightnessAlert];
    }];
    [alert addAction:brightnessAction];

    // 取消
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];

    [self presentViewController:alert animated:YES completion:nil];
}

// ⭐ 亮度调节
- (void)showBrightnessAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"亮度调节"
                                                                   message:@"\n\n\n"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(20, 50, 230, 30)];
    slider.minimumValue = 0.1;
    slider.maximumValue = 1.0;
    slider.value = [UIScreen mainScreen].brightness;
    [slider addTarget:self action:@selector(brightnessChanged:) forControlEvents:UIControlEventValueChanged];
    [alert.view addSubview:slider];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)brightnessChanged:(UISlider *)slider {
    [[UIScreen mainScreen] setBrightness:slider.value];
}

#pragma mark - ⭐ 阅读设置

- (void)showSettings {
    [self toggleToolbar];  // 隐藏工具栏

    // 创建设置面板
    UIAlertController *settingsAlert = [UIAlertController alertControllerWithTitle:@"阅读设置"
                                                                           message:nil
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];

    // 字体大小设置
    UIAlertAction *fontSizeAction = [UIAlertAction actionWithTitle:@"📝 字体大小" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showFontSizeSettings];
    }];
    [settingsAlert addAction:fontSizeAction];

    // 背景色设置
    UIAlertAction *bgColorAction = [UIAlertAction actionWithTitle:@"🎨 背景颜色" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showBackgroundColorSettings];
    }];
    [settingsAlert addAction:bgColorAction];

    // 夜间模式切换
    BOOL isNightMode = [self isNightModeEnabled];
    NSString *nightModeTitle = isNightMode ? @"☀️ 日间模式" : @"🌙 夜间模式";
    UIAlertAction *nightModeAction = [UIAlertAction actionWithTitle:nightModeTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self toggleNightMode];
    }];
    [settingsAlert addAction:nightModeAction];

    // 取消
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [settingsAlert addAction:cancelAction];

    [self presentViewController:settingsAlert animated:YES completion:nil];
}

- (void)showFontSizeSettings {
    UIAlertController *fontAlert = [UIAlertController alertControllerWithTitle:@"字体大小"
                                                                       message:@"\n\n\n"
                                                                preferredStyle:UIAlertControllerStyleAlert];

    // 添加 UISlider
    UISlider *fontSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 50, 230, 30)];
    fontSlider.minimumValue = kMinFontSize;
    fontSlider.maximumValue = kMaxFontSize;
    fontSlider.value = [self getCurrentFontSize];
    fontSlider.continuous = YES;
    [fontSlider addTarget:self action:@selector(fontSizeChanged:) forControlEvents:UIControlEventValueChanged];
    [fontAlert.view addSubview:fontSlider];

    // 显示当前字号
    UILabel *sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 85, 230, 30)];
    sizeLabel.text = [NSString stringWithFormat:@"%.0f", fontSlider.value];
    sizeLabel.textAlignment = NSTextAlignmentCenter;
    sizeLabel.tag = 999;  // 用于后续更新
    [fontAlert.view addSubview:sizeLabel];

    // 确定按钮
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self saveFontSize:fontSlider.value];
        [self applyReadingSettings];
    }];
    [fontAlert addAction:confirmAction];

    [self presentViewController:fontAlert animated:YES completion:nil];
}

- (void)fontSizeChanged:(UISlider *)slider {
    // 实时更新字号显示
    UILabel *sizeLabel = (UILabel *)[slider.superview viewWithTag:999];
    if (sizeLabel) {
        sizeLabel.text = [NSString stringWithFormat:@"%.0f", slider.value];
    }
}

- (void)showBackgroundColorSettings {
    UIAlertController *colorAlert = [UIAlertController alertControllerWithTitle:@"背景颜色"
                                                                         message:nil
                                                                  preferredStyle:UIAlertControllerStyleActionSheet];

    // 预设颜色选项
    NSArray *colors = @[
        @{@"name": @"默认白色", @"color": @"white"},
        @{@"name": @"护眼绿", @"color": @"green"},
        @{@"name": @"羊皮纸", @"color": @"parchment"},
        @{@"name": @"浅灰色", @"color": @"gray"}
    ];

    for (NSDictionary *colorInfo in colors) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:colorInfo[@"name"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self saveBackgroundColor:colorInfo[@"color"]];
            [self applyReadingSettings];
        }];
        [colorAlert addAction:action];
    }

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [colorAlert addAction:cancelAction];

    [self presentViewController:colorAlert animated:YES completion:nil];
}

- (void)toggleNightMode {
    BOOL isNightMode = [self isNightModeEnabled];
    [[NSUserDefaults standardUserDefaults] setBool:!isNightMode forKey:kReadingNightModeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self applyReadingSettings];
}

#pragma mark - 设置存储和读取

- (CGFloat)getCurrentFontSize {
    CGFloat fontSize = [[NSUserDefaults standardUserDefaults] floatForKey:kReadingFontSizeKey];
    return fontSize > 0 ? fontSize : kDefaultFontSize;
}

- (void)saveFontSize:(CGFloat)fontSize {
    [[NSUserDefaults standardUserDefaults] setFloat:fontSize forKey:kReadingFontSizeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)getCurrentBackgroundColor {
    NSString *color = [[NSUserDefaults standardUserDefaults] stringForKey:kReadingBackgroundColorKey];
    return color ?: @"white";
}

- (void)saveBackgroundColor:(NSString *)color {
    [[NSUserDefaults standardUserDefaults] setObject:color forKey:kReadingBackgroundColorKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isNightModeEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kReadingNightModeKey];
}

- (UIColor *)getBackgroundColorFromString:(NSString *)colorName {
    if ([colorName isEqualToString:@"green"]) {
        return [UIColor colorWithRed:199.0/255.0 green:237.0/255.0 blue:204.0/255.0 alpha:1.0];  // 护眼绿
    } else if ([colorName isEqualToString:@"parchment"]) {
        return [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:220.0/255.0 alpha:1.0];  // 羊皮纸
    } else if ([colorName isEqualToString:@"gray"]) {
        return [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];  // 浅灰色
    } else {
        return [UIColor whiteColor];  // 默认白色
    }
}

- (UIColor *)getTextColorForNightMode:(BOOL)isNightMode {
    return isNightMode ? [UIColor colorWithWhite:0.85 alpha:1.0] : [UIColor blackColor];
}

- (UIColor *)getBackgroundColorForNightMode:(BOOL)isNightMode {
    if (isNightMode) {
        return [UIColor colorWithRed:30.0/255.0 green:30.0/255.0 blue:30.0/255.0 alpha:1.0];  // 深灰黑
    } else {
        return [self getBackgroundColorFromString:[self getCurrentBackgroundColor]];
    }
}

#pragma mark - 应用阅读设置

- (void)applyReadingSettings {
    CGFloat fontSize = [self getCurrentFontSize];
    BOOL isNightMode = [self isNightModeEnabled];
    UIColor *bgColor = [self getBackgroundColorForNightMode:isNightMode];
    UIColor *textColor = [self getTextColorForNightMode:isNightMode];

    // 应用到当前页面
    if (self.currentPageVC) {
        self.currentPageVC.view.backgroundColor = bgColor;
        self.currentPageVC.scrollView.backgroundColor = bgColor;
        self.currentPageVC.contentTextView.backgroundColor = bgColor;
        self.currentPageVC.contentTextView.textColor = textColor;

        // 更新字体大小
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.currentPageVC.contentTextView.attributedText];
        [attributedText addAttribute:NSFontAttributeName
                              value:[UIFont systemFontOfSize:fontSize]
                              range:NSMakeRange(0, attributedText.length)];
        [attributedText addAttribute:NSForegroundColorAttributeName
                              value:textColor
                              range:NSMakeRange(0, attributedText.length)];
        self.currentPageVC.contentTextView.attributedText = attributedText;
    }

    // 应用到主视图
    self.view.backgroundColor = bgColor;

    // 应用到浮动标题
    if (self.floatingTitleLabel) {
        self.floatingTitleLabel.textColor = textColor;
        self.floatingTitleLabel.backgroundColor = [bgColor colorWithAlphaComponent:0.9];
    }
}

- (void)togglePageMode {
    // 切换翻页模式
    self.pageTurnMode = (self.pageTurnMode == PageTurnModeVertical) ? PageTurnModeHorizontal : PageTurnModeVertical;

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

                        // ⭐ 记录阅读记录
                        [[ReadingStatsManager sharedManager] addReadingRecord:self.book.bookUrl
                                                                     bookTitle:self.book.title
                                                                   chapterName:chapter.chapterName
                                                                  chapterIndex:chapter.chapterIndex];

                        // ⭐ 记录阅读字数（估算：章节内容长度）
                        NSString *content = self.contentCache[@(chapter.chapterIndex)];
                        if (content) {
                            [[ReadingStatsManager sharedManager] addReadingWords:content.length];
                        }

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

/**
 * ⭐ 保存阅读进度（章节 + 滚动位置）
 */
- (void)saveReadingProgress {
    if (!self.book || !self.currentChapter) {
        return;
    }

    NSString *progressKey = [NSString stringWithFormat:@"ReadProgress_%@", self.book.bookUrl];
    NSDictionary *progress = @{
        @"chapterIndex": @(self.currentChapter.chapterIndex),
        @"scrollOffset": @(self.currentPageVC.scrollView.contentOffset.y)
    };

    [[NSUserDefaults standardUserDefaults] setObject:progress forKey:progressKey];
}

/**
 * ⭐ 恢复阅读进度（章节 + 滚动位置）
 */
- (void)restoreReadingProgress {
    if (!self.book) {
        return;
    }

    NSString *progressKey = [NSString stringWithFormat:@"ReadProgress_%@", self.book.bookUrl];
    NSDictionary *progress = [[NSUserDefaults standardUserDefaults] objectForKey:progressKey];

    if (progress && [progress isKindOfClass:[NSDictionary class]]) {
        CGFloat scrollOffset = [progress[@"scrollOffset"] floatValue];

        // 延迟恢复滚动位置（等待内容加载完成）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.pageTurnMode == PageTurnModeVertical && self.currentPageVC) {
                [self.currentPageVC.scrollView setContentOffset:CGPointMake(0, scrollOffset) animated:NO];
            }
        });
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
    NSNumber *indexKey = @(chapterIndex);

    // ⭐ 1. 先检查内存缓存
    NSString *cachedContent = self.contentCache[indexKey];
    if (cachedContent) {
        [self updateCacheAccessTime:chapterIndex];  // ⭐ 更新访问时间

        if (isFirst) {
            [self displayFirstChapter:chapter content:cachedContent];
        } else {
            [self appendChapterToScrollView:chapter content:cachedContent];
        }

        if (completion) completion(YES);
        return;
    }

    // ⭐ 2. 检查离线缓存
    NSString *localContent = [self loadLocalCacheForChapter:chapterIndex];
    if (localContent) {
        // 加载到内存缓存
        self.contentCache[indexKey] = localContent;
        [self updateCacheAccessTime:chapterIndex];
        [self trimCacheIfNeeded];  // ⭐ LRU 清理

        if (isFirst) {
            [self displayFirstChapter:chapter content:localContent];
        } else {
            [self appendChapterToScrollView:chapter content:localContent];
        }

        if (completion) completion(YES);
        return;
    }

    // ⭐ 3. 请求去重检查
    if ([self.pendingRequests containsObject:indexKey]) {
        if (completion) completion(NO);
        return;
    }
    [self.pendingRequests addObject:indexKey];

    // ⭐ 4. 从网络加载
    [[BookContentService sharedService] fetchChapterContent:chapter.chapterUrl
                                                 bookSource:self.bookSource
                                                    success:^(ChapterContent *content) {

        // 缓存到内存
        self.contentCache[indexKey] = content.content;
        [self updateCacheAccessTime:chapterIndex];
        [self trimCacheIfNeeded];  // ⭐ LRU 清理

        // ⭐ 保存到离线缓存
        [self saveLocalCacheForChapter:chapterIndex content:content.content];

        // 移除请求标记
        [self.pendingRequests removeObject:indexKey];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (isFirst) {
                [self displayFirstChapter:chapter content:content.content];
            } else {
                [self appendChapterToScrollView:chapter content:content.content];
            }

            if (completion) completion(YES);
        });

    } failure:^(NSError *error) {
        [self.pendingRequests removeObject:indexKey];  // 移除请求标记
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
    NSNumber *indexKey = @(nextIndex);

    // ⭐ 在后台线程加载
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ChapterModel *nextChapter = self.chapters[nextIndex];

        // ⭐ 1. 先检查内存缓存
        NSString *cachedContent = self.contentCache[indexKey];
        if (cachedContent) {
            [self updateCacheAccessTime:nextIndex];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self appendChapterToScrollView:nextChapter content:cachedContent];
                self.isLoadingNextChapter = NO;
                [self preloadNext3Chapters];
            });
            return;
        }

        // ⭐ 2. 检查离线缓存
        NSString *localContent = [self loadLocalCacheForChapter:nextIndex];
        if (localContent) {
            self.contentCache[indexKey] = localContent;
            [self updateCacheAccessTime:nextIndex];
            [self trimCacheIfNeeded];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self appendChapterToScrollView:nextChapter content:localContent];
                self.isLoadingNextChapter = NO;
                [self preloadNext3Chapters];
            });
            return;
        }

        // ⭐ 3. 请求去重检查
        if ([self.pendingRequests containsObject:indexKey]) {
            self.isLoadingNextChapter = NO;
            return;
        }
        [self.pendingRequests addObject:indexKey];

        // ⭐ 4. 从网络加载
        [[BookContentService sharedService] fetchChapterContent:nextChapter.chapterUrl
                                                     bookSource:self.bookSource
                                                        success:^(ChapterContent *content) {

            // 缓存内容
            self.contentCache[indexKey] = content.content;
            [self updateCacheAccessTime:nextIndex];
            [self trimCacheIfNeeded];

            // ⭐ 保存到离线缓存
            [self saveLocalCacheForChapter:nextIndex content:content.content];

            [self.pendingRequests removeObject:indexKey];

            // 在主线程追加到UI
            dispatch_async(dispatch_get_main_queue(), ^{
                [self appendChapterToScrollView:nextChapter content:content.content];
                self.isLoadingNextChapter = NO;
                [self preloadNext3Chapters];
            });

        } failure:^(NSError *error) {
            [self.pendingRequests removeObject:indexKey];
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

    // ⭐ 恢复上次阅读位置
    [self restoreReadingProgress];

}

// 追加章节到 ScrollView 底部（后台加载完成后调用）
- (void)appendChapterToScrollView:(ChapterModel *)chapter content:(NSString *)content {
    [self.loadedChapters addObject:chapter];

    // ⭐ 在主线程获取 UI 相关的值（避免线程安全问题）
    CGFloat width = self.view.bounds.size.width - 30;
    CGFloat currentContentHeight = self.currentPageVC.currentContentHeight;

    // ⭐ 在后台线程计算新章节高度（增量计算，不需要重新计算整个文本）
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 构建新章节内容
        NSString *chapterTitle = [NSString stringWithFormat:@"【 %@ 】\n\n", chapter.chapterName];
        NSString *newContent = [NSString stringWithFormat:@"%@%@\n\n━━━━━━━━━━━━━━━━━━━━\n\n", chapterTitle, content];


        // ⭐ 只计算新章节的高度（增量计算）
        UIFont *contentFont = [UIFont systemFontOfSize:17];

        CGSize newChapterSize = [newContent boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName: contentFont}
                                                          context:nil].size;

        // 回到主线程更新UI
        dispatch_async(dispatch_get_main_queue(), ^{

            // 记录新章节的起始偏移（使用缓存的当前高度）
            self.chapterOffsets[@(chapter.chapterIndex)] = @(currentContentHeight);

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
            CGFloat newTotalHeight = currentContentHeight + newChapterSize.height;
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

    // ⭐ 使用 ScreenAdapter 获取正确的内容宽度
    CGFloat pageWidth = [ScreenAdapter readingContentWidth];
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

    // ⭐ 1. 更新浮动标题（使用节流优化，避免频繁更新）
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (now - self.lastTitleUpdateTime >= FLOATING_TITLE_UPDATE_INTERVAL) {
        [self updateFloatingTitleWithOffset:offsetY];
        self.lastTitleUpdateTime = now;
    }

    // ⭐ 2. 精确保存阅读进度（每滚动100pt保存一次，避免过于频繁）
    if (fabs(offsetY - self.lastSavedScrollOffset) > 100) {
        self.lastSavedScrollOffset = offsetY;
        [self saveReadingProgress];
    }

    // 3. ⭐ 智能加载：当用户阅读到最后已显示章节的80%位置时，显示下一章
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

#pragma mark - ⭐ 内存管理优化


- (void)trimCacheIfNeeded {
    if (self.contentCache.count <= MAX_CACHE_COUNT) {
        return;
    }

    // 按访问时间排序，移除最旧的章节
    NSArray *sortedKeys = [self.contentCache.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSNumber *key1, NSNumber *key2) {
        NSDate *time1 = self.cacheAccessTime[key1] ?: [NSDate distantPast];
        NSDate *time2 = self.cacheAccessTime[key2] ?: [NSDate distantPast];
        return [time1 compare:time2];
    }];

    // 移除最旧的章节（保留最新的 MAX_CACHE_COUNT 章）
    NSInteger removeCount = sortedKeys.count - MAX_CACHE_COUNT;
    for (NSInteger i = 0; i < removeCount; i++) {
        NSNumber *key = sortedKeys[i];
        [self.contentCache removeObjectForKey:key];
        [self.cacheAccessTime removeObjectForKey:key];
    }
}






/**
 * 更新缓存访问时间（用于 LRU）
 */
- (void)updateCacheAccessTime:(NSInteger)chapterIndex {
    self.cacheAccessTime[@(chapterIndex)] = [NSDate date];
}

/**
 * 保存章节到离线缓存
 */
- (void)saveLocalCacheForChapter:(NSInteger)chapterIndex content:(NSString *)content {
    if (chapterIndex >= self.chapters.count) {
        return;
    }

    ChapterModel *chapterModel = self.chapters[chapterIndex];

    // 创建 Chapter 对象（BookContentManager 使用的模型）
    Chapter *chapter = [[Chapter alloc] init];
    chapter.bookId = self.book.bookUrl;  // 使用 bookUrl 作为唯一标识
    chapter.chapterId = [@(chapterIndex) stringValue];
    chapter.chapterName = chapterModel.chapterName;
    chapter.chapterUrl = chapterModel.chapterUrl;
    chapter.content = content;
    chapter.isDownloaded = YES;
    chapter.downloadDate = [NSDate date];

    // 异步保存到本地
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[BookContentManager sharedManager] saveChapter:chapter];
    });
}

/**
 * 从离线缓存加载章节
 */
- (nullable NSString *)loadLocalCacheForChapter:(NSInteger)chapterIndex {
    Chapter *chapter = [[BookContentManager sharedManager] loadChapterWithBookId:self.book.bookUrl
                                                                       chapterId:[@(chapterIndex) stringValue]];
    return chapter.content;
}

#pragma mark - ⭐ 横竖屏适配

/**
 * 处理屏幕旋转
 */
- (void)handleOrientationChange:(NSNotification *)notification {
    // ⭐ 检查 UI 是否已初始化
    if (!self.isUIInitialized) {
        return;  // UI 还没初始化完成，不处理旋转
    }

    // ⭐ 延迟处理，等待旋转动画完成和 view bounds 更新
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateLayoutForCurrentOrientation];
    });
}

/**
 * viewWillTransitionToSize - 系统旋转时调用
 * 这个方法在 bounds 更新之前调用，可以提前准备
 */
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    // ⭐ 检查 UI 是否已初始化
    if (!self.isUIInitialized) {
        return;  // UI 还没初始化完成，不处理旋转
    }

    // ⭐ 在转场完成后更新布局
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        // 转场动画完成后，bounds 已经更新
        [self updateLayoutForCurrentOrientation];
    }];
}

/**
 * 更新布局以适应当前方向
 */
- (void)updateLayoutForCurrentOrientation {
    if (self.pageTurnMode == PageTurnModeVertical) {
        [self updateVerticalModeLayout];
    } else {
        [self updateHorizontalModeLayout];
    }

    // 更新工具栏
    [self updateToolbarLayout];

    // 更新浮动标题
    [self updateFloatingTitleLayout];
}

/**
 * 更新垂直模式布局
 */
- (void)updateVerticalModeLayout {
    if (!self.currentPageVC) return;

    // ⭐ 保存当前滚动位置（百分比）
    UIScrollView *scrollView = self.currentPageVC.scrollView;
    CGFloat oldContentHeight = scrollView.contentSize.height;
    CGFloat oldOffset = scrollView.contentOffset.y;
    CGFloat scrollPercentage = oldContentHeight > 0 ? oldOffset / oldContentHeight : 0;

    // ⭐ 更新 currentPageVC 的 view frame
    self.currentPageVC.view.frame = self.view.bounds;

    // ⭐ 重新计算内容宽度
    CGFloat contentWidth = [ScreenAdapter readingContentWidth];
    CGFloat screenWidth = [ScreenAdapter screenWidth];
    CGFloat screenHeight = [ScreenAdapter screenHeight];

    // iPad 横屏：内容居中
    CGFloat leftMargin = [ScreenAdapter horizontalPadding];
    if (ScreenAdapter.isIPad && ScreenAdapter.isLandscape) {
        leftMargin = (screenWidth - contentWidth) / 2;
    }

    // ⭐ 更新 scrollView frame
    CGFloat scrollY = self.floatingTitleLabel ? 44 : 0;
    CGFloat toolbarHeight = self.isToolbarVisible ? 60 : 0;
    scrollView.frame = CGRectMake(0, scrollY, screenWidth, screenHeight - scrollY - toolbarHeight);

    // ⭐ 更新 textView 布局和内容
    UITextView *textView = self.currentPageVC.contentTextView;
    if (textView && textView.text.length > 0) {
        // 重新计算文本高度
        NSAttributedString *attributedText = textView.attributedText;
        CGSize textSize = [attributedText boundingRectWithSize:CGSizeMake(contentWidth, CGFLOAT_MAX)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                        context:nil].size;

        // 更新 textView frame
        textView.frame = CGRectMake(leftMargin, 10, contentWidth, textSize.height);

        // 更新 scrollView contentSize
        scrollView.contentSize = CGSizeMake(screenWidth, textSize.height + 20);

        // ⭐ 恢复滚动位置（按百分比）
        CGFloat newContentHeight = scrollView.contentSize.height;
        CGFloat newOffset = newContentHeight * scrollPercentage;
        [scrollView setContentOffset:CGPointMake(0, newOffset) animated:NO];
    }
}

/**
 * 更新横向模式布局（需要重新分页）
 */
- (void)updateHorizontalModeLayout {
    // ⭐ 检查是否在横向模式
    if (!self.pageViewController) {
        return;  // 不在横向模式，无需处理
    }

    // ⭐ 保存当前页面索引和旧的总页数
    NSInteger oldPageIndex = self.currentPageIndex;
    NSInteger oldPagesCount = self.allPages.count;

    // 清除旧的分页缓存
    [self.pagesCache removeAllObjects];
    [self.allPages removeAllObjects];

    // ⭐ 重新分页（使用新的屏幕尺寸）
    if (!self.currentChapter) {
        return;  // 没有当前章节，无法分页
    }

    [self buildAllPagesFromChapter:self.currentChapter];

    // ⭐ 尝试恢复到相近的页面
    if (self.allPages.count == 0) {
        return;  // 分页失败，无法设置页面
    }

    // 计算新的页面索引（按比例）
    NSInteger newPageIndex = 0;
    if (oldPageIndex > 0 && oldPagesCount > 0) {
        // 按照之前的进度比例来定位
        CGFloat progress = (CGFloat)oldPageIndex / (CGFloat)oldPagesCount;
        newPageIndex = (NSInteger)(progress * self.allPages.count);
        newPageIndex = MAX(0, MIN(newPageIndex, self.allPages.count - 1));  // 确保在有效范围内
    }

    self.currentPageIndex = newPageIndex;

    // 创建新页面
    ContentPageViewController *newPageVC = [[ContentPageViewController alloc] init];
    if (!newPageVC) {
        return;  // 创建失败
    }

    newPageVC.scrollEnabled = NO;
    newPageVC.pageModel = self.allPages[newPageIndex];

    // ⭐ 检查 pageModel 是否有效
    if (!newPageVC.pageModel) {
        return;  // pageModel 无效，不能设置
    }

    self.currentPageVC = newPageVC;

    // ⭐ 确保 newPageVC 不为 nil 才设置
    [self.pageViewController setViewControllers:@[newPageVC]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
}

/**
 * 更新工具栏布局
 */
- (void)updateToolbarLayout {
    if (!self.toolbar) return;

    CGFloat screenWidth = [ScreenAdapter screenWidth];
    CGFloat toolbarHeight = 60;

    self.toolbar.frame = CGRectMake(0,
                                    [ScreenAdapter screenHeight] - toolbarHeight,
                                    screenWidth,
                                    toolbarHeight);

    // ⭐ 重新布局工具栏按钮（安全地创建数组，过滤 nil）
    CGFloat buttonWidth = ScreenAdapter.isIPad ? 80 : 60;
    CGFloat spacing = (screenWidth - 4 * buttonWidth) / 5;
    CGFloat y = 10;

    // ⭐ 手动检查每个按钮，避免 nil 导致崩溃
    NSMutableArray *buttons = [NSMutableArray array];
    if (self.catalogButton) [buttons addObject:self.catalogButton];
    if (self.readAloudButton) [buttons addObject:self.readAloudButton];
    if (self.interfaceButton) [buttons addObject:self.interfaceButton];
    if (self.settingsButton) [buttons addObject:self.settingsButton];

    for (NSInteger i = 0; i < buttons.count; i++) {
        UIButton *button = buttons[i];
        button.frame = CGRectMake(spacing + i * (buttonWidth + spacing), y, buttonWidth, 40);
    }
}

/**
 * 更新浮动标题布局
 */
- (void)updateFloatingTitleLayout {
    if (!self.floatingTitleLabel) return;

    CGFloat contentWidth = [ScreenAdapter readingContentWidth];
    CGFloat screenWidth = [ScreenAdapter screenWidth];
    CGFloat leftMargin = [ScreenAdapter horizontalPadding];

    // iPad 横屏：标题与内容同宽且居中
    if (ScreenAdapter.isIPad && ScreenAdapter.isLandscape) {
        leftMargin = (screenWidth - contentWidth) / 2;
    }

    self.floatingTitleLabel.frame = CGRectMake(leftMargin,
                                               [ScreenAdapter safeAreaInsets].top,
                                               contentWidth,
                                               44);
}

- (void)dealloc {
    // 移除通知监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    // 保存当前滚动位置
    if (self.pageTurnMode == PageTurnModeVertical && self.currentPageVC) {
        CGFloat currentOffset = self.currentPageVC.scrollView.contentOffset.y;
        [[NSUserDefaults standardUserDefaults] setFloat:currentOffset
                                                 forKey:[NSString stringWithFormat:@"ReadProgress_%@_%ld", self.book.bookUrl, (long)self.currentChapter.chapterIndex]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    // 返回时通知书架刷新
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BookReadProgressUpdated" object:nil];
}

@end
