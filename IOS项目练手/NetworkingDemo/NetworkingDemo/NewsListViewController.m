//
//  NewsListViewController.m
//  NetworkingDemo
//
//  新闻列表 - 综合示例（GET 请求 + JSON 解析 + TableView）
//

#import "NewsListViewController.h"
#import "NewsModel.h"
#import "NewsCell.h"

@interface NewsListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray<NewsModel *> *newsArray;
@property (assign, nonatomic) BOOL isLoading;
@end

@implementation NewsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"新闻列表";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    self.newsArray = [NSMutableArray array];
    self.isLoading = NO;

    [self setupTableView];
    [self loadNews];  // 首次加载
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 90;

    // 注册 Cell
    [self.tableView registerClass:[NewsCell class] forCellReuseIdentifier:@"NewsCell"];

    // 添加下拉刷新
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(handleRefresh) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = self.refreshControl;

    [self.view addSubview:self.tableView];
}

- (void)handleRefresh {
    [self loadNews];
}

- (void)loadNews {
    if (self.isLoading) {
        return;
    }

    self.isLoading = YES;

    // 创建 URL（使用 JSONPlaceholder 测试 API）
    NSString *urlString = @"https://jsonplaceholder.typicode.com/posts";
    NSURL *url = [NSURL URLWithString:urlString];

    // 创建请求
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    // 创建 session
    NSURLSession *session = [NSURLSession sharedSession];

    // 创建任务
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isLoading = NO;
            [self.refreshControl endRefreshing];

            if (error) {
                [self showError:error.localizedDescription];
                return;
            }

            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode != 200) {
                [self showError:[NSString stringWithFormat:@"HTTP 错误：%ld", (long)httpResponse.statusCode]];
                return;
            }

            // 解析 JSON
            NSError *jsonError;
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];

            if (jsonError) {
                [self showError:@"JSON 解析失败"];
                return;
            }

            // 转换为模型
            [self.newsArray removeAllObjects];
            for (NSDictionary *dict in jsonArray) {
                NewsModel *news = [NewsModel modelWithDictionary:dict];
                [self.newsArray addObject:news];

                // 只加载前 20 条
                if (self.newsArray.count >= 20) {
                    break;
                }
            }

            // 刷新列表
            [self.tableView reloadData];

            NSLog(@"✅ 加载了 %lu 条新闻", (unsigned long)self.newsArray.count);
        });
    }];

    [task resume];
    NSLog(@"📡 开始加载新闻...");
}

- (void)showError:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"加载失败"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self loadNews];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.newsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsCell" forIndexPath:indexPath];

    NewsModel *news = self.newsArray[indexPath.row];
    [cell configureWithNews:news];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NewsModel *news = self.newsArray[indexPath.row];

    // 显示详情
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:news.title
                                                                   message:news.content
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (self.newsArray.count == 0 && !self.isLoading) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 100)];
        label.text = @"下拉刷新加载数据";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor secondaryLabelColor];
        return label;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.newsArray.count == 0 && !self.isLoading) {
        return 100;
    }
    return 0;
}

@end

