//
//  NSOperationViewController.m
//  MultithreadingDemo
//
//  NSOperation 和 NSOperationQueue
//

#import "NSOperationViewController.h"

@interface NSOperationViewController ()
@property (strong, nonatomic) UITextView *logTextView;
@property (strong, nonatomic) NSOperationQueue *operationQueue;
@end

@implementation NSOperationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"NSOperation";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    // 创建操作队列
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.operationQueue.maxConcurrentOperationCount = 2; // 最多同时执行2个操作

    [self setupUI];
}

- (void)setupUI {
    CGFloat padding = 20;
    CGFloat yOffset = 20;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;

    // 说明文本
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 80)];
    descLabel.text = @"NSOperation 是基于 GCD 的高级封装，支持依赖关系、优先级、取消操作等功能。";
    descLabel.numberOfLines = 0;
    descLabel.font = [UIFont systemFontOfSize:14];
    descLabel.textColor = [UIColor secondaryLabelColor];
    [self.view addSubview:descLabel];
    yOffset += 100;

    // 按钮
    NSArray *buttons = @[
        @{@"title": @"🎯 基本操作", @"action": @"basicOperationDemo"},
        @{@"title": @"🔗 操作依赖", @"action": @"dependencyDemo"},
        @{@"title": @"⏸️ 取消操作", @"action": @"cancellationDemo"},
        @{@"title": @"⚡️ 优先级", @"action": @"priorityDemo"},
        @{@"title": @"📊 最大并发数", @"action": @"concurrentDemo"},
        @{@"title": @"🗑️ 清空日志", @"action": @"clearLog"}
    ];

    for (NSDictionary *btnInfo in buttons) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(padding, yOffset, screenWidth - 2 * padding, 44);
        [button setTitle:btnInfo[@"title"] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor systemIndigoColor];
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

// 1. 基本操作
- (void)basicOperationDemo {
    [self log:@"🎯 基本操作开始"];

    // 使用 NSBlockOperation
    NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        [self log:@"→ Operation 1 执行"];
        sleep(2);
        [self log:@"✅ Operation 1 完成"];
    }];

    NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        [self log:@"→ Operation 2 执行"];
        sleep(1);
        [self log:@"✅ Operation 2 完成"];
    }];

    [self.operationQueue addOperation:operation1];
    [self.operationQueue addOperation:operation2];
}

// 2. 操作依赖
- (void)dependencyDemo {
    [self log:@"🔗 操作依赖开始"];
    [self log:@"→ 设置依赖：下载→解析→显示"];

    NSBlockOperation *downloadOperation = [NSBlockOperation blockOperationWithBlock:^{
        [self log:@"→ 1️⃣ 下载数据..."];
        sleep(2);
        [self log:@"✅ 1️⃣ 下载完成"];
    }];

    NSBlockOperation *parseOperation = [NSBlockOperation blockOperationWithBlock:^{
        [self log:@"→ 2️⃣ 解析数据..."];
        sleep(1);
        [self log:@"✅ 2️⃣ 解析完成"];
    }];

    NSBlockOperation *displayOperation = [NSBlockOperation blockOperationWithBlock:^{
        [self log:@"→ 3️⃣ 显示数据..."];
        sleep(1);
        [self log:@"✅ 3️⃣ 显示完成"];
    }];

    // 设置依赖关系
    [parseOperation addDependency:downloadOperation];   // 解析依赖下载
    [displayOperation addDependency:parseOperation];     // 显示依赖解析

    [self.operationQueue addOperations:@[downloadOperation, parseOperation, displayOperation] waitUntilFinished:NO];
}

// 3. 取消操作
- (void)cancellationDemo {
    [self log:@"⏸️ 取消操作演示"];

    __block NSBlockOperation *longOperation = nil;
    longOperation = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 1; i <= 10; i++) {
            // 检查是否被取消（使用 longOperation 引用）
            if (longOperation.isCancelled) {
                [self log:@"❌ 操作被取消"];
                return;
            }

            [self log:[NSString stringWithFormat:@"→ 执行进度: %d/10", i]];
            sleep(1);
        }
        [self log:@"✅ 操作完成"];
    }];

    [self.operationQueue addOperation:longOperation];

    // 2秒后取消操作
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [longOperation cancel];
        [self log:@"🛑 已发送取消指令"];
    });
}

// 4. 优先级
- (void)priorityDemo {
    [self log:@"⚡️ 优先级演示"];

    NSBlockOperation *lowPriority = [NSBlockOperation blockOperationWithBlock:^{
        [self log:@"→ 低优先级任务执行"];
        sleep(1);
    }];
    lowPriority.queuePriority = NSOperationQueuePriorityLow;

    NSBlockOperation *normalPriority = [NSBlockOperation blockOperationWithBlock:^{
        [self log:@"→ 普通优先级任务执行"];
        sleep(1);
    }];
    normalPriority.queuePriority = NSOperationQueuePriorityNormal;

    NSBlockOperation *highPriority = [NSBlockOperation blockOperationWithBlock:^{
        [self log:@"→ 高优先级任务执行"];
        sleep(1);
    }];
    highPriority.queuePriority = NSOperationQueuePriorityHigh;

    [self log:@"→ 添加顺序：低→普通→高"];
    [self log:@"→ 执行顺序会优先高优先级"];

    [self.operationQueue addOperation:lowPriority];
    [self.operationQueue addOperation:normalPriority];
    [self.operationQueue addOperation:highPriority];
}

// 5. 最大并发数
- (void)concurrentDemo {
    [self log:@"📊 最大并发数演示"];
    [self log:[NSString stringWithFormat:@"→ 当前最大并发数: %ld", (long)self.operationQueue.maxConcurrentOperationCount]];

    for (int i = 1; i <= 5; i++) {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            [self log:[NSString stringWithFormat:@"→ 任务 %d 开始", i]];
            sleep(2);
            [self log:[NSString stringWithFormat:@"✅ 任务 %d 完成", i]];
        }];

        [self.operationQueue addOperation:operation];
    }

    [self log:@"→ 观察：同时最多执行2个任务"];
}

// 6. 清空日志
- (void)clearLog {
    self.logTextView.text = @"";
}

@end

