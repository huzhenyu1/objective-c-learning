//
//  NetworkManager.m
//  Read
//
//  网络请求管理器实现
//

#import "NetworkManager.h"

@interface NetworkManager ()
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSMutableArray<NSURLSessionTask *> *tasks;
@end

@implementation NetworkManager

+ (instancetype)sharedManager {
    static NetworkManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[NetworkManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 配置 URLSession
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 10.0;  // 10秒超时（优化）
        config.HTTPMaximumConnectionsPerHost = 5;

        _session = [NSURLSession sessionWithConfiguration:config];
        _tasks = [NSMutableArray array];
    }
    return self;
}

#pragma mark - GET 请求

- (void)GET:(NSString *)urlString
   encoding:(nullable NSString *)encoding
    success:(NetworkSuccessBlock)success
    failure:(NetworkFailureBlock)failure {
    [self GET:urlString headers:nil encoding:encoding success:success failure:failure];
}

- (void)GET:(NSString *)urlString
    headers:(nullable NSDictionary<NSString *, NSString *> *)headers
   encoding:(nullable NSString *)encoding
    success:(NetworkSuccessBlock)success
    failure:(NetworkFailureBlock)failure {

    if (!urlString || urlString.length == 0) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:@"NetworkManager"
                                               code:-1001
                                           userInfo:@{NSLocalizedDescriptionKey: @"URL 为空"}];
            failure(error);
        }
        return;
    }

    // 尝试直接创建 URL（假设已经编码过）
    NSURL *url = [NSURL URLWithString:urlString];

    if (!url) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:@"NetworkManager"
                                               code:-1002
                                           userInfo:@{NSLocalizedDescriptionKey: @"URL 格式错误"}];
            failure(error);
        }
        return;
    }

    // NSLog(@"🌐 GET: %@", urlString);
    if (headers && headers.count > 0) {
        // NSLog(@"📋 Headers: %@", headers);
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    [request setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X)" forHTTPHeaderField:@"User-Agent"];

    // 添加自定义 headers
    if (headers) {
        for (NSString *key in headers) {
            [request setValue:headers[key] forHTTPHeaderField:key];
        }
    }

    [self sendRequest:request encoding:encoding success:success failure:failure];
}

#pragma mark - POST 请求

- (void)POST:(NSString *)urlString
      params:(nullable NSDictionary *)params
    encoding:(nullable NSString *)encoding
     success:(NetworkSuccessBlock)success
     failure:(NetworkFailureBlock)failure {

    if (!urlString || urlString.length == 0) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:@"NetworkManager"
                                               code:-1001
                                           userInfo:@{NSLocalizedDescriptionKey: @"URL 为空"}];
            failure(error);
        }
        return;
    }

    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:@"NetworkManager"
                                               code:-1002
                                           userInfo:@{NSLocalizedDescriptionKey: @"URL 格式错误"}];
            failure(error);
        }
        return;
    }

    // NSLog(@"🌐 POST: %@ params: %@", urlString, params);

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X)" forHTTPHeaderField:@"User-Agent"];

    // 构建 POST body
    if (params && params.count > 0) {
        NSMutableArray *pairs = [NSMutableArray array];
        for (NSString *key in params) {
            NSString *value = [params[key] description];
            NSString *encodedKey = [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            NSString *encodedValue = [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue]];
        }
        NSString *bodyString = [pairs componentsJoinedByString:@"&"];
        request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    }

    [self sendRequest:request encoding:encoding success:success failure:failure];
}

- (void)POST:(NSString *)urlString
        body:(NSString *)body
    encoding:(nullable NSString *)encoding
     success:(NetworkSuccessBlock)success
     failure:(NetworkFailureBlock)failure {

    if (!urlString || urlString.length == 0) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:@"NetworkManager"
                                               code:-1001
                                           userInfo:@{NSLocalizedDescriptionKey: @"URL 为空"}];
            failure(error);
        }
        return;
    }

    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:@"NetworkManager"
                                               code:-1002
                                           userInfo:@{NSLocalizedDescriptionKey: @"URL 格式错误"}];
            failure(error);
        }
        return;
    }

    // NSLog(@"🌐 POST: %@ body: %@", urlString, body);

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X)" forHTTPHeaderField:@"User-Agent"];

    if (body && body.length > 0) {
        request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    }

    [self sendRequest:request encoding:encoding success:success failure:failure];
}

#pragma mark - 通用请求发送

