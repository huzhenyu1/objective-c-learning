# 第一阶段：UIKit 基础

## 学习目标

掌握 iOS UI 的基础组件：UIView, UIViewController, UILabel, UIButton, UIImageView

## 实践项目：基础 UI 组件展示

创建一个展示各种基础 UI 组件的应用。

## 步骤 1：创建项目

1. 打开 Xcode
2. File → New → Project
3. 选择 iOS → App
4. 填写信息：
   ```
   Product Name: UIKitBasicsDemo
   Interface: Storyboard
   Language: Objective-C
   ```
5. 点击 Create

## 步骤 2：修改 ViewController.m

将 ViewController.m 替换为以下代码：

```objective-c
#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UIButton *actionButton;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIView *colorBoxView;
@property (assign, nonatomic) NSInteger clickCount;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.clickCount = 0;
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupUI];
}

- (void)setupUI {
    // 1. 标题标签（UILabel）
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, self.view.bounds.size.width - 40, 50)];
    self.titleLabel.text = @"UIKit 基础组件";
    self.titleLabel.font = [UIFont boldSystemFontOfSize:28];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor systemBlueColor];
    [self.view addSubview:self.titleLabel];

    // 2. 描述标签（UILabel - 多行）
    self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 160, self.view.bounds.size.width - 40, 60)];
    self.descriptionLabel.text = @"这是一个展示 UIKit 基础组件的示例应用\n点击下方按钮查看效果";
    self.descriptionLabel.font = [UIFont systemFontOfSize:16];
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    self.descriptionLabel.numberOfLines = 0;  // 0 表示不限制行数
    self.descriptionLabel.textColor = [UIColor secondaryLabelColor];
    [self.view addSubview:self.descriptionLabel];

    // 3. 彩色方块（UIView）
    self.colorBoxView = [[UIView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 150) / 2, 240, 150, 150)];
    self.colorBoxView.backgroundColor = [UIColor systemPurpleColor];
    self.colorBoxView.layer.cornerRadius = 20;  // 圆角
    self.colorBoxView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.colorBoxView.layer.shadowOffset = CGSizeMake(0, 5);
    self.colorBoxView.layer.shadowOpacity = 0.3;
    self.colorBoxView.layer.shadowRadius = 10;
    [self.view addSubview:self.colorBoxView];

    // 4. 图片视图（UIImageView）
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 100) / 2, 410, 100, 100)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    // 使用系统图标（SF Symbols）
    self.imageView.image = [UIImage systemImageNamed:@"star.fill"];
    self.imageView.tintColor = [UIColor systemYellowColor];
    [self.view addSubview:self.imageView];

    // 5. 按钮（UIButton）
    self.actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.actionButton.frame = CGRectMake(50, 540, self.view.bounds.size.width - 100, 50);
    [self.actionButton setTitle:@"点击我" forState:UIControlStateNormal];
    self.actionButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    self.actionButton.backgroundColor = [UIColor systemBlueColor];
    [self.actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.actionButton.layer.cornerRadius = 25;
    [self.actionButton addTarget:self
                          action:@selector(buttonTapped:)
                forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.actionButton];

    // 6. 重置按钮
    UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    resetButton.frame = CGRectMake(50, 610, self.view.bounds.size.width - 100, 50);
    [resetButton setTitle:@"重置" forState:UIControlStateNormal];
    resetButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [resetButton addTarget:self
                    action:@selector(resetTapped:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetButton];
}

- (void)buttonTapped:(UIButton *)sender {
    self.clickCount++;

    // 修改标签文字
    self.titleLabel.text = [NSString stringWithFormat:@"点击次数：%ld", (long)self.clickCount];

    // 改变方块颜色（随机）
    CGFloat hue = (CGFloat)arc4random() / UINT_MAX;
    self.colorBoxView.backgroundColor = [UIColor colorWithHue:hue saturation:0.7 brightness:0.8 alpha:1.0];

    // 旋转图片
    [UIView animateWithDuration:0.5 animations:^{
        self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, M_PI);
    }];

    // 改变按钮文字
    if (self.clickCount == 1) {
        [self.actionButton setTitle:@"继续点击" forState:UIControlStateNormal];
    } else if (self.clickCount >= 5) {
        [self.actionButton setTitle:@"你已经点击很多次了" forState:UIControlStateNormal];
    }

    // 显示提示框
    if (self.clickCount % 3 == 0) {
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"提示"
            message:[NSString stringWithFormat:@"你已经点击了 %ld 次", (long)self.clickCount]
            preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *okAction = [UIAlertAction
            actionWithTitle:@"知道了"
            style:UIAlertActionStyleDefault
            handler:nil];

        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)resetTapped:(UIButton *)sender {
    self.clickCount = 0;

    // 重置所有 UI
    self.titleLabel.text = @"UIKit 基础组件";
    self.colorBoxView.backgroundColor = [UIColor systemPurpleColor];
    [self.actionButton setTitle:@"点击我" forState:UIControlStateNormal];
    self.imageView.transform = CGAffineTransformIdentity;
}

// 视图控制器生命周期方法
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear - 视图即将显示");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear - 视图已经显示");
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear - 视图即将消失");
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"viewDidDisappear - 视图已经消失");
}

@end
```

