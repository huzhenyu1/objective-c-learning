//
//  SearchResultViewController.m
//  Read
//
//  搜索结果页面
//

#import "SearchResultViewController.h"
#import "BookSearchService.h"
#import "BookSourceManager.h"
#import "BookshelfManager.h"
#import "BookModel.h"

@interface SearchResultViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIActivityIndicatorView *loadingIndicator;
@property (strong, nonatomic) UILabel *emptyLabel;
@property (strong, nonatomic) NSArray<SearchResultBook *> *searchResults;
@property (assign, nonatomic) BOOL isFirstAppearance;  // 标记是否首次出现
@property (assign, nonatomic) BOOL isSearching;
@end

@implementation SearchResultViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        // 必须在 init 中设置，否则不生效
        self.hidesBottomBarWhenPushed = YES;
        self.isFirstAppearance = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.searchResults = @[];

    // 创建搜索框并放入 titleView
    [self setupSearchBar];

    [self setupTableView];
    [self setupLoadingIndicator];
    [self setupEmptyLabel];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // 在视图完全显示后才聚焦搜索框
    if (self.isFirstAppearance) {
        [self.searchBar becomeFirstResponder];
        self.isFirstAppearance = NO;
    }
}

// 设置搜索框
- (void)setupSearchBar {
    // 创建搜索框
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"搜索...";
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.showsCancelButton = NO;
    self.searchBar.translatesAutoresizingMaskIntoConstraints = NO;

    // 创建容器视图来包裹搜索框
    UIView *containerView = [[UIView alloc] init];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:self.searchBar];

    // 使用 AutoLayout 设置搜索框在容器内的约束
    [NSLayoutConstraint activateConstraints:@[
        // 搜索框在容器内居中，左侧留出空间避免与返回按钮冲突
        [self.searchBar.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:8],
        [self.searchBar.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor constant:-8],
        [self.searchBar.topAnchor constraintEqualToAnchor:containerView.topAnchor],
        [self.searchBar.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor],

        // 容器视图的尺寸约束
        [containerView.widthAnchor constraintEqualToConstant:[UIScreen mainScreen].bounds.size.width - 140],
        [containerView.heightAnchor constraintEqualToConstant:44]
    ]];

    // 设置容器视图为导航栏标题
    self.navigationItem.titleView = containerView;
}

- (void)setupTableView {
    // TableView 从视图顶部开始（搜索框已经在导航栏中了）
    // 使用 autoresizingMask 让 TableView 自动适应视图大小
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 100;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SearchResultCell"];
    self.tableView.hidden = YES;
    [self.view addSubview:self.tableView];
}

- (void)setupLoadingIndicator {
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.loadingIndicator.center = self.view.center;
    self.loadingIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.loadingIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.loadingIndicator];
}

- (void)setupEmptyLabel {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat centerY = screenHeight / 2;
    self.emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, centerY - 50, screenWidth - 100, 100)];
    self.emptyLabel.text = @"📚\n输入书名开始搜索";
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyLabel.textColor = [UIColor secondaryLabelColor];
    self.emptyLabel.numberOfLines = 0;
    self.emptyLabel.font = [UIFont systemFontOfSize:16];
    self.emptyLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                       UIViewAutoresizingFlexibleRightMargin |
                                       UIViewAutoresizingFlexibleTopMargin |
                                       UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.emptyLabel];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];

    NSString *keyword = searchBar.text;
    if (!keyword || keyword.length == 0) {
        return;
    }

    [self performSearch:keyword];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - 搜索

- (void)performSearch:(NSString *)keyword {
    if (self.isSearching) {
        return;
    }

    self.isSearching = YES;
    self.emptyLabel.hidden = YES;
    self.tableView.hidden = YES;
    [self.loadingIndicator startAnimating];


    // 获取所有启用的书源
    NSArray<BookSource *> *enabledSources = [[BookSourceManager sharedManager] enabledBookSources];

    if (enabledSources.count == 0) {
        [self showError:@"没有启用的书源"];
        return;
    }


    // 多书源搜索
    [[BookSearchService sharedService] searchBooks:keyword
                                      inBookSources:enabledSources
                                           progress:^(BookSource *source, NSArray<SearchResultBook *> *books) {
    } completion:^(NSArray<SearchResultBook *> *allBooks) {
        [self handleSearchResults:allBooks keyword:keyword];
    }];
}

