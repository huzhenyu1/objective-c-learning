//
//  UIViewController+Alert.m
//  Read
//
//  统一的 Alert 工具分类实现
//

#import "UIViewController+Alert.h"

@implementation UIViewController (Alert)

#pragma mark - 简单提示

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    [self showAlertWithTitle:title message:message handler:nil];
}

- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
                   handler:(void(^)(void))handler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title ?: @"提示"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        if (handler) {
            handler();
        }
    }];
    [alert addAction:okAction];

    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 确认对话框

- (void)showConfirmAlertWithTitle:(NSString *)title
                          message:(NSString *)message
                     confirmTitle:(NSString *)confirmTitle
                      cancelTitle:(NSString *)cancelTitle
                   confirmHandler:(void(^)(void))confirmHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title ?: @"提示"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    // 取消按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle ?: @"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alert addAction:cancelAction];

    // 确认按钮
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:confirmTitle ?: @"确定"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
        if (confirmHandler) {
            confirmHandler();
        }
    }];
    [alert addAction:confirmAction];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showDestructiveAlertWithTitle:(NSString *)title
                              message:(NSString *)message
                     destructiveTitle:(NSString *)destructiveTitle
                              handler:(void(^)(void))handler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title ?: @"警告"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    // 取消按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alert addAction:cancelAction];

    // 危险操作按钮（红色）
    UIAlertAction *destructiveAction = [UIAlertAction actionWithTitle:destructiveTitle
                                                                style:UIAlertActionStyleDestructive
                                                              handler:^(UIAlertAction * _Nonnull action) {
        if (handler) {
            handler();
        }
    }];
    [alert addAction:destructiveAction];

    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - ActionSheet

- (void)showActionSheetWithTitle:(NSString *)title
                         message:(NSString *)message
                         actions:(NSArray<UIAlertAction *> *)actions {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:title
                                                                         message:message
                                                                  preferredStyle:UIAlertControllerStyleActionSheet];

    // 添加所有操作按钮
    for (UIAlertAction *action in actions) {
        [actionSheet addAction:action];
    }

    // 添加取消按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [actionSheet addAction:cancelAction];

    // iPad 需要设置 popoverPresentationController
    if (actionSheet.popoverPresentationController) {
        actionSheet.popoverPresentationController.sourceView = self.view;
        actionSheet.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2,
                                                                          self.view.bounds.size.height / 2,
                                                                          1, 1);
        actionSheet.popoverPresentationController.permittedArrowDirections = 0;
    }

    [self presentViewController:actionSheet animated:YES completion:nil];
}

#pragma mark - 输入框

- (void)showInputAlertWithTitle:(NSString *)title
                        message:(NSString *)message
                    placeholder:(NSString *)placeholder
                 confirmHandler:(void(^)(NSString *inputText))confirmHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title ?: @"输入"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    // 添加输入框
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = placeholder;
    }];

    // 取消按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alert addAction:cancelAction];

    // 确认按钮
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = alert.textFields.firstObject;
        if (confirmHandler) {
            confirmHandler(textField.text ?: @"");
        }
    }];
    [alert addAction:confirmAction];

    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 加载提示

- (UIAlertController *)showLoadingAlertWithMessage:(NSString *)message {
    UIAlertController *loadingAlert = [UIAlertController alertControllerWithTitle:@"加载中"
                                                                          message:message
                                                                   preferredStyle:UIAlertControllerStyleAlert];

    // 添加 ActivityIndicator
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    indicator.translatesAutoresizingMaskIntoConstraints = NO;
    [loadingAlert.view addSubview:indicator];

    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        [indicator.centerXAnchor constraintEqualToAnchor:loadingAlert.view.centerXAnchor],
        [indicator.bottomAnchor constraintEqualToAnchor:loadingAlert.view.bottomAnchor constant:-20]
    ]];

    [indicator startAnimating];

    [self presentViewController:loadingAlert animated:YES completion:nil];

    return loadingAlert;
}

@end

