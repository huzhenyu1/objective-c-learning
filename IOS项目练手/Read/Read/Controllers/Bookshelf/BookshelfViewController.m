//
//  BookshelfViewController.m
//  Read
//
//  书架页面 - 顶部 Segment + 中间 TableView
//

#import "BookshelfViewController.h"
#import "BookModel.h"
#import "BookCell.h"
#import "BookshelfManager.h"
#import "ChapterListViewController.h"
#import "SearchResultViewController.h"
#import "ReaderViewController.h"
#import "BookContentService.h"
#import "BookSourceManager.h"
#import "ScreenAdapter.h"  // ⭐ 屏幕适配工具

@interface BookshelfViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UIScrollView *tabScrollView;  // ⭐ 可滚动的标签栏容器
@property (strong, nonatomic) NSMutableArray<UIButton *> *tabButtons;  // ⭐ 标签按钮数组
@property (assign, nonatomic) NSInteger selectedTabIndex;  // ⭐ 当前选中的标签索引
@property (strong, nonatomic) UIView *tabIndicator;  // ⭐ 选中指示器（下划线）
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<BookModel *> *networkBooks;  // 网络书籍
@property (strong, nonatomic) NSMutableArray<BookModel *> *localBooks;    // 本地书籍
@property (strong, nonatomic) NSMutableArray<BookModel *> *followBooks;   // 关注书籍
@property (strong, nonatomic) NSMutableArray<BookModel *> *currentBooks;  // 当前显示的书籍
@property (assign, nonatomic) BOOL needsReload;  // 是否需要重新加载
@property (strong, nonatomic) NSMutableSet<NSString *> *loadingBookIds;  // 正在加载的书籍ID（防重复点击）
@property (strong, nonatomic) UIAlertController *currentLoadingAlert;     // 当前的加载提示
@end

@implementation BookshelfViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // ⭐ 不设置 title，使用自定义标签栏
    self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];  // ⭐ 浅灰色背景
    self.needsReload = YES; // 初始化时需要加载
    self.loadingBookIds = [NSMutableSet set]; // 初始化加载中的书籍集合

    // ⭐ 设置导航栏背景色（棕红色）
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        appearance.backgroundColor = [UIColor colorWithRed:0.58 green:0.36 blue:0.27 alpha:1.0];
        appearance.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
    } else {
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.58 green:0.36 blue:0.27 alpha:1.0];
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    }
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];  // 按钮颜色

    [self setupData];
    [self setupScrollableTabBar];  // ⭐ 改用可滚动标签栏
    [self setupTableView];
    [self setupNavigationBar];

    // 监听书籍添加通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onBookAdded:)
                                                 name:@"BookAddedNotification"
                                               object:nil];

    // 监听阅读进度更新通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onReadProgressUpdated:)
                                                 name:@"BookReadProgressUpdated"
                                               object:nil];
    
    // ⭐ 监听屏幕旋转
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleOrientationChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onBookAdded:(NSNotification *)notification {
    // 标记需要重新加载
    self.needsReload = YES;
}

- (void)onReadProgressUpdated:(NSNotification *)notification {
    // 标记需要重新加载
    self.needsReload = YES;
}

// ⭐ 处理屏幕旋转
- (void)handleOrientationChange:(NSNotification *)notification {
    // 重新布局标签栏
    [self updateTabBarLayout];
    
    // 重新加载 TableView（调整 Cell 高度）
    self.tableView.rowHeight = [ScreenAdapter bookCellHeight];
    [self.tableView reloadData];
}

// ⭐ 更新标签栏布局（适配屏幕宽度）
- (void)updateTabBarLayout {
    if (!self.tabScrollView || self.tabButtons.count == 0) {
        return;
    }
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat xOffset = [ScreenAdapter horizontalPadding];
    
    // 重新计算按钮位置
    for (NSInteger i = 0; i < self.tabButtons.count; i++) {
        UIButton *button = self.tabButtons[i];
        CGSize textSize = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: button.titleLabel.font}];
        CGFloat buttonWidth = textSize.width + 20;
        
        button.frame = CGRectMake(xOffset, 0, buttonWidth, 44);
        xOffset += buttonWidth + 15;
    }
    
    // 更新 contentSize
    self.tabScrollView.contentSize = CGSizeMake(xOffset, 44);
    
    // 更新指示器位置
    if (self.selectedTabIndex < self.tabButtons.count) {
        UIButton *selectedButton = self.tabButtons[self.selectedTabIndex];
        self.tabIndicator.frame = CGRectMake(selectedButton.frame.origin.x, 40, selectedButton.frame.size.width, 3);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // 优化：只在需要时重新加载数据
    if (self.needsReload) {
        [self loadBooksFromManager];

        // ⭐ 刷新当前显示的列表（使用当前选中的标签）
        [self switchToTabAtIndex:self.selectedTabIndex];

        self.needsReload = NO;
    }
}

