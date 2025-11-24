//
//  ObserverViewController.m
//  DesignPatternsDemo
//
//  KVO 观察者模式演示：键值观察（Key-Value Observing）
//

#import "ObserverViewController.h"

#pragma mark - Model（被观察对象）

@interface Player : NSObject
@property (copy, nonatomic) NSString *name;
@property (assign, nonatomic) NSInteger health;  // 血量
@property (assign, nonatomic) NSInteger mana;    // 魔法值
@property (assign, nonatomic) NSInteger level;   // 等级
@end

@implementation Player
@end

#pragma mark - Controller

@interface ObserverViewController ()
@property (strong, nonatomic) Player *player;

@property (strong, nonatomic) UILabel *healthLabel;
@property (strong, nonatomic) UIProgressView *healthBar;

@property (strong, nonatomic) UILabel *manaLabel;
@property (strong, nonatomic) UIProgressView *manaBar;

@property (strong, nonatomic) UILabel *levelLabel;
@property (strong, nonatomic) UILabel *statusLabel;
@end

@implementation ObserverViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"KVO 观察者模式";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupModel];
    [self setupUI];
    [self registerKVO];  // ⭐ 注册 KVO
}

- (void)setupModel {
    self.player = [[Player alloc] init];
    self.player.name = @"勇士";
    self.player.health = 100;
    self.player.mana = 50;
    self.player.level = 1;
}

- (void)setupUI {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat yOffset = 100;

    // 说明
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, yOffset, screenWidth - 40, 80)];
    descLabel.text = @"KVO（键值观察）：\n观察对象属性的变化，自动收到通知\n点击按钮修改属性，观察UI的自动更新";
    descLabel.numberOfLines = 0;
    descLabel.font = [UIFont systemFontOfSize:14];
    descLabel.textColor = [UIColor secondaryLabelColor];
    [self.view addSubview:descLabel];
    yOffset += 100;

    // 玩家信息
    UILabel *playerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, yOffset, screenWidth - 40, 30)];
    playerLabel.text = [NSString stringWithFormat:@"👤 %@ (等级 %ld)", self.player.name, (long)self.player.level];
    playerLabel.font = [UIFont boldSystemFontOfSize:18];
    playerLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:playerLabel];
    self.levelLabel = playerLabel;
    yOffset += 50;

    // 血量
    UILabel *healthTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, yOffset, 100, 30)];
    healthTitle.text = @"❤️ 血量:";
    healthTitle.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:healthTitle];

    self.healthLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth - 100, yOffset, 80, 30)];
    self.healthLabel.text = [NSString stringWithFormat:@"%ld/100", (long)self.player.health];
    self.healthLabel.textAlignment = NSTextAlignmentRight;
    self.healthLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.view addSubview:self.healthLabel];
    yOffset += 35;

    self.healthBar = [[UIProgressView alloc] initWithFrame:CGRectMake(20, yOffset, screenWidth - 40, 4)];
    self.healthBar.progress = self.player.health / 100.0;
    self.healthBar.progressTintColor = [UIColor systemRedColor];
    [self.view addSubview:self.healthBar];
    yOffset += 30;

    // 魔法值
    UILabel *manaTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, yOffset, 100, 30)];
    manaTitle.text = @"💙 魔法:";
    manaTitle.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:manaTitle];

    self.manaLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth - 100, yOffset, 80, 30)];
    self.manaLabel.text = [NSString stringWithFormat:@"%ld/100", (long)self.player.mana];
    self.manaLabel.textAlignment = NSTextAlignmentRight;
    self.manaLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.view addSubview:self.manaLabel];
    yOffset += 35;

    self.manaBar = [[UIProgressView alloc] initWithFrame:CGRectMake(20, yOffset, screenWidth - 40, 4)];
    self.manaBar.progress = self.player.mana / 100.0;
    self.manaBar.progressTintColor = [UIColor systemBlueColor];
    [self.view addSubview:self.manaBar];
    yOffset += 50;

    // 状态标签
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, yOffset, screenWidth - 40, 60)];
    self.statusLabel.text = @"KVO 正在监听属性变化...";
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.font = [UIFont systemFontOfSize:14];
    self.statusLabel.textColor = [UIColor systemGreenColor];
    self.statusLabel.backgroundColor = [[UIColor systemGrayColor] colorWithAlphaComponent:0.1];
    self.statusLabel.layer.cornerRadius = 8;
    self.statusLabel.layer.masksToBounds = YES;
    [self.view addSubview:self.statusLabel];
    yOffset += 80;

    // 按钮
    NSArray *buttons = @[
        @{@"title": @"🩹 恢复血量 +20", @"action": @"addHealth"},
        @{@"title": @"⚔️ 受伤 -30", @"action": @"takeDamage"},
        @{@"title": @"💧 恢复魔法 +25", @"action": @"restoreMana"},
        @{@"title": @"🔮 使用魔法 -20", @"action": @"useMana"},
        @{@"title": @"⬆️ 升级", @"action": @"levelUp"}
    ];

    for (NSDictionary *btnInfo in buttons) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(20, yOffset, screenWidth - 40, 44);
        [button setTitle:btnInfo[@"title"] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor systemBlueColor];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        button.layer.cornerRadius = 8;

        SEL action = NSSelectorFromString(btnInfo[@"action"]);
        [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];

        yOffset += 50;
    }
}

