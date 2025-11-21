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

@interface BookshelfViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<BookModel *> *networkBooks;  // 网络书籍
@property (strong, nonatomic) NSMutableArray<BookModel *> *localBooks;    // 本地书籍
@property (strong, nonatomic) NSMutableArray<BookModel *> *followBooks;   // 关注书籍
@property (strong, nonatomic) NSMutableArray<BookModel *> *currentBooks;  // 当前显示的书籍
@property (assign, nonatomic) BOOL needsReload;  // 是否需要重新加载
@end

@implementation BookshelfViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"书架";
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.needsReload = YES; // 初始化时需要加载

    [self setupData];
    [self setupSegmentedControl];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // 优化：只在需要时重新加载数据
    if (self.needsReload) {
        [self loadBooksFromManager];

        // 刷新当前显示的列表
        NSInteger selectedIndex = self.segmentedControl.selectedSegmentIndex;
        switch (selectedIndex) {
            case 0:
                self.currentBooks = self.networkBooks;
                break;
            case 1:
                self.currentBooks = self.localBooks;
                break;
            case 2:
                self.currentBooks = self.followBooks;
                break;
        }

        [self.tableView reloadData];
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

- (void)setupSegmentedControl {
    // 创建分段控件
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"网络未分组", @"本地", @"关注"]];
    self.segmentedControl.selectedSegmentIndex = 0;
    [self.segmentedControl addTarget:self
                               action:@selector(segmentChanged:)
                     forControlEvents:UIControlEventValueChanged];

    // 设置样式
    if (@available(iOS 13.0, *)) {
        self.segmentedControl.selectedSegmentTintColor = [UIColor systemRedColor];
    }
    [self.segmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}
                                        forState:UIControlStateSelected];

    // 作为导航栏的 titleView
    self.navigationItem.titleView = self.segmentedControl;
}

- (void)setupTableView {
    CGFloat yOffset = 0;  // 导航栏下方
    CGFloat screenHeight = self.view.bounds.size.height;
    CGFloat tabBarHeight = 49;  // TabBar 高度

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, yOffset, self.view.bounds.size.width, screenHeight - tabBarHeight)
                                                   style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 160;  // Cell 高度

    // 注册 Cell
    [self.tableView registerClass:[BookCell class] forCellReuseIdentifier:@"BookCell"];

    [self.view addSubview:self.tableView];
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

- (void)segmentChanged:(UISegmentedControl *)segment {
    // 切换显示的书籍列表
    switch (segment.selectedSegmentIndex) {
        case 0:  // 网络未分组
            self.currentBooks = self.networkBooks;
            break;
        case 1:  // 本地
            self.currentBooks = self.localBooks;
            break;
        case 2:  // 关注
            self.currentBooks = self.followBooks;
            break;
        default:
            break;
    }

    [self.tableView reloadData];
    // NSLog(@"切换到：%@，共 %lu 本书", [segment titleForSegmentAtIndex:segment.selectedSegmentIndex], (unsigned long)self.currentBooks.count);
}

- (void)searchButtonTapped {
    // NSLog(@"🔍 搜索按钮点击");

    // 跳转到搜索页面
    UIViewController *searchVC = [[NSClassFromString(@"SearchResultViewController") alloc] init];
    if (searchVC) {
        [self.navigationController pushViewController:searchVC animated:YES];
    }
}

- (void)moreButtonTapped {
    // NSLog(@"更多按钮点击");
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

    // 跳转到章节列表页面
    ChapterListViewController *chapterListVC = [[ChapterListViewController alloc] initWithBook:book];
    [self.navigationController pushViewController:chapterListVC animated:YES];
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

            NSLog(@"🗑️ 已删除书籍: %@", book.title);
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

            NSLog(@"🗑️ 已删除书籍: %@", book.title);

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
