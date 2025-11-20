//
//  TableViewDemoViewController.m
//  NavigationDemo
//
//  Created by 胡振宇 on 2025/11/20.
//  UITableView 列表演示
//

#import "TableViewDemoViewController.h"
#import "DetailViewController.h"

@interface TableViewDemoViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *dataArray;
@end

@implementation TableViewDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"列表视图";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    // 准备数据
    self.dataArray = @[
        @{@"title": @"iPhone 15 Pro", @"subtitle": @"钛金属设计"},
        @{@"title": @"iPhone 15", @"subtitle": @"全新配色"},
        @{@"title": @"iPhone 14", @"subtitle": @"强劲性能"},
        @{@"title": @"iPhone 13", @"subtitle": @"超长续航"},
        @{@"title": @"iPhone SE", @"subtitle": @"小巧便携"},
        @{@"title": @"iPad Pro", @"subtitle": @"M2 芯片"},
        @{@"title": @"iPad Air", @"subtitle": @"轻薄设计"},
        @{@"title": @"MacBook Pro", @"subtitle": @"专业之选"},
        @{@"title": @"MacBook Air", @"subtitle": @"轻盈便携"},
        @{@"title": @"Apple Watch", @"subtitle": @"健康助手"}
    ];

    [self setupUI];
}

- (void)setupUI {
    // 创建 TableView
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 60;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDictionary *data = self.dataArray[indexPath.row];
    cell.textLabel.text = data[@"title"];
    cell.detailTextLabel.text = data[@"subtitle"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    // 配置 cell 样式
    cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];

    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    // 跳转到详情页
    NSDictionary *data = self.dataArray[indexPath.row];
    DetailViewController *detailVC = [[DetailViewController alloc] init];
    detailVC.productName = data[@"title"];
    detailVC.productDescription = data[@"subtitle"];

    [self.navigationController pushViewController:detailVC animated:YES];
}

@end

