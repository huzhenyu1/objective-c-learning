//
//  MultiSectionTableViewController.m
//  TableViewDemo
//
//  多 Section 列表 - 演示分组、Header、Footer
//

#import "MultiSectionTableViewController.h"

@interface MultiSectionTableViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *sectionTitles;  // Section 标题
@property (strong, nonatomic) NSArray *sectionData;    // 每个 Section 的数据
@end

@implementation MultiSectionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"多 Section 列表";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    // 准备数据
    self.sectionTitles = @[@"📱 数码产品", @"👕 服装鞋帽", @"🍎 食品饮料", @"📚 图书音像"];
    self.sectionData = @[
        @[@"iPhone 15 Pro", @"iPad Air", @"MacBook Pro", @"Apple Watch", @"AirPods Pro"],
        @[@"T恤", @"牛仔裤", @"运动鞋", @"帽子", @"围巾", @"手套"],
        @[@"苹果", @"香蕉", @"牛奶", @"咖啡", @"饼干", @"巧克力", @"薯片"],
        @[@"iOS 编程", @"设计模式", @"算法导论", @"人工智能"]
    ];

    [self setupTableView];
}

- (void)setupTableView {
    // 使用 Grouped 样式
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];

    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource

// 有多少个 Section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionTitles.count;
}

// 每个 Section 有多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *items = self.sectionData[section];
    return items.count;
}

// 每行显示什么
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    // 获取对应数据
    NSArray *items = self.sectionData[indexPath.section];
    cell.textLabel.text = items[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDetailButton;

    return cell;
}

// Section 的标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sectionTitles[section];
}

// Section 的底部文字（可选）
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSArray *items = self.sectionData[section];
    return [NSString stringWithFormat:@"共 %ld 件商品", (long)items.count];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSArray *items = self.sectionData[indexPath.section];
    NSString *item = items[indexPath.row];
    NSString *category = self.sectionTitles[indexPath.section];

    NSString *message = [NSString stringWithFormat:@"分类：%@\n商品：%@", category, item];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"商品信息"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

// 自定义 Header 高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

// 自定义 Footer 高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 30;
}

// 自定义 Header 视图（更灵活的方式）
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 50)];
    headerView.backgroundColor = [UIColor systemGray6Color];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, tableView.bounds.size.width - 30, 50)];
    titleLabel.text = self.sectionTitles[section];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.textColor = [UIColor systemBlueColor];

    [headerView addSubview:titleLabel];

    return headerView;
}

@end

