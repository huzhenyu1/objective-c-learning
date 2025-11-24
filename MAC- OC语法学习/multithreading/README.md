# 多线程学习（Multithreading）

> 多线程是 Objective-C 语言层面的特性，适用于 macOS 和 iOS 开发

---

## 📚 学习文件

### 1️⃣ GCD 基础 (`01_gcd_basic.m`)
- `dispatch_async` - 异步执行（不阻塞）⭐⭐⭐
- `dispatch_sync` - 同步执行（阻塞）
- `dispatch_get_main_queue()` - 主队列
- `dispatch_get_global_queue()` - 全局队列
- `dispatch_after` - 延迟执行
- 实战：下载进度、异步vs同步对比

### 2️⃣ GCD 高级 (`02_gcd_advanced.m`)
- 串行队列（Serial Queue）- 顺序执行 ⭐⭐⭐
- 并行队列（Concurrent Queue）- 同时执行 ⭐⭐⭐
- `dispatch_group` - 等待多个任务完成 ⭐⭐⭐
- `dispatch_barrier` - 栅栏函数（读写锁）⭐⭐
- 全局队列 vs 自定义队列
- 实战：批量下载图片

### 3️⃣ NSOperation (`03_nsoperation.m`)
- `NSBlockOperation` - 基础操作
- `addDependency` - 依赖关系 ⭐⭐⭐
- `cancel` - 取消操作 ⭐⭐
- `maxConcurrentOperationCount` - 最大并发数 ⭐⭐
- `queuePriority` - 操作优先级
- NSOperation vs GCD 对比
- 实战：可取消的批量下载

### 4️⃣ 线程安全 (`04_thread_safety.m`)
- 竞态条件（Race Condition）- 问题演示 ⚠️
- `NSLock` - 互斥锁 ⭐⭐⭐
- `@synchronized` - 同步锁 ⭐⭐⭐
- 性能对比：NSLock vs @synchronized
- 死锁（Deadlock）示例
- 实战：银行转账（线程安全）

---

## 🚀 快速开始

### 编译运行

```bash
# 进入多线程目录
cd /Users/huzhenyu/study/MAC-\ OC语法学习/multithreading/

# 编译并运行 GCD 基础
clang -fobjc-arc -framework Foundation 01_gcd_basic.m -o 01_gcd_basic && ./01_gcd_basic

# 编译并运行 GCD 高级
clang -fobjc-arc -framework Foundation 02_gcd_advanced.m -o 02_gcd_advanced && ./02_gcd_advanced

# 编译并运行 NSOperation
clang -fobjc-arc -framework Foundation 03_nsoperation.m -o 03_nsoperation && ./03_nsoperation

# 编译并运行线程安全
clang -fobjc-arc -framework Foundation 04_thread_safety.m -o 04_thread_safety && ./04_thread_safety
```

---

## 📖 核心概念

### 1. 队列类型

```
┌──────────────────────────────────────────┐
│           iOS/macOS 队列体系              │
└──────────────────────────────────────────┘

主队列（Main Queue）
├── 串行队列
├── 运行在主线程
└── UI 更新必须在这里 ⭐⭐⭐

全局队列（Global Queue）
├── 并发队列
├── 系统管理，全局共享
├── 4 个优先级
└── 后台任务常用 ⭐⭐⭐

自定义队列（Custom Queue）
├── 可以是串行或并发
├── 自己命名和管理
└── 适合需要精确控制的场景 ⭐⭐
```

### 2. GCD vs NSOperation

| 特性 | GCD | NSOperation |
|------|-----|-------------|
| 性能 | 更快 ⭐⭐⭐ | 略慢 ⭐⭐ |
| 语法 | 简洁 ⭐⭐⭐ | 面向对象 ⭐⭐ |
| 依赖关系 | ❌ 不支持 | ✅ addDependency ⭐⭐⭐ |
| 取消操作 | ❌ 不支持 | ✅ cancel ⭐⭐⭐ |
| 优先级 | ✅ 队列优先级 | ✅ 操作优先级 ⭐⭐ |
| 状态监听 | ❌ 不支持 | ✅ isExecuting/isFinished |

### 3. 线程安全方案

```objective-c
// 方式 1: NSLock（性能最好）⭐⭐⭐
NSLock *lock = [[NSLock alloc] init];
[lock lock];
counter++;  // 临界区
[lock unlock];

// 方式 2: @synchronized（语法最简单）⭐⭐⭐
@synchronized (lockObj) {
    counter++;  // 临界区
}

// 方式 3: 串行队列（GCD 风格）⭐⭐
dispatch_queue_t serialQueue = dispatch_queue_create("com.app.serial", DISPATCH_QUEUE_SERIAL);
dispatch_sync(serialQueue, ^{
    counter++;  // 临界区
});
```

---

## 💡 使用建议

### 何时使用 GCD？
- ✅ 简单的异步任务
- ✅ 不需要取消的操作
- ✅ 追求性能
- ✅ 批量并发操作

### 何时使用 NSOperation？
- ✅ 需要依赖关系（A完成后执行B）
- ✅ 需要取消操作
- ✅ 需要监听任务状态
- ✅ 复杂任务管理

### 何时需要线程安全？
- ✅ 多个线程访问同一变量
- ✅ 至少有一个线程在写入
- ✅ 操作不是原子的（如 `counter++`）

---

## 🎯 学习顺序

```
1. 先学 GCD 基础（01_gcd_basic.m）
   ↓
2. 掌握队列概念（02_gcd_advanced.m）
   ↓
3. 了解 NSOperation（03_nsoperation.m）
   ↓
4. 理解线程安全（04_thread_safety.m）
   ↓
5. 实战项目中应用
```

---

## ⚠️ 常见陷阱

### 1. 主线程死锁
```objective-c
// ❌ 错误：主线程同步调用主队列
dispatch_sync(dispatch_get_main_queue(), ^{
    // 死锁！主线程等待自己
});

// ✅ 正确：异步调用
dispatch_async(dispatch_get_main_queue(), ^{
    // 不阻塞
});
```

### 2. UI 更新必须在主线程
```objective-c
// ✅ 正确
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    // 后台下载数据
    NSData *data = [self downloadData];

    // 回到主线程更新 UI
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = [UIImage imageWithData:data];
    });
});
```

### 3. 线程不安全操作
```objective-c
// ❌ 错误：多线程同时修改数组
dispatch_async(queue, ^{ [array addObject:obj1]; });
dispatch_async(queue, ^{ [array addObject:obj2]; }); // 崩溃！

// ✅ 正确：加锁保护
NSLock *lock = [[NSLock alloc] init];
dispatch_async(queue, ^{
    [lock lock];
    [array addObject:obj1];
    [lock unlock];
});
```

---

## 📊 性能测试结果

```
并发下载 10 张图片（每张 1 秒）:
  串行队列: 10 秒
  并发队列: ~1 秒（快 10 倍）⭐

线程安全方案性能（10 万次操作）:
  NSLock:        ~0.05 秒 ⭐⭐⭐
  @synchronized: ~0.08 秒 ⭐⭐
  串行队列:      ~0.10 秒 ⭐
```

---

## 🔗 相关文档

- [Apple - Concurrency Programming Guide](https://developer.apple.com/library/archive/documentation/General/Conceptual/ConcurrencyProgrammingGuide/)
- [Apple - Grand Central Dispatch (GCD) Reference](https://developer.apple.com/documentation/dispatch)
- [Apple - NSOperation Class Reference](https://developer.apple.com/documentation/foundation/nsoperation)

---

**💡 提示**: 多线程是 iOS/macOS 开发的核心技能，建议结合实际项目多练习！

