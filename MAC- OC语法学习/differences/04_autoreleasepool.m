//
//  04_autoreleasepool.m
//  OC vs C++ 核心差异：@autoreleasepool
//
//  重点：@autoreleasepool 用于管理临时对象的内存，避免内存峰值过高
//

#import <Foundation/Foundation.h>

@interface TempObject : NSObject

@property NSString *name;

+ (instancetype)tempObjectWithName:(NSString *)name;

@end

@implementation TempObject

+ (instancetype)tempObjectWithName:(NSString *)name {
    // ARC 下，类方法返回的对象会自动加入 autoreleasepool
    return [[self alloc] initWithName:name];
}

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _name = name;
        NSLog(@"创建对象: %@", name);
    }
    return self;
}

- (void)dealloc {
    NSLog(@"释放对象: %@", _name);
    // ARC 下不需要调用 [super dealloc]
}

@end

int main(int argc, const char * argv[]) {
    // ========== 不使用 autoreleasepool ==========
    NSLog(@"\n=== 不使用 autoreleasepool ===");
    for (int i = 0; i < 5; i++) {
        // 这些对象会一直存在，直到程序结束
        NSString *str = [NSString stringWithFormat:@"字符串 %d", i];
        NSLog(@"创建: %@", str);
        // 对象不会被释放，内存持续增长
    }
    NSLog(@"循环结束，但对象还未释放\n");

    // ========== 使用 autoreleasepool ==========
    NSLog(@"=== 使用 @autoreleasepool ===");
    @autoreleasepool {
        for (int i = 0; i < 5; i++) {
            // 这些对象会被加入 autoreleasepool
            NSString *str = [NSString stringWithFormat:@"字符串 %d", i];
            NSLog(@"创建: %@", str);
        }
        NSLog(@"循环结束，但对象还在 autoreleasepool 中");
    }  // autoreleasepool 结束，所有对象被释放
    NSLog(@"autoreleasepool 结束，对象已释放\n");

    // ========== 嵌套 autoreleasepool ==========
    NSLog(@"=== 嵌套 @autoreleasepool ===");
    @autoreleasepool {
        NSLog(@"外层 pool 开始");

        @autoreleasepool {
            NSLog(@"内层 pool 开始");
            NSString *innerStr = [NSString stringWithFormat:@"内层字符串"];
            NSLog(@"创建: %@", innerStr);
            NSLog(@"内层 pool 结束，内层对象被释放");
        }  // 内层对象在这里释放

        NSString *outerStr = [NSString stringWithFormat:@"外层字符串"];
        NSLog(@"创建: %@", outerStr);
        NSLog(@"外层 pool 结束，外层对象被释放");
    }  // 外层对象在这里释放

    // ========== 实际应用场景 ==========
    NSLog(@"\n=== 实际应用场景 ===");

    // 场景1: 大量临时对象
    @autoreleasepool {
        NSMutableArray *tempArray = [NSMutableArray array];
        for (int i = 0; i < 1000; i++) {
            [tempArray addObject:[NSString stringWithFormat:@"Item %d", i]];
        }
        NSLog(@"创建了 1000 个临时对象");
        // 使用完立即释放，避免内存峰值过高
    }
    NSLog(@"临时对象已释放，内存占用降低");

    // 场景2: 循环中创建大量对象
    NSLog(@"\n=== 循环中使用 autoreleasepool ===");
    for (int i = 0; i < 3; i++) {
        @autoreleasepool {
            // 每次循环创建的对象在循环结束时释放
            NSMutableArray *items = [NSMutableArray array];
            for (int j = 0; j < 100; j++) {
                [items addObject:[NSString stringWithFormat:@"%d-%d", i, j]];
            }
            NSLog(@"循环 %d: 创建了 100 个对象", i);
        }  // 每次循环结束，对象立即释放
    }
    NSLog(@"所有循环完成，内存已释放");

    // ========== 哪些方法会创建 autorelease 对象 ==========
    NSLog(@"\n=== 创建 autorelease 对象的方法 ===");
    @autoreleasepool {
        // 1. 类方法创建的对象（通常返回 autorelease 对象）
        NSString *str1 = [NSString stringWithFormat:@"格式化字符串"];
        NSArray *arr1 = [NSArray arrayWithObjects:@"A", @"B", nil];
        NSDictionary *dict1 = [NSDictionary dictionaryWithObject:@"value" forKey:@"key"];

        // 2. 使用 autorelease 方法
        TempObject *obj1 = [TempObject tempObjectWithName:@"临时对象1"];

        NSLog(@"创建了多个 autorelease 对象");
        // 这些对象会在 autoreleasepool 结束时释放
    }
    NSLog(@"autoreleasepool 结束，所有对象已释放");

    // ========== 对比 C++ ==========
    NSLog(@"\n=== 对比 C++ ===");
    // C++: 使用 RAII，对象离开作用域自动析构
    // {
    //     std::vector<std::string> vec;
    //     // 对象在栈上，离开作用域自动析构
    // }
    //
    // OC: 所有对象在堆上，需要手动管理或使用 autoreleasepool
    // @autoreleasepool {
    //     NSArray *arr = [NSArray array];
    //     // 对象在堆上，autoreleasepool 结束时释放
    // }

    // ========== 关键点总结 ==========
    NSLog(@"\n=== 关键点总结 ===");
    NSLog(@"1. @autoreleasepool 用于批量管理临时对象");
    NSLog(@"2. 避免内存峰值过高，及时释放不需要的对象");
    NSLog(@"3. 在循环中创建大量对象时特别有用");
    NSLog(@"4. 可以嵌套使用，内层对象先释放");
    NSLog(@"5. main 函数中的 @autoreleasepool 会在程序结束时释放所有对象");

    return 0;
}

