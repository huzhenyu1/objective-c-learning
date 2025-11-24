//
//  NotificationViewController.m
//  DesignPatternsDemo
//
//  Notification 通知模式演示：观察者模式（一对多）
//

#import "NotificationViewController.h"

// 定义通知名称
static NSString * const kScoreChangedNotification = @"ScoreChangedNotification";
static NSString * const kLevelUpNotification = @"LevelUpNotification";

@interface NotificationViewController ()
@property (strong, nonatomic) UILabel *scoreLabel;
@property (strong, nonatomic) UILabel *levelLabel;
@property (strong, nonatomic) UILabel *observer1Label;
@property (strong, nonatomic) UILabel *observer2Label;
@property (strong, nonatomic) UILabel *observer3Label;

@property (assign, nonatomic) NSInteger score;
@property (assign, nonatomic) NSInteger level;
@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Notification 通知模式";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    self.score = 0;
    self.level = 1;

    [self setupUI];
    [self registerNotifications];  // ⭐ 注册通知
}

- (void)setupUI {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat yOffset = 100;

    // 说明
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, yOffset, screenWidth - 40, 80)];
    descLabel.text = @"Notification 通知模式（观察者）：\n一对多通信，多个对象监听同一个通知\n点击按钮发送通知，观察3个观察者的反应";
    descLabel.numberOfLines = 0;
    descLabel.font = [UIFont systemFontOfSize:14];
    descLabel.textColor = [UIColor secondaryLabelColor];
    [self.view addSubview:descLabel];
    yOffset += 100;

    // 分数显示
    UIView *scoreContainer = [[UIView alloc] initWithFrame:CGRectMake(20, yOffset, screenWidth - 40, 80)];
    scoreContainer.backgroundColor = [UIColor systemBlueColor];
    scoreContainer.layer.cornerRadius = 10;
    [self.view addSubview:scoreContainer];

    self.scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, scoreContainer.frame.size.width, 30)];
    self.scoreLabel.text = @"分数：0";
    self.scoreLabel.textAlignment = NSTextAlignmentCenter;
    self.scoreLabel.font = [UIFont boldSystemFontOfSize:24];
    self.scoreLabel.textColor = [UIColor whiteColor];
    [scoreContainer addSubview:self.scoreLabel];

    self.levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 45, scoreContainer.frame.size.width, 25)];
    self.levelLabel.text = @"等级：1";
    self.levelLabel.textAlignment = NSTextAlignmentCenter;
    self.levelLabel.font = [UIFont systemFontOfSize:16];
    self.levelLabel.textColor = [UIColor whiteColor];
    [scoreContainer addSubview:self.levelLabel];
    yOffset += 100;

    // 观察者标题
    UILabel *observerTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, yOffset, screenWidth - 40, 30)];
    observerTitle.text = @"📢 观察者（监听通知）：";
    observerTitle.font = [UIFont boldSystemFontOfSize:16];
    [self.view addSubview:observerTitle];
    yOffset += 40;

    // 观察者1
    self.observer1Label = [self createObserverLabelWithFrame:CGRectMake(20, yOffset, screenWidth - 40, 60) title:@"观察者1（UI更新）"];
    [self.view addSubview:self.observer1Label];
    yOffset += 70;

    // 观察者2
    self.observer2Label = [self createObserverLabelWithFrame:CGRectMake(20, yOffset, screenWidth - 40, 60) title:@"观察者2（成就系统）"];
    [self.view addSubview:self.observer2Label];
    yOffset += 70;

    // 观察者3
    self.observer3Label = [self createObserverLabelWithFrame:CGRectMake(20, yOffset, screenWidth - 40, 60) title:@"观察者3（日志系统）"];
    [self.view addSubview:self.observer3Label];
    yOffset += 80;

    // 按钮
    UIButton *addScoreButton = [UIButton buttonWithType:UIButtonTypeSystem];
    addScoreButton.frame = CGRectMake(20, yOffset, (screenWidth - 50) / 2, 50);
    [addScoreButton setTitle:@"➕ 加分" forState:UIControlStateNormal];
    addScoreButton.backgroundColor = [UIColor systemGreenColor];
    [addScoreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    addScoreButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    addScoreButton.layer.cornerRadius = 10;
    [addScoreButton addTarget:self action:@selector(addScore) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addScoreButton];

    UIButton *levelUpButton = [UIButton buttonWithType:UIButtonTypeSystem];
    levelUpButton.frame = CGRectMake(CGRectGetMaxX(addScoreButton.frame) + 10, yOffset, (screenWidth - 50) / 2, 50);
    [levelUpButton setTitle:@"⬆️ 升级" forState:UIControlStateNormal];
    levelUpButton.backgroundColor = [UIColor systemOrangeColor];
    [levelUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    levelUpButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    levelUpButton.layer.cornerRadius = 10;
    [levelUpButton addTarget:self action:@selector(levelUp) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:levelUpButton];
}

- (UILabel *)createObserverLabelWithFrame:(CGRect)frame title:(NSString *)title {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = [NSString stringWithFormat:@"%@\n等待通知...", title];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:14];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [[UIColor systemGrayColor] colorWithAlphaComponent:0.1];
    label.layer.cornerRadius = 8;
    label.layer.masksToBounds = YES;
    return label;
}

