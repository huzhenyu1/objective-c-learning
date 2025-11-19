//
//  03_block.m
//  OC 特有特性：Block（块）
//
//  重点：Block 是 OC 的闭包，类似 C++11 的 lambda，但功能更强大
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // ========== Block 基本语法 ==========
        // 格式：返回值类型 (^块名)(参数类型) = ^(参数) { 代码 };

        // 无参数无返回值
        void (^simpleBlock)(void) = ^{
            NSLog(@"这是一个简单的 Block");
        };
        simpleBlock();

        // 有参数有返回值
        int (^addBlock)(int, int) = ^(int a, int b) {
            return a + b;
        };
        int result = addBlock(5, 3);
        NSLog(@"5 + 3 = %d", result);

        // ========== Block 作为参数 ==========
        // OC 常用模式：Block 作为回调
        NSArray *numbers = @[@1, @2, @3, @4, @5];

        [numbers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSLog(@"索引 %lu: %@", (unsigned long)idx, obj);
            if (idx == 2) {
                *stop = YES;  // 停止枚举
            }
        }];

        // ========== 捕获变量 ==========
        int multiplier = 10;
        int (^multiplyBlock)(int) = ^(int num) {
            return num * multiplier;  // 捕获外部变量 multiplier
        };
        NSLog(@"4 * %d = %d", multiplier, multiplyBlock(4));

        // ========== __block 修饰符 ==========
        // 允许在 Block 内修改外部变量
        __block int counter = 0;
        void (^incrementBlock)(void) = ^{
            counter++;  // 可以修改外部变量
            NSLog(@"计数器: %d", counter);
        };
        incrementBlock();
        incrementBlock();

        // ========== Block 类型定义 ==========
        // 使用 typedef 定义 Block 类型，提高可读性
        typedef int (^MathOperation)(int, int);

        MathOperation add = ^(int a, int b) { return a + b; };
        MathOperation multiply = ^(int a, int b) { return a * b; };

        NSLog(@"10 + 5 = %d", add(10, 5));
        NSLog(@"10 * 5 = %d", multiply(10, 5));

        // ========== Block 作为属性 ==========
        // 注意：Block 属性通常使用 copy
        typedef void (^CompletionBlock)(BOOL success, NSString *message);

        CompletionBlock completion = ^(BOOL success, NSString *message) {
            if (success) {
                NSLog(@"成功: %@", message);
            } else {
                NSLog(@"失败: %@", message);
            }
        };

        completion(YES, @"操作完成");
        completion(NO, @"操作失败");

        // ========== 对比 C++ Lambda ==========
        // C++:
        // auto lambda = [](int a, int b) { return a + b; };
        // int result = lambda(5, 3);
        //
        // OC Block 的优势：
        // 1. 可以捕获 Objective-C 对象
        // 2. 可以修改 __block 变量
        // 3. 与 OC 对象系统集成更好

        // ========== 内存管理 ==========
        // Block 捕获对象时：
        // - 默认是强引用（可能导致循环引用）
        // - 使用 __weak 避免循环引用

        // 示例：在类方法中使用 weak self
        // @interface MyClass : NSObject
        // @end
        // @implementation MyClass
        // - (void)someMethod {
        //     __weak typeof(self) weakSelf = self;
        //     void (^block)(void) = ^{
        //         [weakSelf doSomething];  // 使用 weakSelf 避免循环引用
        //     };
        // }
        // @end

        // ========== 实际应用场景 ==========
        // 1. 异步回调（网络请求、文件操作）
        // 2. 集合操作（map, filter, reduce）
        // 3. 动画完成回调
        // 4. 错误处理回调

        // 示例：模拟异步操作
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 后台执行
            NSLog(@"后台执行任务");

            dispatch_async(dispatch_get_main_queue(), ^{
                // 主线程更新 UI
                NSLog(@"主线程更新 UI");
            });
        });
    }
    return 0;
}

