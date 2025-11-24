//
//  ViewController.m
//  MultithreadingDemo
//
//  多线程示例 - 主菜单
//

#import "ViewController.h"
#import "GCDBasicViewController.h"
#import "GCDAdvancedViewController.h"
#import "NSOperationViewController.h"
#import "ThreadSafetyViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray<NSDictionary *> *demos;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"多线程示例";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    // 配置导航栏样式
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor systemPurpleColor];
        appearance.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};

        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }

    // 准备示例数据
    self.demos = @[
        @{@"title": @"⚡️ GCD 基础",
          @"subtitle": @"dispatch_async, dispatch_sync, 主队列",
          @"class": @"GCDBasicViewController"},

        @{@"title": @"🔀 GCD 高级",
          @"subtitle": @"串行队列、并行队列、dispatch_group",
          @"class": @"GCDAdvancedViewController"},

        @{@"title": @"🎯 NSOperation",
          @"subtitle": @"NSOperationQueue, 依赖关系, 取消操作",
          @"class": @"NSOperationViewController"},

        @{@"title": @"🔒 线程安全",
          @"subtitle": @"竞态条件、@synchronized、NSLock",
          @"class": @"ThreadSafetyViewController"}
    ];

    [self setupTableView];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                                   style:UITableViewStyleInsetGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.demos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    NSDictionary *demo = self.demos[indexPath.row];
    cell.textLabel.text = demo[@"title"];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
    cell.detailTextLabel.text = demo[@"subtitle"];
    cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *demo = self.demos[indexPath.row];
    NSString *className = demo[@"class"];

    Class vcClass = NSClassFromString(className);
    if (vcClass) {
        UIViewController *vc = [[vcClass alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

@end
