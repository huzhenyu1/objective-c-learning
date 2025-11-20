//
//  AutoLayoutVC.m
//  LayoutSystemDemo
//
//  Created by 胡振宇 on 2025/11/20.
//  Auto Layout 演示 - 现代约束布局系统
//

#import "AutoLayoutVC.h"

@interface AutoLayoutVC ()
@property (strong, nonatomic) UIView *centerBox;
@property (strong, nonatomic) UIView *topBox;
@property (strong, nonatomic) UIView *bottomBox;
@property (strong, nonatomic) UILabel *infoLabel;
@property (strong, nonatomic) NSLayoutConstraint *centerBoxWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *centerBoxHeightConstraint;
@property (nonatomic, assign) BOOL isExpanded;
@end

@implementation AutoLayoutVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Auto Layout";
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.isExpanded = NO;

    [self setupUI];
}

- (void)setupUI {
    // 说明标签
    self.infoLabel = [[UILabel alloc] init];
    self.infoLabel.text = @"Auto Layout：约束布局\n自动适配不同屏幕和方向\n点击按钮查看约束动画";
    self.infoLabel.font = [UIFont systemFontOfSize:16];
    self.infoLabel.textAlignment = NSTextAlignmentCenter;
    self.infoLabel.numberOfLines = 0;
    self.infoLabel.textColor = [UIColor secondaryLabelColor];
    self.infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.infoLabel];

    // 顶部方块
    self.topBox = [[UIView alloc] init];
    self.topBox.backgroundColor = [UIColor systemOrangeColor];
    self.topBox.layer.cornerRadius = 15;
    self.topBox.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.topBox];

    UILabel *topLabel = [[UILabel alloc] init];
    topLabel.text = @"顶部固定";
    topLabel.textAlignment = NSTextAlignmentCenter;
    topLabel.textColor = [UIColor whiteColor];
    topLabel.font = [UIFont boldSystemFontOfSize:16];
    topLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.topBox addSubview:topLabel];

    // 中心方块（可变大小）
    self.centerBox = [[UIView alloc] init];
    self.centerBox.backgroundColor = [UIColor systemPurpleColor];
    self.centerBox.layer.cornerRadius = 15;
    self.centerBox.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.centerBox];

    UILabel *centerLabel = [[UILabel alloc] init];
    centerLabel.text = @"居中可变";
    centerLabel.textAlignment = NSTextAlignmentCenter;
    centerLabel.textColor = [UIColor whiteColor];
    centerLabel.font = [UIFont boldSystemFontOfSize:16];
    centerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.centerBox addSubview:centerLabel];

    // 底部方块
    self.bottomBox = [[UIView alloc] init];
    self.bottomBox.backgroundColor = [UIColor systemTealColor];
    self.bottomBox.layer.cornerRadius = 15;
    self.bottomBox.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.bottomBox];

    UILabel *bottomLabel = [[UILabel alloc] init];
    bottomLabel.text = @"底部固定";
    bottomLabel.textAlignment = NSTextAlignmentCenter;
    bottomLabel.textColor = [UIColor whiteColor];
    bottomLabel.font = [UIFont boldSystemFontOfSize:16];
    bottomLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.bottomBox addSubview:bottomLabel];

    // 动画按钮
    UIButton *animateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [animateButton setTitle:@"切换大小" forState:UIControlStateNormal];
    [animateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    animateButton.backgroundColor = [UIColor systemBlueColor];
    animateButton.layer.cornerRadius = 12;
    animateButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    animateButton.translatesAutoresizingMaskIntoConstraints = NO;
    [animateButton addTarget:self action:@selector(toggleSize) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:animateButton];

    // 创建约束
    [self setupConstraints:topLabel centerLabel:centerLabel bottomLabel:bottomLabel animateButton:animateButton];
}

- (void)setupConstraints:(UILabel *)topLabel centerLabel:(UILabel *)centerLabel bottomLabel:(UILabel *)bottomLabel animateButton:(UIButton *)animateButton {
    // 说明标签约束
    [NSLayoutConstraint activateConstraints:@[
        [self.infoLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [self.infoLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.infoLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20]
    ]];

    // 顶部方块约束
    [NSLayoutConstraint activateConstraints:@[
        [self.topBox.topAnchor constraintEqualToAnchor:self.infoLabel.bottomAnchor constant:30],
        [self.topBox.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.topBox.widthAnchor constraintEqualToConstant:150],
        [self.topBox.heightAnchor constraintEqualToConstant:80]
    ]];

    [NSLayoutConstraint activateConstraints:@[
        [topLabel.centerXAnchor constraintEqualToAnchor:self.topBox.centerXAnchor],
        [topLabel.centerYAnchor constraintEqualToAnchor:self.topBox.centerYAnchor]
    ]];

    // 中心方块约束（保存宽高约束以便后续修改）
    self.centerBoxWidthConstraint = [self.centerBox.widthAnchor constraintEqualToConstant:120];
    self.centerBoxHeightConstraint = [self.centerBox.heightAnchor constraintEqualToConstant:120];

    [NSLayoutConstraint activateConstraints:@[
        [self.centerBox.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.centerBox.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        self.centerBoxWidthConstraint,
        self.centerBoxHeightConstraint
    ]];

    [NSLayoutConstraint activateConstraints:@[
        [centerLabel.centerXAnchor constraintEqualToAnchor:self.centerBox.centerXAnchor],
        [centerLabel.centerYAnchor constraintEqualToAnchor:self.centerBox.centerYAnchor]
    ]];

    // 底部方块约束
    [NSLayoutConstraint activateConstraints:@[
        [self.bottomBox.bottomAnchor constraintEqualToAnchor:animateButton.topAnchor constant:-30],
        [self.bottomBox.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.bottomBox.widthAnchor constraintEqualToConstant:150],
        [self.bottomBox.heightAnchor constraintEqualToConstant:80]
    ]];

    [NSLayoutConstraint activateConstraints:@[
        [bottomLabel.centerXAnchor constraintEqualToAnchor:self.bottomBox.centerXAnchor],
        [bottomLabel.centerYAnchor constraintEqualToAnchor:self.bottomBox.centerYAnchor]
    ]];

    // 动画按钮约束
    [NSLayoutConstraint activateConstraints:@[
        [animateButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-30],
        [animateButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [animateButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [animateButton.heightAnchor constraintEqualToConstant:50]
    ]];
}

- (void)toggleSize {
    self.isExpanded = !self.isExpanded;

    // 修改约束值
    if (self.isExpanded) {
        self.centerBoxWidthConstraint.constant = 200;
        self.centerBoxHeightConstraint.constant = 200;
    } else {
        self.centerBoxWidthConstraint.constant = 120;
        self.centerBoxHeightConstraint.constant = 120;
    }

    // 动画更新约束
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];  // 触发布局更新
    } completion:nil];
}

@end
