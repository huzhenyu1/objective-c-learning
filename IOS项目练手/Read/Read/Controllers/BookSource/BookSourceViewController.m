//
//  BookSourceViewController.m
//  Read
//
//  书源管理页面
//

#import "BookSourceViewController.h"
#import "BookSourceManager.h"
#import "BookSource.h"

@interface BookSourceViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray<BookSource *> *bookSources;
@end

@implementation BookSourceViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"书源";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    // 设置导航栏按钮
    [self setupNavigationBar];

    // 创建表格视图
    [self setupTableView];

    // 加载书源数据
    [self loadBookSources];
}

- (void)setupNavigationBar {
    // 添加按钮
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(addButtonTapped)];

    // 导入按钮
    UIBarButtonItem *importButton = [[UIBarButtonItem alloc] initWithTitle:@"导入"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(importButtonTapped)];

    self.navigationItem.rightBarButtonItems = @[addButton, importButton];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 80;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"BookSourceCell"];
    [self.view addSubview:self.tableView];
}

- (void)loadBookSources {
    self.bookSources = [[BookSourceManager sharedManager] allBookSources];
    [self.tableView reloadData];

}

#pragma mark - Button Actions

- (void)addButtonTapped {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"添加书源"
                                                                   message:@"请输入书源 JSON"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"粘贴书源 JSON 数据";
    }];

    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
        NSString *jsonString = alert.textFields.firstObject.text;
        [self importJSONString:jsonString];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil];

    [alert addAction:cancelAction];
    [alert addAction:confirmAction];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)importButtonTapped {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"导入书源"
                                                                   message:@"选择导入方式"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *jsonAction = [UIAlertAction actionWithTitle:@"从 JSON 导入"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
        [self showImportJSONAlert];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil];

    [alert addAction:jsonAction];
    [alert addAction:cancelAction];

    // iPad 需要设置 popover
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        alert.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItems[1];
    }

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showImportJSONAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"导入 JSON"
                                                                   message:@"粘贴书源 JSON 数组\n支持单个书源或多个书源"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"粘贴 JSON 数据";
    }];

    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"导入"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
        NSString *jsonString = alert.textFields.firstObject.text;
        [self importJSONString:jsonString];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil];

    [alert addAction:cancelAction];
    [alert addAction:confirmAction];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)importJSONString:(NSString *)jsonString {
    if (!jsonString || jsonString.length == 0) {
        [self showMessage:@"JSON 数据为空"];
        return;
    }

    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

    if (error) {
        [self showMessage:[NSString stringWithFormat:@"JSON 解析失败: %@", error.localizedDescription]];
        return;
    }

    BOOL success = NO;
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        // 单个书源
        BookSource *source = [BookSource bookSourceFromJSON:jsonObject];
        success = [[BookSourceManager sharedManager] addBookSource:source];
    } else if ([jsonObject isKindOfClass:[NSArray class]]) {
        // 多个书源
        success = [[BookSourceManager sharedManager] importBookSourcesFromJSONArray:jsonObject];
    } else {
        [self showMessage:@"无效的 JSON 格式"];
        return;
    }

    if (success) {
        [self loadBookSources];
        [self showMessage:@"导入成功"];
    } else {
        [self showMessage:@"导入失败"];
    }
}

