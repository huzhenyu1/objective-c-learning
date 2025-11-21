//
//  CustomCellTableViewController.m
//  TableViewDemo
//
//  自定义 Cell 列表 - 演示如何使用自定义 Cell
//

#import "CustomCellTableViewController.h"
#import "ContactCell.h"

@interface CustomCellTableViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *contacts;
@end

@implementation CustomCellTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"自定义 Cell";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    // 准备联系人数据
    self.contacts = @[
        @{@"name": @"张三", @"phone": @"138-1234-5678", @"company": @"苹果公司"},
        @{@"name": @"李四", @"phone": @"139-2345-6789", @"company": @"谷歌公司"},
        @{@"name": @"王五", @"phone": @"136-3456-7890", @"company": @"微软公司"},
        @{@"name": @"赵六", @"phone": @"137-4567-8901", @"company": @"亚马逊"},
        @{@"name": @"孙七", @"phone": @"135-5678-9012", @"company": @"特斯拉"},
        @{@"name": @"周八", @"phone": @"134-6789-0123", @"company": @"Meta"},
        @{@"name": @"吴九", @"phone": @"133-7890-1234", @"company": @"Netflix"},
        @{@"name": @"郑十", @"phone": @"132-8901-2345", @"company": @"Adobe"},
        @{@"name": @"钱一", @"phone": @"131-9012-3456", @"company": @"阿里巴巴"},
        @{@"name": @"陈二", @"phone": @"130-0123-4567", @"company": @"腾讯"},
        @{@"name": @"林三", @"phone": @"188-1234-5678", @"company": @"字节跳动"},
        @{@"name": @"黄四", @"phone": @"189-2345-6789", @"company": @"百度"},
        @{@"name": @"刘五", @"phone": @"186-3456-7890", @"company": @"京东"},
        @{@"name": @"杨六", @"phone": @"187-4567-8901", @"company": @"美团"}
    ];

    [self setupTableView];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 80;  // 自定义 Cell 高度

    // 注册自定义 Cell
    [self.tableView registerClass:[ContactCell class] forCellReuseIdentifier:@"ContactCell"];

    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 使用自定义 Cell
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell" forIndexPath:indexPath];

    // 获取联系人数据
    NSDictionary *contact = self.contacts[indexPath.row];

    // 配置 Cell
    [cell configureWithName:contact[@"name"]
                      phone:contact[@"phone"]
                    company:contact[@"company"]];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *contact = self.contacts[indexPath.row];

    // 创建详细信息提示
    NSString *message = [NSString stringWithFormat:@"姓名：%@\n电话：%@\n公司：%@",
                        contact[@"name"], contact[@"phone"], contact[@"company"]];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"联系人详情"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    // 添加拨打电话按钮
    [alert addAction:[UIAlertAction actionWithTitle:@"拨打电话"
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"拨打电话：%@", contact[@"phone"]);
    }]];

    // 添加发送短信按钮
    [alert addAction:[UIAlertAction actionWithTitle:@"发送短信"
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"发送短信：%@", contact[@"phone"]);
    }]];

    // 添加取消按钮
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                             style:UIAlertActionStyleCancel
                                           handler:nil]];

    [self presentViewController:alert animated:YES completion:nil];
}

@end

