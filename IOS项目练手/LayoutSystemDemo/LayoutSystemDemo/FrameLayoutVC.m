//
//  FrameLayoutVC.m
//  LayoutSystemDemo
//
//  Created by 胡振宇 on 2025/11/20.
//  Frame 布局演示 - 传统的坐标定位方式
//

#import "FrameLayoutVC.h"

@interface FrameLayoutVC ()
@property (strong, nonatomic) UIView *redBox;
@property (strong, nonatomic) UIView *greenBox;
@property (strong, nonatomic) UIView *blueBox;
@property (strong, nonatomic) UILabel *infoLabel;
@end

@implementation FrameLayoutVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Frame 布局";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupUI];
}

- (void)setupUI {
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat screenHeight = self.view.bounds.size.height;
    CGFloat boxSize = 100;
    CGFloat padding = 20;

    // 说明标签
    self.infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 100, screenWidth - 2 * padding, 80)];
    self.infoLabel.text = @"Frame 布局：手动计算坐标\n旋转设备查看布局变化\n（需要重写 viewWillTransitionToSize）";
    self.infoLabel.font = [UIFont systemFontOfSize:16];
    self.infoLabel.textAlignment = NSTextAlignmentCenter;
    self.infoLabel.numberOfLines = 0;
    self.infoLabel.textColor = [UIColor secondaryLabelColor];
    [self.view addSubview:self.infoLabel];

    // 红色方块 - 左上角
    self.redBox = [[UIView alloc] initWithFrame:CGRectMake(padding, 200, boxSize, boxSize)];
    self.redBox.backgroundColor = [UIColor systemRedColor];
    self.redBox.layer.cornerRadius = 15;
    self.redBox.layer.shadowColor = [UIColor blackColor].CGColor;
    self.redBox.layer.shadowOffset = CGSizeMake(0, 2);
    self.redBox.layer.shadowOpacity = 0.3;
    self.redBox.layer.shadowRadius = 4;
    [self.view addSubview:self.redBox];

    // 添加标签到红色方块
    UILabel *redLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, boxSize, boxSize)];
    redLabel.text = @"左上";
    redLabel.textAlignment = NSTextAlignmentCenter;
    redLabel.textColor = [UIColor whiteColor];
    redLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.redBox addSubview:redLabel];

    // 绿色方块 - 右上角
    self.greenBox = [[UIView alloc] initWithFrame:CGRectMake(screenWidth - padding - boxSize, 200, boxSize, boxSize)];
    self.greenBox.backgroundColor = [UIColor systemGreenColor];
    self.greenBox.layer.cornerRadius = 15;
    self.greenBox.layer.shadowColor = [UIColor blackColor].CGColor;
    self.greenBox.layer.shadowOffset = CGSizeMake(0, 2);
    self.greenBox.layer.shadowOpacity = 0.3;
    self.greenBox.layer.shadowRadius = 4;
    [self.view addSubview:self.greenBox];

    UILabel *greenLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, boxSize, boxSize)];
    greenLabel.text = @"右上";
    greenLabel.textAlignment = NSTextAlignmentCenter;
    greenLabel.textColor = [UIColor whiteColor];
    greenLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.greenBox addSubview:greenLabel];

    // 蓝色方块 - 水平居中
    self.blueBox = [[UIView alloc] initWithFrame:CGRectMake((screenWidth - boxSize) / 2, 340, boxSize, boxSize)];
    self.blueBox.backgroundColor = [UIColor systemBlueColor];
    self.blueBox.layer.cornerRadius = 15;
    self.blueBox.layer.shadowColor = [UIColor blackColor].CGColor;
    self.blueBox.layer.shadowOffset = CGSizeMake(0, 2);
    self.blueBox.layer.shadowOpacity = 0.3;
    self.blueBox.layer.shadowRadius = 4;
    [self.view addSubview:self.blueBox];

    UILabel *blueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, boxSize, boxSize)];
    blueLabel.text = @"居中";
    blueLabel.textAlignment = NSTextAlignmentCenter;
    blueLabel.textColor = [UIColor whiteColor];
    blueLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.blueBox addSubview:blueLabel];

    // 添加动画按钮
    UIButton *animateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    animateButton.frame = CGRectMake(padding, 480, screenWidth - 2 * padding, 50);
    [animateButton setTitle:@"播放动画" forState:UIControlStateNormal];
    [animateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    animateButton.backgroundColor = [UIColor systemPurpleColor];
    animateButton.layer.cornerRadius = 12;
    animateButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [animateButton addTarget:self action:@selector(animateBoxes) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:animateButton];
}

// 处理屏幕旋转 - Frame 布局需要手动重新布局
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        // 重新计算布局
        CGFloat screenWidth = size.width;
        CGFloat boxSize = 100;
        CGFloat padding = 20;

        // 更新说明标签
        self.infoLabel.frame = CGRectMake(padding, 100, screenWidth - 2 * padding, 80);

        // 更新红色方块（左上）
        self.redBox.frame = CGRectMake(padding, 200, boxSize, boxSize);

        // 更新绿色方块（右上）
        self.greenBox.frame = CGRectMake(screenWidth - padding - boxSize, 200, boxSize, boxSize);

        // 更新蓝色方块（居中）
        self.blueBox.frame = CGRectMake((screenWidth - boxSize) / 2, 340, boxSize, boxSize);

    } completion:nil];
}

- (void)animateBoxes {
    // 移动动画
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        // 向下移动
        self.redBox.transform = CGAffineTransformMakeTranslation(0, 50);
        self.greenBox.transform = CGAffineTransformMakeTranslation(0, 50);
        self.blueBox.transform = CGAffineTransformMakeTranslation(0, 50);
    } completion:^(BOOL finished) {
        // 返回原位
        [UIView animateWithDuration:0.5 animations:^{
            self.redBox.transform = CGAffineTransformIdentity;
            self.greenBox.transform = CGAffineTransformIdentity;
            self.blueBox.transform = CGAffineTransformIdentity;
        }];
    }];

    // 旋转动画
    [UIView animateWithDuration:1.0 animations:^{
        self.blueBox.transform = CGAffineTransformMakeRotation(M_PI);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 animations:^{
            self.blueBox.transform = CGAffineTransformIdentity;
        }];
    }];
}

@end
