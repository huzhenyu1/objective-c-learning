//
//  ThreadSafetyViewController.m
//  MultithreadingDemo
//
//  线程安全 - 竞态条件、锁
//

#import "ThreadSafetyViewController.h"

@interface ThreadSafetyViewController ()
@property (strong, nonatomic) UITextView *logTextView;
@property (assign, nonatomic) NSInteger unsafeCounter;     // 不安全的计数器
@property (assign, nonatomic) NSInteger safeCounter;       // 安全的计数器
@property (strong, nonatomic) NSLock *lock;                // 锁对象
@end

@implementation ThreadSafetyViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"线程安全";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    self.lock = [[NSLock alloc] init];

    [self setupUI];
}

- (void)setupUI {
    CGFloat padding = 20;
    CGFloat yOffset = 20;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;

    // 说明文本
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 100)];
    descLabel.text = @"多线程访问共享资源时可能产生竞态条件（Race Condition）。使用锁可以保证线程安全。";
    descLabel.numberOfLines = 0;
    descLabel.font = [UIFont systemFontOfSize:14];
    descLabel.textColor = [UIColor secondaryLabelColor];
    [self.view addSubview:descLabel];
    yOffset += 120;

    // 按钮
    NSArray *buttons = @[
        @{@"title": @"❌ 不安全的计数器", @"action": @"unsafeCounterDemo"},
        @{@"title": @"✅ 使用 NSLock", @"action": @"nsLockDemo"},
        @{@"title": @"🔒 使用 @synchronized", @"action": @"synchronizedDemo"},
        @{@"title": @"💰 银行转账问题", @"action": @"bankTransferDemo"},
        @{@"title": @"🗑️ 清空日志", @"action": @"clearLog"}
    ];

    for (NSDictionary *btnInfo in buttons) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(padding, yOffset, screenWidth - 2 * padding, 44);
        [button setTitle:btnInfo[@"title"] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor systemRedColor];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        button.layer.cornerRadius = 8;

        SEL action = NSSelectorFromString(btnInfo[@"action"]);
        [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];

        yOffset += 54;
    }

    // 日志显示
    CGFloat logHeight = screenHeight - yOffset - 40;
    self.logTextView = [[UITextView alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, logHeight)];
    self.logTextView.font = [UIFont monospacedSystemFontOfSize:12 weight:UIFontWeightRegular];
    self.logTextView.editable = NO;
    self.logTextView.layer.borderColor = [UIColor systemGrayColor].CGColor;
    self.logTextView.layer.borderWidth = 1;
    self.logTextView.layer.cornerRadius = 8;
    [self.view addSubview:self.logTextView];
}

#pragma mark - 日志方法

- (void)log:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"HH:mm:ss.SSS";
        NSString *timeStr = [formatter stringFromDate:[NSDate date]];

        NSString *logEntry = [NSString stringWithFormat:@"[%@] %@\n", timeStr, message];
        self.logTextView.text = [self.logTextView.text stringByAppendingString:logEntry];

        NSRange bottom = NSMakeRange(self.logTextView.text.length - 1, 1);
        [self.logTextView scrollRangeToVisible:bottom];
    });
}

#pragma mark - 示例方法

// 1. 不安全的计数器 - 演示竞态条件
- (void)unsafeCounterDemo {
    [self log:@"❌ 不安全的计数器演示"];
    [self log:@"→ 10个线程同时对计数器 +1，各执行1000次"];
    [self log:@"→ 预期结果: 10000"];

    self.unsafeCounter = 0;

    dispatch_group_t group = dispatch_group_create();

    for (int thread = 0; thread < 10; thread++) {
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (int i = 0; i < 1000; i++) {
                // 不安全的操作：读取-修改-写入
                NSInteger temp = self.unsafeCounter;
                temp = temp + 1;
                self.unsafeCounter = temp;
            }
        });
    }

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self log:[NSString stringWithFormat:@"→ 实际结果: %ld", (long)self.unsafeCounter]];
        [self log:@"❌ 数据不一致！这就是竞态条件"];
    });
}

// 2. 使用 NSLock
- (void)nsLockDemo {
    [self log:@"✅ 使用 NSLock 保证线程安全"];
    [self log:@"→ 10个线程同时对计数器 +1，各执行1000次"];
    [self log:@"→ 预期结果: 10000"];

    self.safeCounter = 0;

    dispatch_group_t group = dispatch_group_create();

    for (int thread = 0; thread < 10; thread++) {
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (int i = 0; i < 1000; i++) {
                // 使用锁保护
                [self.lock lock];
                NSInteger temp = self.safeCounter;
                temp = temp + 1;
                self.safeCounter = temp;
                [self.lock unlock];
            }
        });
    }

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self log:[NSString stringWithFormat:@"→ 实际结果: %ld", (long)self.safeCounter]];
        [self log:@"✅ 数据一致！线程安全"];
    });
}

// 3. 使用 @synchronized
- (void)synchronizedDemo {
    [self log:@"🔒 使用 @synchronized 保证线程安全"];
    [self log:@"→ 10个线程同时对计数器 +1，各执行1000次"];

    __block NSInteger counter = 0;
    dispatch_group_t group = dispatch_group_create();

    for (int thread = 0; thread < 10; thread++) {
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (int i = 0; i < 1000; i++) {
                // 使用 @synchronized
                @synchronized (self) {
                    counter++;
                }
            }
        });
    }

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self log:[NSString stringWithFormat:@"→ 结果: %ld", (long)counter]];
        [self log:@"✅ @synchronized 更简洁但性能略低"];
    });
}

// 4. 银行转账问题 - 经典的线程安全问题
- (void)bankTransferDemo {
    [self log:@"💰 银行转账问题"];
    [self log:@"→ 账户A: 1000元, 账户B: 1000元"];
    [self log:@"→ 10个线程同时从A转100元到B"];

    __block NSInteger accountA = 1000;
    __block NSInteger accountB = 1000;

    NSLock *transferLock = [[NSLock alloc] init];
    dispatch_group_t group = dispatch_group_create();

    for (int i = 0; i < 10; i++) {
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 不加锁会导致数据不一致
            [transferLock lock];

            // 转账操作
            if (accountA >= 100) {
                [self log:[NSString stringWithFormat:@"→ 转账 %d: A减100", i + 1]];
                accountA -= 100;
                usleep(10000); // 模拟网络延迟
                accountB += 100;
                [self log:[NSString stringWithFormat:@"→ 转账 %d: B加100", i + 1]];
            }

            [transferLock unlock];
        });
    }

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self log:[NSString stringWithFormat:@"→ 最终账户A: %ld元", (long)accountA]];
        [self log:[NSString stringWithFormat:@"→ 最终账户B: %ld元", (long)accountB]];
        [self log:[NSString stringWithFormat:@"→ 总金额: %ld元", (long)(accountA + accountB)]];

        if (accountA + accountB == 2000) {
            [self log:@"✅ 转账成功，总金额一致"];
        } else {
            [self log:@"❌ 数据错误！"];
        }
    });
}

// 5. 清空日志
- (void)clearLog {
    self.logTextView.text = @"";
}

@end

