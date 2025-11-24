//
//  ViewController.m
//  DesignPatternsDemo
//
//  设计模式演示 - 主菜单
//

#import "ViewController.h"
#import "MVCViewController.h"
#import "DelegateViewController.h"
#import "NotificationViewController.h"
#import "SingletonViewController.h"
#import "ObserverViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray<NSDictionary *> *dataSources;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"iOS 设计模式演示";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupData];
    [self setupTableView];
}

- (void)setupData {
    self.dataSources = @[
        @{@"title": @"🏗️ MVC 模式", @"subtitle": @"Model-View-Controller 架构", @"class": [MVCViewController class]},
        @{@"title": @"🤝 Delegate 委托", @"subtitle": @"协议和代理模式", @"class": [DelegateViewController class]},
        @{@"title": @"📢 Notification 通知", @"subtitle": @"观察者模式 - 一对多通信", @"class": [NotificationViewController class]},
        @{@"title": @"👁️ KVO 观察", @"subtitle": @"键值观察 - 属性变化监听", @"class": [ObserverViewController class]},
        @{@"title": @"🔒 Singleton 单例", @"subtitle": @"全局共享实例", @"class": [SingletonViewController class]}
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"点击查看各种设计模式的实现";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"这些设计模式是 iOS 开发的核心，贯穿整个应用开发过程。";
}

@end
