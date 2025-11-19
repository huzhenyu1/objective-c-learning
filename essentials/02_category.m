//
//  02_category.m
//  OC 特有特性：分类（Category）
//
//  重点：Category 可以在不修改原类的情况下扩展功能
//       这是 OC 运行时特性的体现，C++ 没有类似功能
//

#import <Foundation/Foundation.h>

// ========== 原始类 ==========
@interface Person : NSObject

@property NSString *name;

@end

@implementation Person

@end

// ========== Category 1: 添加方法 ==========
// 格式：@interface 类名 (分类名)
@interface Person (StringExtension)

- (NSString *)uppercaseName;
- (NSString *)reverseName;

@end

@implementation Person (StringExtension)

- (NSString *)uppercaseName {
    return [self.name uppercaseString];
}

- (NSString *)reverseName {
    NSMutableString *reversed = [NSMutableString string];
    for (NSInteger i = [self.name length] - 1; i >= 0; i--) {
        [reversed appendFormat:@"%C", [self.name characterAtIndex:i]];
    }
    return reversed;
}

@end

// ========== Category 2: 为系统类添加方法 ==========
// 这是 Category 的强大之处：可以扩展系统类！
@interface NSString (MyExtension)

- (BOOL)isEmail;
- (NSString *)removeSpaces;

@end

@implementation NSString (MyExtension)

- (BOOL)isEmail {
    return [self containsString:@"@"];
}

- (NSString *)removeSpaces {
    return [self stringByReplacingOccurrencesOfString:@" " withString:@""];
}

@end

// ========== Category 3: 添加属性（使用关联对象）==========
#import <objc/runtime.h>

@interface Person (PropertyExtension)

@property NSString *nickname;  // 注意：Category 不能直接添加实例变量

@end

@implementation Person (PropertyExtension)

// 使用关联对象实现属性存储
- (void)setNickname:(NSString *)nickname {
    objc_setAssociatedObject(self, @selector(nickname), nickname, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)nickname {
    return objc_getAssociatedObject(self, @selector(nickname));
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // ========== 使用 Category 扩展的方法 ==========
        Person *person = [[Person alloc] init];
        person.name = @"张三";

        NSLog(@"原始名字: %@", person.name);
        NSLog(@"大写名字: %@", [person uppercaseName]);  // Category 方法
        NSLog(@"反转名字: %@", [person reverseName]);   // Category 方法

        person.nickname = @"小张";
        NSLog(@"昵称: %@", person.nickname);  // Category 属性

        // ========== 扩展系统类 ==========
        NSString *email = @"test@example.com";
        NSLog(@"%@ 是邮箱: %@", email, [email isEmail] ? @"是" : @"否");

        NSString *text = @"Hello World";
        NSLog(@"移除空格: %@", [text removeSpaces]);

        // ========== 对比 C++ ==========
        // C++: 无法在不修改源码的情况下扩展类
        // 只能通过继承或组合，但无法扩展系统类

        // ========== Category 的限制 ==========
        // 1. 不能添加实例变量（但可以用关联对象模拟）
        // 2. 不能覆盖原类方法（会编译警告）
        // 3. 方法名冲突时，Category 方法会覆盖原方法（危险！）

        // ========== 实际应用场景 ==========
        // 1. 为系统类添加便利方法
        // 2. 将大类拆分为多个 Category 文件
        // 3. 为第三方库添加功能（无需修改源码）
        // 4. 实现可选协议方法
    }
    return 0;
}