// 标记需要重新加载（从外部调用）
- (void)setNeedsReload {
    self.needsReload = YES;
}

- (void)setupData {
    // 从 BookshelfManager 加载数据
    [self loadBooksFromManager];

    // 默认显示网络书籍
    self.currentBooks = self.networkBooks;
}

- (void)loadBooksFromManager {
    // 初始化数组
    self.networkBooks = [NSMutableArray arrayWithArray:[[BookshelfManager sharedManager] getBooksWithType:BookTypeNetwork]];
    self.localBooks = [NSMutableArray arrayWithArray:[[BookshelfManager sharedManager] getBooksWithType:BookTypeLocal]];
    self.followBooks = [NSMutableArray arrayWithArray:[[BookshelfManager sharedManager] getBooksWithType:BookTypeFollow]];
}

// ⭐ 创建可滚动的标签栏
- (void)setupScrollableTabBar {
    // 标签名称
    NSArray *tabTitles = @[@"网络未分组", @"音频", @"本地", @"关注"];

    // ⭐ 创建 ScrollView 容器（作为导航栏的 titleView）
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.tabScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth - 100, 44)];  // 预留左右按钮空间
    self.tabScrollView.backgroundColor = [UIColor clearColor];  // 透明背景
    self.tabScrollView.showsHorizontalScrollIndicator = NO;
    self.tabScrollView.showsVerticalScrollIndicator = NO;

    // 创建按钮数组
    self.tabButtons = [NSMutableArray array];
    CGFloat xOffset = 15;

    for (NSInteger i = 0; i < tabTitles.count; i++) {
        NSString *title = tabTitles[i];

        // 创建按钮
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        [button setTitle:title forState:UIControlStateNormal];
        [button addTarget:self action:@selector(tabButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

        // 设置字体
        button.titleLabel.font = (i == 0) ? [UIFont boldSystemFontOfSize:16] : [UIFont systemFontOfSize:15];

        // 设置颜色
        UIColor *textColor = (i == 0) ? [UIColor whiteColor] : [UIColor colorWithWhite:1.0 alpha:0.6];
        [button setTitleColor:textColor forState:UIControlStateNormal];

        // 计算按钮宽度（根据文字自适应）
        CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName: button.titleLabel.font}];
        CGFloat buttonWidth = titleSize.width + 20;  // 左右各留10px

        button.frame = CGRectMake(xOffset, 0, buttonWidth, 44);
        [self.tabScrollView addSubview:button];
        [self.tabButtons addObject:button];

        xOffset += buttonWidth + 10;  // 按钮间距10px
    }

    // 设置 ScrollView 的 contentSize
    self.tabScrollView.contentSize = CGSizeMake(xOffset + 15, 44);

    // 创建选中指示器（下划线）
    UIButton *firstButton = self.tabButtons.firstObject;
    self.tabIndicator = [[UIView alloc] initWithFrame:CGRectMake(firstButton.frame.origin.x, 40, firstButton.frame.size.width, 3)];
    self.tabIndicator.backgroundColor = [UIColor whiteColor];
    self.tabIndicator.layer.cornerRadius = 1.5;
    [self.tabScrollView addSubview:self.tabIndicator];

    // 初始化选中索引
    self.selectedTabIndex = 0;

    // ⭐ 将 ScrollView 设置为导航栏的 titleView
    self.navigationItem.titleView = self.tabScrollView;
}

// ⭐ 标签按钮点击事件
- (void)tabButtonTapped:(UIButton *)button {
    NSInteger index = button.tag;

    if (index == self.selectedTabIndex) {
        return;  // 已经选中，不处理
    }

    // 更新选中状态
    [self selectTabAtIndex:index animated:YES];

    // 切换数据
    [self switchToTabAtIndex:index];
}

