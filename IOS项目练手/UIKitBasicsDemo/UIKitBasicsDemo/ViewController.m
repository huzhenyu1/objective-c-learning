//
//  ViewController.m
//  UIKitBasicsDemo
//
//  Created by 胡振宇 on 2025/11/20.
//  这是第一阶段的完整项目，包含所有基础组件和练习任务
//

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>  // 震动需要

@interface ViewController () <UITextFieldDelegate>

// 基础组件
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UILabel *counterLabel;
@property (strong, nonatomic) UIView *colorBoxView;
@property (strong, nonatomic) UIImageView *starImageView;
@property (strong, nonatomic) UIButton *mainButton;
@property (strong, nonatomic) UIButton *resetButton;

// 练习任务1：额外组件
@property (strong, nonatomic) UITextField *titleTextField;
@property (strong, nonatomic) UISlider *sizeSlider;
@property (strong, nonatomic) UISwitch *animationSwitch;
@property (strong, nonatomic) UILabel *sliderValueLabel;
@property (strong, nonatomic) UILabel *switchLabel;

// 渐变图层
@property (strong, nonatomic) CAGradientLayer *gradientLayer;

// 状态数据
@property (nonatomic, assign) NSInteger clickCount;
@property (strong, nonatomic) UIImpactFeedbackGenerator *impactFeedback;

@end

@implementation ViewController

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.clickCount = 0;

    // 初始化触觉反馈生成器
    self.impactFeedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    [self.impactFeedback prepare];

    [self setupUI];
    [self setupGestures];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    // 在布局完成后设置渐变图层的 frame
    if (self.gradientLayer) {
        self.gradientLayer.frame = self.titleLabel.bounds;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"视图即将显示");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"视图已经显示");
}

#pragma mark - UI 设置

