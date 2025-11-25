//
//  ProfileViewController.m
//  Read
//
//  个人中心页面
//

#import "ProfileViewController.h"
#import "BookContentManager.h"
#import "BookSourceManager.h"
#import "ReadingStatsManager.h"

@interface ProfileViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray<NSArray<NSDictionary *> *> *menuData;
@property (copy, nonatomic) NSString *cacheSizeText;

// ⭐ 阅读设置相关
@property (assign, nonatomic) CGFloat currentFontSize;
@property (copy, nonatomic) NSString *currentTheme;
@property (assign, nonatomic) BOOL isNightMode;
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
    ReadingStatsManager *manager = [ReadingStatsManager sharedManager];

    NSInteger booksCount = [manager getReadBooksCount];
    NSInteger chaptersCount = [manager getReadChaptersCount];
    NSInteger todayWords = [manager getTodayReadingWords];
    NSInteger todayDuration = [manager getTodayReadingDuration];
    NSInteger weekDuration = [manager getThisWeekReadingDuration];

    NSString *message = [NSString stringWithFormat:
                        @"📚 已读书籍：%ld 本\n"
                        @"📖 已读章节：%ld 章\n"
                        @"📝 今日阅读：%@ 字\n"
                        @"⏱ 今日时长：%@\n"
                        @"📊 本周时长：%@",
                        (long)booksCount,
                        (long)chaptersCount,
                        [self formatNumber:todayWords],
                        [self formatDuration:todayDuration],
                        [self formatDuration:weekDuration]];

    [self showAlert:@"阅读统计" message:message];
}

- (void)showReadingTime {
    ReadingStatsManager *manager = [ReadingStatsManager sharedManager];

    NSInteger todayDuration = [manager getTodayReadingDuration];
    NSInteger weekDuration = [manager getThisWeekReadingDuration];
    NSInteger totalDuration = [manager getTotalReadingDuration];

    NSString *message = [NSString stringWithFormat:
                        @"今日阅读时长\n%@\n\n"
                        @"本周阅读时长\n%@\n\n"
                        @"历史总时长\n%@\n\n"
                        @"继续加油！ 📖",
                        [self formatDuration:todayDuration],
                        [self formatDuration:weekDuration],
                        [self formatDuration:totalDuration]];

    [self showAlert:@"阅读时长" message:message];
}

- (void)showReadingHistory {
    ReadingStatsManager *manager = [ReadingStatsManager sharedManager];
    NSArray<ReadingRecord *> *records = [manager getRecentReadingRecords];

    if (records.count == 0) {
        [self showAlert:@"阅读记录" message:@"暂无阅读记录\n\n开始阅读书籍后，这里会显示您的阅读历史"];
        return;
    }

    NSMutableString *message = [NSMutableString stringWithString:@"最近阅读记录：\n\n"];

    NSInteger count = MIN(10, records.count);
    for (NSInteger i = 0; i < count; i++) {
        ReadingRecord *record = records[i];
        NSString *timeStr = [self formatRelativeTime:record.readTime];
        [message appendFormat:@"📖 %@\n   %@ · %@\n\n",
         record.bookTitle,
         record.chapterName,
         timeStr];
    }

    [self showAlert:@"阅读记录" message:message];
}

- (void)showFontSettings {
    self.currentFontSize = [[NSUserDefaults standardUserDefaults] floatForKey:@"ReadingFontSize"];
    if (self.currentFontSize <= 0) {
        self.currentFontSize = 17.0;
    }

    UIAlertController *fontAlert = [UIAlertController alertControllerWithTitle:@"字体设置"
                                                                       message:@"\n\n\n"
                                                                preferredStyle:UIAlertControllerStyleAlert];

    // 添加 UISlider
    UISlider *fontSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 50, 230, 30)];
    fontSlider.minimumValue = 12.0;
    fontSlider.maximumValue = 30.0;
    fontSlider.value = self.currentFontSize;
    fontSlider.continuous = YES;
    [fontSlider addTarget:self action:@selector(fontSizeChangedInProfile:) forControlEvents:UIControlEventValueChanged];
    [fontAlert.view addSubview:fontSlider];

    // 显示当前字号
    UILabel *sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 85, 230, 30)];
    sizeLabel.text = [NSString stringWithFormat:@"%.0f pt", fontSlider.value];
    sizeLabel.textAlignment = NSTextAlignmentCenter;
    sizeLabel.tag = 999;
    [fontAlert.view addSubview:sizeLabel];

    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setFloat:fontSlider.value forKey:@"ReadingFontSize"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self showAlert:@"字体设置" message:[NSString stringWithFormat:@"字体大小已设置为 %.0f pt\n\n下次阅读时生效", fontSlider.value]];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];

    [fontAlert addAction:cancelAction];
    [fontAlert addAction:confirmAction];

    [self presentViewController:fontAlert animated:YES completion:nil];
}

