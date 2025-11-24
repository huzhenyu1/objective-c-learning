//
//  UserDefaultsViewController.m
//  DataPersistenceDemo
//
//  NSUserDefaults 示例 - 简单数据存储
//

#import "UserDefaultsViewController.h"

@interface UserDefaultsViewController ()
@property (strong, nonatomic) UITextField *usernameField;
@property (strong, nonatomic) UISwitch *notificationSwitch;
@property (strong, nonatomic) UISlider *volumeSlider;
@property (strong, nonatomic) UILabel *volumeLabel;
@property (strong, nonatomic) UISegmentedControl *themeSegment;
@property (strong, nonatomic) UILabel *infoLabel;
@end

@implementation UserDefaultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"NSUserDefaults";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupUI];
    [self loadSettings];
}

- (void)setupUI {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:scrollView];

    CGFloat padding = 20;
    CGFloat yOffset = 20;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat labelWidth = screenWidth - 2 * padding;

    // 说明文本
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, labelWidth, 80)];
    descLabel.text = @"NSUserDefaults 用于存储应用的简单配置数据，如用户偏好设置。数据会自动持久化，应用重启后仍然存在。";
    descLabel.numberOfLines = 0;
    descLabel.font = [UIFont systemFontOfSize:14];
    descLabel.textColor = [UIColor secondaryLabelColor];
    [scrollView addSubview:descLabel];
    yOffset += 100;

    // 1. 用户名输入
    [self addSectionTitle:@"📝 用户名" to:scrollView at:&yOffset];

    self.usernameField = [[UITextField alloc] initWithFrame:CGRectMake(padding, yOffset, labelWidth, 44)];
    self.usernameField.placeholder = @"请输入用户名";
    self.usernameField.borderStyle = UITextBorderStyleRoundedRect;
    self.usernameField.delegate = (id<UITextFieldDelegate>)self;
    [self.usernameField addTarget:self action:@selector(usernameChanged) forControlEvents:UIControlEventEditingChanged];
    [scrollView addSubview:self.usernameField];
    yOffset += 60;

    // 2. 通知开关
    [self addSectionTitle:@"🔔 推送通知" to:scrollView at:&yOffset];

    UIView *notificationView = [[UIView alloc] initWithFrame:CGRectMake(padding, yOffset, labelWidth, 44)];

    UILabel *notificationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth - 60, 44)];
    notificationLabel.text = @"接收推送通知";
    [notificationView addSubview:notificationLabel];

    self.notificationSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(labelWidth - 51, 6, 51, 31)];
    [self.notificationSwitch addTarget:self action:@selector(notificationSwitchChanged) forControlEvents:UIControlEventValueChanged];
    [notificationView addSubview:self.notificationSwitch];

    [scrollView addSubview:notificationView];
    yOffset += 60;

    // 3. 音量滑块
    [self addSectionTitle:@"🔊 音量大小" to:scrollView at:&yOffset];

    self.volumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(padding, yOffset, labelWidth - 60, 31)];
    self.volumeSlider.minimumValue = 0;
    self.volumeSlider.maximumValue = 100;
    [self.volumeSlider addTarget:self action:@selector(volumeChanged) forControlEvents:UIControlEventValueChanged];
    [scrollView addSubview:self.volumeSlider];

    self.volumeLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth - padding - 50, yOffset, 50, 31)];
    self.volumeLabel.textAlignment = NSTextAlignmentRight;
    self.volumeLabel.font = [UIFont boldSystemFontOfSize:16];
    self.volumeLabel.textColor = [UIColor systemBlueColor];
    [scrollView addSubview:self.volumeLabel];
    yOffset += 50;

    // 4. 主题选择
    [self addSectionTitle:@"🎨 应用主题" to:scrollView at:&yOffset];

    self.themeSegment = [[UISegmentedControl alloc] initWithItems:@[@"浅色", @"深色", @"跟随系统"]];
    self.themeSegment.frame = CGRectMake(padding, yOffset, labelWidth, 32);
    [self.themeSegment addTarget:self action:@selector(themeChanged) forControlEvents:UIControlEventValueChanged];
    [scrollView addSubview:self.themeSegment];
    yOffset += 60;

    // 5. 信息显示
    self.infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, labelWidth, 120)];
    self.infoLabel.numberOfLines = 0;
    self.infoLabel.font = [UIFont systemFontOfSize:14];
    self.infoLabel.backgroundColor = [UIColor secondarySystemBackgroundColor];
    self.infoLabel.layer.cornerRadius = 8;
    self.infoLabel.clipsToBounds = YES;
    self.infoLabel.textAlignment = NSTextAlignmentLeft;
    self.infoLabel.textColor = [UIColor secondaryLabelColor];
    [scrollView addSubview:self.infoLabel];
    yOffset += 140;

    // 6. 按钮
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
    clearButton.frame = CGRectMake(padding, yOffset, labelWidth, 44);
    [clearButton setTitle:@"清除所有设置" forState:UIControlStateNormal];
    clearButton.backgroundColor = [UIColor systemRedColor];
    [clearButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    clearButton.layer.cornerRadius = 8;
    [clearButton addTarget:self action:@selector(clearAllSettings) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:clearButton];
    yOffset += 60;

    scrollView.contentSize = CGSizeMake(screenWidth, yOffset);
}