// ⭐ 选中指定标签
- (void)selectTabAtIndex:(NSInteger)index animated:(BOOL)animated {
    // 更新旧按钮样式
    UIButton *oldButton = self.tabButtons[self.selectedTabIndex];
    oldButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [oldButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.6] forState:UIControlStateNormal];

    // 更新新按钮样式
    UIButton *newButton = self.tabButtons[index];
    newButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [newButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    // 移动指示器
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            self.tabIndicator.frame = CGRectMake(newButton.frame.origin.x, 40, newButton.frame.size.width, 3);
        }];
    } else {
        self.tabIndicator.frame = CGRectMake(newButton.frame.origin.x, 40, newButton.frame.size.width, 3);
    }

    // 滚动到可见位置
    [self.tabScrollView scrollRectToVisible:CGRectInset(newButton.frame, -20, 0) animated:animated];

    // 更新选中索引
    self.selectedTabIndex = index;
}

// ⭐ 切换到指定标签的数据
- (void)switchToTabAtIndex:(NSInteger)index {
    switch (index) {
        case 0:  // 网络未分组
            self.currentBooks = self.networkBooks;
            break;
        case 1:  // 音频
            self.currentBooks = self.localBooks;
            break;
        case 2:  // 本地
            self.currentBooks = self.localBooks;
            break;
        case 3:  // 关注
            self.currentBooks = self.followBooks;
            break;
        default:
            break;
    }

    [self.tableView reloadData];
}

- (void)setupTableView {
    // ⭐ 使用 AutoLayout 支持横竖屏
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = [ScreenAdapter bookCellHeight];  // ⭐ 根据设备自适应
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];

    // 注册 Cell
    [self.tableView registerClass:[BookCell class] forCellReuseIdentifier:@"BookCell"];

    [self.view addSubview:self.tableView];
    
    // ⭐ AutoLayout 约束
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];
}

- (void)setupNavigationBar {
    // 右侧搜索按钮
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"magnifyingglass"]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(searchButtonTapped)];

    // 右侧更多按钮
    UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"ellipsis"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(moreButtonTapped)];

    self.navigationItem.rightBarButtonItems = @[moreButton, searchButton];
}

#pragma mark - Actions


- (void)searchButtonTapped {
    // 跳转到搜索页面
    UIViewController *searchVC = [[NSClassFromString(@"SearchResultViewController") alloc] init];
    if (searchVC) {
        [self.navigationController pushViewController:searchVC animated:YES];
    }
}

- (void)moreButtonTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"更多选项"
                                                                   message:@"功能开发中..."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currentBooks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BookCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BookCell" forIndexPath:indexPath];

    BookModel *book = self.currentBooks[indexPath.row];
    [cell configureWithBook:book];

    // 🚀 性能优化：减少不必要的重绘
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    BookModel *book = self.currentBooks[indexPath.row];

    // 检查书籍是否有必要的信息
    if (!book.bookUrl || book.bookUrl.length == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                       message:@"该书籍信息不完整，无法阅读"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    // ⭐ 直接跳转到阅读器页面
    [self openReaderWithBook:book];
}

#pragma mark - 打开阅读器

- (void)openReaderWithBook:(BookModel *)book {
    // ⭐ 防止重复点击
    if ([self.loadingBookIds containsObject:book.bookId]) {
        return;
    }

    // 获取书源
    BookSource *bookSource = [[BookSourceManager sharedManager] getBookSourceByName:book.bookSourceName];
    if (!bookSource) {
        [self showAlertWithMessage:@"未找到书源"];
        return;
    }

    // ⭐ 优先使用缓存的章节列表（秒开）
    NSArray<ChapterModel *> *cachedChapters = [[BookContentService sharedService] getCachedChapterListForBook:book];
    if (cachedChapters && cachedChapters.count > 0) {
        [self handleChaptersLoaded:cachedChapters forBook:book bookSource:bookSource];
        return;
    }

    // 标记为加载中
    [self.loadingBookIds addObject:book.bookId];

    // 显示加载提示
    self.currentLoadingAlert = [UIAlertController alertControllerWithTitle:@"加载中"
                                                                    message:@"正在获取章节列表..."
                                                             preferredStyle:UIAlertControllerStyleAlert];

    // 添加加载指示器
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    indicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.currentLoadingAlert.view addSubview:indicator];
    [NSLayoutConstraint activateConstraints:@[
        [indicator.centerXAnchor constraintEqualToAnchor:self.currentLoadingAlert.view.centerXAnchor],
        [indicator.bottomAnchor constraintEqualToAnchor:self.currentLoadingAlert.view.bottomAnchor constant:-20]
    ]];
    [indicator startAnimating];

    [self presentViewController:self.currentLoadingAlert animated:YES completion:nil];

    // 从网络加载章节列表
    __weak typeof(self) weakSelf = self;
    [[BookContentService sharedService] fetchChapterList:book.bookUrl
                                              bookSource:bookSource
                                                 success:^(NSString *tocUrl, NSArray<ChapterModel *> *chapters) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;

            // 移除加载标记
            [self.loadingBookIds removeObject:book.bookId];

            // 关闭加载提示
            [self.currentLoadingAlert dismissViewControllerAnimated:YES completion:^{
                [self handleChaptersLoaded:chapters forBook:book bookSource:bookSource];
            }];
            self.currentLoadingAlert = nil;
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;

            // 移除加载标记
            [self.loadingBookIds removeObject:book.bookId];

            // 关闭加载提示
            [self.currentLoadingAlert dismissViewControllerAnimated:YES completion:^{
                NSString *message = [NSString stringWithFormat:@"加载失败：%@\n\n请检查网络连接后重试", error.localizedDescription];
                [self showAlertWithMessage:message];
            }];
            self.currentLoadingAlert = nil;
        });
    }];
}

