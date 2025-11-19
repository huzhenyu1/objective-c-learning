//
//  02_at_syntax.m
//  OC vs C++ 核心差异：@ 语法糖
//
//  重点：OC 使用 @ 前缀创建对象字面量，这是 OC 特有的语法
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // ========== 字符串 ==========
        // OC: 使用 @"" 创建 NSString 对象
        NSString *ocString = @"Hello Objective-C";

        // C++: 使用 std::string 或字符串字面量
        // std::string cppString = "Hello C++";

        NSLog(@"OC 字符串: %@", ocString);

        // ========== 数字对象 ==========
        // OC: 使用 @数字 创建 NSNumber 对象
        NSNumber *intNum = @42;
        NSNumber *floatNum = @3.14f;
        NSNumber *doubleNum = @2.71828;
        NSNumber *boolNum = @YES;  // YES/NO 是 OC 的布尔值

        NSLog(@"整数: %@, 浮点: %@, 双精度: %@, 布尔: %@",
              intNum, floatNum, doubleNum, boolNum);

        // C++: 需要手动创建对象或使用基本类型
        // int cppInt = 42;
        // std::shared_ptr<int> cppIntPtr = std::make_shared<int>(42);

        // ========== 数组 ==========
        // OC: 使用 @[] 创建 NSArray（不可变数组）
        NSArray *ocArray = @[@"苹果", @"香蕉", @"橙子"];
        NSLog(@"OC 数组: %@", ocArray);

        // 访问元素
        NSLog(@"第一个元素: %@", ocArray[0]);  // 使用下标访问

        // C++: 使用 std::vector
        // std::vector<std::string> cppVector = {"苹果", "香蕉", "橙子"};

        // ========== 字典 ==========
        // OC: 使用 @{} 创建 NSDictionary（键值对）
        NSDictionary *ocDict = @{
            @"name": @"张三",
            @"age": @25,
            @"city": @"北京"
        };
        NSLog(@"OC 字典: %@", ocDict);

        // 访问值
        NSLog(@"姓名: %@", ocDict[@"name"]);
        NSLog(@"年龄: %@", ocDict[@"age"]);

        // C++: 使用 std::map 或 std::unordered_map
        // std::map<std::string, std::string> cppMap = {
        //     {"name", "张三"},
        //     {"city", "北京"}
        // };

        // ========== 可变集合 ==========
        // OC: 使用 NSMutableArray 和 NSMutableDictionary
        NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:@[@"A", @"B"]];
        [mutableArray addObject:@"C"];
        NSLog(@"可变数组: %@", mutableArray);

        NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:@{
            @"key1": @"value1"
        }];
        mutableDict[@"key2"] = @"value2";
        NSLog(@"可变字典: %@", mutableDict);

        // ========== 关键差异总结 ==========
        // 1. OC 所有对象都是指针（id 类型）
        // 2. @ 语法是编译时语法糖，会被转换为方法调用
        // 3. OC 集合类都是对象，可以存储任意对象类型
        // 4. OC 使用引用计数管理内存，不是 RAII
    }
    return 0;
}

