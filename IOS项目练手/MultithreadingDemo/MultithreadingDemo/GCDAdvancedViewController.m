//
//  GCDAdvancedViewController.m
//  MultithreadingDemo
//
//  GCD 高级 - 串行/并行队列, dispatch_group
//

#import "GCDAdvancedViewController.h"

@interface GCDAdvancedViewController ()
@property (strong, nonatomic) UITextView *logTextView;
@property (strong, nonatomic) dispatch_queue_t serialQueue;    // 串行队列
@property (strong, nonatomic) dispatch_queue_t concurrentQueue; // 并行队列
@end

@implementation GCDAdvancedViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"GCD 高级";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    // 创建自定义队列
    self.serialQueue = dispatch_queue_create("com.demo.serialQueue", DISPATCH_QUEUE_SERIAL);
    self.concurrentQueue = dispatch_queue_create("com.demo.concurrentQueue", DISPATCH_QUEUE_CONCURRENT);

    [self setupUI];
}

- (void)setupUI {
    CGFloat padding = 20;
    CGFloat yOffset = 20;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;

    // 说明文本
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 60)];
    descLabel.text = @"串行队列按顺序执行任务，并行队列同时执行多个任务。dispatch_group 可以监听多个任务完成。";
    descLabel.numberOfLines = 0;
    descLabel.font = [UIFont systemFontOfSize:14];
    descLabel.textColor = [UIColor secondaryLabelColor];
    [self.view addSubview:descLabel];
    yOffset += 80;

    // 按钮
    NSArray *buttons = @[
        @{@"title": @"📝 串行队列演示", @"action": @"serialQueueDemo"},
        @{@"title": @"🔀 并行队列演示", @"action": @"concurrentQueueDemo"},
        @{@"title": @"📊 队列对比", @"action": @"queueComparisonDemo"},
        @{@"title": @"👥 Dispatch Group", @"action": @"dispatchGroupDemo"},
        @{@"title": @"🔁 Dispatch Barrier", @"action": @"dispatchBarrierDemo"},
        @{@"title": @"🗑️ 清空日志", @"action": @"clearLog"}
    ];

    for (NSDictionary *btnInfo in buttons) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(padding, yOffset, screenWidth - 2 * padding, 44);
        [button setTitle:btnInfo[@"title"] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor systemPurpleColor];
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

        NSString *threadName = [NSThread currentThread].name ?: @"匿名线程";
        if ([NSThread isMainThread]) {
            threadName = @"主线程";
        }

        NSString *logEntry = [NSString stringWithFormat:@"[%@] [%@] %@\n", timeStr, threadName, message];

        self.logTextView.text = [self.logTextView.text stringByAppendingString:logEntry];

        NSRange bottom = NSMakeRange(self.logTextView.text.length - 1, 1);
        [self.logTextView scrollRangeToVisible:bottom];
    });
}

#pragma mark - 示例方法

// 1. 串行队列 - 按顺序执行
- (void)serialQueueDemo {
    [self log:@"📝 串行队列开始"];

    for (int i = 1; i <= 5; i++) {
        dispatch_async(self.serialQueue, ^{
            [self log:[NSString stringWithFormat:@"→ 任务 %d 开始", i]];
            sleep(1);
            [self log:[NSString stringWithFormat:@"→ 任务 %d 完成", i]];
        });
    }

    [self log:@"→ 5 个任务已提交到串行队列"];
}

// 2. 并行队列 - 同时执行
- (void)concurrentQueueDemo {
    [self log:@"🔀 并行队列开始"];

    for (int i = 1; i <= 5; i++) {
        dispatch_async(self.concurrentQueue, ^{
            [self log:[NSString stringWithFormat:@"→ 任务 %d 开始", i]];
            sleep(1);
            [self log:[NSString stringWithFormat:@"→ 任务 %d 完成", i]];
        });
    }

    [self log:@"→ 5 个任务已提交到并行队列"];
}

// 3. 队列对比
- (void)queueComparisonDemo {
    [self log:@"📊 队列对比开始"];
    [self log:@"→ 串行队列（顺序执行）:"];

    for (int i = 1; i <= 3; i++) {
        dispatch_async(self.serialQueue, ^{
            [self log:[NSString stringWithFormat:@"  串行任务 %d 执行", i]];
            sleep(1);
        });
    }

    [self log:@"→ 并行队列（同时执行）:"];

    for (int i = 1; i <= 3; i++) {
        dispatch_async(self.concurrentQueue, ^{
            [self log:[NSString stringWithFormat:@"  并行任务 %d 执行", i]];
            sleep(1);
        });
    }
}

// 4. Dispatch Group - 等待多个任务完成
- (void)dispatchGroupDemo {
    [self log:@"👥 Dispatch Group 开始"];

    dispatch_group_t group = dispatch_group_create();

    // 任务 1
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self log:@"→ 任务1: 下载图片1"];
        sleep(2);
        [self log:@"✅ 任务1: 图片1下载完成"];
    });

    // 任务 2
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self log:@"→ 任务2: 下载图片2"];
        sleep(3);
        [self log:@"✅ 任务2: 图片2下载完成"];
    });

    // 任务 3
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self log:@"→ 任务3: 下载图片3"];
        sleep(1);
        [self log:@"✅ 任务3: 图片3下载完成"];
    });

    [self log:@"→ 3个下载任务已提交，等待全部完成..."];

    // 所有任务完成后的回调
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self log:@"🎉 所有任务完成！可以刷新UI了"];

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"完成"
                                                                       message:@"所有图片下载完成！"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

// 5. Dispatch Barrier - 栅栏函数
- (void)dispatchBarrierDemo {
    [self log:@"🔁 Dispatch Barrier 开始"];
    [self log:@"→ Barrier 用于在并行队列中创建同步点"];

    // 并行读取
    for (int i = 1; i <= 3; i++) {
        dispatch_async(self.concurrentQueue, ^{
            [self log:[NSString stringWithFormat:@"→ 读取操作 %d", i]];
            sleep(1);
        });
    }

    // Barrier - 等待前面的任务完成，独占队列
    dispatch_barrier_async(self.concurrentQueue, ^{
        [self log:@"🚧 Barrier: 写入操作（独占队列）"];
        sleep(2);
        [self log:@"✅ Barrier: 写入完成"];
    });

    // 继续并行读取
    for (int i = 4; i <= 6; i++) {
        dispatch_async(self.concurrentQueue, ^{
            [self log:[NSString stringWithFormat:@"→ 读取操作 %d", i]];
            sleep(1);
        });
    }

    [self log:@"→ 观察执行顺序：读取→Barrier→读取"];
}

// 6. 清空日志
- (void)clearLog {
    self.logTextView.text = @"";
}

- (void)dealloc {
    // 清理队列（ARC 会自动管理）
}

@end