- (void)setupUI {
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat padding = 20;
    CGFloat yOffset = 80;

    // 1. 文本输入框（练习任务1）
    self.titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 40)];
    self.titleTextField.placeholder = @"在这里输入自定义标题...";
    self.titleTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.titleTextField.font = [UIFont systemFontOfSize:16];
    self.titleTextField.delegate = self;
    self.titleTextField.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:self.titleTextField];
    yOffset += 55;

    // 2. 标题标签（带渐变背景 - 练习任务3）
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 50)];
    self.titleLabel.text = @"📝 UIKit 完整演示";
    self.titleLabel.font = [UIFont boldSystemFontOfSize:28];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor whiteColor];
    [self addGradientToLabel:self.titleLabel];  // 添加渐变背景
    [self.view addSubview:self.titleLabel];
    yOffset += 65;

    // 3. 描述标签
    self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 60)];
    self.descriptionLabel.text = @"这是一个完整的 UIKit 演示项目\n包含所有基础组件和练习任务";
    self.descriptionLabel.font = [UIFont systemFontOfSize:14];
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    self.descriptionLabel.textColor = [UIColor secondaryLabelColor];
    self.descriptionLabel.numberOfLines = 0;
    [self.view addSubview:self.descriptionLabel];
    yOffset += 75;

    // 4. 彩色方块（可点击 - 练习任务2）
    CGFloat boxSize = 100;
    self.colorBoxView = [[UIView alloc] initWithFrame:CGRectMake((screenWidth - boxSize) / 2, yOffset, boxSize, boxSize)];
    self.colorBoxView.backgroundColor = [UIColor systemPurpleColor];
    self.colorBoxView.layer.cornerRadius = 15;
    // 添加阴影（练习任务3）
    self.colorBoxView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.colorBoxView.layer.shadowOffset = CGSizeMake(0, 4);
    self.colorBoxView.layer.shadowOpacity = 0.3;
    self.colorBoxView.layer.shadowRadius = 8;
    self.colorBoxView.userInteractionEnabled = YES;  // 允许交互
    [self.view addSubview:self.colorBoxView];
    yOffset += boxSize + 20;

    // 5. 星星图标
    self.starImageView = [[UIImageView alloc] initWithFrame:CGRectMake((screenWidth - 60) / 2, yOffset, 60, 60)];
    self.starImageView.image = [UIImage systemImageNamed:@"star.fill"];
    self.starImageView.tintColor = [UIColor systemYellowColor];
    self.starImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.starImageView];
    yOffset += 75;

    // 6. 大小滑块（练习任务1）
    UILabel *sliderTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, 60, 30)];
    sliderTitleLabel.text = @"大小:";
    sliderTitleLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:sliderTitleLabel];

    self.sizeSlider = [[UISlider alloc] initWithFrame:CGRectMake(padding + 65, yOffset, screenWidth - 2 * padding - 130, 30)];
    self.sizeSlider.minimumValue = 50;
    self.sizeSlider.maximumValue = 200;
    self.sizeSlider.value = 100;
    [self.sizeSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.sizeSlider];

    self.sliderValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth - padding - 50, yOffset, 50, 30)];
    self.sliderValueLabel.text = @"100";
    self.sliderValueLabel.textAlignment = NSTextAlignmentRight;
    self.sliderValueLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:self.sliderValueLabel];
    yOffset += 45;

    // 7. 动画开关（练习任务1）
    self.switchLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, 120, 30)];
    self.switchLabel.text = @"动画开关: ⚡";
    self.switchLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:self.switchLabel];

    self.animationSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(padding + 130, yOffset, 51, 31)];
    self.animationSwitch.on = YES;  // 默认开启动画
    [self.view addSubview:self.animationSwitch];
    yOffset += 50;

    // 8. 主按钮（带阴影 - 练习任务3）
    CGFloat buttonWidth = (screenWidth - 3 * padding) / 2;
    self.mainButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.mainButton.frame = CGRectMake(padding, yOffset, buttonWidth, 50);
    [self.mainButton setTitle:@"点击我试试" forState:UIControlStateNormal];
    [self.mainButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.mainButton.backgroundColor = [UIColor systemBlueColor];
    self.mainButton.layer.cornerRadius = 12;
    self.mainButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    // 添加阴影（练习任务3）
    self.mainButton.layer.shadowColor = [UIColor systemBlueColor].CGColor;
    self.mainButton.layer.shadowOffset = CGSizeMake(0, 4);
    self.mainButton.layer.shadowOpacity = 0.5;
    self.mainButton.layer.shadowRadius = 8;
    [self.mainButton addTarget:self action:@selector(mainButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.mainButton];

    // 9. 重置按钮（带阴影）
    self.resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.resetButton.frame = CGRectMake(padding + buttonWidth + padding, yOffset, buttonWidth, 50);
    [self.resetButton setTitle:@"重置" forState:UIControlStateNormal];
    [self.resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.resetButton.backgroundColor = [UIColor systemRedColor];
    self.resetButton.layer.cornerRadius = 12;
    self.resetButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    // 添加阴影
    self.resetButton.layer.shadowColor = [UIColor systemRedColor].CGColor;
    self.resetButton.layer.shadowOffset = CGSizeMake(0, 4);
    self.resetButton.layer.shadowOpacity = 0.5;
    self.resetButton.layer.shadowRadius = 8;
    [self.resetButton addTarget:self action:@selector(resetButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.resetButton];
    yOffset += 65;

    // 10. 点击计数标签
    self.counterLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 30)];
    self.counterLabel.text = @"点击次数: 0";
    self.counterLabel.textAlignment = NSTextAlignmentCenter;
    self.counterLabel.font = [UIFont systemFontOfSize:16];
    self.counterLabel.textColor = [UIColor secondaryLabelColor];
    [self.view addSubview:self.counterLabel];
}

// 添加渐变背景到标签（练习任务3）
- (void)addGradientToLabel:(UILabel *)label {
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.colors = @[
        (id)[UIColor systemBlueColor].CGColor,
        (id)[UIColor systemPurpleColor].CGColor
    ];
    self.gradientLayer.startPoint = CGPointMake(0, 0);
    self.gradientLayer.endPoint = CGPointMake(1, 1);
    self.gradientLayer.cornerRadius = 12;

    // 添加到标签的最底层
    [label.layer insertSublayer:self.gradientLayer atIndex:0];
    label.layer.masksToBounds = YES;
}

#pragma mark - 手势设置（练习任务2）

- (void)setupGestures {
    // 1. 点击彩色方块
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(colorBoxTapped:)];
    [self.colorBoxView addGestureRecognizer:tapGesture];

    // 2. 长按主按钮
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(mainButtonLongPressed:)];
    longPressGesture.minimumPressDuration = 1.0;  // 长按1秒
    [self.mainButton addGestureRecognizer:longPressGesture];

    // 3. 点击空白处收起键盘
    UITapGestureRecognizer *dismissKeyboardGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    dismissKeyboardGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:dismissKeyboardGesture];
}

