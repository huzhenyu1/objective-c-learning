//
//  Person.m
//  DataPersistenceDemo
//
//  自定义模型类 - 实现序列化和反序列化
//

#import "Person.h"

@implementation Person

- (instancetype)initWithName:(NSString *)name age:(NSInteger)age email:(NSString *)email phone:(NSString *)phone birthday:(NSDate *)birthday {
    self = [super init];
    if (self) {
        _name = [name copy];
        _age = age;
        _email = [email copy];
        _phone = [phone copy];
        _birthday = birthday;
    }
    return self;
}

#pragma mark - NSCoding

// 编码（序列化）- 将对象转换为数据
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeInteger:self.age forKey:@"age"];
    [coder encodeObject:self.email forKey:@"email"];
    [coder encodeObject:self.phone forKey:@"phone"];
    [coder encodeObject:self.birthday forKey:@"birthday"];
}

// 解码（反序列化）- 将数据转换回对象
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _name = [coder decodeObjectForKey:@"name"];
        _age = [coder decodeIntegerForKey:@"age"];
        _email = [coder decodeObjectForKey:@"email"];
        _phone = [coder decodeObjectForKey:@"phone"];
        _birthday = [coder decodeObjectForKey:@"birthday"];
    }
    return self;
}

// 方便打印调试
- (NSString *)description {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *birthdayStr = [formatter stringFromDate:self.birthday];

    return [NSString stringWithFormat:@"Person(name: %@, age: %ld, email: %@, phone: %@, birthday: %@)",
            self.name, (long)self.age, self.email, self.phone, birthdayStr];
}

@end

