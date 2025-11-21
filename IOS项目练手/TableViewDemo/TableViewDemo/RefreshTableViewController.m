//
//  RefreshTableViewController.m
//  TableViewDemo
//
//  下拉刷新和上拉加载 - 演示数据加载和刷新
//

#import "RefreshTableViewController.h"

@interface RefreshTableViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (assign, nonatomic) NSInteger pageNumber;  // 当前页码
@property (assign, nonatomic) BOOL isLoadingMore;    // 是否正在加载更多
@end

@implementation RefreshTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"下拉刷新/上拉加载";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    self.dataArray = [NSMutableArray array];
    self.pageNumber = 1;
    self.isLoadingMore = NO;

    [self setupTableView];
    [self setupRefreshControl];

    // 首次加载数据
    [self loadData:NO];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];

    [self.view addSubview:self.tableView];
}

- (void)setupRefreshControl {
    // 创建下拉刷新控件
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(handleRefresh)
                  forControlEvents:UIControlEventValueChanged];

    // 自定义刷新文字
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];

    self.tableView.refreshControl = self.refreshControl;
}

#pragma mark - Data Loading

// 下拉刷新
- (void)handleRefresh {
    NSLog(@"开始刷新...");
    self.pageNumber = 1;
    [self loadData:NO];
}

// 加载数据（模拟网络请求）
- (void)loadData:(BOOL)isLoadMore {
    // 模拟网络延迟
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (isLoadMore) {
            // 加载更多
            [self loadMoreData];
        } else {
            // 刷新数据
            [self refreshData];
        }

        // 停止刷新动画
        [self.refreshControl endRefreshing];
        self.isLoadingMore = NO;

        // 刷新列表
        [self.tableView reloadData];
    });
}

// 刷新数据（替换所有数据）
- (void)refreshData {
    [self.dataArray removeAllObjects];

    for (int i = 1; i <= 20; i++) {
        NSString *item = [NSString stringWithFormat:@"📰 新闻 %d - %@", i, [self randomTitle]];
        [self.dataArray addObject:item];
    }

    NSLog(@"刷新完成，当前有 %lu 条数据", (unsigned long)self.dataArray.count);
}

// 加载更多数据（追加数据）
- (void)loadMoreData {
    self.pageNumber++;

    NSInteger startIndex = self.dataArray.count + 1;
    for (int i = 0; i < 10; i++) {
        NSString *item = [NSString stringWithFormat:@"📰 新闻 %ld - %@", (long)(startIndex + i), [self randomTitle]];
        [self.dataArray addObject:item];
    }

    NSLog(@"加载更多完成，当前有 %lu 条数据", (unsigned long)self.dataArray.count);
}

// 随机标题（模拟数据）
- (NSString *)randomTitle {
    NSArray *titles = @[
        @"iOS 17 正式发布",
        @"苹果推出新款 iPhone",
        @"SwiftUI 最新教程",
        @"Xcode 15 新特性",
        @"App Store 优化指南",
        @"UIKit 性能优化技巧",
        @"Core Data 使用指南",
        @"网络请求最佳实践",
        @"iOS 设计模式详解",
        @"多线程编程技巧"
    ];

    NSInteger randomIndex = arc4random_uniform((uint32_t)titles.count);
    return titles[randomIndex];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    cell.textLabel.text = self.dataArray[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSString *item = self.dataArray[indexPath.row];
    NSLog(@"点击了：%@", item);
}

// 滚动到底部时加载更多
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 计算距离底部的距离
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat contentHeight = scrollView.contentSize.height;
    CGFloat scrollViewHeight = scrollView.frame.size.height;

    // 距离底部还有 100 点时开始加载
    if (offsetY + scrollViewHeight >= contentHeight - 100) {
        if (!self.isLoadingMore && self.dataArray.count > 0) {
            self.isLoadingMore = YES;
            NSLog(@"开始加载更多...");

            // 显示加载提示
            [self showLoadingFooter];

            // 加载更多数据
            [self loadData:YES];
        }
    }
}

// 显示加载更多的 Footer
- (void)showLoadingFooter {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 50)];

    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    indicator.center = CGPointMake(footerView.bounds.size.width / 2, footerView.bounds.size.height / 2);
    [indicator startAnimating];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, footerView.bounds.size.width, footerView.bounds.size.height)];
    label.text = @"加载中...";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor secondaryLabelColor];
    label.font = [UIFont systemFontOfSize:14];

    [footerView addSubview:label];
    [footerView addSubview:indicator];

    self.tableView.tableFooterView = footerView;

    // 1.5秒后移除 Footer
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.tableView.tableFooterView = nil;
    });
}

@end