- (void)sendRequest:(NSURLRequest *)request
           encoding:(nullable NSString *)encoding
            success:(NetworkSuccessBlock)success
            failure:(NetworkFailureBlock)failure {

    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // 从任务列表中移除
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tasks removeObject:task];
        });

        if (error) {
            // NSLog(@"❌ 请求失败: %@", error.localizedDescription);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure) {
                    failure(error);
                }
            });
            return;
        }

        if (!data) {
            // NSLog(@"❌ 响应数据为空");
            NSError *emptyError = [NSError errorWithDomain:@"NetworkManager"
                                                     code:-1003
                                                 userInfo:@{NSLocalizedDescriptionKey: @"响应数据为空"}];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure) {
                    failure(emptyError);
                }
            });
            return;
        }

        // 解析 HTML（使用指定的编码）
        NSString *html = [self parseHTMLFromData:data encoding:encoding];

        if (!html) {
            // NSLog(@"⚠️ HTML 解析失败，使用原始数据");
            html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ?: @"";
        }

        // NSLog(@"✅ 请求成功，数据大小: %lu bytes", (unsigned long)data.length);

        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                success(data, html);
            }
        });
    }];

    [self.tasks addObject:task];
    [task resume];
}

#pragma mark - HTML 解析

- (NSString *)parseHTMLFromData:(NSData *)data encoding:(nullable NSString *)encodingName {
    // 尝试使用指定的编码
    if (encodingName && encodingName.length > 0) {
        NSStringEncoding encoding = [self encodingFromName:encodingName];
        NSString *html = [[NSString alloc] initWithData:data encoding:encoding];
        if (html) {
            return html;
        }
    }

    // 尝试常见编码
    NSArray<NSNumber *> *encodings = @[
        @(NSUTF8StringEncoding),
        @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)), // GB2312/GBK
        @(NSISOLatin1StringEncoding),
        @(NSASCIIStringEncoding)
    ];

    for (NSNumber *encodingNumber in encodings) {
        NSStringEncoding encoding = [encodingNumber unsignedIntegerValue];
        NSString *html = [[NSString alloc] initWithData:data encoding:encoding];
        if (html) {
            return html;
        }
    }

    return nil;
}

- (NSStringEncoding)encodingFromName:(NSString *)name {
    NSString *lowercaseName = [name lowercaseString];

    if ([lowercaseName isEqualToString:@"utf-8"] || [lowercaseName isEqualToString:@"utf8"]) {
        return NSUTF8StringEncoding;
    } else if ([lowercaseName isEqualToString:@"gb2312"] ||
               [lowercaseName isEqualToString:@"gbk"] ||
               [lowercaseName isEqualToString:@"gb18030"]) {
        return CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    } else if ([lowercaseName isEqualToString:@"iso-8859-1"] ||
               [lowercaseName isEqualToString:@"latin1"]) {
        return NSISOLatin1StringEncoding;
    }

    return NSUTF8StringEncoding; // 默认 UTF-8
}

#pragma mark - 图片下载

- (void)downloadImage:(NSString *)urlString
              success:(void(^)(NSData *imageData))success
              failure:(NetworkFailureBlock)failure {

    if (!urlString || urlString.length == 0) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:@"NetworkManager"
                                               code:-1001
                                           userInfo:@{NSLocalizedDescriptionKey: @"图片URL为空"}];
            failure(error);
        }
        return;
    }

    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:@"NetworkManager"
                                               code:-1002
                                           userInfo:@{NSLocalizedDescriptionKey: @"图片URL格式错误"}];
            failure(error);
        }
        return;
    }


    NSURLSessionDataTask *task = [self.session dataTaskWithURL:url
                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tasks removeObject:task];
        });

        if (error) {
            // NSLog(@"❌ 图片下载失败: %@", error.localizedDescription);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure) {
                    failure(error);
                }
            });
            return;
        }

        if (!data || data.length == 0) {
            // NSLog(@"❌ 图片数据为空");
            NSError *emptyError = [NSError errorWithDomain:@"NetworkManager"
                                                     code:-1003
                                                 userInfo:@{NSLocalizedDescriptionKey: @"图片数据为空"}];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure) {
                    failure(emptyError);
                }
            });
            return;
        }

        // NSLog(@"✅ 图片下载成功，大小: %lu bytes", (unsigned long)data.length);

        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                success(data);
            }
        });
    }];

    [self.tasks addObject:task];
    [task resume];
}

#pragma mark - 任务管理

- (void)cancelAllRequests {
    // NSLog(@"🚫 取消所有请求 (%lu 个)", (unsigned long)self.tasks.count);

    for (NSURLSessionTask *task in self.tasks) {
        [task cancel];
    }

    [self.tasks removeAllObjects];
}

@end

