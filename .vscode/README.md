# VS Code 配置说明

## 已配置的功能

### 1. 调试配置 (launch.json)
- 为每个示例程序配置了独立的调试配置
- 支持使用 LLDB 进行调试
- 自动编译后启动调试

### 2. 编译任务 (tasks.json)
- 为每个示例配置了编译任务
- 支持一键编译所有示例（默认任务）
- 支持清理编译文件

### 3. 编辑器设置 (settings.json)
- Objective-C 文件关联
- 代码格式化设置
- 文件排除规则

### 4. 推荐扩展 (extensions.json)
- C/C++ 扩展（代码高亮和智能提示）
- CodeLLDB 扩展（调试支持）

## 使用方法

### 编译和运行
1. **使用任务面板**：
   - 按 `Cmd+Shift+P` (Mac) 或 `Ctrl+Shift+P` (Windows/Linux)
   - 输入 "Tasks: Run Task"
   - 选择要编译的任务

2. **使用快捷键**：
   - 按 `Cmd+Shift+B` (Mac) 或 `Ctrl+Shift+B` (Windows/Linux) 编译默认任务（所有示例）

3. **使用终端**：
   ```bash
   make all      # 编译所有示例
   make clean    # 清理编译文件
   ```

### 调试
1. 打开要调试的 `.m` 文件
2. 按 `F5` 或点击调试按钮
3. 选择对应的调试配置（如"调试 Hello World"）
4. 设置断点，开始调试

### 安装推荐扩展
VS Code 会自动提示安装推荐的扩展，或者手动安装：
- C/C++ (ms-vscode.cpptools)
- CodeLLDB (vadimcn.vscode-lldb)

## 注意事项

- 确保已安装 Xcode Command Line Tools：
  ```bash
  xcode-select --install
  ```
- 调试需要 LLDB，macOS 系统自带
- 编译后的可执行文件会生成在源文件同目录下

