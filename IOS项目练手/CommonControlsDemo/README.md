# CommonControlsDemo - 常用控件演示项目

## 📱 项目简介

这是第九阶段的学习项目，演示 iOS 开发中的常用控件，包括：
- ✅ **UITextField** - 文本输入框（单行）
- ✅ **UITextView** - 多行文本编辑
- ✅ **UIScrollView** - 滚动视图（滚动、缩放、分页）
- ✅ **UIAlertController** - 提示框和操作表
- ✅ **其他控件** - Switch, Slider, Segment, Picker, DatePicker, Progress, ActivityIndicator
- ✅ **综合表单** - 实战：完整的用户信息表单

---

## 📂 项目文件

### 需要添加到 Xcode 的文件

```
CommonControlsDemo/
├── ViewController.m                    # ✅ 已生成 - 主菜单
├── TextFieldViewController.h           # ✅ 已生成
├── TextFieldViewController.m           # ✅ 已生成 - UITextField 演示
├── TextViewViewController.h            # ✅ 已生成
├── TextViewViewController.m            # ✅ 已生成 - UITextView 演示
├── ScrollViewViewController.h          # ✅ 已生成
├── ScrollViewViewController.m          # ✅ 已生成 - UIScrollView 演示
├── AlertViewController.h               # ✅ 已生成
├── AlertViewController.m               # ✅ 已生成 - UIAlertController 演示
├── OtherControlsViewController.h       # ✅ 已生成
├── OtherControlsViewController.m       # ✅ 已生成 - 其他控件演示
├── FormViewController.h                # ✅ 已生成
├── FormViewController.m                # ✅ 已生成 - 综合表单
└── SceneDelegate.m                     # ✅ 已生成 - 配置导航控制器
```

---

## 🚀 如何添加到 Xcode

### 方法 1：批量拖拽（推荐）⭐

1. **在 Finder 中选中所有文件**
   ```
   选中以下文件（按住 Cmd 多选）：
   - ViewController.m
   - TextFieldViewController.h/m
   - TextViewViewController.h/m
   - ScrollViewViewController.h/m
   - AlertViewController.h/m
   - OtherControlsViewController.h/m
   - FormViewController.h/m
   - SceneDelegate.m
   ```

2. **拖拽到 Xcode 项目中**
   - 拖拽到 `CommonControlsDemo` 文件夹
   - ✅ 勾选 "Copy items if needed"
   - ✅ 勾选 "CommonControlsDemo" target
   - 点击 Finish

### 方法 2：使用 Xcode 添加

1. **右键点击 `CommonControlsDemo` 文件夹**
2. **选择 "Add Files to CommonControlsDemo..."**
3. **选择所有生成的文件**
4. **✅ 勾选 "Copy items if needed"**
5. **✅ 勾选 "CommonControlsDemo" target**
6. **点击 Add**

---

## 🎯 运行项目

### 1. 添加所有文件后

在 Xcode 左侧项目导航栏应该看到：

```
CommonControlsDemo/
├── AppDelegate.h
├── AppDelegate.m
├── SceneDelegate.h
├── SceneDelegate.m (替换)
├── ViewController.h
├── ViewController.m (替换)
├── TextFieldViewController.h
├── TextFieldViewController.m
├── TextViewViewController.h
├── TextViewViewController.m
├── ScrollViewViewController.h
├── ScrollViewViewController.m
├── AlertViewController.h
├── AlertViewController.m
├── OtherControlsViewController.h
├── OtherControlsViewController.m
├── FormViewController.h
├── FormViewController.m
├── Main.storyboard
├── Assets.xcassets
├── LaunchScreen.storyboard
└── Info.plist
```

### 2. 编译运行

1. **选择模拟器**（iPhone 15 Pro 或其他）
2. **点击 ▶️ 运行按钮** 或按 `Cmd + R`
3. **等待编译完成**

### 3. 如果遇到编译错误