- (void)fontSizeChangedInProfile:(UISlider *)slider {
    UILabel *sizeLabel = (UILabel *)[slider.superview viewWithTag:999];
    if (sizeLabel) {
        sizeLabel.text = [NSString stringWithFormat:@"%.0f pt", slider.value];
    }
}

- (void)showThemeSettings {
    UIAlertController *themeAlert = [UIAlertController alertControllerWithTitle:@"主题设置"
                                                                         message:nil
                                                                  preferredStyle:UIAlertControllerStyleActionSheet];

    // 预设主题选项
    NSArray *themes = @[
        @{@"name": @"默认白色", @"value": @"white"},
        @{@"name": @"护眼绿", @"value": @"green"},
        @{@"name": @"羊皮纸", @"value": @"parchment"},
        @{@"name": @"浅灰色", @"value": @"gray"}
    ];

    NSString *currentTheme = [[NSUserDefaults standardUserDefaults] stringForKey:@"ReadingBackgroundColor"] ?: @"white";

    for (NSDictionary *theme in themes) {
        BOOL isCurrentTheme = [currentTheme isEqualToString:theme[@"value"]];
        NSString *title = isCurrentTheme ? [NSString stringWithFormat:@"✓ %@", theme[@"name"]] : theme[@"name"];

        UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[NSUserDefaults standardUserDefaults] setObject:theme[@"value"] forKey:@"ReadingBackgroundColor"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self showAlert:@"主题设置" message:[NSString stringWithFormat:@"主题已设置为「%@」\n\n下次阅读时生效", theme[@"name"]]];
        }];
        [themeAlert addAction:action];
    }

    // 夜间模式
    BOOL isNightMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"ReadingNightMode"];
    NSString *nightModeTitle = isNightMode ? @"✓ 夜间模式" : @"夜间模式";
    UIAlertAction *nightModeAction = [UIAlertAction actionWithTitle:nightModeTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        BOOL newMode = !isNightMode;
        [[NSUserDefaults standardUserDefaults] setBool:newMode forKey:@"ReadingNightMode"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        NSString *msg = newMode ? @"夜间模式已开启 🌙\n\n下次阅读时生效" : @"夜间模式已关闭 ☀️\n\n下次阅读时生效";
        [self showAlert:@"主题设置" message:msg];
    }];
    [themeAlert addAction:nightModeAction];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [themeAlert addAction:cancelAction];

    [self presentViewController:themeAlert animated:YES completion:nil];
}

- (void)showReadingSettings {
    UIAlertController *settingsAlert = [UIAlertController alertControllerWithTitle:@"阅读设置"
                                                                           message:@"可在阅读界面点击工具栏「⚙️ 设置」进行调整"
                                                                    preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil];
    [settingsAlert addAction:okAction];

    [self presentViewController:settingsAlert animated:YES completion:nil];
}

#pragma mark - Helper Methods

- (NSString *)formatDuration:(NSInteger)seconds {
    if (seconds == 0) {
        return @"0 分钟";
    }

    NSInteger hours = seconds / 3600;
    NSInteger minutes = (seconds % 3600) / 60;

    if (hours > 0) {
        return [NSString stringWithFormat:@"%ld 小时 %ld 分钟", (long)hours, (long)minutes];
    } else {
        return [NSString stringWithFormat:@"%ld 分钟", (long)minutes];
    }
}

- (NSString *)formatNumber:(NSInteger)number {
    if (number >= 10000) {
        return [NSString stringWithFormat:@"%.1f 万", number / 10000.0];
    } else {
        return [NSString stringWithFormat:@"%ld", (long)number];
    }
}

- (NSString *)formatRelativeTime:(NSDate *)date {
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:date];

    if (interval < 60) {
        return @"刚刚";
    } else if (interval < 3600) {
        return [NSString stringWithFormat:@"%ld 分钟前", (long)(interval / 60)];
    } else if (interval < 86400) {
        return [NSString stringWithFormat:@"%ld 小时前", (long)(interval / 3600)];
    } else if (interval < 604800) {
        return [NSString stringWithFormat:@"%ld 天前", (long)(interval / 86400)];
    } else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM-dd";
        return [formatter stringFromDate:date];
    }
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

