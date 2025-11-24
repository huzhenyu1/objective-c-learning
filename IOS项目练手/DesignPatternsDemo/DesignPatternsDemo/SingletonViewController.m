//
//  SingletonViewController.m
//  DesignPatternsDemo
//
//  Singleton 单例模式演示：全局唯一实例
//

#import "SingletonViewController.h"

#pragma mark - Singleton 单例类

@interface UserManager : NSObject

// ⭐ 单例访问方法
+ (instancetype)sharedManager;

@property (copy, nonatomic) NSString *username;
@property (assign, nonatomic) NSInteger loginCount;
@property (strong, nonatomic) NSMutableArray *logs;

- (void)login:(NSString *)username;
- (void)logout;
- (void)addLog:(NSString *)log;

@end

@implementation UserManager

// ⭐ 单例实现（线程安全）
+ (instancetype)sharedManager {
    static UserManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];  // ⭐ 调用父类的 allocWithZone
        instance.logs = [NSMutableArray array];
        instance.loginCount = 0;
    });
    return instance;
}

// 防止外部通过 alloc/init 创建多个实例
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    // ⭐ 必须使用同样的 dispatch_once，避免递归
    return [self sharedManager];
}

- (id)copyWithZone:(NSZone *)zone {
    // ⭐ copy 也返回同一个实例
    return self;
}

- (void)login:(NSString *)username {
    self.username = username;
    self.loginCount += 1;
    [self addLog:[NSString stringWithFormat:@"用户 %@ 登录（第 %ld 次）", username, (long)self.loginCount]];
}

- (void)logout {
    [self addLog:[NSString stringWithFormat:@"用户 %@ 登出", self.username]];
    self.username = nil;
}

- (void)addLog:(NSString *)log {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm:ss";
    NSString *timeStr = [formatter stringFromDate:[NSDate date]];

    NSString *logEntry = [NSString stringWithFormat:@"[%@] %@", timeStr, log];
    [self.logs addObject:logEntry];
}

@end

#pragma mark - Controller

@interface SingletonViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) UITableView *logTableView;
@property (strong, nonatomic) UILabel *instanceLabel;
@end

@implementation SingletonViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Singleton 单例模式";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupUI];
    [self updateUI];
}

- (void)setupUI {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat yOffset = 100;

    // 说明
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, yOffset, screenWidth - 40, 80)];
    descLabel.text = @"Singleton 单例模式：\n全局唯一实例，整个应用共享同一对象\n多次获取得到的都是同一个实例";
    descLabel.numberOfLines = 0;
    descLabel.font = [UIFont systemFontOfSize:14];
    descLabel.textColor = [UIColor secondaryLabelColor];
    [self.view addSubview:descLabel];
    yOffset += 100;

    // 实例地址
    self.instanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, yOffset, screenWidth - 40, 40)];
    self.instanceLabel.numberOfLines = 0;
    self.instanceLabel.font = [UIFont systemFontOfSize:12];
    self.instanceLabel.textAlignment = NSTextAlignmentCenter;
    self.instanceLabel.textColor = [UIColor systemOrangeColor];
    self.instanceLabel.backgroundColor = [[UIColor systemGrayColor] colorWithAlphaComponent:0.1];
    self.instanceLabel.layer.cornerRadius = 8;
    self.instanceLabel.layer.masksToBounds = YES;
    [self.view addSubview:self.instanceLabel];
    yOffset += 50;

    // 状态显示
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, yOffset, screenWidth - 40, 80)];
    self.statusLabel.text = @"未登录";
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.font = [UIFont boldSystemFontOfSize:18];
    self.statusLabel.backgroundColor = [UIColor systemBlueColor];
    self.statusLabel.textColor = [UIColor whiteColor];
    self.statusLabel.layer.cornerRadius = 10;
    self.statusLabel.layer.masksToBounds = YES;
    [self.view addSubview:self.statusLabel];
    yOffset += 100;

    // 按钮
    NSArray *buttons = @[
        @{@"title": @"👤 登录（张三）", @"action": @"loginAsZhangSan"},
        @{@"title": @"👤 登录（李四）", @"action": @"loginAsLiSi"},
        @{@"title": @"🚪 登出", @"action": @"logout"},
        @{@"title": @"🔍 验证单例", @"action": @"verifySingleton"}
    ];

    for (NSDictionary *btnInfo in buttons) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(20, yOffset, screenWidth - 40, 44);
        [button setTitle:btnInfo[@"title"] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor systemGreenColor];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        button.layer.cornerRadius = 8;

        SEL action = NSSelectorFromString(btnInfo[@"action"]);
        [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];

        yOffset += 50;
    }

    // 日志标题
    UILabel *logTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, yOffset, screenWidth - 40, 30)];
    logTitle.text = @"📝 操作日志（单例内部存储）：";
    logTitle.font = [UIFont boldSystemFontOfSize:14];
    [self.view addSubview:logTitle];
    yOffset += 35;

    // 日志 TableView
    self.logTableView = [[UITableView alloc] initWithFrame:CGRectMake(20, yOffset, screenWidth - 40, screenHeight - yOffset - 20) style:UITableViewStylePlain];
    self.logTableView.dataSource = self;
    self.logTableView.delegate = self;
    self.logTableView.layer.cornerRadius = 8;
    [self.logTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:self.logTableView];
}

#pragma mark - Actions

- (void)loginAsZhangSan {
    // ⭐ 获取单例
    [[UserManager sharedManager] login:@"张三"];
    [self updateUI];
    [self.logTableView reloadData];
}

- (void)loginAsLiSi {
    [[UserManager sharedManager] login:@"李四"];
    [self updateUI];
    [self.logTableView reloadData];
}

- (void)logout {
    [[UserManager sharedManager] logout];
    [self updateUI];
    [self.logTableView reloadData];
}

- (void)verifySingleton {
    // ⭐ 验证单例：多次获取是同一个对象
    UserManager *instance1 = [UserManager sharedManager];
    UserManager *instance2 = [UserManager sharedManager];
    UserManager *instance3 = [[UserManager alloc] init];  // 也会返回同一个实例

    BOOL isSame = (instance1 == instance2) && (instance2 == instance3);

    NSString *message = [NSString stringWithFormat:@"instance1: %p\ninstance2: %p\ninstance3: %p\n\n结果：%@",
                        instance1, instance2, instance3,
                        isSame ? @"✅ 是同一个实例（单例成功）" : @"❌ 不是同一个实例"];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"单例验证"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];

    [[UserManager sharedManager] addLog:@"验证单例：所有实例地址相同"];
    [self.logTableView reloadData];
}

- (void)updateUI {
    UserManager *manager = [UserManager sharedManager];

    // 更新状态
    if (manager.username) {
        self.statusLabel.text = [NSString stringWithFormat:@"👤 当前用户：%@\n登录次数：%ld", manager.username, (long)manager.loginCount];
        self.statusLabel.backgroundColor = [UIColor systemGreenColor];
    } else {
        self.statusLabel.text = @"未登录";
        self.statusLabel.backgroundColor = [UIColor systemGrayColor];
    }

    // 更新实例地址
    self.instanceLabel.text = [NSString stringWithFormat:@"单例实例地址：%p\n（全局唯一）", manager];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [UserManager sharedManager].logs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSArray *logs = [UserManager sharedManager].logs;
    NSString *log = logs[logs.count - 1 - indexPath.row];  // 倒序显示（最新的在上面）

    cell.textLabel.text = log;
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

@end

