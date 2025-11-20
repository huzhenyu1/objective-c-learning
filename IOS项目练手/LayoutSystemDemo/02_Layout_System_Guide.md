# 第二阶段：布局系统完整指南

## 📱 项目概述

这是第二阶段的完整项目，包含：
- ✅ Frame 布局演示
- ✅ Auto Layout 约束布局
- ✅ StackView 栈视图布局
- ✅ Safe Area 安全区域适配
- ✅ 横竖屏自适应

## 🎯 项目功能

### 主页面
一个菜单页面，包含 4 个按钮，分别跳转到不同的布局演示页面。

### 演示页面
1. **Frame 布局** - 传统的绝对定位方式
2. **Auto Layout** - 现代约束布局系统
3. **StackView** - 简化的栈布局
4. **Safe Area** - 安全区域和横竖屏适配

## 📁 文件结构

```
LayoutSystemDemo/
├── ViewController.m/h          # 主菜单页面
├── FrameLayoutVC.m/h          # Frame 布局演示
├── AutoLayoutVC.m/h           # Auto Layout 演示
├── StackViewVC.m/h            # StackView 演示
└── SafeAreaVC.m/h             # Safe Area 演示
```

## 🚀 创建步骤

### 1. 添加新文件
在 Xcode 中为每个演示页面创建新的 ViewController：

```
File → New → File → Cocoa Touch Class
- Class: FrameLayoutVC
- Subclass of: UIViewController
- Language: Objective-C
```

重复以上步骤创建：
- AutoLayoutVC
- StackViewVC
- SafeAreaVC

### 2. 替换代码
将生成的代码分别复制到对应文件中。

### 3. 运行测试
- Cmd + R 运行
- 点击菜单按钮查看各种布局方式
- 旋转设备测试横竖屏适配

## 📚 学习重点

### 1. Frame 布局
- CGRect, CGPoint, CGSize 基础
- 手动计算坐标和尺寸
- `layoutSubviews` 方法处理旋转
- 优缺点分析

### 2. Auto Layout
- NSLayoutConstraint 约束创建
- 约束的激活和管理
- 约束优先级
- 动画约束变化
- `translatesAutoresizingMaskIntoConstraints = NO`

### 3. StackView
- axis（轴向）：horizontal/vertical
- distribution（分布方式）：fill/fillEqually/fillProportionally等
- alignment（对齐方式）：fill/leading/center等
- spacing（间距）
- arrangedSubviews 管理

### 4. Safe Area
- safeAreaLayoutGuide 安全区域
- 刘海屏/动态岛适配
- 横竖屏切换处理
- 不同设备适配

## 🎨 界面预览

### 主页面
```
┌─────────────────────────────┐
│                             │
│    📐 布局系统演示            │
│                             │
│  ┌───────────────────────┐ │
│  │  Frame 布局           │ │
│  └───────────────────────┘ │
│                             │
│  ┌───────────────────────┐ │
│  │  Auto Layout 布局     │ │
│  └───────────────────────┘ │
│                             │
│  ┌───────────────────────┐ │
│  │  StackView 布局       │ │
│  └───────────────────────┘ │
│                             │
│  ┌───────────────────────┐ │
│  │  Safe Area 演示       │ │
│  └───────────────────────┘ │
│                             │
└─────────────────────────────┘
```

### Frame 布局页面
展示传统的 Frame 布局方式，包含多个固定位置的视图。

### Auto Layout 页面
展示约束布局，包含可动画的约束变化。

### StackView 页面
展示栈视图的强大功能，动态添加/删除子视图。

### Safe Area 页面
展示安全区域适配，支持横竖屏切换。

## 🔍 关键代码解析

### Frame 布局
```objective-c
// 手动计算位置
CGFloat x = (screenWidth - width) / 2;
CGFloat y = 100;
view.frame = CGRectMake(x, y, width, height);

// 处理旋转
- (void)viewWillTransitionToSize:(CGSize)size {
    // 重新计算布局
}
```

### Auto Layout
```objective-c
// 关闭自动转换
view.translatesAutoresizingMaskIntoConstraints = NO;

// 创建约束
[NSLayoutConstraint activateConstraints:@[
    [view.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
    [view.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
    [view.widthAnchor constraintEqualToConstant:200],
    [view.heightAnchor constraintEqualToConstant:100]
]];
```

