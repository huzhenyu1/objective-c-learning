//
//  01_common_classes.m
//  Foundation 框架常用类
//
//  重点：实际开发中最常用的 Foundation 类
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // ========== NSString（字符串）==========
        // 最常用的类之一
        NSString *str1 = @"Hello";  // 字面量
        NSString *str2 = [NSString stringWithFormat:@"格式化: %d", 42];
        NSString *str3 = [[NSString alloc] initWithFormat:@"初始化: %@", @"World"];

        NSLog(@"字符串长度: %lu", (unsigned long)[str1 length]);
        NSLog(@"是否包含: %@", [str1 containsString:@"ell"] ? @"是" : @"否");
        NSLog(@"转大写: %@", [str1 uppercaseString]);
        NSLog(@"转小写: %@", [@"WORLD" lowercaseString]);

        // 字符串拼接
        NSString *combined = [str1 stringByAppendingString:@" World"];
        NSLog(@"拼接: %@", combined);

        // ========== NSMutableString（可变字符串）==========
        NSMutableString *mutableStr = [NSMutableString stringWithString:@"可变"];
        [mutableStr appendString:@"字符串"];
        [mutableStr insertString:@"的" atIndex:2];
        NSLog(@"可变字符串: %@", mutableStr);

        // ========== NSArray（数组）==========
        NSArray *array = @[@"A", @"B", @"C"];
        NSLog(@"数组元素数: %lu", (unsigned long)[array count]);
        NSLog(@"第一个元素: %@", array[0]);
        NSLog(@"包含 'B': %@", [array containsObject:@"B"] ? @"是" : @"否");

        // 遍历数组
        for (NSString *item in array) {
            NSLog(@"元素: %@", item);
        }

        // ========== NSMutableArray（可变数组）==========
        NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:@[@"1", @"2"]];
        [mutableArray addObject:@"3"];
        [mutableArray insertObject:@"0" atIndex:0];
        [mutableArray removeObjectAtIndex:1];
        NSLog(@"可变数组: %@", mutableArray);

        // ========== NSDictionary（字典）==========
        NSDictionary *dict = @{
            @"name": @"张三",
            @"age": @25,
            @"city": @"北京"
        };
        NSLog(@"字典值: %@", dict[@"name"]);
        NSLog(@"所有键: %@", [dict allKeys]);
        NSLog(@"所有值: %@", [dict allValues]);

        // 遍历字典
        for (NSString *key in dict) {
            NSLog(@"%@: %@", key, dict[key]);
        }

        // ========== NSMutableDictionary（可变字典）==========
        NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
        mutableDict[@"key1"] = @"value1";
        [mutableDict setObject:@"value2" forKey:@"key2"];
        [mutableDict removeObjectForKey:@"key1"];
        NSLog(@"可变字典: %@", mutableDict);

        // ========== NSNumber（数字对象）==========
        NSNumber *intNum = @42;
        NSNumber *floatNum = @3.14f;
        NSNumber *boolNum = @YES;

        NSLog(@"整数: %d", [intNum intValue]);
        NSLog(@"浮点: %.2f", [floatNum floatValue]);
        NSLog(@"布尔: %@", [boolNum boolValue] ? @"YES" : @"NO");

        // ========== NSDate（日期）==========
        NSDate *now = [NSDate date];
        NSLog(@"当前时间: %@", now);

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *dateString = [formatter stringFromDate:now];
        NSLog(@"格式化时间: %@", dateString);

        // ========== NSSet（集合，无序，唯一）==========
        NSSet *set = [NSSet setWithObjects:@"A", @"B", @"C", @"A", nil];
        NSLog(@"集合: %@ (自动去重)", set);
        NSLog(@"包含 'B': %@", [set containsObject:@"B"] ? @"是" : @"否");

        // ========== 实际开发技巧 ==========
        // 1. 使用字面量语法创建对象（@"" @[] @{}）
        // 2. 优先使用不可变类型（NSArray, NSDictionary），需要时再使用可变类型
        // 3. NSString 使用 copy 属性，防止外部修改
        // 4. 使用快速枚举（for-in）遍历集合
        // 5. 使用 stringWithFormat 格式化字符串
    }
    return 0;
}

