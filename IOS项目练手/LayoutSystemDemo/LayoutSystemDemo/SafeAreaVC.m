//
//  SafeAreaVC.m
//  LayoutSystemDemo
//
//  Created by 胡振宇 on 2025/11/20.
//  Safe Area 演示 - 安全区域和横竖屏适配
//

#import "SafeAreaVC.h"

@interface SafeAreaVC ()
@property (strong, nonatomic) UIView *topBar;
@property (strong, nonatomic) UIView *bottomBar;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UILabel *orientationLabel;
@end

@implementation SafeAreaVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Safe Area";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupUI];
}

- (void)setupUI {
    // 顶部栏（使用 Safe Area）
    self.topBar = [[UIView alloc] init];
    self.topBar.backgroundColor = [UIColor systemBlueColor];
    self.topBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.topBar];

    UILabel *topLabel = [[UILabel alloc] init];
    topLabel.text = @"顶部安全区域";
    topLabel.textAlignment = NSTextAlignmentCenter;
    topLabel.textColor = [UIColor whiteColor];
    topLabel.font = [UIFont boldSystemFontOfSize:16];
    topLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.topBar addSubview:topLabel];

    // 内容区域
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = [UIColor systemGray6Color];
    self.contentView.layer.cornerRadius = 20;
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.contentView];

    // 说明标签
    UILabel *infoLabel = [[UILabel alloc] init];
    infoLabel.text = @"Safe Area：安全区域\n\n自动避开刘海、Home Indicator等\n旋转设备查看适配效果\n\n顶部和底部的蓝色/绿色区域\n会自动适配安全区域";
    infoLabel.font = [UIFont systemFontOfSize:16];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.numberOfLines = 0;
    infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:infoLabel];

    // 方向显示标签
    self.orientationLabel = [[UILabel alloc] init];
    [self updateOrientationLabel];
    self.orientationLabel.font = [UIFont boldSystemFontOfSize:20];
    self.orientationLabel.textAlignment = NSTextAlignmentCenter;
    self.orientationLabel.textColor = [UIColor systemPurpleColor];
    self.orientationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.orientationLabel];

    // 底部栏（使用 Safe Area）
    self.bottomBar = [[UIView alloc] init];
    self.bottomBar.backgroundColor = [UIColor systemGreenColor];
    self.bottomBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.bottomBar];

    UILabel *bottomLabel = [[UILabel alloc] init];
    bottomLabel.text = @"底部安全区域";
    bottomLabel.textAlignment = NSTextAlignmentCenter;
    bottomLabel.textColor = [UIColor whiteColor];
    bottomLabel.font = [UIFont boldSystemFontOfSize:16];
    bottomLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.bottomBar addSubview:bottomLabel];

    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        // 顶部栏 - 从安全区域顶部开始
        [self.topBar.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.topBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.topBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.topBar.heightAnchor constraintEqualToConstant:60],

        [topLabel.centerXAnchor constraintEqualToAnchor:self.topBar.centerXAnchor],
        [topLabel.centerYAnchor constraintEqualToAnchor:self.topBar.centerYAnchor],

        // 底部栏 - 到安全区域底部结束
        [self.bottomBar.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [self.bottomBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.bottomBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.bottomBar.heightAnchor constraintEqualToConstant:60],

        [bottomLabel.centerXAnchor constraintEqualToAnchor:self.bottomBar.centerXAnchor],
        [bottomLabel.centerYAnchor constraintEqualToAnchor:self.bottomBar.centerYAnchor],

        // 内容区域 - 在顶部和底部栏之间
        [self.contentView.topAnchor constraintEqualToAnchor:self.topBar.bottomAnchor constant:20],
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.bottomBar.topAnchor constant:-20],
        [self.contentView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],

        // 说明标签
        [infoLabel.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
        [infoLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor constant:-40],
        [infoLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        [infoLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20],

        // 方向标签
        [self.orientationLabel.topAnchor constraintEqualToAnchor:infoLabel.bottomAnchor constant:30],
        [self.orientationLabel.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor]
    ]];
}

// 处理屏幕旋转
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self updateOrientationLabel];
    } completion:nil];
}

- (void)updateOrientationLabel {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];

    if (orientation == UIInterfaceOrientationPortrait) {
        self.orientationLabel.text = @"📱 竖屏模式";
    } else if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        self.orientationLabel.text = @"📱 横屏模式";
    } else {
        self.orientationLabel.text = @"📱 当前方向";
    }
}

@end