### StackView
```objective-c
UIStackView *stackView = [[UIStackView alloc] init];
stackView.axis = UILayoutConstraintAxisVertical;
stackView.distribution = UIStackViewDistributionFillEqually;
stackView.alignment = UIStackViewAlignmentFill;
stackView.spacing = 10;

// 添加子视图
[stackView addArrangedSubview:view1];
[stackView addArrangedSubview:view2];
```

### Safe Area
```objective-c
// 使用安全区域布局
[view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = YES;
[view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor].active = YES;
```

## ⚖️ 布局方式对比

| 特性 | Frame | Auto Layout | StackView |
|-----|-------|-------------|-----------|
| **学习难度** | ⭐ | ⭐⭐⭐ | ⭐⭐ |
| **代码量** | 多 | 中 | 少 |
| **灵活性** | 低 | 高 | 中 |
| **性能** | 高 | 中 | 中 |
| **自适应** | 需手动 | 自动 | 自动 |
| **动画** | 简单 | 强大 | 简单 |
| **维护性** | 差 | 好 | 很好 |
| **推荐度** | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |

## 📝 练习任务

### 任务 1：修改布局参数
- 修改 StackView 的 spacing
- 修改 Auto Layout 约束的优先级
- 尝试不同的 distribution 和 alignment

### 任务 2：添加新视图
- 在 Frame 布局页面添加一个新视图
- 在 Auto Layout 页面用约束添加视图
- 在 StackView 页面动态添加视图

### 任务 3：横竖屏适配
- 在 Frame 布局中实现横竖屏自动调整
- 测试 Auto Layout 和 StackView 的自动适配
- 观察 Safe Area 在不同方向的变化

### 任务 4：创建复杂布局
- 结合 StackView 和 Auto Layout
- 创建嵌套的 StackView
- 实现响应式布局

## 🐛 常见问题

### Q1: Auto Layout 约束冲突？
```
A: 检查是否设置了 translatesAutoresizingMaskIntoConstraints = NO
   检查约束是否有冲突（过度约束）
   使用约束优先级解决冲突
```

### Q2: StackView 子视图大小不对？
```
A: 检查 distribution 属性
   检查子视图的 intrinsicContentSize
   考虑使用 widthAnchor/heightAnchor 约束
```

### Q3: Safe Area 不生效？
```
A: 确保使用 safeAreaLayoutGuide
   检查是否在正确的生命周期方法中设置
   测试时使用有刘海的设备或模拟器
```

### Q4: 旋转后布局错乱？
```
A: Frame 布局需要重写 layoutSubviews 或监听旋转事件
   Auto Layout 和 StackView 会自动处理
   检查约束是否完整
```

## ✅ 测试清单

- [ ] 主页面显示 4 个菜单按钮
- [ ] 点击按钮可以跳转到对应页面
- [ ] Frame 布局页面显示多个视图
- [ ] Auto Layout 页面约束正确
- [ ] StackView 页面布局整齐
- [ ] Safe Area 页面适配刘海屏
- [ ] 旋转设备时布局自动调整
- [ ] 动画效果流畅
- [ ] 可以返回主页面

## 🎯 学习建议

1. **按顺序学习**：从 Frame → Auto Layout → StackView → Safe Area
2. **对比理解**：运行项目，对比不同布局方式的代码和效果
3. **动手修改**：改变参数，观察效果变化
4. **旋转测试**：横竖屏切换，理解自适应布局
5. **阅读文档**：查看 Apple 官方文档深入理解

## 📖 下一步

完成本阶段后，你将掌握：
- ✅ iOS 三种主要布局方式
- ✅ Auto Layout 约束系统
- ✅ StackView 的使用
- ✅ 安全区域适配
- ✅ 横竖屏自适应布局

接下来可以进入**第三阶段：交互与导航**，学习 UINavigationController 和 UITabBarController。

## 📚 参考资源

- [Auto Layout Guide](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/)
- [UIStackView](https://developer.apple.com/documentation/uikit/uistackview)
- [Safe Area Layout Guide](https://developer.apple.com/documentation/uikit/uiview/2891102-safearealayoutguide)

