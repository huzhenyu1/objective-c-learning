# TestDemo - 自动高度对比演示

## 📱 项目说明

这是一个对比演示项目，展示了 `UITableView` 自动高度设置的**正确做法**和**错误做法**。

---

## 🎯 演示内容

### ❌ **错误做法** (`WrongViewController`)
- 在 `viewDidAppear:` 中设置 `estimatedRowHeight` 和 `rowHeight`
- 在 `viewDidAppear:` 中调用 `setupConstraints`
- **问题**：用户会看到界面跳动和闪烁

### ✅ **正确做法** (`CorrectViewController`)
- 在 `viewDidLoad` 中设置 `estimatedRowHeight` 和 `rowHeight`
- 在 `viewDidLoad` 中调用 `setupConstraints`
- **优点**：界面流畅自然，用户体验好

---

## 🔍 如何观察区别

### 1. 运行项目
```bash
cd /Users/huzhenyu/study/IOS项目练手/TestDemo
open TestDemo.xcodeproj
```

### 2. 观察要点

#### **错误做法的表现：**
1. 点击 "❌ 错误做法 (viewDidAppear)"
2. **注意观察**：页面切换时，你会看到：
   - 界面先显示默认高度的 Cell（文本可能被截断）
   - 然后突然跳动，Cell 变高
   - 整个过程用户都能看到，体验很差

#### **正确做法的表现：**
1. 点击 "✅ 正确做法 (viewDidLoad)"
2. **注意观察**：页面切换时，你会看到：
   - 界面直接显示正确高度的 Cell
   - 没有任何跳动或闪烁
   - 流畅自然，体验好

### 3. 测试动态更新

两个页面都有右上角的 **「切换文本」** 按钮：
- 点击后会修改第一行的文本（短文本 ↔ 长文本）
- 观察高度是否能正确更新
- **结论**：两种方法的动态更新都正常工作

---

## 📋 关键代码对比

### ❌ 错误做法

```objective-c
// WrongViewController.m

- (void)viewDidLoad {
    [super viewDidLoad];

    // 只创建 TableView，不设置自动高度
    [self setupTableView];
    // 不设置约束
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] init];
    // ⚠️ 没有设置 estimatedRowHeight 和 rowHeight
}

// ❌❌❌ 错误1：在 viewDidAppear 中设置
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // 用户已经看到界面了，此时设置会导致跳动
    self.tableView.estimatedRowHeight = CELL_HEIGHT;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    // 每次显示都设置约束（可能重复）
    [self setupConstraints];

    // 刷新界面（用户会看到跳动）
    [self.tableView reloadData];
}

// ❌❌❌ 错误2：手动计算高度（逻辑矛盾）
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (self.tableView.rowHeight == UITableViewAutomaticDimension) {

        // 问题1：设置了自动高度，又手动计算，逻辑矛盾
        // 问题2：使用 systemLayoutSizeFittingSize 性能开销大
        // 问题3：每个 Cell 都要计算，滚动时性能差

        static BookCell *sizingCell = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sizingCell = [[BookCell alloc] init];
        });

        sizingCell.bookTitle = self.bookTitles[indexPath.row];

        CGSize size = [sizingCell systemLayoutSizeFittingSize:CGSizeMake(tableView.bounds.size.width, 0)
                                  withHorizontalFittingPriority:UILayoutPriorityRequired
                                        verticalFittingPriority:UILayoutPriorityFittingSizeLevel];

        return (size.height > CELL_HEIGHT ? size.height : CELL_HEIGHT);
    }

    return CELL_HEIGHT;
}
```

---

### ✅ 正确做法