- (void)addSectionTitle:(NSString *)title to:(UIScrollView *)scrollView at:(CGFloat *)yOffset {
    CGFloat padding = 20;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(padding, *yOffset, screenWidth - 2 * padding, 24)];
    label.text = title;
    label.font = [UIFont boldSystemFontOfSize:16];
    label.textColor = [UIColor labelColor];
    [scrollView addSubview:label];
    *yOffset += 30;
}

#pragma mark - 数据持久化方法

- (void)loadSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // 读取用户名
    NSString *username = [defaults stringForKey:@"username"];
    if (username) {
        self.usernameField.text = username;
    }

    // 读取通知开关（默认值为 YES）
    BOOL notificationEnabled = [defaults boolForKey:@"notificationEnabled"];
    if (![defaults objectForKey:@"notificationEnabled"]) {
        notificationEnabled = YES; // 首次默认开启
    }
    self.notificationSwitch.on = notificationEnabled;

    // 读取音量（默认值为 50）
    float volume = [defaults floatForKey:@"volume"];
    if (volume == 0 && ![defaults objectForKey:@"volume"]) {
        volume = 50; // 首次默认 50
    }
    self.volumeSlider.value = volume;
    self.volumeLabel.text = [NSString stringWithFormat:@"%.0f", volume];

    // 读取主题（默认值为 0 - 浅色）
    NSInteger theme = [defaults integerForKey:@"theme"];
    self.themeSegment.selectedSegmentIndex = theme;

    [self updateInfoLabel];
}

- (void)usernameChanged {
    NSString *username = self.usernameField.text;

    // 保存到 UserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:username forKey:@"username"];
    [defaults synchronize]; // 立即同步（可选，系统会自动定期同步）

    [self updateInfoLabel];
}

- (void)notificationSwitchChanged {
    BOOL enabled = self.notificationSwitch.on;

    // 保存到 UserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:enabled forKey:@"notificationEnabled"];
    [defaults synchronize];

    [self updateInfoLabel];
}

- (void)volumeChanged {
    float volume = self.volumeSlider.value;
    self.volumeLabel.text = [NSString stringWithFormat:@"%.0f", volume];

    // 保存到 UserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:volume forKey:@"volume"];
    [defaults synchronize];

    [self updateInfoLabel];
}

- (void)themeChanged {
    NSInteger theme = self.themeSegment.selectedSegmentIndex;

    // 保存到 UserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:theme forKey:@"theme"];
    [defaults synchronize];

    [self updateInfoLabel];
}

- (void)updateInfoLabel {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSString *username = [defaults stringForKey:@"username"] ?: @"未设置";
    BOOL notificationEnabled = [defaults boolForKey:@"notificationEnabled"];
    float volume = [defaults floatForKey:@"volume"];
    NSInteger theme = [defaults integerForKey:@"theme"];
    NSString *themeText = @[@"浅色", @"深色", @"跟随系统"][theme];

    NSString *info = [NSString stringWithFormat:@"\n💾 当前保存的设置:\n\n用户名: %@\n通知: %@\n音量: %.0f\n主题: %@",
                     username,
                     notificationEnabled ? @"开启" : @"关闭",
                     volume,
                     themeText];

    self.infoLabel.text = info;
}

- (void)clearAllSettings {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认清除"
                                                                   message:@"确定要清除所有设置吗？"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];

    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        // 清除所有设置
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"username"];
        [defaults removeObjectForKey:@"notificationEnabled"];
        [defaults removeObjectForKey:@"volume"];
        [defaults removeObjectForKey:@"theme"];
        [defaults synchronize];

        // 重置 UI
        self.usernameField.text = @"";
        self.notificationSwitch.on = YES;
        self.volumeSlider.value = 50;
        self.volumeLabel.text = @"50";
        self.themeSegment.selectedSegmentIndex = 0;

        [self updateInfoLabel];

        // 提示
        UIAlertController *successAlert = [UIAlertController alertControllerWithTitle:@"✅ 清除成功"
                                                                               message:@"所有设置已清除"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
        [successAlert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:successAlert animated:YES completion:nil];
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

@end

