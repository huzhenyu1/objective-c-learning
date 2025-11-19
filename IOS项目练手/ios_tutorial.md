# Xcode 创建 iOS 项目完整教程

## 一、创建项目

### 1. 打开 Xcode
- 应用程序 → Xcode
- 或从 App Store 下载（如果还没安装）

### 2. 创建新项目
- 点击 "Create New Project"
- 或 File → New → Project (Cmd+Shift+N)

### 3. 选择模板
- 选择 **iOS** → **App**
- 点击 Next

### 4. 配置项目
```
Product Name: MyFirstApp
Team: None (首次可留空)
Organization Identifier: com.yourname
Interface: Storyboard
Language: Objective-C
```
点击 Next → 选择保存位置 → Create

## 二、项目结构

```
MyFirstApp/
├── AppDelegate.h/m          # 应用生命周期管理
├── SceneDelegate.h/m        # 场景管理（iOS 13+）
├── ViewController.h/m       # 主要视图控制器 ⭐
├── Main.storyboard          # 界面设计
├── Assets.xcassets          # 资源文件
├── LaunchScreen.storyboard  # 启动画面
└── Info.plist               # 配置文件
```

## 三、编写第一个界面

### ViewController.m 示例代码

```objective-c
#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *actionButton;
@property (assign, nonatomic) NSInteger counter;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.counter = 0;
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    // 标题标签
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 150, 300, 100)];
    self.titleLabel.text = @"计数器: 0";
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:30];
    self.titleLabel.numberOfLines = 0;
    [self.view addSubview:self.titleLabel];

    // 增加按钮
    self.actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.actionButton.frame = CGRectMake(100, 300, 200, 50);
    [self.actionButton setTitle:@"点击增加" forState:UIControlStateNormal];
    self.actionButton.titleLabel.font = [UIFont systemFontOfSize:20];
    self.actionButton.backgroundColor = [UIColor systemBlueColor];
    [self.actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.actionButton.layer.cornerRadius = 10;
    [self.actionButton addTarget:self
                          action:@selector(incrementCounter:)
                forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.actionButton];

    // 重置按钮
    UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    resetButton.frame = CGRectMake(100, 370, 200, 50);
    [resetButton setTitle:@"重置" forState:UIControlStateNormal];
    resetButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [resetButton addTarget:self
                    action:@selector(resetCounter:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetButton];
}

- (void)incrementCounter:(UIButton *)sender {
    self.counter++;
    self.titleLabel.text = [NSString stringWithFormat:@"计数器: %ld", (long)self.counter];

    // 动画效果
    [UIView animateWithDuration:0.3 animations:^{
        self.titleLabel.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.titleLabel.transform = CGAffineTransformIdentity;
        }];
    }];
}

- (void)resetCounter:(UIButton *)sender {
    self.counter = 0;
    self.titleLabel.text = @"计数器: 0";
}

@end
```

## 四、运行项目

### 在模拟器上运行
1. Xcode 顶部选择目标：`MyFirstApp > iPhone 15 Pro`
2. 点击 ▶️ 或按 `Cmd+R`
3. 等待编译和启动

### 在真机上运行

#### 1. 登录 Apple ID
```
Xcode → Preferences (Cmd+,) → Accounts
点击 + → Add Apple ID
```

#### 2. 连接设备
- 用数据线连接 iPhone/iPad
- 解锁设备
- 点击"信任此电脑"

#### 3. 配置签名
```
项目导航器 → 选择项目 → Targets → MyFirstApp
→ Signing & Capabilities
→ Team: 选择你的 Apple ID
→ 勾选 "Automatically manage signing"
```

#### 4. 选择设备并运行
- Xcode 顶部选择你的 iPhone
- 点击 ▶️ 运行

#### 5. 信任开发者（首次）
```
iPhone：设置 → 通用 → VPN与设备管理
→ 开发者应用 → 信任 xxx
```

## 五、常用功能

### 1. 添加图片资源
```
Assets.xcassets → 右键 → New Image Set
拖拽图片到对应位置（1x, 2x, 3x）
```

### 2. 使用 Storyboard
```
打开 Main.storyboard
右上角 + 按钮 → 选择控件
拖拽到界面上
```

### 3. 调试输出
```objective-c
NSLog(@"调试信息: %@", someObject);
```

### 4. 断点调试
- 点击代码行号左侧设置断点
- 运行时会在断点处暂停
- 查看变量值、单步执行

## 六、常见问题

### Q1: 真机安装失败
**A:** 检查以下几点：
1. Apple ID 是否登录
2. 设备是否解锁
3. 是否信任开发者证书
4. Bundle Identifier 是否唯一

### Q2: 模拟器启动慢
**A:** 首次启动较慢（1-2分钟），后续会快很多

### Q3: 免费账号限制
**A:**
- 7天后需要重新安装
- 最多3个设备
- 升级到付费开发者账号（$99/年）解除限制

### Q4: 代码自动补全不工作
**A:**
- Product → Clean Build Folder (Cmd+Shift+K)
- 重启 Xcode

## 七、学习资源

### 官方文档
- [iOS 开发文档](https://developer.apple.com/documentation/uikit)
- [Objective-C 编程指南](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/)

### 推荐学习路径
1. UIKit 基础（UIView, UIViewController）
2. Auto Layout（界面布局）
3. UITableView（列表）
4. 网络请求（NSURLSession）
5. 数据持久化（Core Data, UserDefaults）
6. 多线程（GCD）

## 八、快捷键速查

| 快捷键 | 功能 |
|--------|------|
| `Cmd+R` | 运行 |
| `Cmd+.` | 停止 |
| `Cmd+B` | 编译 |
| `Cmd+Shift+K` | 清理 |
| `Cmd+0` | 显示/隐藏导航器 |
| `Cmd+Shift+O` | 快速打开文件 |
| `Cmd+/` | 注释 |
| `Cmd+Shift+J` | 在导航器中定位当前文件 |
| `Ctrl+6` | 显示当前文件的方法列表 |

## 九、下一步

- 学习 Auto Layout 自适应布局
- 学习 UITableView 表格视图
- 学习网络请求和 JSON 解析
- 学习数据持久化
- 学习 iOS 设计模式（MVC, MVVM, Delegate）