- (void)showMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                      style:UIAlertActionStyleDefault
                                                    handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // 按分组显示，过滤掉 NSNull 对象
    NSMutableSet *groups = [NSMutableSet set];
    for (BookSource *source in self.bookSources) {
        NSString *group = source.bookSourceGroup;
        if (group && ![group isKindOfClass:[NSNull class]] && group.length > 0) {
            [groups addObject:group];
        }
    }
    return groups.count > 0 ? groups.count : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *groups = [self getValidGroups];
    if (section < groups.count) {
        NSString *group = groups[section];
        return [[BookSourceManager sharedManager] bookSourcesInGroup:group].count;
    }
    return self.bookSources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BookSourceCell" forIndexPath:indexPath];

    NSArray *groups = [self getValidGroups];
    NSArray<BookSource *> *sourcesInSection = self.bookSources;

    if (indexPath.section < groups.count) {
        NSString *group = groups[indexPath.section];
        sourcesInSection = [[BookSourceManager sharedManager] bookSourcesInGroup:group];
    }

    if (indexPath.row < sourcesInSection.count) {
        BookSource *source = sourcesInSection[indexPath.row];

        // 配置 cell
        cell.textLabel.text = source.bookSourceName ?: @"未知书源";
        NSString *url = source.bookSourceUrl ?: @"无URL";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ | %@",
                                     url,
                                     source.enabled ? @"已启用" : @"已禁用"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        // 根据启用状态设置文字颜色
        cell.textLabel.textColor = source.enabled ? [UIColor labelColor] : [UIColor secondaryLabelColor];
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *groups = [self getValidGroups];
    if (section < groups.count) {
        return groups[section];
    }
    return @"书源列表";
}

// 辅助方法：获取有效的分组列表（过滤 NSNull）
- (NSArray<NSString *> *)getValidGroups {
    NSMutableSet *groups = [NSMutableSet set];
    for (BookSource *source in self.bookSources) {
        NSString *group = source.bookSourceGroup;
        if (group && ![group isKindOfClass:[NSNull class]] && group.length > 0) {
            [groups addObject:group];
        }
    }
    return [groups allObjects];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSArray *groups = [self getValidGroups];
    NSArray<BookSource *> *sourcesInSection = self.bookSources;

    if (indexPath.section < groups.count) {
        NSString *group = groups[indexPath.section];
        sourcesInSection = [[BookSourceManager sharedManager] bookSourcesInGroup:group];
    }

    if (indexPath.row < sourcesInSection.count) {
        BookSource *source = sourcesInSection[indexPath.row];
        [self showBookSourceDetail:source];
    }
}

- (void)showBookSourceDetail:(BookSource *)source {
    NSString *message = [NSString stringWithFormat:@"名称: %@\nURL: %@\n分组: %@\n备注: %@\n状态: %@",
                        source.bookSourceName ?: @"未知",
                        source.bookSourceUrl ?: @"无",
                        source.bookSourceGroup ?: @"未分组",
                        source.bookSourceComment ?: @"无",
                        source.enabled ? @"已启用" : @"已禁用"];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"书源详情"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    // 切换启用状态按钮
    NSString *toggleTitle = source.enabled ? @"禁用" : @"启用";
    UIAlertAction *toggleAction = [UIAlertAction actionWithTitle:toggleTitle
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
        source.enabled = !source.enabled;
        [[BookSourceManager sharedManager] updateBookSource:source];
        [self loadBookSources];
        [self showMessage:[NSString stringWithFormat:@"已%@书源", source.enabled ? @"启用" : @"禁用"]];
    }];

    // 删除按钮
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除"
                                                          style:UIAlertActionStyleDestructive
                                                        handler:^(UIAlertAction * _Nonnull action) {
        [[BookSourceManager sharedManager] removeBookSource:source];
        [self loadBookSources];
        [self showMessage:@"已删除书源"];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"关闭"
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil];

    [alert addAction:toggleAction];
    [alert addAction:deleteAction];
    [alert addAction:cancelAction];

    [self presentViewController:alert animated:YES completion:nil];
}

// 支持左滑删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *groups = [self getValidGroups];
        NSArray<BookSource *> *sourcesInSection = self.bookSources;

        if (indexPath.section < groups.count) {
            NSString *group = groups[indexPath.section];
            sourcesInSection = [[BookSourceManager sharedManager] bookSourcesInGroup:group];
        }

        if (indexPath.row < sourcesInSection.count) {
            BookSource *source = sourcesInSection[indexPath.row];
            [[BookSourceManager sharedManager] removeBookSource:source];
            [self loadBookSources];
        }
    }
}

@end
