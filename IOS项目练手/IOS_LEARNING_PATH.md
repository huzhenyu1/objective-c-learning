# iOS 开发学习路径（针对有 OC 基础的开发者）

你已经掌握了 Objective-C 基础，现在开始学习 iOS 应用开发。

## 🎯 学习目标

从零开始，逐步掌握 iOS 开发的核心技能，最终能够独立开发完整的 iOS 应用。

## 📚 学习路径（10 个阶段）

### 第一阶段：UIKit 基础（3-5天）
**目标**：掌握 iOS UI 的基础组件

#### 学习内容
1. **UIView** - 视图基础
   - frame, bounds, center
   - backgroundColor, alpha
   - 视图层级（addSubview, removeFromSuperview）

2. **UIViewController** - 视图控制器
   - 生命周期（viewDidLoad, viewWillAppear, viewDidAppear）
   - 视图管理
   - 导航和模态展示

3. **UILabel** - 标签
   - text, font, textColor
   - textAlignment, numberOfLines

4. **UIButton** - 按钮
   - setTitle, setImage
   - addTarget: action:
   - 按钮状态（normal, highlighted, selected, disabled）

5. **UIImageView** - 图片视图
   - image, contentMode
   - 图片加载和显示

**实践项目**：`01_UIKit_Basics/` - 基础 UI 组件展示

---

### 第二阶段：布局系统（3-5天）
**目标**：掌握界面布局的多种方式

#### 学习内容
1. **Frame 布局** - 传统布局方式
   - CGRect, CGPoint, CGSize
   - 手动计算和设置 frame

2. **Auto Layout** - 自适应布局（重点）
   - NSLayoutConstraint
   - VFL（Visual Format Language）
   - 约束的创建和管理

3. **StackView** - 栈视图（推荐）
   - axis, distribution, alignment, spacing
   - 简化布局的利器

4. **Safe Area** - 安全区域
   - 适配不同设备（iPhone, iPad）
   - 刘海屏适配

**实践项目**：`02_Layout_System/` - 各种布局方式对比

---

### 第三阶段：交互与导航（3-5天）
**目标**：掌握用户交互和页面跳转

#### 学习内容
1. **UINavigationController** - 导航控制器
   - push, pop
   - navigationBar 自定义
   - 导航栈管理

2. **UITabBarController** - 标签栏控制器
   - viewControllers
   - tabBar 自定义
   - 选中状态管理

3. **Modal Presentation** - 模态展示
   - presentViewController
   - dismissViewControllerAnimated
   - 展示样式（fullScreen, pageSheet, formSheet）

4. **UIGestureRecognizer** - 手势识别
   - Tap, Swipe, Pan, Pinch, Rotate
   - 手势处理

**实践项目**：`03_Navigation/` - 多页面导航应用

---

### 第四阶段：列表视图（5-7天）
**目标**：掌握最常用的列表展示

#### 学习内容
1. **UITableView** - 表格视图（重点）
   - UITableViewDataSource
   - UITableViewDelegate
   - UITableViewCell 自定义
   - section 和 row 管理

2. **UICollectionView** - 集合视图
   - UICollectionViewDataSource
   - UICollectionViewDelegate
   - UICollectionViewLayout
   - 网格布局

3. **Cell 重用机制**
   - dequeueReusableCell
   - 性能优化

4. **刷新和加载**
   - reloadData
   - 下拉刷新
   - 上拉加载更多

**实践项目**：`04_TableView/` - 联系人列表应用
**实践项目**：`05_CollectionView/` - 照片墙应用

---

### 第五阶段：网络请求（5-7天）
**目标**：掌握网络数据获取

#### 学习内容
1. **NSURLSession** - 网络请求（重点）
   - GET, POST 请求
   - dataTask, downloadTask, uploadTask
   - 请求头和参数

2. **JSON 解析**
   - NSJSONSerialization
   - 模型转换
   - JSONModel, YYModel 等第三方库

3. **错误处理**
   - NSError
   - 网络异常处理
   - 超时重试

4. **图片加载**
   - 异步图片加载
   - 图片缓存
   - SDWebImage 库使用

**实践项目**：`06_Networking/` - 新闻列表应用（请求 API 显示数据）

---

### 第六阶段：数据持久化（3-5天）
**目标**：掌握本地数据存储

#### 学习内容
1. **NSUserDefaults** - 简单数据存储
   - 存储和读取基本类型
   - 应用偏好设置

2. **文件操作**
   - NSFileManager
   - 文档目录、缓存目录
   - 文件读写

3. **归档（Archive）**
   - NSCoding 协议
   - NSKeyedArchiver
   - 对象序列化

4. **Core Data** - 数据库（可选，进阶）
   - 实体和关系
   - CRUD 操作
   - 查询和筛选

**实践项目**：`07_DataPersistence/` - 待办事项应用（本地存储）

---

### 第七阶段：多线程（3-5天）
**目标**：掌握异步编程

#### 学习内容
1. **GCD（Grand Central Dispatch）** - 重点
   - dispatch_async, dispatch_sync
   - 主队列和全局队列
   - 串行队列和并行队列

