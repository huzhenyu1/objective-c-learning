//
//  NetworkManager.h
//  Read
//
//  网络请求管理器 - 负责 HTTP 请求和响应处理
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 请求完成回调
typedef void(^NetworkSuccessBlock)(NSData *data, NSString *html);
typedef void(^NetworkFailureBlock)(NSError *error);

@interface NetworkManager : NSObject

// 单例
+ (instancetype)sharedManager;

#pragma mark - HTTP 请求

/**
 * 发送 GET 请求
 * @param urlString 请求URL
 * @param encoding 字符编码（如 @"UTF-8" 或 @"GB2312"）
 * @param success 成功回调（返回 NSData 和 HTML 字符串）
 * @param failure 失败回调
 */
- (void)GET:(NSString *)urlString
   encoding:(nullable NSString *)encoding
    success:(NetworkSuccessBlock)success
    failure:(NetworkFailureBlock)failure;

/**
 * 发送 GET 请求（带自定义 Header）
 * @param urlString 请求URL
 * @param headers 自定义请求头
 * @param encoding 字符编码
 * @param success 成功回调
 * @param failure 失败回调
 */
- (void)GET:(NSString *)urlString
    headers:(nullable NSDictionary<NSString *, NSString *> *)headers
   encoding:(nullable NSString *)encoding
    success:(NetworkSuccessBlock)success
    failure:(NetworkFailureBlock)failure;

/**
 * 发送 POST 请求
 * @param urlString 请求URL
 * @param params POST 参数字典
 * @param encoding 字符编码
 * @param success 成功回调
 * @param failure 失败回调
 */
- (void)POST:(NSString *)urlString
      params:(nullable NSDictionary *)params
    encoding:(nullable NSString *)encoding
     success:(NetworkSuccessBlock)success
     failure:(NetworkFailureBlock)failure;

/**
 * 发送 POST 请求（带 body）
 * @param urlString 请求URL
 * @param body POST body 字符串
 * @param encoding 字符编码
 * @param success 成功回调
 * @param failure 失败回调
 */
- (void)POST:(NSString *)urlString
        body:(NSString *)body
    encoding:(nullable NSString *)encoding
     success:(NetworkSuccessBlock)success
     failure:(NetworkFailureBlock)failure;

/**
 * 下载图片
 * @param urlString 图片URL
 * @param success 成功回调（返回 NSData）
 * @param failure 失败回调
 */
- (void)downloadImage:(NSString *)urlString
              success:(void(^)(NSData *imageData))success
              failure:(NetworkFailureBlock)failure;

/**
 * 取消所有请求
 */
- (void)cancelAllRequests;

@end

NS_ASSUME_NONNULL_END

