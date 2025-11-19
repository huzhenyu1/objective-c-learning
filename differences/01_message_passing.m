//
//  01_message_passing.m
//  OC vs C++ 核心差异：消息传递机制
//
//  重点：Objective-C 使用消息传递，而不是函数调用
//  这是 OC 最核心的特性，也是与 C++ 最大的区别
//

#import <Foundation/Foundation.h>

@interface Calculator : NSObject

// OC 方法声明：- 表示实例方法，+ 表示类方法
// 格式：[返回值类型] 方法名:(参数类型)参数名 标签:(参数类型)参数名
- (int)add:(int)a to:(int)b;           // 方法名是 "add:to:"
- (int)multiply:(int)a by:(int)b;      // 方法名是 "multiply:by:"

@end

@implementation Calculator

- (int)add:(int)a to:(int)b {
    return a + b;
}

- (int)multiply:(int)a by:(int)b {
    return a * b;
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Calculator *calc = [[Calculator alloc] init];

        // ========== OC 消息传递 ==========
        // [对象 消息]
        int result1 = [calc add:10 to:20];        // 发送消息 "add:to:"
        int result2 = [calc multiply:5 by:4];      // 发送消息 "multiply:by:"

        NSLog(@"OC 消息传递: add:10 to:20 = %d", result1);
        NSLog(@"OC 消息传递: multiply:5 by:4 = %d", result2);

        // ========== 对比 C++ ==========
        // C++ 中会是：
        // Calculator calc;
        // int result = calc.add(10, 20);  // 直接函数调用

        // ========== OC 的关键点 ==========
        // 1. 消息可以在运行时动态发送（即使方法不存在也不会编译错误）
        // 2. 方法名包含参数标签，更易读
        // 3. 可以发送消息给 nil（不会崩溃，返回 0/nil）

        Calculator *nilCalc = nil;
        int result3 = [nilCalc add:10 to:20];  // 不会崩溃！返回 0
        NSLog(@"发送消息给 nil: %d (不会崩溃)", result3);

        // ========== 嵌套消息 ==========
        // OC 支持嵌套消息调用
        // 示例1: 嵌套 alloc 和 init
        Calculator *calc2 = [[Calculator alloc] init];
        int nested = [calc2 add:1 to:2];  // 直接使用返回值（int 类型）
        NSLog(@"嵌套消息调用: 1 + 2 = %d", nested);

        // 示例2: 嵌套调用返回对象的方法
        NSString *resultStr = [[NSString alloc] initWithFormat:@"结果: %d", nested];
        NSLog(@"%@", resultStr);
    }
    return 0;
}