#pragma mark - 按钮事件

- (void)mainButtonTapped:(UIButton *)sender {
    self.clickCount++;
    self.counterLabel.text = [NSString stringWithFormat:@"点击次数: %ld", (long)self.clickCount];

    // 震动反馈（练习任务2）
    [self.impactFeedback impactOccurred];

    // 按钮缩放动画（练习任务3）
    [self animateButtonPress:sender];

    // 改变方块颜色
    [self changeColorBoxColor];

    // 旋转星星
    [self rotateStarImage];

    // 每3次点击弹出提示
    if (self.clickCount % 3 == 0) {
        [self showAlert];
    }
}

- (void)resetButtonTapped:(UIButton *)sender {
    // 震动反馈
    [self.impactFeedback impactOccurred];

    // 按钮缩放动画
    [self animateButtonPress:sender];

    // 重置所有状态
    self.clickCount = 0;
    self.counterLabel.text = @"点击次数: 0";

    self.titleLabel.text = @"📝 UIKit 完整演示";
    self.titleTextField.text = @"";

    // 重置方块
    CGFloat animationDuration = self.animationSwitch.isOn ? 0.3 : 0;
    [UIView animateWithDuration:animationDuration animations:^{
        self.colorBoxView.backgroundColor = [UIColor systemPurpleColor];

        CGFloat boxSize = 100;
        CGFloat screenWidth = self.view.bounds.size.width;
        self.colorBoxView.frame = CGRectMake((screenWidth - boxSize) / 2, self.colorBoxView.frame.origin.y, boxSize, boxSize);
    }];

    // 重置滑块
    self.sizeSlider.value = 100;
    self.sliderValueLabel.text = @"100";

    // 重置星星旋转
    self.starImageView.transform = CGAffineTransformIdentity;

    NSLog(@"所有状态已重置");
}

#pragma mark - 手势事件（练习任务2）

- (void)colorBoxTapped:(UITapGestureRecognizer *)gesture {
    NSLog(@"彩色方块被点击");

    // 震动反馈
    [self.impactFeedback impactOccurred];

    // 改变颜色
    [self changeColorBoxColor];

    // 弹跳动画（练习任务3）
    [self animateBounce:self.colorBoxView];
}

- (void)mainButtonLongPressed:(UILongPressGestureRecognizer *)gesture {
    // 只在手势开始时触发一次
    if (gesture.state == UIGestureRecognizerStateBegan) {
        NSLog(@"主按钮被长按");

        // 震动反馈（使用通知类型）
        UINotificationFeedbackGenerator *notificationFeedback = [[UINotificationFeedbackGenerator alloc] init];
        [notificationFeedback notificationOccurred:UINotificationFeedbackTypeSuccess];

        // 显示特殊提示
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"🎉 发现彩蛋！"
            message:@"你发现了长按功能！\n试试点击彩色方块和调整滑块吧~"
            preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *okAction = [UIAlertAction
            actionWithTitle:@"太棒了！"
            style:UIAlertActionStyleDefault
            handler:nil];

        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - 滑块事件（练习任务1）

- (void)sliderValueChanged:(UISlider *)slider {
    NSInteger value = (NSInteger)slider.value;
    self.sliderValueLabel.text = [NSString stringWithFormat:@"%ld", (long)value];

    // 改变方块大小（带弹性动画）
    CGFloat newSize = slider.value;
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat newX = (screenWidth - newSize) / 2;

    CGFloat animationDuration = self.animationSwitch.isOn ? 0.3 : 0;

    if (animationDuration > 0) {
        // 弹性动画（练习任务3）
        [UIView animateWithDuration:animationDuration
                              delay:0
             usingSpringWithDamping:0.6  // 弹性阻尼
              initialSpringVelocity:0.5
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
            self.colorBoxView.frame = CGRectMake(newX, self.colorBoxView.frame.origin.y, newSize, newSize);
        } completion:nil];
    } else {
        // 无动画
        self.colorBoxView.frame = CGRectMake(newX, self.colorBoxView.frame.origin.y, newSize, newSize);
    }
}

#pragma mark - UITextField Delegate（练习任务1）

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];  // 收起键盘
    return YES;
}

