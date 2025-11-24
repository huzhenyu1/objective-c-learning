//
//  Person.h
//  DataPersistenceDemo
//
//  自定义模型类 - 实现 NSCoding 协议
//

#import <Foundation/Foundation.h>

@interface Person : NSObject <NSCoding>

@property (copy, nonatomic) NSString *name;
@property (assign, nonatomic) NSInteger age;
@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *phone;
@property (strong, nonatomic) NSDate *birthday;

- (instancetype)initWithName:(NSString *)name age:(NSInteger)age email:(NSString *)email phone:(NSString *)phone birthday:(NSDate *)birthday;

@end