```objective-c
// CorrectViewController.m

- (void)viewDidLoad {
    [super viewDidLoad];

    // ✅ 在初始化时完成所有配置
    [self setupTableView];
    [self setupConstraints];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] init];

    // ✅✅✅ 正确：在 viewDidLoad 中设置自动高度
    self.tableView.estimatedRowHeight = 80;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)setupConstraints {
    // ✅ 约束在初始化时设置一次
    [NSLayoutConstraint activateConstraints:@[
        // ... 约束配置 ...
    ]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    BookCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BookCell"];
    if (!cell) {
        cell = [[BookCell alloc] initWithStyle:UITableViewCellStyleDefault
                                reuseIdentifier:@"BookCell"];
    }

    cell.bookTitle = self.bookTitles[indexPath.row];
    return cell;
}

// ✅✅✅ 正确：不实现 heightForRowAtIndexPath:
// 让系统自动根据 Cell 的约束计算高度
// 性能好、代码简洁、易维护

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // ✅ 用户看到的已经是正确的界面
    // 这里可以做其他事情（埋点、弹窗等）
}
```

---

## 🎯 核心结论

### **设置时机**

| 项目 | 错误做法 | 正确做法 |
|------|---------|---------|
| **estimatedRowHeight** | ❌ viewDidAppear | ✅ viewDidLoad |
| **rowHeight** | ❌ viewDidAppear | ✅ viewDidLoad |
| **setupConstraints** | ❌ viewDidAppear | ✅ viewDidLoad 或 init |
| **heightForRowAtIndexPath:** | ❌ 手动计算（矛盾） | ✅ 不实现（自动计算） |
| **用户体验** | ❌ 看到跳动 | ✅ 流畅自然 |
| **性能** | ❌ 每次都计算 | ✅ 系统自动优化 |
| **代码复杂度** | ❌ 复杂难维护 | ✅ 简洁易维护 |

### **动态更新**

```objective-c
// ✅ 数据修改后的正确做法
- (void)updateData {
    // 1. 修改数据
    self.bookTitles[0] = @"新的很长的标题";

    // 2. 刷新 TableView
    [self.tableView reloadData];

    // 高度会自动重新计算，不需要重新设置 rowHeight
}
```

---

## 📝 学习要点

1. **自动高度配置**（`estimatedRowHeight`、`rowHeight`）是**初始化工作**
   - 只需要在 `viewDidLoad` 中设置**一次**
   - 告诉 TableView："请使用自动高度计算模式"

2. **实际高度计算**是**动态的**
   - 每次 `reloadData` 都会重新计算
   - 根据 Cell 的实际内容自动调整

3. **约束设置**应该在 `viewDidLoad` 或 `init` 中
   - 只设置一次，避免重复添加
   - 不要在 `viewDidAppear` 中设置

4. **不要实现 `heightForRowAtIndexPath:`**（如果使用自动高度）
   - ⚠️ 设置了 `UITableViewAutomaticDimension` 后再手动计算高度是**逻辑矛盾**
   - ⚠️ 使用 `systemLayoutSizeFittingSize` 性能开销大
   - ✅ 让系统自动根据约束计算，性能更好

5. **数据修改后只需要 `reloadData`**
   - 不需要重新设置自动高度配置
   - TableView 会自动重新计算高度

---

## 🚀 运行项目

1. 打开项目：`open TestDemo.xcodeproj`
2. 选择模拟器或真机
3. 点击 Run（⌘R）
4. 依次点击两个选项，**仔细观察页面切换时的区别**
5. 点击右上角的「切换文本」按钮测试动态更新

---

## 💡 建议

- **慢放动画**：在模拟器中按 `⌘T` 开启慢动作模式，更容易观察到错误做法的跳动
- **查看日志**：打开 Console，可以看到两种做法的执行流程
- **对比体验**：多次进入两个页面，感受用户体验的差异

---

## 🎉 总结

**永远记住：**
- ✅ 自动高度配置在 `viewDidLoad` 中设置
- ✅ 约束在 `viewDidLoad` 或 `init` 中设置
- ✅ 数据修改后只需要 `reloadData`
- ❌ 不要在 `viewDidAppear` 中设置布局和配置

**目标：让界面在用户看到之前就准备好！**

