//
//  BasicTableViewController.m
//  TableViewDemo
//
//  基础列表 - 演示最简单的 TableView 使用
//

#import "BasicTableViewController.h"

@interface BasicTableViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *dataArray;
@end

@implementation BasicTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"基础列表";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    // 准备数据
    self.dataArray = @[
        @"苹果 Apple", @"香蕉 Banana", @"樱桃 Cherry",
        @"枣 Date", @"接骨木果 Elderberry", @"无花果 Fig",
        @"葡萄 Grape", @"蜜瓜 Honeydew", @"猕猴桃 Kiwi",
        @"柠檬 Lemon", @"芒果 Mango", @"油桃 Nectarine",
        @"橙子 Orange", @"木瓜 Papaya", @"木瓜 Quince",
        @"覆盆子 Raspberry", @"草莓 Strawberry", @"橘子 Tangerine",
        @"西瓜 Watermelon"
    ];

    [self setupTableView];
}

- (void)setupTableView {
    // 创建 TableView
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    // 注册 Cell
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];

    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource

// 必需方法1：有多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

// 必需方法2：每行显示什么
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    // 配置 cell
    cell.textLabel.text = self.dataArray[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

#pragma mark - UITableViewDelegate

// 可选方法：点击某行
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取消选中效果
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    // 显示提示
    NSString *selectedItem = self.dataArray[indexPath.row];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"你选择了"
                                                                   message:selectedItem
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];

    NSLog(@"点击了第 %ld 行：%@", (long)indexPath.row, selectedItem);
}

// 可选方法：设置行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

@end

