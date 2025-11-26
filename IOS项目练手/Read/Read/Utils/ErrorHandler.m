//
//  ErrorHandler.m
//  Read
//
//  统一错误处理器实现
//

#import "ErrorHandler.h"
#import "UIViewController+Alert.h"

@implementation ErrorHandler

#pragma mark - 错误处理

+ (void)handleError:(NSError *)error inView:(UIViewController *)viewController {
    [self handleError:error inView:viewController retryBlock:nil];
}

+ (void)handleError:(NSError *)error
             inView:(UIViewController *)viewController
         retryBlock:(void(^)(void))retryBlock {

    if (!error || !viewController) {
        return;
    }

    // 记录错误日志
    [self logError:error context:@"User facing error"];

    // 获取友好的错误信息
    NSString *message = [self friendlyMessageFromError:error];

    if (retryBlock) {
        // 提供重试选项
        [viewController showConfirmAlertWithTitle:@"错误"
                                          message:message
                                     confirmTitle:@"重试"
                                      cancelTitle:@"取消"
                                   confirmHandler:retryBlock];
    } else {
        // 仅显示错误
        [viewController showAlertWithTitle:@"错误" message:message];
    }
}

+ (void)handleNetworkError:(NSError *)error
                    inView:(UIViewController *)viewController
            autoRetryTimes:(NSInteger)maxRetries
                retryBlock:(void(^)(void))retryBlock {

    if (!error || !viewController || !retryBlock) {
        return;
    }

    // 记录错误
    [self logError:error context:[NSString stringWithFormat:@"Network error, auto retry %ld times", (long)maxRetries]];

    if (maxRetries > 0 && [self shouldRetryForError:error]) {
        // 自动重试
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            retryBlock();
        });

        // 显示重试提示
        NSString *message = [NSString stringWithFormat:@"网络请求失败，正在重试...（%ld/%ld）",
                            (long)(maxRetries), (long)(maxRetries)];
        [viewController showAlertWithTitle:@"提示" message:message handler:nil];

    } else {
        // 重试次数用尽，提示用户
        NSString *message = [self friendlyMessageFromError:error];
        [viewController showConfirmAlertWithTitle:@"网络错误"
                                          message:[NSString stringWithFormat:@"%@\n\n是否手动重试？", message]
                                     confirmTitle:@"重试"
                                      cancelTitle:@"取消"
                                   confirmHandler:retryBlock];
    }
}

+ (void)handleError:(NSError *)error
             inView:(UIViewController *)viewController
    fallbackMessage:(NSString *)fallbackMessage
      fallbackBlock:(void(^)(void))fallbackBlock {

    if (!error || !viewController) {
        return;
    }

    // 记录错误
    [self logError:error context:@"Error with fallback"];

    // 获取错误信息
    NSString *errorMessage = [self friendlyMessageFromError:error];
    NSString *fullMessage = [NSString stringWithFormat:@"%@\n\n%@", errorMessage, fallbackMessage];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误"
                                                                   message:fullMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];

    // 取消按钮
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];

    // 降级方案按钮
    [alert addAction:[UIAlertAction actionWithTitle:@"继续"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        if (fallbackBlock) {
            fallbackBlock();
        }
    }]];

    [viewController presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 错误分析

+ (ErrorType)errorTypeFromError:(NSError *)error {
    if ([self isNetworkError:error]) {
        return ErrorTypeNetwork;
    }

    if ([error.domain isEqualToString:@"BookContentService"] ||
        [error.domain isEqualToString:@"RuleParser"]) {
        return ErrorTypeParsing;
    }

    if ([error.domain isEqualToString:NSCocoaErrorDomain] &&
        error.code >= 256 && error.code <= 260) {
        return ErrorTypeStorage;
    }

    return ErrorTypeUnknown;
}

+ (NSString *)friendlyMessageFromError:(NSError *)error {
    if (!error) {
        return @"未知错误";
    }

    ErrorType type = [self errorTypeFromError:error];

    switch (type) {
        case ErrorTypeNetwork:
            return [self friendlyNetworkErrorMessage:error];

        case ErrorTypeParsing:
            return @"内容解析失败，可能是书源规则不兼容，请尝试更换书源";

        case ErrorTypeStorage:
            return @"存储空间不足或文件访问失败，请检查设备存储空间";

        case ErrorTypeUnknown:
        default:
            // 返回系统错误信息（如果有）
            if (error.localizedDescription && error.localizedDescription.length > 0) {
                return error.localizedDescription;
            }
            return @"操作失败，请稍后重试";
    }
}

+ (NSString *)friendlyNetworkErrorMessage:(NSError *)error {
    if ([error.domain isEqualToString:NSURLErrorDomain]) {
        switch (error.code) {
            case NSURLErrorNotConnectedToInternet:
                return @"网络未连接，请检查网络设置";
            case NSURLErrorTimedOut:
                return @"网络请求超时，请检查网络连接";
            case NSURLErrorCannotFindHost:
            case NSURLErrorCannotConnectToHost:
                return @"无法连接到服务器，请稍后重试";
            case NSURLErrorNetworkConnectionLost:
                return @"网络连接已中断";
            case NSURLErrorDNSLookupFailed:
                return @"DNS 解析失败，请检查网络设置";
            default:
                return [NSString stringWithFormat:@"网络错误（%ld），请检查网络连接", (long)error.code];
        }
    }

    return @"网络请求失败，请检查网络连接";
}

+ (BOOL)isNetworkError:(NSError *)error {
    if (!error) {
        return NO;
    }

    return [error.domain isEqualToString:NSURLErrorDomain];
}

+ (BOOL)shouldRetryForError:(NSError *)error {
    if (![self isNetworkError:error]) {
        return NO;
    }

    // 可重试的网络错误码
    NSArray *retryableCodes = @[
        @(NSURLErrorTimedOut),
        @(NSURLErrorNetworkConnectionLost),
        @(NSURLErrorDNSLookupFailed),
        @(NSURLErrorCannotConnectToHost)
    ];

    return [retryableCodes containsObject:@(error.code)];
}

#pragma mark - 错误日志

+ (void)logError:(NSError *)error context:(NSString *)context {
    if (!error) {
        return;
    }

    NSString *logMessage = [NSString stringWithFormat:@"⚠️ [ErrorHandler] %@\n"
                           @"   Domain: %@\n"
                           @"   Code: %ld\n"
                           @"   Description: %@\n"
                           @"   UserInfo: %@",
                           context ?: @"Unknown context",
                           error.domain,
                           (long)error.code,
                           error.localizedDescription,
                           error.userInfo];

    NSLog(@"%@", logMessage);
}

@end