#pragma mark - 注册通知（⭐ 关键）

- (void)registerNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    // 观察者1：监听分数变化
    [center addObserver:self
               selector:@selector(onScoreChanged:)
                   name:kScoreChangedNotification
                 object:nil];

    // 观察者2：监听分数变化（同一个通知，多个观察者）
    [center addObserver:self
               selector:@selector(onScoreChangedForAchievement:)
                   name:kScoreChangedNotification
                 object:nil];

    // 观察者3：监听分数变化
    [center addObserver:self
               selector:@selector(onScoreChangedForLog:)
                   name:kScoreChangedNotification
                 object:nil];

    // 监听升级通知
    [center addObserver:self
               selector:@selector(onLevelUp:)
                   name:kLevelUpNotification
                 object:nil];
}

#pragma mark - 发送通知

- (void)addScore {
    self.score += 10;
    self.scoreLabel.text = [NSString stringWithFormat:@"分数：%ld", (long)self.score];

    // ⭐ 发送通知（携带数据）
    NSDictionary *userInfo = @{@"score": @(self.score)};
    [[NSNotificationCenter defaultCenter] postNotificationName:kScoreChangedNotification
                                                        object:self
                                                      userInfo:userInfo];
}

- (void)levelUp {
    self.level += 1;
    self.levelLabel.text = [NSString stringWithFormat:@"等级：%ld", (long)self.level];

    // ⭐ 发送通知
    NSDictionary *userInfo = @{@"level": @(self.level)};
    [[NSNotificationCenter defaultCenter] postNotificationName:kLevelUpNotification
                                                        object:self
                                                      userInfo:userInfo];
}

#pragma mark - 通知回调（观察者响应）

- (void)onScoreChanged:(NSNotification *)notification {
    NSInteger score = [notification.userInfo[@"score"] integerValue];
    self.observer1Label.text = [NSString stringWithFormat:@"观察者1（UI更新）\n收到通知：分数变为 %ld", (long)score];
    self.observer1Label.backgroundColor = [[UIColor systemGreenColor] colorWithAlphaComponent:0.2];

    // 动画效果
    [self animateLabel:self.observer1Label];
}

- (void)onScoreChangedForAchievement:(NSNotification *)notification {
    NSInteger score = [notification.userInfo[@"score"] integerValue];

    NSString *achievement = @"";
    if (score >= 100) achievement = @"🏆 成就：百分达人";
    else if (score >= 50) achievement = @"🥉 成就：五十分";
    else achievement = @"继续加油！";

    self.observer2Label.text = [NSString stringWithFormat:@"观察者2（成就系统）\n%@", achievement];
    self.observer2Label.backgroundColor = [[UIColor systemOrangeColor] colorWithAlphaComponent:0.2];

    [self animateLabel:self.observer2Label];
}

- (void)onScoreChangedForLog:(NSNotification *)notification {
    NSInteger score = [notification.userInfo[@"score"] integerValue];
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm:ss";
    NSString *timeStr = [formatter stringFromDate:now];

    self.observer3Label.text = [NSString stringWithFormat:@"观察者3（日志系统）\n[%@] 分数更新：%ld", timeStr, (long)score];
    self.observer3Label.backgroundColor = [[UIColor systemBlueColor] colorWithAlphaComponent:0.2];

    [self animateLabel:self.observer3Label];
}

- (void)onLevelUp:(NSNotification *)notification {
    NSInteger level = [notification.userInfo[@"level"] integerValue];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"🎉 恭喜升级！"
                                                                   message:[NSString stringWithFormat:@"您已升至 %ld 级", (long)level]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)animateLabel:(UILabel *)label {
    [UIView animateWithDuration:0.2 animations:^{
        label.transform = CGAffineTransformMakeScale(1.05, 1.05);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            label.transform = CGAffineTransformIdentity;
        }];
    }];
}

#pragma mark - 移除通知（⭐ 重要）

- (void)dealloc {
    // 必须移除观察者，防止崩溃
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