- (void)textFieldDidChangeSelection:(UITextField *)textField {
    // 实时更新标题
    if (textField.text.length > 0) {
        self.titleLabel.text = textField.text;
    } else {
        self.titleLabel.text = @"📝 UIKit 完整演示";
    }
}

- (void)dismissKeyboard {
    [self.titleTextField resignFirstResponder];
}

#pragma mark - 动画效果（练习任务3）

// 改变方块颜色
- (void)changeColorBoxColor {
    NSArray *colors = @[
        [UIColor systemRedColor],
        [UIColor systemOrangeColor],
        [UIColor systemYellowColor],
        [UIColor systemGreenColor],
        [UIColor systemBlueColor],
        [UIColor systemIndigoColor],
        [UIColor systemPurpleColor],
        [UIColor systemPinkColor]
    ];

    UIColor *randomColor = colors[arc4random_uniform((uint32_t)colors.count)];

    CGFloat animationDuration = self.animationSwitch.isOn ? 0.3 : 0;
    [UIView animateWithDuration:animationDuration animations:^{
        self.colorBoxView.backgroundColor = randomColor;
    }];
}

// 旋转星星图标
- (void)rotateStarImage {
    CGFloat animationDuration = self.animationSwitch.isOn ? 0.5 : 0;

    if (animationDuration > 0) {
        [UIView animateWithDuration:animationDuration animations:^{
            self.starImageView.transform = CGAffineTransformRotate(self.starImageView.transform, M_PI);
        }];
    }
}

// 按钮按下动画
- (void)animateButtonPress:(UIButton *)button {
    CGFloat animationDuration = self.animationSwitch.isOn ? 0.1 : 0;

    if (animationDuration > 0) {
        // 缩小
        [UIView animateWithDuration:animationDuration animations:^{
            button.transform = CGAffineTransformMakeScale(0.95, 0.95);
        } completion:^(BOOL finished) {
            // 恢复
            [UIView animateWithDuration:animationDuration animations:^{
                button.transform = CGAffineTransformIdentity;
            }];
        }];
    }
}

// 弹跳动画
- (void)animateBounce:(UIView *)view {
    CGFloat animationDuration = self.animationSwitch.isOn ? 0.4 : 0;

    if (animationDuration > 0) {
        [UIView animateWithDuration:animationDuration
                              delay:0
             usingSpringWithDamping:0.3  // 更小的阻尼 = 更大的弹跳
              initialSpringVelocity:1.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
            view.transform = CGAffineTransformMakeScale(1.1, 1.1);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:animationDuration
                                  delay:0
                 usingSpringWithDamping:0.3
                  initialSpringVelocity:1.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                view.transform = CGAffineTransformIdentity;
            } completion:nil];
        }];
    }
}

#pragma mark - 提示框

- (void)showAlert {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"📊 统计信息"
        message:[NSString stringWithFormat:@"你已经点击了 %ld 次\n继续加油！", (long)self.clickCount]
        preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction
        actionWithTitle:@"知道了"
        style:UIAlertActionStyleDefault
        handler:nil];

    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 内存管理

- (void)dealloc {
    NSLog(@"ViewController 被释放");
}

@end