**错误：`Duplicate interface definition`**

```objective-c
// 解决方法：删除 ViewController.h 中的重复声明
// 只保留 @interface ViewController : UIViewController
// @end
```

**错误：`Use of undeclared identifier`**

```
解决方法：确保所有 .h 文件都已正确导入到 ViewController.m 顶部：
#import "TextFieldViewController.h"
#import "TextViewViewController.h"
#import "ScrollViewViewController.h"
#import "AlertViewController.h"
#import "OtherControlsViewController.h"
#import "FormViewController.h"
```

---

## 📚 项目功能

### 1️⃣ UITextField 演示
- **普通文本框** - 用户名输入
- **密码框** - `secureTextEntry`
- **邮箱框** - `UIKeyboardTypeEmailAddress`
- **手机号框** - `UIKeyboardTypePhonePad`
- **数字框** - `UIKeyboardTypeNumberPad`
- **字数限制** - 实时验证
- **Return键切换** - 自动跳转到下一个输入框

### 2️⃣ UITextView 演示
- **多行文本编辑** - 长文本输入
- **Placeholder 实现** - 自定义占位符
- **字数统计** - 实时显示字数（0/200）
- **字数限制** - 超过 200 字自动截断
- **键盘适配** - 自动调整视图避免遮挡

### 3️⃣ UIScrollView 演示
- **普通滚动** - 垂直/水平滚动
- **缩放功能** - `minimumZoomScale` / `maximumZoomScale`
- **双击缩放** - 手势识别
- **分页滚动** - `pagingEnabled`
- **UIPageControl** - 页面指示器

### 4️⃣ UIAlertController 演示
- **简单提示框** - 单按钮
- **确认/取消提示框** - 双按钮
- **多按钮提示框** - 保存/分享/导出/取消
- **文本输入提示框** - 带输入框的弹窗
- **ActionSheet** - 底部弹出选择
- **破坏性操作** - `UIAlertActionStyleDestructive`（红色按钮）

### 5️⃣ 其他控件演示
- **UISwitch** - 开关（开/关）
- **UISlider** - 滑块（0-100）
- **UISegmentedControl** - 分段控制器（选项1/2/3）
- **UIPickerView** - 滚轮选择器（城市选择）
- **UIDatePicker** - 日期选择器
- **UIProgressView** - 进度条（0%-100%）
- **UIActivityIndicatorView** - 加载指示器（转圈）

### 6️⃣ 综合表单演示
一个完整的用户信息表单，综合运用了所有控件：
- ✅ 姓名输入（UITextField）
- ✅ 邮箱输入（UITextField）
- ✅ 手机号输入（UITextField）
- ✅ 性别选择（UISegmentedControl）
- ✅ 生日选择（UIDatePicker）
- ✅ 城市选择（UIPickerView）
- ✅ 自我介绍（UITextView）
- ✅ 同意协议（UISwitch）
- ✅ 表单验证（必填项检查）
- ✅ 键盘适配（UIScrollView + Keyboard Notifications）

---

## 💡 学习要点

### 1. 文本输入
```objective-c
// UITextField - 单行文本
UITextField *textField = [[UITextField alloc] init];
textField.placeholder = @"请输入";
textField.borderStyle = UITextBorderStyleRoundedRect;
textField.keyboardType = UIKeyboardTypeEmailAddress; // 键盘类型
textField.returnKeyType = UIReturnKeyNext;           // Return键类型
textField.clearButtonMode = UITextFieldViewModeWhileEditing; // 清除按钮
textField.delegate = self;

// UITextView - 多行文本
UITextView *textView = [[UITextView alloc] init];
textView.font = [UIFont systemFontOfSize:16];
textView.delegate = self;
// 注意：UITextView 没有 placeholder，需要自己实现
```

