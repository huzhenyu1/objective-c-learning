//
//  ViewController.m
//  CommonControlsDemo
//
//  常用控件演示 - 主菜单
//

#import "ViewController.h"
#import "TextFieldViewController.h"
#import "TextViewViewController.h"
#import "ScrollViewViewController.h"
#import "AlertViewController.h"
#import "OtherControlsViewController.h"
#import "FormViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray<NSDictionary *> *dataSources;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"常用控件演示";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupData];
    [self setupTableView];
}

- (void)setupData {
    self.dataSources = @[
        @{@"title": @"📝 UITextField", @"subtitle": @"文本输入框 - 单行文本输入", @"class": [TextFieldViewController class]},
        @{@"title": @"📄 UITextView", @"subtitle": @"多行文本编辑 - 长文本输入", @"class": [TextViewViewController class]},
        @{@"title": @"📜 UIScrollView", @"subtitle": @"滚动视图 - 滚动、缩放、分页", @"class": [ScrollViewViewController class]},
        @{@"title": @"⚠️ UIAlertController", @"subtitle": @"提示框 - Alert 和 ActionSheet", @"class": [AlertViewController class]},
        @{@"title": @"🎛️ 其他控件", @"subtitle": @"Switch, Slider, Picker, Progress", @"class": [OtherControlsViewController class]},
        @{@"title": @"📋 综合表单", @"subtitle": @"实战：用户信息表单", @"class": [FormViewController class]}
    ];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDictionary *item = self.dataSources[indexPath.row];
    cell.textLabel.text = item[@"title"];
    cell.detailTextLabel.text = item[@"subtitle"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *item = self.dataSources[indexPath.row];
    Class targetClass = item[@"class"];

    if (targetClass && [targetClass isSubclassOfClass:[UIViewController class]]) {
        UIViewController *vc = [[targetClass alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
