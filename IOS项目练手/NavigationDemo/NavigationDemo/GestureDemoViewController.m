//
//  GestureDemoViewController.m
//  NavigationDemo
//
//  Created by 胡振宇 on 2025/11/20.
//  手势识别演示
//

#import "GestureDemoViewController.h"

@interface GestureDemoViewController ()
@property (strong, nonatomic) UIView *gestureBox;
@property (strong, nonatomic) UILabel *infoLabel;
@end

@implementation GestureDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"手势识别";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupUI];
    [self setupGestures];
}

- (void)setupUI {
    CGFloat padding = 20;
    CGFloat screenWidth = self.view.bounds.size.width;

    // 说明标签
    self.infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 100, screenWidth - 2 * padding, 80)];
    self.infoLabel.text = @"UIGestureRecognizer\n\n在下方方块上尝试各种手势";
    self.infoLabel.font = [UIFont systemFontOfSize:16];
    self.infoLabel.textAlignment = NSTextAlignmentCenter;
    self.infoLabel.numberOfLines = 0;
    self.infoLabel.textColor = [UIColor secondaryLabelColor];
    [self.view addSubview:self.infoLabel];

    // 手势操作的方块
    CGFloat boxSize = 150;
    self.gestureBox = [[UIView alloc] initWithFrame:CGRectMake((screenWidth - boxSize) / 2, 230, boxSize, boxSize)];
    self.gestureBox.backgroundColor = [UIColor systemPurpleColor];
    self.gestureBox.layer.cornerRadius = 20;
    self.gestureBox.userInteractionEnabled = YES;
    [self.view addSubview:self.gestureBox];

    UILabel *boxLabel = [[UILabel alloc] initWithFrame:self.gestureBox.bounds];
    boxLabel.text = @"试试看\n各种手势";
    boxLabel.textAlignment = NSTextAlignmentCenter;
    boxLabel.numberOfLines = 0;
    boxLabel.font = [UIFont boldSystemFontOfSize:18];
    boxLabel.textColor = [UIColor whiteColor];
    [self.gestureBox addSubview:boxLabel];

    // 提示文字
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 420, screenWidth - 2 * padding, 120)];
    tipLabel.text = @"支持的手势：\n• 单击 (Tap)\n• 双击 (Double Tap)\n• 长按 (Long Press)\n• 拖动 (Pan)\n• 捏合 (Pinch)\n• 旋转 (Rotation)";
    tipLabel.font = [UIFont systemFontOfSize:14];
    tipLabel.numberOfLines = 0;
    tipLabel.textColor = [UIColor secondaryLabelColor];
    [self.view addSubview:tipLabel];
}

- (void)setupGestures {
    // 1. 单击手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.gestureBox addGestureRecognizer:tapGesture];

    // 2. 双击手势
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self.gestureBox addGestureRecognizer:doubleTapGesture];

    // 单击手势需要等待双击手势失败后才触发
    [tapGesture requireGestureRecognizerToFail:doubleTapGesture];

    // 3. 长按手势
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressGesture.minimumPressDuration = 1.0;
    [self.gestureBox addGestureRecognizer:longPressGesture];

    // 4. 拖动手势
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.gestureBox addGestureRecognizer:panGesture];

    // 5. 捏合手势
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.gestureBox addGestureRecognizer:pinchGesture];

    // 6. 旋转手势
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
    [self.gestureBox addGestureRecognizer:rotationGesture];
}

#pragma mark - 手势处理

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    self.infoLabel.text = @"检测到：单击 👆";

    // 动画反馈
    [UIView animateWithDuration:0.1 animations:^{
        self.gestureBox.transform = CGAffineTransformMakeScale(0.95, 0.95);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.gestureBox.transform = CGAffineTransformIdentity;
        }];
    }];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture {
    self.infoLabel.text = @"检测到：双击 👆👆";

    // 改变颜色
    NSArray *colors = @[
        [UIColor systemPurpleColor],
        [UIColor systemBlueColor],
        [UIColor systemGreenColor],
        [UIColor systemOrangeColor],
        [UIColor systemRedColor]
    ];
    UIColor *randomColor = colors[arc4random_uniform((uint32_t)colors.count)];

    [UIView animateWithDuration:0.3 animations:^{
        self.gestureBox.backgroundColor = randomColor;
    }];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.infoLabel.text = @"检测到：长按 ⏱️";

        [UIView animateWithDuration:0.3 animations:^{
            self.gestureBox.transform = CGAffineTransformMakeScale(1.2, 1.2);
        }];
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.3 animations:^{
            self.gestureBox.transform = CGAffineTransformIdentity;
        }];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.view];

    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        self.infoLabel.text = [NSString stringWithFormat:@"检测到：拖动 👉 (%.0f, %.0f)", translation.x, translation.y];
        gesture.view.center = CGPointMake(gesture.view.center.x + translation.x, gesture.view.center.y + translation.y);
        [gesture setTranslation:CGPointZero inView:self.view];
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        self.infoLabel.text = [NSString stringWithFormat:@"检测到：捏合 🤏 (%.2f)", gesture.scale];
        gesture.view.transform = CGAffineTransformScale(gesture.view.transform, gesture.scale, gesture.scale);
        gesture.scale = 1.0;
    }
}

- (void)handleRotation:(UIRotationGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        CGFloat degrees = gesture.rotation * 180 / M_PI;
        self.infoLabel.text = [NSString stringWithFormat:@"检测到：旋转 🔄 (%.0f°)", degrees];
        gesture.view.transform = CGAffineTransformRotate(gesture.view.transform, gesture.rotation);
        gesture.rotation = 0;
    }
}

@end

