//
//  NewsModel.m
//  NetworkingDemo
//
//  新闻数据模型
//

#import "NewsModel.h"

@implementation NewsModel

+ (instancetype)modelWithDictionary:(NSDictionary *)dict {
    NewsModel *model = [[NewsModel alloc] init];

    // 安全地提取数据
    model.newsId = [dict[@"id"] integerValue];
    model.title = dict[@"title"] ?: @"";
    model.content = dict[@"body"] ?: @"";  // API 返回的是 body 字段
    model.author = dict[@"author"] ?: @"未知作者";
    model.publishTime = dict[@"publishTime"] ?: @"2024-01-01";
    model.imageURL = dict[@"imageURL"] ?: @"";

    return model;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<NewsModel: id=%ld, title=%@>", (long)self.newsId, self.title];
}

@end

