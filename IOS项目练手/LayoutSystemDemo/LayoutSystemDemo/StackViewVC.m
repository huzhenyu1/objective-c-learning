//
//  StackViewVC.m
//  LayoutSystemDemo
//
//  Created by 胡振宇 on 2025/11/20.
//  StackView 演示 - 简化的栈布局
//

#import "StackViewVC.h"

@interface StackViewVC ()
@property (strong, nonatomic) UIStackView *mainStackView;
@property (strong, nonatomic) UIStackView *horizontalStackView;
@property (strong, nonatomic) NSMutableArray *colorViews;
@end

@implementation StackViewVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"StackView";
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.colorViews = [NSMutableArray array];

    [self setupUI];
}

- (void)setupUI {
    // 说明标签
    UILabel *infoLabel = [[UILabel alloc] init];
    infoLabel.text = @"StackView：简化的栈布局\n自动管理子视图排列\n点击按钮动态添加/删除视图";
    infoLabel.font = [UIFont systemFontOfSize:16];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.numberOfLines = 0;
    infoLabel.textColor = [UIColor secondaryLabelColor];
    infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:infoLabel];

    // 主 StackView（垂直）
    self.mainStackView = [[UIStackView alloc] init];
    self.mainStackView.axis = UILayoutConstraintAxisVertical;
    self.mainStackView.distribution = UIStackViewDistributionFillEqually;
    self.mainStackView.alignment = UIStackViewAlignmentFill;
    self.mainStackView.spacing = 15;
    self.mainStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.mainStackView];

    // 添加初始视图
    [self addColorViewWithColor:[UIColor systemRedColor] label:@"视图 1"];
    [self addColorViewWithColor:[UIColor systemGreenColor] label:@"视图 2"];
    [self addColorViewWithColor:[UIColor systemBlueColor] label:@"视图 3"];

    // 水平 StackView（按钮组）
    self.horizontalStackView = [[UIStackView alloc] init];
    self.horizontalStackView.axis = UILayoutConstraintAxisHorizontal;
    self.horizontalStackView.distribution = UIStackViewDistributionFillEqually;
    self.horizontalStackView.alignment = UIStackViewAlignmentFill;
    self.horizontalStackView.spacing = 10;
    self.horizontalStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.horizontalStackView];

    // 添加按钮
    UIButton *addButton = [self createButton:@"添加" color:[UIColor systemGreenColor] action:@selector(addView)];
    UIButton *removeButton = [self createButton:@"删除" color:[UIColor systemRedColor] action:@selector(removeView)];

    [self.horizontalStackView addArrangedSubview:addButton];
    [self.horizontalStackView addArrangedSubview:removeButton];

    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        // 说明标签
        [infoLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [infoLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [infoLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],

        // 主 StackView
        [self.mainStackView.topAnchor constraintEqualToAnchor:infoLabel.bottomAnchor constant:30],
        [self.mainStackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.mainStackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.mainStackView.bottomAnchor constraintEqualToAnchor:self.horizontalStackView.topAnchor constant:-30],

        // 按钮 StackView
        [self.horizontalStackView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-30],
        [self.horizontalStackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.horizontalStackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.horizontalStackView.heightAnchor constraintEqualToConstant:50]
    ]];
}

- (void)addColorViewWithColor:(UIColor *)color label:(NSString *)labelText {
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = color;
    containerView.layer.cornerRadius = 15;
    containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    containerView.layer.shadowOffset = CGSizeMake(0, 2);
    containerView.layer.shadowOpacity = 0.2;
    containerView.layer.shadowRadius = 4;

    UILabel *label = [[UILabel alloc] init];
    label.text = labelText;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:18];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:label];

    [NSLayoutConstraint activateConstraints:@[
        [label.centerXAnchor constraintEqualToAnchor:containerView.centerXAnchor],
        [label.centerYAnchor constraintEqualToAnchor:containerView.centerYAnchor]
    ]];

    [self.colorViews addObject:containerView];
    [self.mainStackView addArrangedSubview:containerView];
}

- (UIButton *)createButton:(NSString *)title color:(UIColor *)color action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = color;
    button.layer.cornerRadius = 12;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)addView {
    NSArray *colors = @[
        [UIColor systemOrangeColor],
        [UIColor systemPinkColor],
        [UIColor systemPurpleColor],
        [UIColor systemIndigoColor],
        [UIColor systemTealColor],
        [UIColor systemBrownColor]
    ];

    UIColor *randomColor = colors[arc4random_uniform((uint32_t)colors.count)];
    NSString *labelText = [NSString stringWithFormat:@"视图 %lu", (unsigned long)(self.colorViews.count + 1)];

    // 创建新视图
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = randomColor;
    containerView.layer.cornerRadius = 15;
    containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    containerView.layer.shadowOffset = CGSizeMake(0, 2);
    containerView.layer.shadowOpacity = 0.2;
    containerView.layer.shadowRadius = 4;
    containerView.alpha = 0;  // 初始透明

    UILabel *label = [[UILabel alloc] init];
    label.text = labelText;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:18];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:label];

    [NSLayoutConstraint activateConstraints:@[
        [label.centerXAnchor constraintEqualToAnchor:containerView.centerXAnchor],
        [label.centerYAnchor constraintEqualToAnchor:containerView.centerYAnchor]
    ]];

    [self.colorViews addObject:containerView];
    [self.mainStackView addArrangedSubview:containerView];

    // 动画显示
    [UIView animateWithDuration:0.3 animations:^{
        containerView.alpha = 1.0;
    }];
}

- (void)removeView {
    if (self.colorViews.count > 1) {
        UIView *lastView = [self.colorViews lastObject];

        // 动画移除
        [UIView animateWithDuration:0.3 animations:^{
            lastView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.mainStackView removeArrangedSubview:lastView];
            [lastView removeFromSuperview];
            [self.colorViews removeLastObject];
        }];
    } else {
        // 显示提示
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"提示"
            message:@"至少保留一个视图"
            preferredStyle:UIAlertControllerStyleAlert];

        [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end
