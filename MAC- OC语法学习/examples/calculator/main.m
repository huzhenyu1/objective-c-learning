//
//  main.m
//  计算器示例 - 主程序
//

#import <Foundation/Foundation.h>
#import "Calculator.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Calculator *calc = [[Calculator alloc] init];

        NSLog(@"=== 计算器示例 ===");

        // 执行计算
        [calc add:10];
        NSLog(@"加 10: %.2f", calc.result);

        [calc subtract:3];
        NSLog(@"减 3: %.2f", calc.result);

        [calc multiply:2];
        NSLog(@"乘 2: %.2f", calc.result);

        [calc divide:4];
        NSLog(@"除 4: %.2f", calc.result);

        [calc clear];
        NSLog(@"清零: %.2f", calc.result);
    }
    return 0;
}