- (void)handleSearchResults:(NSArray<SearchResultBook *> *)books keyword:(NSString *)keyword {
    self.isSearching = NO;
    [self.loadingIndicator stopAnimating];

    self.searchResults = books;
    [self.tableView reloadData];

    if (books.count > 0) {
        self.tableView.hidden = NO;
        self.emptyLabel.hidden = YES;
    } else {
        self.tableView.hidden = YES;
        self.emptyLabel.hidden = NO;
        self.emptyLabel.text = [NSString stringWithFormat:@"😕\n未找到 \"%@\"", keyword];
    }
}

- (void)showError:(NSString *)message {
    self.isSearching = NO;
    [self.loadingIndicator stopAnimating];

    self.emptyLabel.hidden = NO;
    self.emptyLabel.text = [NSString stringWithFormat:@"❌\n%@", message];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"搜索失败"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                      style:UIAlertActionStyleDefault
                                                    handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResultCell" forIndexPath:indexPath];

    // 配置为 Subtitle 样式
    cell.textLabel.numberOfLines = 0;
    cell.detailTextLabel.numberOfLines = 0;

    SearchResultBook *book = self.searchResults[indexPath.row];

    // 主标题：书名
    cell.textLabel.text = [NSString stringWithFormat:@"📖 %@", book.name];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16];

    // 副标题：作者 + 书源
    NSString *detail = [NSString stringWithFormat:@"作者：%@\n来源：%@\n最新：%@",
                       book.author ?: @"未知",
                       book.bookSource.bookSourceName,
                       book.lastChapter ?: @"未知"];
    cell.detailTextLabel.text = detail;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    SearchResultBook *book = self.searchResults[indexPath.row];

    // 显示书籍详情
    NSString *message = [NSString stringWithFormat:@"书名：%@\n作者：%@\n来源：%@\n\n%@\n\n最新章节：%@",
                        book.name,
                        book.author ?: @"未知",
                        book.bookSource.bookSourceName,
                        book.intro ?: @"暂无简介",
                        book.lastChapter ?: @"未知"];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"书籍详情"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"加入书架"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        [self addBookToBookshelf:book];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil];

    [alert addAction:addAction];
    [alert addAction:cancelAction];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)dealloc {
    [[BookSearchService sharedService] cancelAllSearches];
}

#pragma mark - 加入书架

// 🛡️ 安全地从 JSON 对象中获取字符串
- (NSString *)safeString:(id)value defaultValue:(NSString *)defaultValue {
    if (!value || [value isKindOfClass:[NSNull class]]) {
        return defaultValue;
    }
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    }
    return [NSString stringWithFormat:@"%@", value];
}

- (void)addBookToBookshelf:(SearchResultBook *)searchBook {
    // 🛡️ 安全获取字符串值
    NSString *bookName = [self safeString:searchBook.name defaultValue:@"未知书名"];
    NSString *bookAuthor = [self safeString:searchBook.author defaultValue:@"未知作者"];
    NSString *sourceName = [self safeString:searchBook.bookSource.bookSourceName defaultValue:@"未知来源"];

    // 生成书籍ID（使用书名+作者+书源名作为唯一标识）
    NSString *bookId = [NSString stringWithFormat:@"%@_%@_%@", bookName, bookAuthor, sourceName];

    // 检查是否已在书架
    if ([[BookshelfManager sharedManager] containsBookWithId:bookId]) {
        [self showMessage:@"该书籍已在书架中"];
        return;
    }

    // 转换为 BookModel
    BookModel *book = [[BookModel alloc] init];
    book.bookId = bookId;
    book.title = bookName;
    book.author = bookAuthor;
    book.coverImageURL = [self safeString:searchBook.coverUrl defaultValue:@""];
    book.currentChapter = 0;
    book.totalChapters = 0;  // 暂时未知
    book.lastReadTime = @"";
    book.bookType = BookTypeNetwork;  // 搜索的都是网络书籍
    book.fileSize = 0;
    book.unreadCount = 0;

    // 📚 网络书籍额外信息
    book.bookUrl = [self safeString:searchBook.bookUrl defaultValue:@""];
    book.bookSourceName = sourceName;
    book.intro = [self safeString:searchBook.intro defaultValue:@""];

    // 添加到书架
    BOOL success = [[BookshelfManager sharedManager] addBook:book];
    if (success) {
        [self showMessage:@"✅ 已加入书架"];

        // 通知书架页面需要刷新（如果已经创建）
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BookAddedNotification" object:nil];
    } else {
        [self showMessage:@"❌ 加入书架失败"];
    }
}

- (void)showMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                      style:UIAlertActionStyleDefault
                                                    handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end