- (void)handleChaptersLoaded:(NSArray<ChapterModel *> *)chapters
                     forBook:(BookModel *)book
                  bookSource:(BookSource *)bookSource {

    if (chapters.count == 0) {
        [self showAlertWithMessage:@"未找到章节"];
        return;
    }

    // ⭐ 更新总章节数和章节名称
    book.totalChapters = chapters.count;

    // 确定要打开的章节（恢复上次阅读进度）
    NSInteger chapterIndex = book.currentChapter;
    if (chapterIndex < 0 || chapterIndex >= chapters.count) {
        chapterIndex = 0;  // 默认第一章
    }

    // ⭐ 更新当前章节名称
    if (chapterIndex < chapters.count) {
        book.currentChapterName = chapters[chapterIndex].chapterName;
    }

    // ⭐ 更新最新章节名称（最后一章）
    if (chapters.count > 0) {
        book.latestChapterName = chapters.lastObject.chapterName;
    }

    [[BookshelfManager sharedManager] updateBook:book];

    ChapterModel *startChapter = chapters[chapterIndex];

    // 创建阅读器
    ReaderViewController *readerVC = [[ReaderViewController alloc] initWithBook:book
                                                                       chapter:startChapter
                                                                      chapters:chapters
                                                                    bookSource:bookSource];
    [self.navigationController pushViewController:readerVC animated:YES];
}

- (void)showAlertWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 左滑删除

// 允许编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// 删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // 获取要删除的书籍
        BookModel *book = self.currentBooks[indexPath.row];

        // 显示确认对话框
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认删除"
                                                                       message:[NSString stringWithFormat:@"确定要删除《%@》吗？", book.title]
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                              style:UIAlertActionStyleCancel
                                                            handler:nil];

        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除"
                                                              style:UIAlertActionStyleDestructive
                                                            handler:^(UIAlertAction * _Nonnull action) {
            // 从数据源删除
            [self.currentBooks removeObjectAtIndex:indexPath.row];

            // 从管理器删除
            [[BookshelfManager sharedManager] removeBookWithId:book.bookId];

            // 从 TableView 删除（带动画）
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];

        [alert addAction:cancelAction];
        [alert addAction:deleteAction];

        [self presentViewController:alert animated:YES completion:nil];
    }
}

// 自定义删除按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

// iOS 11+ 自定义滑动操作
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) {
    BookModel *book = self.currentBooks[indexPath.row];

    // 删除操作
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive
                                                                               title:@"删除"
                                                                             handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        // 显示确认对话框
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认删除"
                                                                       message:[NSString stringWithFormat:@"确定要删除《%@》吗？", book.title]
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                              style:UIAlertActionStyleCancel
                                                            handler:^(UIAlertAction * _Nonnull action) {
            completionHandler(NO);
        }];

        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"删除"
                                                               style:UIAlertActionStyleDestructive
                                                             handler:^(UIAlertAction * _Nonnull action) {
            // 从数据源删除
            [self.currentBooks removeObjectAtIndex:indexPath.row];

            // 从管理器删除
            [[BookshelfManager sharedManager] removeBookWithId:book.bookId];

            // 从 TableView 删除（带动画）
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

            completionHandler(YES);
        }];

        [alert addAction:cancelAction];
        [alert addAction:confirmAction];

        [self presentViewController:alert animated:YES completion:nil];
    }];

    deleteAction.backgroundColor = [UIColor systemRedColor];

    UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
    configuration.performsFirstActionWithFullSwipe = NO; // 防止误操作

    return configuration;
}

@end
