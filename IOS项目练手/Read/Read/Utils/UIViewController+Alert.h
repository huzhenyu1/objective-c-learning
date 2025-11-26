//
//  UIViewController+Alert.h
//  Read
//
//  统一的 Alert 工具分类 - 简化 UIAlertController 的创建
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Alert)

#pragma mark - 简单提示

/**
 * 显示简单的提示框（只有"确定"按钮）
 * @param title 标题
 * @param message 提示信息
 */
- (void)showAlertWithTitle:(nullable NSString *)title message:(NSString *)message;

/**
 * 显示简单的提示框（只有"确定"按钮，带回调）
 * @param title 标题
 * @param message 提示信息
 * @param handler 点击"确定"后的回调
 */
- (void)showAlertWithTitle:(nullable NSString *)title
                   message:(NSString *)message
                   handler:(nullable void(^)(void))handler;

#pragma mark - 确认对话框

/**
 * 显示确认对话框（"确定" + "取消"）
 * @param title 标题
 * @param message 提示信息
 * @param confirmTitle 确认按钮标题（默认"确定"）
 * @param cancelTitle 取消按钮标题（默认"取消"）
 * @param confirmHandler 点击确认按钮的回调
 */
- (void)showConfirmAlertWithTitle:(nullable NSString *)title
                          message:(NSString *)message
                     confirmTitle:(nullable NSString *)confirmTitle
                      cancelTitle:(nullable NSString *)cancelTitle
                   confirmHandler:(void(^)(void))confirmHandler;

/**
 * 显示危险操作确认框（红色按钮）
 * @param title 标题
 * @param message 提示信息
 * @param destructiveTitle 危险按钮标题（如"删除"）
 * @param handler 点击危险按钮的回调
 */
- (void)showDestructiveAlertWithTitle:(nullable NSString *)title
                              message:(NSString *)message
                     destructiveTitle:(NSString *)destructiveTitle
                              handler:(void(^)(void))handler;

#pragma mark - ActionSheet（底部弹出）

/**
 * 显示 ActionSheet（从底部弹出的选项列表）
 * @param title 标题
 * @param message 提示信息
 * @param actions 操作按钮数组
 */
- (void)showActionSheetWithTitle:(nullable NSString *)title
                         message:(nullable NSString *)message
                         actions:(NSArray<UIAlertAction *> *)actions;

#pragma mark - 输入框

/**
 * 显示输入框对话框
 * @param title 标题
 * @param message 提示信息
 * @param placeholder 输入框占位符
 * @param confirmHandler 确认回调（参数为输入的文本）
 */
- (void)showInputAlertWithTitle:(nullable NSString *)title
                        message:(nullable NSString *)message
                    placeholder:(nullable NSString *)placeholder
                 confirmHandler:(void(^)(NSString *inputText))confirmHandler;

#pragma mark - 加载提示

/**
 * 显示加载中提示（带ActivityIndicator）
 * @param message 加载提示信息
 * @return 返回 UIAlertController 实例，用于后续关闭
 */
- (UIAlertController *)showLoadingAlertWithMessage:(NSString *)message;

@end

NS_ASSUME_NONNULL_END

