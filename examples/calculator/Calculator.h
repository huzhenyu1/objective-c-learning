//
//  Calculator.h
//  计算器示例 - 头文件
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Calculator : NSObject

@property (nonatomic, assign) double result;

- (instancetype)init;
- (void)add:(double)value;
- (void)subtract:(double)value;
- (void)multiply:(double)value;
- (void)divide:(double)value;
- (void)clear;

@end

NS_ASSUME_NONNULL_END