2. **NSOperation** - 高级异步操作
   - NSOperationQueue
   - 操作依赖
   - 取消操作

3. **主线程 UI 更新**
   - dispatch_main_async
   - performSelectorOnMainThread

4. **线程安全**
   - @synchronized
   - 信号量（Semaphore）
   - 锁（NSLock）

**实践项目**：`08_Multithreading/` - 图片下载应用（并发下载）

---

### 第八阶段：常用控件（3-5天）
**目标**：掌握更多 UI 组件

#### 学习内容
1. **UITextField** - 文本输入框
   - delegate 方法
   - 键盘管理
   - 输入验证

2. **UITextView** - 多行文本
   - 文本编辑
   - placeholder 实现

3. **UIScrollView** - 滚动视图
   - contentSize, contentOffset
   - 缩放功能
   - 分页滚动

4. **UIAlertController** - 提示框
   - alert 和 actionSheet
   - 文本输入提示框

5. **其他控件**
   - UISwitch, UISlider, UISegmentedControl
   - UIPickerView, UIDatePicker
   - UIActivityIndicatorView, UIProgressView

**实践项目**：`09_Common_Controls/` - 表单应用

---

### 第九阶段：设计模式（5-7天）
**目标**：掌握 iOS 常用设计模式

#### 学习内容
1. **MVC** - Model-View-Controller
   - iOS 的标准架构
   - 职责分离

2. **Delegate（委托）** - 已学习
   - 协议定义
   - 代理模式应用

3. **Block（闭包）** - 已学习
   - 回调实现
   - 循环引用避免

4. **Notification（通知）**
   - NSNotificationCenter
   - 发送和接收通知
   - 观察者模式

5. **KVO（键值观察）** - 已学习
   - 数据变化监听

6. **Singleton（单例）**
   - 共享实例
   - 应用场景

**实践项目**：`10_Design_Patterns/` - 重构之前的项目

---

### 第十阶段：综合项目（10-14天）
**目标**：整合所有知识，开发完整应用

#### 项目建议
1. **新闻阅读应用**
   - 列表展示
   - 网络请求
   - 详情页面
   - 收藏功能

2. **天气应用**
   - API 集成
   - 定位服务
   - 数据展示
   - 多城市管理

3. **笔记应用**
   - 数据存储
   - 列表和详情
   - 搜索功能
   - 分类管理

4. **社交媒体客户端**
   - 用户登录
   - 动态列表
   - 评论互动
   - 图片上传

**实践项目**：`11_Complete_App/` - 选择一个完整应用开发

---

## 📝 学习建议

### 学习方法
1. **理论 + 实践**：每个知识点都要动手写代码
2. **循序渐进**：不要跳过基础，扎实前进
3. **多看文档**：Apple 官方文档是最好的资料
4. **多写 Demo**：每个概念都写一个小 Demo
5. **代码阅读**：阅读优秀的开源项目

### 时间安排
- **每天 2-3 小时**：约 2-3 个月完成
- **每天 4-6 小时**：约 1-1.5 个月完成
- **全职学习**：约 3-4 周完成

### 学习资源
1. **官方文档**
   - [iOS Documentation](https://developer.apple.com/documentation/uikit)
   - [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

2. **推荐书籍**
   - 《iOS 编程（第7版）》
   - 《Effective Objective-C 2.0》

3. **在线资源**
   - Ray Wenderlich 教程
   - objc.io 文章
   - Stack Overflow

### 评估标准
完成学习后，你应该能够：
- ✅ 独立搭建 iOS 应用界面
- ✅ 实现多页面导航和交互
- ✅ 处理网络请求和数据展示
- ✅ 使用本地存储保存数据
- ✅ 理解并应用 iOS 设计模式
- ✅ 调试和优化应用性能
- ✅ 发布应用到 App Store

---

## 🚀 下一步

1. **创建第一个练习项目**
   - 从 `01_UIKit_Basics` 开始
   - 按顺序完成每个阶段

2. **保持学习节奏**
   - 每天固定时间学习
   - 及时复习和总结

3. **参与社区**
   - GitHub 查看开源项目
   - 技术博客分享经验

4. **实战项目**
   - 开发自己的 App
   - 发布到 App Store

---

## 📌 重要提示

### 你已经掌握的（优势）
✅ Objective-C 语法
✅ Foundation 框架基础
✅ 内存管理（ARC）
✅ Block 和 Protocol
✅ 设计模式基础

### 需要重点学习的（新知识）
🎯 UIKit 框架（iOS UI 组件）
🎯 Auto Layout（界面布局）
🎯 UITableView/UICollectionView（列表）
🎯 网络请求和 JSON 解析
🎯 iOS 应用架构和设计模式

### 学习重点
1. **实践为主**：多写代码，少看理论
2. **官方文档**：遇到问题先查文档
3. **循序渐进**：不要跳跃式学习
4. **项目驱动**：通过项目巩固知识

准备好了吗？让我们从第一阶段开始！ 🚀