### 2. 滚动视图
```objective-c
UIScrollView *scrollView = [[UIScrollView alloc] init];
scrollView.contentSize = CGSizeMake(width, height); // ⭐ 重要！设置内容大小
scrollView.pagingEnabled = YES;                     // 分页
scrollView.minimumZoomScale = 1.0;                  // 最小缩放
scrollView.maximumZoomScale = 3.0;                  // 最大缩放
scrollView.delegate = self;

// 实现缩放
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView; // 返回要缩放的视图
}
```

### 3. 提示框
```objective-c
// Alert
UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"标题"
                                                               message:@"消息"
                                                        preferredStyle:UIAlertControllerStyleAlert];

[alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                          style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction *action) {
    // 点击确定
}]];

[self presentViewController:alert animated:YES completion:nil];

// ActionSheet（底部弹出）
preferredStyle:UIAlertControllerStyleActionSheet
```

### 4. 其他控件
```objective-c
// Switch
UISwitch *switchControl = [[UISwitch alloc] init];
switchControl.on = YES;
[switchControl addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];

// Slider
UISlider *slider = [[UISlider alloc] init];
slider.minimumValue = 0;
slider.maximumValue = 100;
slider.value = 50;

// Segment
UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:@[@"选项1", @"选项2"]];
segment.selectedSegmentIndex = 0;

// DatePicker
UIDatePicker *datePicker = [[UIDatePicker alloc] init];
datePicker.datePickerMode = UIDatePickerModeDate;
datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;

// Progress
UIProgressView *progress = [[UIProgressView alloc] init];
progress.progress = 0.5; // 0.0 - 1.0

// Activity Indicator
UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
[indicator startAnimating]; // 开始
[indicator stopAnimating];  // 停止
```

### 5. 键盘管理
```objective-c
// 监听键盘通知
[[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(keyboardWillShow:)
                                             name:UIKeyboardWillShowNotification
                                           object:nil];

[[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(keyboardWillHide:)
                                             name:UIKeyboardWillHideNotification
                                           object:nil];

// 处理键盘遮挡
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardFrame.size.height;

    // 调整视图位置
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
}

// 点击空白处收起键盘
- (void)dismissKeyboard {
    [self.view endEditing:YES];
}
```

---

## 🎨 界面预览

```
┌────────────────────────────┐
│  📱 常用控件演示             │
├────────────────────────────┤
│ 📝 UITextField             │
│    文本输入框 - 单行文本输入  │
├────────────────────────────┤
│ 📄 UITextView              │
│    多行文本编辑 - 长文本输入  │
├────────────────────────────┤
│ 📜 UIScrollView            │
│    滚动视图 - 滚动、缩放、分页│
├────────────────────────────┤
│ ⚠️ UIAlertController       │
│    提示框 - Alert和ActionSheet│
├────────────────────────────┤
│ 🎛️ 其他控件                │
│    Switch, Slider, Picker等│
├────────────────────────────┤
│ 📋 综合表单                 │
│    实战：用户信息表单        │
└────────────────────────────┘
```

---

## ✅ 完成标准

学完本阶段后，你应该能够：
- ✅ 熟练使用各种常用 UI 控件
- ✅ 实现文本输入和验证
- ✅ 处理键盘遮挡问题
- ✅ 使用滚动视图和分页
- ✅ 显示各种提示框
- ✅ 创建完整的表单界面
- ✅ 理解 Delegate 模式的应用

---

## 🎯 下一步学习

完成本项目后，可以继续学习：
1. **DesignPatternsDemo** - 设计模式（MVC、Delegate、Singleton、Observer）
2. **CompleteApp** - 完整应用（综合运用所有知识）

---

## 📞 遇到问题？

1. **编译错误** - 检查所有文件是否正确添加到 target
2. **运行崩溃** - 检查 `SceneDelegate.m` 是否正确配置
3. **界面显示异常** - 检查控制器是否正确导入
4. **键盘遮挡** - 使用 UIScrollView + contentInset

---

**祝学习愉快！** 🎉

