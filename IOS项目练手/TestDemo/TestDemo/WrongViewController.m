//
//  WrongViewController.m
//  TestDemo
//
//  ❌ 错误做法：在 viewDidAppear 中设置自动高度和约束
//

#import "WrongViewController.h"
#import "BookCell.h"

@interface WrongViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *bookTitles;
@property (assign, nonatomic) BOOL hasSetupConstraints;
@end

@implementation WrongViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"❌ 错误做法";
    self.view.backgroundColor = [UIColor whiteColor];

    // 准备测试数据
    self.bookTitles = [NSMutableArray arrayWithArray:@[
        @"短标题",
        @"这是一个比较长的书名，会需要换行显示的那种",
        @"三体",
        @"三体：地球往事三部曲之一，雨果奖获奖作品，刘慈欣代表作，中国科幻文学里程碑之作，讲述了人类文明与三体文明的第一次接触",
        @"活着",
        @"流浪地球：刘慈欣短篇科幻小说集，包含多个脑洞大开的科幻故事，探讨人类文明的未来与宇宙的终极奥秘"
    ]];

    // ⚠️ 注意：这里只创建 TableView，不设置自动高度
    [self setupTableView];

    // 添加修改按钮
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"切换文本"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(onToggleText)];
    self.navigationItem.rightBarButtonItem = editButton;
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;

    // ⚠️ 注意：这里故意不设置自动高度
    // 模拟初始化时没有配置的情况

    [self.view addSubview:self.tableView];

    // ⚠️ 注意：这里不调用 setupConstraints
}

// ❌❌❌ 错误做法：在 viewDidAppear 中设置
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    NSLog(@"⚠️ viewDidAppear 开始执行");

    // ❌ 错误1：在用户已经看到界面后设置自动高度
    self.tableView.estimatedRowHeight = CELL_HEIGHT;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    NSLog(@"⚠️ 设置了自动高度配置");

    // ❌ 错误2：在用户已经看到界面后设置约束
    [self setupConstraints];

    NSLog(@"⚠️ 设置了约束");

    // 刷新 TableView（用户会看到跳动）
    [self.tableView reloadData];

    NSLog(@"⚠️ viewDidAppear 执行完成");
}

- (void)setupConstraints {
    // 防止重复添加约束
    if (self.hasSetupConstraints) {
        NSLog(@"⚠️ 约束已存在，跳过");
        return;
    }

    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];

    self.hasSetupConstraints = YES;
}

- (void)onToggleText {
    // 切换第一行的文本
    if ([self.bookTitles[0] isEqualToString:@"短标题"]) {
        self.bookTitles[0] = @"这是一个很长很长很长很长很长的标题，需要多行显示才能看完全部内容";
    } else {
        self.bookTitles[0] = @"短标题";
    }

    // 刷新数据
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.bookTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"BookCell";
    BookCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];

    if (!cell) {
        cell = [[BookCell alloc] initWithStyle:UITableViewCellStyleDefault
                                reuseIdentifier:ID];
    }

    cell.bookTitle = self.bookTitles[indexPath.row];

    return cell;
}

// ❌ 错误做法：手动计算高度（模拟复杂场景）
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (self.tableView.rowHeight == UITableViewAutomaticDimension) {

        NSLog(@"⚠️ 正在手动计算 Cell 高度...");

        // 获取 tableView 的实际宽度
        CGFloat tableViewWidth = tableView.bounds.size.width;

        // ⚠️ 使用单例 Cell 进行高度计算（性能开销）
        static BookCell *sizingCell = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sizingCell = [[BookCell alloc] initWithStyle:UITableViewCellStyleDefault
                                         reuseIdentifier:nil];
            NSLog(@"⚠️ 创建了 sizingCell 用于高度计算");
        });

        // 填充数据
        NSString *title = self.bookTitles[indexPath.row];
        sizingCell.bookTitle = title;

        // ⚠️ 手动计算实际高度（systemLayoutSizeFittingSize 调用成本高）
        CGSize size = [sizingCell systemLayoutSizeFittingSize:CGSizeMake(tableViewWidth, 0)
                                  withHorizontalFittingPriority:UILayoutPriorityRequired
                                        verticalFittingPriority:UILayoutPriorityFittingSizeLevel];

        CGFloat calculatedHeight = (size.height > CELL_HEIGHT ? size.height : CELL_HEIGHT);

        NSLog(@"⚠️ 第 %ld 行计算高度: %.2f", (long)indexPath.row, calculatedHeight);

        return calculatedHeight;
    }

    return CELL_HEIGHT;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"❌ 错误做法演示";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"注意：当你进入这个页面时，会看到界面跳动\n因为自动高度配置在 viewDidAppear 中设置，此时用户已经看到界面了\n点击右上角「切换文本」按钮测试动态更新";
}

@end

