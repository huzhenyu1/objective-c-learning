//
//  02_kvc_kvo.m
//  实际工程中的重点：KVC/KVO（键值编码/键值观察）
//
//  重点：KVC/KVO 是 Cocoa 框架的核心特性，用于数据绑定和观察者模式
//

#import <Foundation/Foundation.h>

// ========== KVC（Key-Value Coding）==========
@interface Person : NSObject

@property NSString *name;
@property int age;

@end

@implementation Person

@end

// ========== KVO（Key-Value Observing）==========
@interface Observer : NSObject

@end

@implementation Observer

// KVO 回调方法
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    NSLog(@"属性 %@ 发生变化", keyPath);
    NSLog(@"旧值: %@", change[NSKeyValueChangeOldKey]);
    NSLog(@"新值: %@", change[NSKeyValueChangeNewKey]);
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // ========== KVC 使用 ==========
        Person *person = [[Person alloc] init];

        // 使用 KVC 设置值
        [person setValue:@"张三" forKey:@"name"];
        [person setValue:@25 forKey:@"age"];

        // 使用 KVC 获取值
        NSString *name = [person valueForKey:@"name"];
        NSNumber *age = [person valueForKey:@"age"];

        NSLog(@"KVC - 姓名: %@, 年龄: %@", name, age);

        // KVC 路径访问（访问嵌套属性）
        // [person setValue:@"北京" forKeyPath:@"address.city"];

        // ========== KVO 使用 ==========
        Observer *observer = [[Observer alloc] init];

        // 添加观察者
        [person addObserver:observer
                  forKeyPath:@"name"
                     options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                     context:nil];

        [person addObserver:observer
                  forKeyPath:@"age"
                     options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                     context:nil];

        // 修改属性（会触发 KVO）
        person.name = @"李四";  // 触发观察者
        person.age = 30;        // 触发观察者

        // 移除观察者（重要！）
        [person removeObserver:observer forKeyPath:@"name"];
        [person removeObserver:observer forKeyPath:@"age"];

        // ========== KVC 字典操作 ==========
        NSDictionary *dict = @{
            @"name": @"王五",
            @"age": @28
        };

        // 批量设置属性
        [person setValuesForKeysWithDictionary:dict];
        NSLog(@"批量设置后 - 姓名: %@, 年龄: %d", person.name, person.age);

        // 获取所有属性值
        NSDictionary *values = [person dictionaryWithValuesForKeys:@[@"name", @"age"]];
        NSLog(@"所有属性值: %@", values);

        // ========== 实际应用场景 ==========
        // 1. 数据绑定（Cocoa Binding）
        // 2. Core Data（ORM 框架）
        // 3. 模型-视图绑定
        // 4. 配置管理

        // ========== 注意事项 ==========
        // 1. KVO 必须手动移除观察者（dealloc 中）
        // 2. KVC 访问不存在的键会崩溃（使用 valueForKey: 返回 nil）
        // 3. KVO 只对属性有效（使用 @property）
        // 4. 性能考虑：KVO 有开销，不要过度使用
    }
    return 0;
}

