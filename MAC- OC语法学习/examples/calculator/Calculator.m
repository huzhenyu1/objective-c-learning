//
//  Calculator.m
//  计算器示例 - 实现文件
//

#import "Calculator.h"

@implementation Calculator

- (instancetype)init {
    self = [super init];
    if (self) {
        _result = 0.0;
    }
    return self;
}

- (void)add:(double)value {
    self.result += value;
}

- (void)subtract:(double)value {
    self.result -= value;
}

- (void)multiply:(double)value {
    self.result *= value;
}

- (void)divide:(double)value {
    if (value != 0) {
        self.result /= value;
    } else {
        NSLog(@"错误: 除数不能为0");
    }
}

- (void)clear {
    self.result = 0.0;
}

@end

