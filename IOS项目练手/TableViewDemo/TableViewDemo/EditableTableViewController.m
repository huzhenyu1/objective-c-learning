//
//  EditableTableViewController.m
//  TableViewDemo
//
//  可编辑列表 - 演示增删改、重排序功能
//

#import "EditableTableViewController.h"

@interface EditableTableViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) UIBarButtonItem *editButton;
@property (strong, nonatomic) UIBarButtonItem *addButton;
@end

@implementation EditableTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"可编辑列表";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    // 准备数据（使用可变数组）
    self.dataArray = [NSMutableArray arrayWithArray:@[
        @"📝 学习 iOS 开发",
        @"💻 完成项目代码",
        @"📖 阅读技术书籍",
        @"🏃‍♂️ 每天跑步",
        @"🎵 练习吉他",
        @"🍳 学做新菜"
    ]];

    [self setupNavigationBar];
    [self setupTableView];
}

- (void)setupNavigationBar {
    // 添加按钮
    self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                   target:self
                                                                   action:@selector(addItem)];

    // 编辑/完成按钮
    self.editButton = [[UIBarButtonItem alloc] initWithTitle:@"编辑"
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(toggleEdit)];

    self.navigationItem.rightBarButtonItems = @[self.editButton, self.addButton];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];

    [self.view addSubview:self.tableView];
}

#pragma mark - Actions

// 切换编辑模式
- (void)toggleEdit {
    BOOL isEditing = !self.tableView.isEditing;
    [self.tableView setEditing:isEditing animated:YES];

    self.editButton.title = isEditing ? @"完成" : @"编辑";
    self.addButton.enabled = !isEditing;  // 编辑模式下禁用添加按钮
}

// 添加新项
- (void)addItem {
    // 创建输入框提示
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"添加新任务"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入任务内容";
    }];

    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                             style:UIAlertActionStyleCancel
                                           handler:nil]];

    [alert addAction:[UIAlertAction actionWithTitle:@"添加"
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = alert.textFields.firstObject;
        NSString *newItem = textField.text;

        if (newItem.length > 0) {
            // 添加到数据源
            [self.dataArray insertObject:newItem atIndex:0];

            // 更新 TableView（带动画）
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    cell.textLabel.text = self.dataArray[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:17];

    return cell;
}

// 是否可以编辑（删除）
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// 提交编辑（删除/插入）
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // 从数据源删除
        [self.dataArray removeObjectAtIndex:indexPath.row];

        // 更新 TableView
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

        NSLog(@"删除了第 %ld 行", (long)indexPath.row);
    }
}

// 是否可以移动（重排序）
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// 移动行（重排序）
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    // 更新数据源
    NSString *movedItem = self.dataArray[sourceIndexPath.row];
    [self.dataArray removeObjectAtIndex:sourceIndexPath.row];
    [self.dataArray insertObject:movedItem atIndex:destinationIndexPath.row];

    NSLog(@"从第 %ld 行移动到第 %ld 行", (long)sourceIndexPath.row, (long)destinationIndexPath.row);
}

// 自定义删除按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    // 非编辑模式下才能选中
    if (!tableView.isEditing) {
        NSString *item = self.dataArray[indexPath.row];
        NSLog(@"选中了：%@", item);
    }
}

// 自定义编辑样式（默认是删除，也可以是插入）
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

@end

