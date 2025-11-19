# Objective-C 学习路径（C/C++ 开发者）

## 🎯 学习重点

如果你已经有 C/C++ 基础，重点关注以下内容：

## 第一阶段：核心差异（必须掌握）

### 1. 消息传递机制
**文件**: `differences/01_message_passing.m`

**关键点**:
- `[object method]` vs `object.method()`
- 消息可以在运行时动态发送
- 发送消息给 `nil` 不会崩溃
- 方法名包含参数标签，更易读

**与 C++ 的区别**:
- C++: 编译时确定函数调用
- OC: 运行时发送消息，更灵活

### 2. @ 语法糖
**文件**: `differences/02_at_syntax.m`

**关键点**:
- `@"字符串"` - NSString 字面量
- `@42` - NSNumber 字面量
- `@[]` - NSArray 字面量
- `@{}` - NSDictionary 字面量

**与 C++ 的区别**:
- C++: 需要手动创建对象或使用模板
- OC: 编译时语法糖，自动转换为对象

### 3. 内存管理（ARC）
**文件**: `differences/03_memory_management.m`

**关键点**:
- ARC（自动引用计数）vs C++ 的 RAII
- `strong`（强引用）和 `weak`（弱引用）
- 避免循环引用
- `@autoreleasepool` 管理临时对象

**与 C++ 的区别**:
- C++: RAII，栈对象自动管理
- OC: 引用计数，所有对象在堆上

## 第二阶段：OC 特有特性

### 1. @property 属性
**文件**: `essentials/01_property.m`

**关键点**:
- 自动生成 getter/setter
- 属性修饰符：`strong`, `weak`, `copy`, `assign`
- 点语法调用
- `readonly` 只读属性

**实际应用**:
- `copy` 用于 NSString，防止外部修改
- `weak` 用于避免循环引用

### 2. Category（分类）
**文件**: `essentials/02_category.m`

**关键点**:
- 运行时扩展类，无需修改源码
- 可以为系统类添加方法
- 使用关联对象添加属性

**实际应用**:
- 为系统类添加便利方法
- 将大类拆分为多个文件
- 扩展第三方库

### 3. Block（块）
**文件**: `essentials/03_block.m`

**关键点**:
- 类似 C++ lambda，但功能更强大
- 可以捕获外部变量
- `__block` 修饰符允许修改外部变量
- 注意循环引用（使用 `__weak`）

**实际应用**:
- 异步回调
- 集合操作
- 动画完成回调

## 第三阶段：Foundation 框架

### 常用类
**文件**: `foundation/01_common_classes.m`

**重点类**:
- `NSString` / `NSMutableString` - 字符串
- `NSArray` / `NSMutableArray` - 数组
- `NSDictionary` / `NSMutableDictionary` - 字典
- `NSNumber` - 数字对象
- `NSDate` - 日期时间
- `NSSet` - 集合（无序，唯一）

**最佳实践**:
- 优先使用不可变类型
- NSString 使用 `copy` 属性
- 使用字面量语法创建对象

## 第四阶段：实际工程模式

### 1. 委托模式（Delegate）
**文件**: `patterns/01_delegate_pattern.m`

**关键点**:
- Cocoa 框架的核心设计模式
- 使用协议定义接口
- 委托属性使用 `weak`
- 使用 `respondsToSelector:` 检查可选方法

**实际应用**:
- UITableViewDelegate
- UITextFieldDelegate
- 自定义回调接口

### 2. KVC/KVO
**文件**: `patterns/02_kvc_kvo.m`

**关键点**:
- KVC（键值编码）：通过字符串访问属性
- KVO（键值观察）：观察属性变化
- 必须手动移除观察者

**实际应用**:
- 数据绑定
- Core Data
- 模型-视图绑定

## 📝 学习建议

1. **先看差异**：理解 OC 与 C++ 的核心不同
2. **掌握特性**：学习 OC 特有的语法和特性
3. **熟悉框架**：掌握 Foundation 常用类
4. **实践模式**：理解实际开发中的设计模式

## ⚠️ 常见陷阱

1. **循环引用**：使用 `weak` 避免
2. **内存管理**：理解 ARC 的工作原理
3. **nil 消息**：OC 中发送消息给 nil 不会崩溃
4. **属性修饰符**：正确使用 `strong`, `weak`, `copy`

## 🔗 下一步

- 学习 Cocoa Touch（iOS 开发）
- 学习 Core Data（数据持久化）
- 学习网络编程（NSURLSession）
- 学习多线程（GCD, NSOperation）

