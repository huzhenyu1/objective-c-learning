//
//  05_arc_autoreleasepool.m
//  ARC 环境下 @autoreleasepool 的必要性
//
//  重点：即使使用 ARC，@autoreleasepool 仍然非常重要
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSLog(@"=== ARC 环境下 @autoreleasepool 的作用 ===\n");

        // ========== 关键点1: 类方法返回的对象仍然使用 autorelease ==========
        NSLog(@"1. 类方法返回的对象会自动加入 autoreleasepool");
        NSLog(@"   即使使用 ARC，这些对象也不会立即释放\n");

        // 这些类方法返回的对象都是 autorelease 对象
        NSString *str1 = [NSString stringWithFormat:@"字符串1"];
        NSArray *arr1 = [NSArray arrayWithObjects:@"A", @"B", nil];
        NSDictionary *dict1 = [NSDictionary dictionaryWithObject:@"value" forKey:@"key"];

        NSLog(@"创建了多个对象，它们都在 autoreleasepool 中");
        NSLog(@"这些对象会在 autoreleasepool 结束时释放\n");

        // ========== 关键点2: 循环中创建大量对象 ==========
        NSLog(@"2. 循环中创建大量对象时的内存管理");

        // 不使用 autoreleasepool（内存峰值高）
        NSLog(@"\n--- 不使用 autoreleasepool ---");
        NSMutableArray *allObjects = [NSMutableArray array];
        for (int i = 0; i < 1000; i++) {
            NSString *temp = [NSString stringWithFormat:@"Item %d", i];
            [allObjects addObject:temp];  // 强引用，对象不会释放
        }
        NSLog(@"创建了 1000 个对象，内存占用高");
        NSLog(@"这些对象会一直存在，直到 allObjects 被释放\n");

        // 使用 autoreleasepool（及时释放）
        NSLog(@"--- 使用 @autoreleasepool ---");
        for (int i = 0; i < 5; i++) {
            @autoreleasepool {
                // 每次循环创建的对象在循环结束时释放
                NSMutableArray *tempArray = [NSMutableArray array];
                for (int j = 0; j < 100; j++) {
                    [tempArray addObject:[NSString stringWithFormat:@"%d-%d", i, j]];
                }
                NSLog(@"循环 %d: 创建了 100 个临时对象", i);
                // tempArray 在这里被释放，包含的所有对象也被释放
            }  // 循环结束，临时对象立即释放
        }
        NSLog(@"所有循环完成，临时对象已释放，内存占用低\n");

        // ========== 关键点3: ARC 不会自动创建 autoreleasepool ==========
        NSLog(@"3. ARC 不会自动创建 autoreleasepool");
        NSLog(@"   如果没有 @autoreleasepool，autorelease 对象会累积\n");

        // ========== 实际测试：内存峰值对比 ==========
        NSLog(@"4. 实际测试：内存峰值对比\n");

        // 测试1: 不使用 autoreleasepool
        NSLog(@"测试1: 不使用 autoreleasepool");
        NSMutableArray *test1 = [NSMutableArray array];
        for (int i = 0; i < 10000; i++) {
            NSString *obj = [NSString stringWithFormat:@"Object %d", i];
            [test1 addObject:obj];  // 所有对象都保留在内存中
        }
        NSLog(@"结果: 内存中保留了 10000 个对象\n");

        // 测试2: 使用 autoreleasepool
        NSLog(@"测试2: 使用 @autoreleasepool");
        NSMutableArray *test2 = [NSMutableArray array];
        for (int i = 0; i < 10000; i++) {
            @autoreleasepool {
                NSString *obj = [NSString stringWithFormat:@"Object %d", i];
                [test2 addObject:obj];
                // 如果不需要保留，obj 在这里就会被释放
            }
        }
        NSLog(@"结果: 临时对象及时释放，只保留需要的对象\n");

        // ========== 关键点4: 什么时候必须使用 ==========
        NSLog(@"5. 什么时候必须使用 @autoreleasepool:\n");
        NSLog(@"   ✓ 在循环中创建大量临时对象");
        NSLog(@"   ✓ 处理大文件或大量数据");
        NSLog(@"   ✓ 创建大量不需要长期保留的对象");
        NSLog(@"   ✓ 避免内存峰值过高\n");

        // ========== 关键点5: ARC 下的最佳实践 ==========
        NSLog(@"6. ARC 下的最佳实践:\n");
        NSLog(@"   • main 函数中必须有 @autoreleasepool");
        NSLog(@"   • 在循环中创建大量对象时使用");
        NSLog(@"   • 处理临时数据时使用");
        NSLog(@"   • 可以嵌套使用，精确控制释放时机\n");

        // ========== 总结 ==========
        NSLog(@"=== 总结 ===");
        NSLog(@"ARC 环境下 @autoreleasepool 仍然必要，因为：");
        NSLog(@"1. 类方法返回的对象使用 autorelease 机制");
        NSLog(@"2. 可以控制临时对象的释放时机");
        NSLog(@"3. 避免内存峰值过高");
        NSLog(@"4. 提高内存使用效率");
    }

    return 0;
}

