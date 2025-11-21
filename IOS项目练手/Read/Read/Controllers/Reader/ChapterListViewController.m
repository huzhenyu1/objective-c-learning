//
//  ChapterListViewController.m
//  Read
//
//  章节列表页面实现
//

#import "ChapterListViewController.h"
#import "BookContentService.h"
#import "BookSourceManager.h"
#import "BookshelfManager.h"
#import "ChapterModel.h"
#import "ReaderViewController.h"

@interface ChapterListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) BookModel *book;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIActivityIndicatorView *loadingIndicator;
@property (strong, nonatomic) UILabel *errorLabel;
@property (strong, nonatomic) NSArray<ChapterModel *> *chapters;
@property (copy, nonatomic) NSString *tocUrl;  // 目录URL
@end

@implementation ChapterListViewController

- (instancetype)initWithBook:(BookModel *)book {
    self = [super init];
    if (self) {
        _book = book;
        _chapters = @[];
        // 隐藏底部 TabBar
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.book.title;
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupTableView];
    [self setupLoadingIndicator];
    [self setupErrorLabel];

    // 开始加载章节列表
    [self loadChapterList];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 50;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ChapterCell"];
    self.tableView.hidden = YES;
    [self.view addSubview:self.tableView];
}

- (void)setupLoadingIndicator {
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.loadingIndicator.center = self.view.center;
    self.loadingIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                             UIViewAutoresizingFlexibleRightMargin |
                                             UIViewAutoresizingFlexibleTopMargin |
                                             UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.loadingIndicator];
}

- (void)setupErrorLabel {
    CGFloat width = self.view.bounds.size.width - 40;
    CGFloat height = 100;
    CGFloat x = 20;
    CGFloat y = (self.view.bounds.size.height - height) / 2;

    self.errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
    self.errorLabel.textAlignment = NSTextAlignmentCenter;
    self.errorLabel.textColor = [UIColor secondaryLabelColor];
    self.errorLabel.numberOfLines = 0;
    self.errorLabel.font = [UIFont systemFontOfSize:16];
    self.errorLabel.hidden = YES;
    self.errorLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                       UIViewAutoresizingFlexibleRightMargin |
                                       UIViewAutoresizingFlexibleTopMargin |
                                       UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.errorLabel];
}

#pragma mark - 加载章节列表

- (void)loadChapterList {
    NSLog(@"📚 开始加载章节列表");
    NSLog(@"   书名: %@", self.book.title);
    NSLog(@"   bookUrl: %@", self.book.bookUrl ?: @"(空)");
    NSLog(@"   bookSourceName: %@", self.book.bookSourceName ?: @"(空)");

    if (!self.book.bookUrl || self.book.bookUrl.length == 0) {
        NSLog(@"❌ 书籍URL为空");
        [self showError:@"❌\n书籍信息不完整"];
        return;
    }

    if (!self.book.bookSourceName || self.book.bookSourceName.length == 0) {
        NSLog(@"❌ 书源名称为空");
        [self showError:@"❌\n书源信息丢失"];
        return;
    }

    // 获取书源
    BookSource *bookSource = [[BookSourceManager sharedManager] getBookSourceByName:self.book.bookSourceName];
    if (!bookSource) {
        NSLog(@"❌ 未找到书源: %@", self.book.bookSourceName);
        [self showError:@"❌\n未找到书源"];
        return;
    }

    NSLog(@"✅ 找到书源: %@", bookSource.bookSourceName);
    NSLog(@"   ruleBookInfo.baseRule: %@", bookSource.ruleBookInfo.baseRule ?: @"(nil)");
    NSLog(@"   ruleBookInfo.tocUrl: %@", bookSource.ruleBookInfo.tocUrl ?: @"(nil)");

    [self.loadingIndicator startAnimating];
    self.errorLabel.hidden = YES;

    [[BookContentService sharedService] fetchChapterList:self.book.bookUrl
                                              bookSource:bookSource
                                                 success:^(NSString *tocUrl, NSArray<ChapterModel *> *chapters) {
        [self handleChapterListSuccess:tocUrl chapters:chapters];
    } failure:^(NSError *error) {
        [self handleChapterListFailure:error];
    }];
}

- (void)handleChapterListSuccess:(NSString *)tocUrl chapters:(NSArray<ChapterModel *> *)chapters {
    [self.loadingIndicator stopAnimating];

    NSLog(@"✅ 章节列表加载成功");
    NSLog(@"   目录URL: %@", tocUrl);
    NSLog(@"   章节数量: %ld", (long)chapters.count);
    if (chapters.count > 0) {
        NSLog(@"   第一章: %@", chapters[0].chapterName);
        NSLog(@"   第一章URL: %@", chapters[0].chapterUrl);
    }

    self.tocUrl = tocUrl;
    self.chapters = chapters;

    // 更新总章节数并保存
    self.book.totalChapters = chapters.count;
    [[BookshelfManager sharedManager] updateBook:self.book];
    NSLog(@"💾 已更新书籍总章节数: %ld", (long)chapters.count);

    if (chapters.count > 0) {
        self.tableView.hidden = NO;
        [self.tableView reloadData];
    } else {
        [self showError:@"😕\n未找到章节"];
    }
}

- (void)handleChapterListFailure:(NSError *)error {
    [self.loadingIndicator stopAnimating];
    NSLog(@"❌ 章节列表加载失败: %@", error.localizedDescription);
    NSString *message = [NSString stringWithFormat:@"❌\n加载失败\n%@", error.localizedDescription];
    [self showError:message];
}

- (void)showError:(NSString *)message {
    self.errorLabel.text = message;
    self.errorLabel.hidden = NO;
    self.tableView.hidden = YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chapters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChapterCell" forIndexPath:indexPath];

    ChapterModel *chapter = self.chapters[indexPath.row];

    // 显示章节序号和名称
    cell.textLabel.text = [NSString stringWithFormat:@"%ld. %@", (long)(indexPath.row + 1), chapter.chapterName];
    cell.textLabel.font = [UIFont systemFontOfSize:15];

    // 如果是当前章节，高亮显示
    if (indexPath.row == self.book.currentChapter) {
        cell.textLabel.textColor = [UIColor systemBlueColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
    } else {
        cell.textLabel.textColor = [UIColor labelColor];
    }

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ChapterModel *chapter = self.chapters[indexPath.row];

    // 进入阅读页面
    BookSource *bookSource = [[BookSourceManager sharedManager] getBookSourceByName:self.book.bookSourceName];
    if (!bookSource) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误"
                                                                       message:@"未找到书源"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    ReaderViewController *readerVC = [[ReaderViewController alloc] initWithBook:self.book
                                                                         chapter:chapter
                                                                        chapters:self.chapters
                                                                      bookSource:bookSource];
    [self.navigationController pushViewController:readerVC animated:YES];
}

@end

