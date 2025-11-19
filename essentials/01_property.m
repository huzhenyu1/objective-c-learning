//
//  01_property.m
//  OC 特有特性：@property 属性
//
//  重点：@property 自动生成 getter/setter，比 C++ 的 getter/setter 更强大
//

#import <Foundation/Foundation.h>

@interface Student : NSObject

// ========== @property 属性修饰符 ==========
// strong: 强引用（对象类型默认）
// weak: 弱引用（避免循环引用）
// assign: 直接赋值（基本类型，如 int, float）
// copy: 复制对象（NSString 常用）
// readonly: 只读属性
// nonatomic: 非原子性（性能更好，单线程安全）

@property (strong, nonatomic) NSString *name;        // 强引用，非原子
@property (assign, nonatomic) int age;                // 直接赋值
@property (copy, nonatomic) NSString *school;         // 复制（NSString 推荐）
@property (readonly, nonatomic) NSString *studentID; // 只读
@property (weak, nonatomic) Student *friend;          // 弱引用

// 自定义 getter/setter 名称
@property (getter=isGraduated, nonatomic) BOOL graduated;

- (instancetype)initWithName:(NSString *)name age:(int)age;

@end

@implementation Student {
    NSString *_studentID;  // 私有实例变量
}

- (instancetype)initWithName:(NSString *)name age:(int)age {
    self = [super init];
    if (self) {
        _name = name;
        _age = age;
        _studentID = [NSString stringWithFormat:@"STU%05d", arc4random() % 100000];
        _graduated = NO;
    }
    return self;
}

// 只读属性的 getter（自动生成，但可以自定义）
- (NSString *)studentID {
    return _studentID;
}

// 自定义 getter
- (BOOL)isGraduated {
    return _graduated;
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Student *student = [[Student alloc] initWithName:@"李四" age:20];

        // ========== 使用点语法 ==========
        // OC: 点语法调用 getter/setter
        student.school = @"清华大学";  // 等价于 [student setSchool:@"清华大学"]
        NSLog(@"姓名: %@", student.name);  // 等价于 [student name]
        NSLog(@"年龄: %d", student.age);
        NSLog(@"学校: %@", student.school);
        NSLog(@"学号: %@", student.studentID);  // 只读属性

        // ========== 对比 C++ ==========
        // C++: 需要手动实现 getter/setter
        // class Student {
        // private:
        //     std::string name_;
        // public:
        //     void setName(const std::string& name) { name_ = name; }
        //     const std::string& getName() const { return name_; }
        // };

        // ========== 属性特性 ==========
        // copy 的作用：防止外部修改
        NSMutableString *mutableName = [NSMutableString stringWithString:@"可变名字"];
        student.name = mutableName;  // strong: 直接引用
        [mutableName appendString:@"被修改"];
        NSLog(@"strong 属性: %@ (可能被修改)", student.name);

        student.school = mutableName;  // copy: 复制一份
        [mutableName appendString:@"再次修改"];
        NSLog(@"copy 属性: %@ (不会被修改)", student.school);

        // ========== 弱引用示例 ==========
        Student *friend1 = [[Student alloc] initWithName:@"朋友1" age:21];
        Student *friend2 = [[Student alloc] initWithName:@"朋友2" age:22];

        friend1.friend = friend2;  // weak 引用
        friend2.friend = friend1;  // weak 引用

        NSLog(@"朋友1的朋友: %@", friend1.friend.name);
        NSLog(@"朋友2的朋友: %@", friend2.friend.name);

        // ========== 关键点总结 ==========
        // 1. @property 自动生成 getter/setter 和实例变量
        // 2. 点语法是语法糖，实际调用方法
        // 3. 属性修饰符控制内存管理和线程安全
        // 4. copy 用于 NSString/NSArray 等可变类，防止外部修改
        // 5. weak 用于避免循环引用
    }
    return 0;
}

