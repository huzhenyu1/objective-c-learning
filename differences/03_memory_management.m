//
//  03_memory_management.m
//  OC vs C++ 核心差异：内存管理
//
//  重点：OC 使用 ARC（自动引用计数），与 C++ 的 RAII 完全不同
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property (strong) NSString *name;  // strong: 强引用（默认）
@property (weak) Person *spouse;     // weak: 弱引用，避免循环引用

- (instancetype)initWithName:(NSString *)name;

@end

@implementation Person

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _name = name;
        NSLog(@"创建 Person: %@", name);
    }
    return self;
}

- (void)dealloc {
    NSLog(@"释放 Person: %@", _name);
    // ARC 下不需要调用 [super dealloc]
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // ========== ARC 自动内存管理 ==========
        // OC: ARC 自动管理引用计数
        Person *person1 = [[Person alloc] init];  // 引用计数 = 1
        person1.name = @"张三";

        Person *person2 = person1;  // 引用计数 = 2（strong 引用）

        // 当 person1 和 person2 超出作用域时，ARC 自动释放
        // 引用计数变为 0 时，dealloc 被调用

        // ========== 对比 C++ ==========
        // C++: 使用 RAII，对象离开作用域自动析构
        // {
        //     Person person("张三");  // 栈对象，自动管理
        //     // 离开作用域时自动调用析构函数
        // }
        //
        // // 或使用智能指针
        // std::shared_ptr<Person> person = std::make_shared<Person>("张三");

        // ========== 强引用和弱引用 ==========
        Person *husband = [[Person alloc] initWithName:@"丈夫"];
        Person *wife = [[Person alloc] initWithName:@"妻子"];

        // 建立双向关系
        husband.spouse = wife;  // weak 引用，不会增加引用计数
        wife.spouse = husband;  // weak 引用

        // 如果使用 strong，会导致循环引用，内存泄漏！
        // husband.spouse = wife;  // strong: 引用计数 +1
        // wife.spouse = husband;  // strong: 引用计数 +1
        // 即使没有外部引用，引用计数也不会变为 0，导致泄漏

        NSLog(@"丈夫的配偶: %@", husband.spouse.name);
        NSLog(@"妻子的配偶: %@", wife.spouse.name);

        // ========== @autoreleasepool ==========
        // OC: 使用 autoreleasepool 管理临时对象
        @autoreleasepool {
            NSString *tempString = [NSString stringWithFormat:@"临时字符串 %d", 42];
            NSLog(@"临时对象: %@", tempString);
            // tempString 会在 autoreleasepool 结束时释放
        }

        // ========== 关键差异总结 ==========
        // 1. OC: 引用计数（ARC），对象是堆分配的
        // 2. C++: RAII，栈对象自动管理，堆对象需要智能指针
        // 3. OC: 所有对象都是指针，没有栈对象
        // 4. OC: 需要特别注意循环引用（使用 weak）
        // 5. OC: @autoreleasepool 用于批量释放临时对象
    }

    NSLog(@"autoreleasepool 结束，对象将被释放");
    return 0;
}

