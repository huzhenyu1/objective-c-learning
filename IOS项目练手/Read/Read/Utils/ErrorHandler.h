//
//  ErrorHandler.h
//  Read
//
//  统一错误处理器 - 提供友好的错误提示和重试机制
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 错误类型
 */
typedef NS_ENUM(NSInteger, ErrorType) {
    ErrorTypeNetwork,      // 网络错误
    ErrorTypeParsing,      // 解析错误
    ErrorTypeStorage,      // 存储错误
    ErrorTypeUnknown       // 未知错误
};

/**
 * 统一错误处理器
 *
 * 职责：
 *   1. 将系统错误转换为用户友好的提示
 *   2. 提供自动重试机制
 *   3. 记录错误日志
 *   4. 提供降级方案
 *
 * 使用示例：
 *   [ErrorHandler handleError:error
 *                      inView:self
 *                  retryBlock:^{
 *       [self loadData];
 *   }];
 */
@interface ErrorHandler : NSObject

#pragma mark - 错误处理

/**
 * 处理错误并显示提示
 * @param error 错误对象
 * @param viewController 显示提示的视图控制器
 */
+ (void)handleError:(NSError *)error inView:(UIViewController *)viewController;

/**
 * 处理错误并提供重试选项
 * @param error 错误对象
 * @param viewController 显示提示的视图控制器
 * @param retryBlock 重试回调
 */
+ (void)handleError:(NSError *)error
             inView:(UIViewController *)viewController
         retryBlock:(void(^)(void))retryBlock;

/**
 * 处理网络错误（自动重试N次）
 * @param error 错误对象
 * @param viewController 显示提示的视图控制器
 * @param maxRetries 最大重试次数
 * @param retryBlock 重试回调
 */
+ (void)handleNetworkError:(NSError *)error
                    inView:(UIViewController *)viewController
            autoRetryTimes:(NSInteger)maxRetries
                retryBlock:(void(^)(void))retryBlock;

/**
 * 处理错误并提供降级方案
 * @param error 错误对象
 * @param viewController 显示提示的视图控制器
 * @param fallbackMessage 降级提示信息
 * @param fallbackBlock 降级回调
 */
+ (void)handleError:(NSError *)error
             inView:(UIViewController *)viewController
    fallbackMessage:(NSString *)fallbackMessage
      fallbackBlock:(void(^)(void))fallbackBlock;

#pragma mark - 错误分析

/**
 * 判断错误类型
 * @param error 错误对象
 * @return 错误类型
 */
+ (ErrorType)errorTypeFromError:(NSError *)error;

/**
 * 获取用户友好的错误信息
 * @param error 错误对象
 * @return 友好的错误提示
 */
+ (NSString *)friendlyMessageFromError:(NSError *)error;

/**
 * 判断是否为网络错误
 * @param error 错误对象
 * @return 是否为网络错误
 */
+ (BOOL)isNetworkError:(NSError *)error;

/**
 * 判断是否需要重试
 * @param error 错误对象
 * @return 是否应该重试
 */
+ (BOOL)shouldRetryForError:(NSError *)error;

#pragma mark - 错误日志

/**
 * 记录错误日志
 * @param error 错误对象
 * @param context 错误上下文
 */
+ (void)logError:(NSError *)error context:(nullable NSString *)context;

@end

NS_ASSUME_NONNULL_END

