//
//  ViewController.m
//  TestDemo
//
//  自动高度对比演示 - 主菜单
//

#import "ViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *menuItems;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"自动高度对比演示";
    self.view.backgroundColor = [UIColor whiteColor];

    // 菜单选项
    self.menuItems = @[
        @"❌ 错误做法 (viewDidAppear)",
        @"✅ 正确做法 (viewDidLoad)"
    ];

    [self setupTableView];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                                   style:UITableViewStyleInsetGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:ID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    cell.textLabel.text = self.menuItems[indexPath.row];

    if (indexPath.row == 0) {
        cell.detailTextLabel.text = @"你会看到界面跳动（不推荐）";
        cell.detailTextLabel.textColor = [UIColor systemRedColor];
    } else {
        cell.detailTextLabel.text = @"界面流畅自然（推荐）";
        cell.detailTextLabel.textColor = [UIColor systemGreenColor];
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UIViewController *vc = nil;

    if (indexPath.row == 0) {
        // 错误做法
        vc = [[NSClassFromString(@"WrongViewController") alloc] init];
    } else {
        // 正确做法
        vc = [[NSClassFromString(@"CorrectViewController") alloc] init];
    }

    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"请点击查看两种实现方式的区别";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"注意观察页面切换时的动画效果\n错误做法会看到界面跳动\n正确做法则流畅自然";
}

@end
