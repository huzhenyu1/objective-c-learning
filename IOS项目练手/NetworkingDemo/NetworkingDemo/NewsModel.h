//
//  NewsModel.h
//  NetworkingDemo
//
//  新闻数据模型
//

#import <Foundation/Foundation.h>

@interface NewsModel : NSObject

@property (assign, nonatomic) NSInteger newsId;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *content;
@property (copy, nonatomic) NSString *author;
@property (copy, nonatomic) NSString *publishTime;
@property (copy, nonatomic) NSString *imageURL;

// 从字典创建模型
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;

@end

