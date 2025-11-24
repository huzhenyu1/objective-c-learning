//
//  GCDBasicViewController.m
//  MultithreadingDemo
//
//  GCD 基础 - dispatch_async, dispatch_sync
//

#import "GCDBasicViewController.h"

@interface GCDBasicViewController ()
@property (strong, nonatomic) UITextView *logTextView;
@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) UILabel *statusLabel;
@end

@implementation GCDBasicViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"GCD 基础";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupUI];
}

- (void)setupUI {
    CGFloat padding = 20;
    CGFloat yOffset = 20;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;

    // 说明文本
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 80)];
    descLabel.text = @"GCD (Grand Central Dispatch) 是 iOS 的多线程解决方案。点击按钮查看不同线程操作的效果。";
    descLabel.numberOfLines = 0;
    descLabel.font = [UIFont systemFontOfSize:14];
    descLabel.textColor = [UIColor secondaryLabelColor];
    [self.view addSubview:descLabel];
    yOffset += 100;

    // 状态标签
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 30)];
    self.statusLabel.text = @"就绪";
    self.statusLabel.font = [UIFont boldSystemFontOfSize:16];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.textColor = [UIColor systemGreenColor];
    [self.view addSubview:self.statusLabel];
    yOffset += 40;

    // 进度条
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 4)];
    self.progressView.progress = 0;
    [self.view addSubview:self.progressView];
    yOffset += 30;

    // 按钮
    NSArray *buttons = @[
        @{@"title": @"🚀 异步执行（后台线程）", @"action": @"asyncDemo"},
        @{@"title": @"⏳ 同步执行（阻塞）", @"action": @"syncDemo"},
        @{@"title": @"🔄 主线程更新 UI", @"action": @"mainThreadDemo"},
        @{@"title": @"⏰ 延迟执行", @"action": @"delayDemo"},
        @{@"title": @"🔁 重复执行（模拟下载）", @"action": @"downloadDemo"},
        @{@"title": @"🗑️ 清空日志", @"action": @"clearLog"}
    ];

    for (NSDictionary *btnInfo in buttons) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(padding, yOffset, screenWidth - 2 * padding, 44);
        [button setTitle:btnInfo[@"title"] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor systemBlueColor];
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

        NSString *threadInfo = [NSThread isMainThread] ? @"[主线程]" : @"[后台线程]";
        NSString *logEntry = [NSString stringWithFormat:@"[%@] %@ %@\n", timeStr, threadInfo, message];

        self.logTextView.text = [self.logTextView.text stringByAppendingString:logEntry];

        // 滚动到底部
        NSRange bottom = NSMakeRange(self.logTextView.text.length - 1, 1);
        [self.logTextView scrollRangeToVisible:bottom];
    });
}

- (void)updateStatus:(NSString *)status color:(UIColor *)color {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusLabel.text = status;
        self.statusLabel.textColor = color;
    });
}

- (void)updateProgress:(float)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressView setProgress:progress animated:YES];
    });
}

#pragma mark - 示例方法

// 1. 异步执行 - 不阻塞当前线程
- (void)asyncDemo {
    [self log:@"🚀 开始异步任务"];
    [self updateStatus:@"执行中..." color:[UIColor systemOrangeColor]];

    // 在全局队列中异步执行
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self log:@"→ 异步任务正在后台执行"];

        // 模拟耗时操作
        for (int i = 1; i <= 5; i++) {
            sleep(1);
            [self log:[NSString stringWithFormat:@"  进度: %d/5", i]];
        }

        [self log:@"✅ 异步任务完成"];
        [self updateStatus:@"完成" color:[UIColor systemGreenColor]];
    });

    [self log:@"→ 主线程继续执行（不等待异步任务）"];
}

// 2. 同步执行 - 阻塞当前线程
- (void)syncDemo {
    [self log:@"⏳ 开始同步任务"];
    [self updateStatus:@"阻塞中..." color:[UIColor systemRedColor]];

    // 在全局队列中同步执行
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self log:@"→ 同步任务正在执行"];

        // 模拟耗时操作
        for (int i = 1; i <= 3; i++) {
            sleep(1);
            [self log:[NSString stringWithFormat:@"  进度: %d/3", i]];
        }

        [self log:@"✅ 同步任务完成"];
    });

    [self log:@"→ 主线程等待同步任务完成后才执行这里"];
    [self updateStatus:@"完成" color:[UIColor systemGreenColor]];
}

// 3. 主线程更新 UI
- (void)mainThreadDemo {
    [self log:@"🔄 演示主线程更新 UI"];
    [self updateStatus:@"后台处理中..." color:[UIColor systemOrangeColor]];

    // 在后台线程执行耗时操作
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self log:@"→ 后台线程：开始下载数据"];
        sleep(2);
        [self log:@"→ 后台线程：数据下载完成"];

        // 回到主线程更新 UI
        dispatch_async(dispatch_get_main_queue(), ^{
            [self log:@"→ 主线程：更新 UI"];
            [self updateStatus:@"UI 已更新" color:[UIColor systemGreenColor]];

            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                           message:@"数据已加载完成！"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        });
    });
}

// 4. 延迟执行
- (void)delayDemo {
    [self log:@"⏰ 3秒后执行任务"];
    [self updateStatus:@"等待中..." color:[UIColor systemYellowColor]];

    // 3秒后在主线程执行
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self log:@"✅ 延迟任务执行"];
        [self updateStatus:@"完成" color:[UIColor systemGreenColor]];
    });
}

// 5. 模拟下载（带进度）
- (void)downloadDemo {
    [self log:@"📥 开始下载"];
    [self updateStatus:@"下载中..." color:[UIColor systemOrangeColor]];
    [self updateProgress:0];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 1; i <= 100; i++) {
            usleep(30000); // 0.03 秒

            float progress = i / 100.0;
            [self updateProgress:progress];

            if (i % 20 == 0) {
                [self log:[NSString stringWithFormat:@"→ 下载进度: %d%%", i]];
            }
        }

        [self log:@"✅ 下载完成"];
        [self updateStatus:@"下载完成" color:[UIColor systemGreenColor]];
    });
}

// 6. 清空日志
- (void)clearLog {
    self.logTextView.text = @"";
    self.statusLabel.text = @"就绪";
    self.statusLabel.textColor = [UIColor systemGreenColor];
    self.progressView.progress = 0;
}

@end