## 步骤 3：运行项目

1. 选择模拟器：iPhone 15 Pro
2. 点击 ▶️ 或按 `Cmd+R`
3. 在模拟器中测试各个功能

## 学习重点

### 1. UIView 基础
```objective-c
// 创建视图
UIView *view = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];

// 设置属性
view.backgroundColor = [UIColor redColor];
view.alpha = 0.5;  // 透明度
view.layer.cornerRadius = 10;  // 圆角

// 添加到父视图
[self.view addSubview:view];
```

### 2. UILabel（标签）
```objective-c
UILabel *label = [[UILabel alloc] initWithFrame:frame];
label.text = @"文字内容";
label.font = [UIFont systemFontOfSize:16];
label.textColor = [UIColor blackColor];
label.textAlignment = NSTextAlignmentCenter;
label.numberOfLines = 0;  // 多行显示
```

### 3. UIButton（按钮）
```objective-c
UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
[button setTitle:@"按钮" forState:UIControlStateNormal];
[button addTarget:self
          action:@selector(buttonTapped:)
forControlEvents:UIControlEventTouchUpInside];
```

### 4. UIImageView（图片视图）
```objective-c
UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
imageView.image = [UIImage systemImageNamed:@"star.fill"];
imageView.contentMode = UIViewContentModeScaleAspectFit;
```

### 5. 视图层级
```objective-c
[parentView addSubview:childView];     // 添加子视图
[childView removeFromSuperview];       // 移除自己
[parentView bringSubviewToFront:view]; // 置顶
[parentView sendSubviewToBack:view];   // 置底
```

### 6. ViewController 生命周期
```objective-c
- (void)viewDidLoad           // 视图加载完成（只调用一次）
- (void)viewWillAppear:       // 视图即将显示
- (void)viewDidAppear:        // 视图已经显示
- (void)viewWillDisappear:    // 视图即将消失
- (void)viewDidDisappear:     // 视图已经消失
```

## 练习任务

### 任务 1：添加更多组件
- 添加一个 UISwitch（开关）
- 添加一个 UISlider（滑块）
- 添加一个 UITextField（文本输入框）

### 任务 2：交互增强
- 点击彩色方块时也触发动画
- 长按按钮显示不同提示
- 添加震动反馈

### 任务 3：样式美化
- 给按钮添加阴影
- 给标签添加渐变背景
- 添加更多动画效果

## 常见问题

**Q1: 为什么创建的视图看不到？**
A: 检查：
1. frame 是否正确
2. 是否添加到父视图（addSubview）
3. backgroundColor 是否设置
4. alpha 是否为 0

**Q2: 按钮点击没反应？**
A: 检查：
1. addTarget 是否正确
2. action 方法名是否正确
3. 按钮是否被其他视图遮挡

**Q3: 如何调试视图层级？**
A: 在 Xcode 调试时：
1. Debug → View Debugging → Capture View Hierarchy
2. 可以 3D 查看视图层级

## 下一步

完成本阶段后，进入**第二阶段：布局系统**，学习更灵活的界面布局方式。

## 参考资源

- [UIView 官方文档](https://developer.apple.com/documentation/uikit/uiview)
- [UIViewController 官方文档](https://developer.apple.com/documentation/uikit/uiviewcontroller)
- [SF Symbols 图标库](https://developer.apple.com/sf-symbols/)

