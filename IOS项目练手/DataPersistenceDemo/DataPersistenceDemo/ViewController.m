//
//  ViewController.m
//  DataPersistenceDemo
//
//  数据持久化示例 - 主菜单
//

#import "ViewController.h"
#import "UserDefaultsViewController.h"
#import "FileOperationViewController.h"
#import "ArchiveViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray<NSDictionary *> *demos;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"数据持久化示例";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    // 配置导航栏样式
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor systemBlueColor];
        appearance.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};

        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }

    // 准备示例数据
    self.demos = @[
        @{@"title": @"📝 NSUserDefaults",
          @"subtitle": @"简单数据存储 - 用户偏好设置",
          @"class": @"UserDefaultsViewController"},

        @{@"title": @"📁 文件操作",
          @"subtitle": @"文本文件读写 - NSFileManager",
          @"class": @"FileOperationViewController"},

        @{@"title": @"💾 归档（Archive）",
          @"subtitle": @"对象序列化 - NSCoding",
          @"class": @"ArchiveViewController"}
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
