//
//  MVCViewController.m
//  DesignPatternsDemo
//
//  MVC 模式演示：Model-View-Controller
//

#import "MVCViewController.h"

#pragma mark - Model（数据模型）

@interface User : NSObject
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *email;
@property (assign, nonatomic) NSInteger age;

- (instancetype)initWithName:(NSString *)name email:(NSString *)email age:(NSInteger)age;
- (NSString *)description;
@end

@implementation User

- (instancetype)initWithName:(NSString *)name email:(NSString *)email age:(NSInteger)age {
    self = [super init];
    if (self) {
        _name = name;
        _email = email;
        _age = age;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"姓名：%@\n邮箱：%@\n年龄：%ld", self.name, self.email, (long)self.age];
}

@end

#pragma mark - Controller（控制器）

@interface MVCViewController () <UITableViewDataSource, UITableViewDelegate>
// Model
@property (strong, nonatomic) NSMutableArray<User *> *users;

// View
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIButton *addButton;
@end

@implementation MVCViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"MVC 模式";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    // 初始化 Model
    [self setupModel];

    // 初始化 View
    [self setupView];
}

#pragma mark - Model Setup

- (void)setupModel {
    self.users = [NSMutableArray array];

    // 初始数据
    [self.users addObject:[[User alloc] initWithName:@"张三" email:@"zhangsan@example.com" age:25]];
    [self.users addObject:[[User alloc] initWithName:@"李四" email:@"lisi@example.com" age:30]];
    [self.users addObject:[[User alloc] initWithName:@"王五" email:@"wangwu@example.com" age:28]];
}

#pragma mark - View Setup

- (void)setupView {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;

    // 说明标签
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, screenWidth - 40, 80)];
    descLabel.text = @"MVC 架构：\nModel（数据）+ View（界面）+ Controller（控制器）\n点击「添加用户」按钮测试";
    descLabel.numberOfLines = 0;
    descLabel.font = [UIFont systemFontOfSize:14];
    descLabel.textColor = [UIColor secondaryLabelColor];
    descLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:descLabel];

    // TableView（View 层）
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 200, screenWidth, screenHeight - 280) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:self.tableView];

    // 添加按钮（View 层）
    self.addButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.addButton.frame = CGRectMake(20, screenHeight - 70, screenWidth - 40, 50);
    [self.addButton setTitle:@"添加用户" forState:UIControlStateNormal];
    self.addButton.backgroundColor = [UIColor systemBlueColor];
    [self.addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.addButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.addButton.layer.cornerRadius = 10;
    [self.addButton addTarget:self action:@selector(addUserButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addButton];
}

#pragma mark - Controller Logic（业务逻辑）

- (void)addUserButtonTapped {
    // Controller 负责处理用户交互，更新 Model
    NSInteger userCount = self.users.count + 1;
    User *newUser = [[User alloc] initWithName:[NSString stringWithFormat:@"用户 %ld", (long)userCount]
                                         email:[NSString stringWithFormat:@"user%ld@example.com", (long)userCount]
                                           age:20 + arc4random_uniform(30)];

    // 更新 Model
    [self.users addObject:newUser];

    // 更新 View
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.users.count - 1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

    // 显示提示
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"添加成功"
                                                                   message:[newUser description]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)deleteUserAtIndex:(NSInteger)index {
    // Controller 负责删除逻辑
    [self.users removeObjectAtIndex:index];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - UITableViewDataSource（View 层的数据源）

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    // Controller 从 Model 获取数据，配置 View
    User *user = self.users[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %ld岁", user.name, (long)user.age];
    cell.detailTextLabel.text = user.email;

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    User *user = self.users[indexPath.row];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"用户详情"
                                                                   message:[user description]
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self deleteUserAtIndex:indexPath.row];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteUserAtIndex:indexPath.row];
    }
}

@end