#pragma mark - 注册 KVO（⭐ 关键）

- (void)registerKVO {
    // 观察 health 属性
    [self.player addObserver:self
                  forKeyPath:@"health"
                     options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                     context:NULL];

    // 观察 mana 属性
    [self.player addObserver:self
                  forKeyPath:@"mana"
                     options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                     context:NULL];

    // 观察 level 属性
    [self.player addObserver:self
                  forKeyPath:@"level"
                     options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                     context:NULL];
}

#pragma mark - KVO 回调（⭐ 自动触发）

- (void)observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                        context:(void *)context {

    if ([keyPath isEqualToString:@"health"]) {
        NSInteger oldValue = [change[NSKeyValueChangeOldKey] integerValue];
        NSInteger newValue = [change[NSKeyValueChangeNewKey] integerValue];

        // 自动更新 UI
        self.healthLabel.text = [NSString stringWithFormat:@"%ld/100", (long)newValue];
        self.healthBar.progress = newValue / 100.0;

        // 状态提示
        if (newValue > oldValue) {
            self.statusLabel.text = [NSString stringWithFormat:@"KVO 监听到血量变化\n%ld → %ld（+%ld）", (long)oldValue, (long)newValue, (long)(newValue - oldValue)];
            self.statusLabel.textColor = [UIColor systemGreenColor];
        } else {
            self.statusLabel.text = [NSString stringWithFormat:@"KVO 监听到血量变化\n%ld → %ld（%ld）", (long)oldValue, (long)newValue, (long)(newValue - oldValue)];
            self.statusLabel.textColor = [UIColor systemRedColor];
        }

        // 血量低警告
        if (newValue < 30) {
            [self showAlert:@"⚠️ 血量过低！" message:@"快恢复血量！"];
        }

    } else if ([keyPath isEqualToString:@"mana"]) {
        NSInteger oldValue = [change[NSKeyValueChangeOldKey] integerValue];
        NSInteger newValue = [change[NSKeyValueChangeNewKey] integerValue];

        self.manaLabel.text = [NSString stringWithFormat:@"%ld/100", (long)newValue];
        self.manaBar.progress = newValue / 100.0;

        self.statusLabel.text = [NSString stringWithFormat:@"KVO 监听到魔法值变化\n%ld → %ld", (long)oldValue, (long)newValue];
        self.statusLabel.textColor = [UIColor systemBlueColor];

    } else if ([keyPath isEqualToString:@"level"]) {
        NSInteger newLevel = [change[NSKeyValueChangeNewKey] integerValue];

        self.levelLabel.text = [NSString stringWithFormat:@"👤 %@ (等级 %ld)", self.player.name, (long)newLevel];

        self.statusLabel.text = [NSString stringWithFormat:@"KVO 监听到等级提升\n等级: %ld", (long)newLevel];
        self.statusLabel.textColor = [UIColor systemOrangeColor];

        [self showAlert:@"🎉 升级成功！" message:[NSString stringWithFormat:@"恭喜升至 %ld 级", (long)newLevel]];
    }
}

#pragma mark - Actions（修改属性，自动触发 KVO）

- (void)addHealth {
    self.player.health = MIN(100, self.player.health + 20);  // ⭐ 修改属性，触发 KVO
}

- (void)takeDamage {
    self.player.health = MAX(0, self.player.health - 30);
}

- (void)restoreMana {
    self.player.mana = MIN(100, self.player.mana + 25);
}

- (void)useMana {
    if (self.player.mana >= 20) {
        self.player.mana -= 20;
    } else {
        [self showAlert:@"魔法值不足" message:@"无法使用魔法"];
    }
}

- (void)levelUp {
    self.player.level += 1;
    self.player.health = 100;  // 升级恢复满血
    self.player.mana = 100;    // 升级恢复满魔法
}

- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 移除 KVO（⭐ 必须）

- (void)dealloc {
    // 必须移除观察者，否则崩溃
    [self.player removeObserver:self forKeyPath:@"health"];
    [self.player removeObserver:self forKeyPath:@"mana"];
    [self.player removeObserver:self forKeyPath:@"level"];
}

@end

