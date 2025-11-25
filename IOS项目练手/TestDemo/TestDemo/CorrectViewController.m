//
//  CorrectViewController.m
//  TestDemo
//
//  ✅ 正确做法：在 viewDidLoad 中设置自动高度和约束
//

#import "CorrectViewController.h"
#import "BookCell.h"

@interface CorrectViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *bookTitles;
@end

@implementation CorrectViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"✅ 正确做法";
    self.view.backgroundColor = [UIColor whiteColor];

    // 准备测试数据（与错误做法相同的数据）
    self.bookTitles = [NSMutableArray arrayWithArray:@[
        @"短标题",
        @"这是一个比较长的书名，会需要换行显示的那种",
        @"三体",
        @"三体：地球往事三部曲之一，雨果奖获奖作品，刘慈欣代表作，中国科幻文学里程碑之作，讲述了人类文明与三体文明的第一次接触",
        @"活着",
        @"流浪地球：刘慈欣短篇科幻小说集，包含多个脑洞大开的科幻故事，探讨人类文明的未来与宇宙的终极奥秘"
    ]];

    // ✅ 正确：在 viewDidLoad 中完成所有初始化
    [self setupTableView];
    [self setupConstraints];

    // 添加修改按钮
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"切换文本"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(onToggleText)];
    self.navigationItem.rightBarButtonItem = editButton;

    NSLog(@"✅ viewDidLoad 完成，所有配置已就绪");
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;

    // ✅✅✅ 正确做法：在 viewDidLoad 中设置自动高度
    self.tableView.estimatedRowHeight = 80;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    NSLog(@"✅ 在 viewDidLoad 中设置了自动高度配置");

    [self.view addSubview:self.tableView];
}

- (void)setupConstraints {
    // ✅ 正确：约束在初始化时设置一次
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];

    NSLog(@"✅ 在 viewDidLoad 中设置了约束");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"✅ viewWillAppear 调用（用户还看不到界面）");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"✅ viewDidAppear 调用（用户已经看到流畅的界面）");
}

- (void)onToggleText {
    // 切换第一行的文本
    if ([self.bookTitles[0] isEqualToString:@"短标题"]) {
        self.bookTitles[0] = @"这是一个很长很长很长很长很长的标题，需要多行显示才能看完全部内容";
    } else {
        self.bookTitles[0] = @"短标题";
    }

    // ✅ 刷新数据，高度会自动重新计算
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
                          withRowAnimation:UITableViewRowAnimationAutomatic];

    NSLog(@"✅ 数据更新后，高度自动重新计算");
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

// ✅ 正确做法：不实现 heightForRowAtIndexPath:
// 让系统自动根据 Cell 的约束计算高度
//
// 对比：WrongViewController 中实现了这个方法并手动计算
//       导致性能下降且逻辑复杂

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"✅ 正确做法演示";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"注意：当你进入这个页面时，界面流畅自然，没有跳动\n因为自动高度配置在 viewDidLoad 中设置，用户看到界面时已经准备好了\n点击右上角「切换文本」按钮测试动态更新";
}

@end

