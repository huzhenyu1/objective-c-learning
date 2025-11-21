//
//  ProfileViewController.m
//  Read
//
//  个人中心页面
//

#import "ProfileViewController.h"
#import "BookContentManager.h"
#import "BookSourceManager.h"

@interface ProfileViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray<NSArray<NSDictionary *> *> *menuData;
@property (copy, nonatomic) NSString *cacheSizeText;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"个人";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    // 初始化菜单数据
    [self setupMenuData];

    // 创建表格视图
    [self setupTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // 每次进入页面时更新缓存大小
    [self updateCacheSize];
}

- (void)setupMenuData {
    self.menuData = @[
        @[
            @{@"title": @"阅读统计", @"icon": @"📊", @"action": @"showReadingStats"},
            @{@"title": @"阅读时长", @"icon": @"⏱", @"action": @"showReadingTime"},
            @{@"title": @"阅读记录", @"icon": @"📖", @"action": @"showReadingHistory"}
        ],
        @[
            @{@"title": @"字体设置", @"icon": @"🔤", @"action": @"showFontSettings"},
            @{@"title": @"主题设置", @"icon": @"🎨", @"action": @"showThemeSettings"},
            @{@"title": @"阅读设置", @"icon": @"⚙️", @"action": @"showReadingSettings"}
        ],
        @[
            @{@"title": @"书源管理", @"icon": @"📚", @"action": @"showBookSourceSettings"},
            @{@"title": @"清理缓存", @"icon": @"🗑", @"action": @"clearCache", @"detail": @"cacheSizeText"},
            @{@"title": @"关于我们", @"icon": @"ℹ️", @"action": @"showAbout"}
        ]
    ];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 50;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"MenuCell"];
    [self.view addSubview:self.tableView];

    // 添加头部视图
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 150)];
    headerView.backgroundColor = [UIColor systemGroupedBackgroundColor];

    // 头像
    UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectMake((headerView.bounds.size.width - 80) / 2, 30, 80, 80)];
    avatarView.backgroundColor = [UIColor systemGrayColor];
    avatarView.layer.cornerRadius = 40;
    avatarView.clipsToBounds = YES;
    avatarView.contentMode = UIViewContentModeCenter;

    // 添加头像文字
    UILabel *avatarLabel = [[UILabel alloc] initWithFrame:avatarView.bounds];
    avatarLabel.text = @"👤";
    avatarLabel.font = [UIFont systemFontOfSize:40];
    avatarLabel.textAlignment = NSTextAlignmentCenter;
    [avatarView addSubview:avatarLabel];

    [headerView addSubview:avatarView];

    // 用户名
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 120, headerView.bounds.size.width, 20)];
    nameLabel.text = @"读书爱好者";
    nameLabel.font = [UIFont boldSystemFontOfSize:16];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:nameLabel];

    self.tableView.tableHeaderView = headerView;
}

- (void)updateCacheSize {
    unsigned long long size = [[BookContentManager sharedManager] getCacheSize];
    self.cacheSizeText = [BookContentManager formatCacheSize:size];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.menuData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuData[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuCell" forIndexPath:indexPath];

    NSDictionary *item = self.menuData[indexPath.section][indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", item[@"icon"], item[@"title"]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    // 如果是清理缓存，显示缓存大小
    if ([item[@"detail"] isEqualToString:@"cacheSizeText"]) {
        cell.detailTextLabel.text = self.cacheSizeText;
    } else {
        cell.detailTextLabel.text = nil;
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *item = self.menuData[indexPath.section][indexPath.row];
    NSString *action = item[@"action"];

    if (action) {
        SEL selector = NSSelectorFromString(action);
        if ([self respondsToSelector:selector]) {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performSelector:selector];
            #pragma clang diagnostic pop
        }
    }
}

#pragma mark - Actions

- (void)showReadingStats {
    [self showAlert:@"阅读统计" message:@"功能开发中...\n\n将显示：\n- 已读书籍数量\n- 总阅读时长\n- 本周阅读统计"];
}

- (void)showReadingTime {
    [self showAlert:@"阅读时长" message:@"功能开发中...\n\n将显示：\n- 今日阅读时长\n- 本周阅读时长\n- 历史总时长"];
}

- (void)showReadingHistory {
    [self showAlert:@"阅读记录" message:@"功能开发中...\n\n将显示最近阅读的书籍列表"];
}

- (void)showFontSettings {
    [self showAlert:@"字体设置" message:@"功能开发中...\n\n可调整：\n- 字体大小\n- 字体类型\n- 行间距"];
}

- (void)showThemeSettings {
    [self showAlert:@"主题设置" message:@"功能开发中...\n\n可选择：\n- 白天模式\n- 夜间模式\n- 护眼模式"];
}

- (void)showReadingSettings {
    [self showAlert:@"阅读设置" message:@"功能开发中...\n\n可调整：\n- 翻页方式\n- 屏幕亮度\n- 音量键翻页"];
}

- (void)showBookSourceSettings {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"书源管理"
                                                                   message:@"书源功能已集成在「书源」标签页"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *switchAction = [UIAlertAction actionWithTitle:@"前往书源页"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
        // 切换到书源标签
        if ([self.tabBarController isKindOfClass:[UITabBarController class]]) {
            self.tabBarController.selectedIndex = 1; // 书源是第2个标签
        }
    }];

    UIAlertAction *resetAction = [UIAlertAction actionWithTitle:@"重置为默认书源"
                                                         style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction * _Nonnull action) {
        [self resetBookSources];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil];

    [alert addAction:switchAction];
    [alert addAction:resetAction];
    [alert addAction:cancelAction];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)resetBookSources {
    UIAlertController *confirmAlert = [UIAlertController alertControllerWithTitle:@"确认重置"
                                                                           message:@"将删除所有自定义书源，恢复为默认书源"
                                                                    preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * _Nonnull action) {
        BOOL success = [[BookSourceManager sharedManager] resetToDefaultBookSources];
        NSString *message = success ? @"重置成功！" : @"重置失败";
        [self showAlert:@"重置书源" message:message];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil];

    [confirmAlert addAction:cancelAction];
    [confirmAlert addAction:confirmAction];

    [self presentViewController:confirmAlert animated:YES completion:nil];
}

- (void)clearCache {
    unsigned long long size = [[BookContentManager sharedManager] getCacheSize];
    NSString *sizeText = [BookContentManager formatCacheSize:size];

    if (size == 0) {
        [self showAlert:@"清理缓存" message:@"当前没有缓存"];
        return;
    }

    NSString *message = [NSString stringWithFormat:@"当前缓存大小：%@\n\n确定要清空所有缓存吗？", sizeText];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"清理缓存"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *clearAction = [UIAlertAction actionWithTitle:@"清空"
                                                         style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction * _Nonnull action) {
        BOOL success = [[BookContentManager sharedManager] clearAllCache];
        if (success) {
            [self updateCacheSize];
            [self showAlert:@"清理缓存" message:@"缓存已清空"];
        } else {
            [self showAlert:@"清理缓存" message:@"清理失败"];
        }
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil];

    [alert addAction:cancelAction];
    [alert addAction:clearAction];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showAbout {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: @"1.0.0";
    NSString *message = [NSString stringWithFormat:@"Read - 小说阅读器\n\n版本：v%@\n\n功能特性：\n✓ 支持多书源\n✓ 在线阅读\n✓ 本地缓存\n✓ 阅读记录\n\n© 2025 Read Team", version];

    [self showAlert:@"关于我们" message:message];
}

- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                      style:UIAlertActionStyleDefault
                                                    handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end

