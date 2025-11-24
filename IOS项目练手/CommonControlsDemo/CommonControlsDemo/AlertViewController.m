//
//  AlertViewController.m
//  CommonControlsDemo
//
//  UIAlertController 演示：Alert 和 ActionSheet
//

#import "AlertViewController.h"

@interface AlertViewController ()
@property (strong, nonatomic) UILabel *resultLabel;
@end

@implementation AlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"UIAlertController 演示";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupUI];
}

- (void)setupUI {
    CGFloat padding = 20;
    CGFloat yOffset = 100;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;

    // 说明文本
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 40)];
    descLabel.text = @"演示各种提示框和操作表";
    descLabel.numberOfLines = 0;
    descLabel.font = [UIFont systemFontOfSize:14];
    descLabel.textColor = [UIColor secondaryLabelColor];
    descLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:descLabel];
    yOffset += 60;

    // 按钮数组
    NSArray *buttons = @[
        @{@"title": @"简单提示框", @"action": @"showSimpleAlert"},
        @{@"title": @"确认/取消提示框", @"action": @"showConfirmAlert"},
        @{@"title": @"多按钮提示框", @"action": @"showMultipleButtonAlert"},
        @{@"title": @"文本输入提示框", @"action": @"showTextInputAlert"},
        @{@"title": @"ActionSheet (底部弹出)", @"action": @"showActionSheet"},
        @{@"title": @"破坏性操作", @"action": @"showDestructiveAlert"}
    ];

    for (NSDictionary *btnInfo in buttons) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(padding, yOffset, screenWidth - 2 * padding, 44);
        [button setTitle:btnInfo[@"title"] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor systemBlueColor];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        button.layer.cornerRadius = 8;

        SEL action = NSSelectorFromString(btnInfo[@"action"]);
        [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];

        yOffset += 54;
    }

    // 结果显示
    self.resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset + 20, screenWidth - 2 * padding, 60)];
    self.resultLabel.text = @"点击按钮查看效果\n选择结果将显示在这里";
    self.resultLabel.numberOfLines = 0;
    self.resultLabel.font = [UIFont boldSystemFontOfSize:16];
    self.resultLabel.textColor = [UIColor systemGreenColor];
    self.resultLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.resultLabel];
}

#pragma mark - Alert Examples

// 1. 简单提示框
- (void)showSimpleAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:@"这是一个简单的提示框"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        self.resultLabel.text = @"点击了「确定」";
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

// 2. 确认/取消提示框
- (void)showConfirmAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认删除"
                                                                   message:@"确定要删除这个项目吗？"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    // 取消按钮
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
        self.resultLabel.text = @"点击了「取消」";
    }]];

    // 确认按钮
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        self.resultLabel.text = @"点击了「确定」\n已删除";
        self.resultLabel.textColor = [UIColor systemRedColor];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.resultLabel.textColor = [UIColor systemGreenColor];
        });
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

// 3. 多按钮提示框
- (void)showMultipleButtonAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择操作"
                                                                   message:@"请选择你要执行的操作"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"保存"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        self.resultLabel.text = @"点击了「保存」";
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"分享"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        self.resultLabel.text = @"点击了「分享」";
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"导出"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        self.resultLabel.text = @"点击了「导出」";
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];

    [self presentViewController:alert animated:YES completion:nil];
}

// 4. 文本输入提示框
- (void)showTextInputAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请输入"
                                                                   message:@"请输入你的名字"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    // 添加文本框
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入名字";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];

    // 添加第二个文本框（密码）
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入密码";
        textField.secureTextEntry = YES;
    }];

    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];

    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        UITextField *nameField = alert.textFields[0];
        UITextField *passwordField = alert.textFields[1];

        NSString *name = nameField.text.length > 0 ? nameField.text : @"未输入";
        NSString *password = passwordField.text.length > 0 ? [@"" stringByPaddingToLength:passwordField.text.length withString:@"*" startingAtIndex:0] : @"未输入";

        self.resultLabel.text = [NSString stringWithFormat:@"名字: %@\n密码: %@", name, password];
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

// 5. ActionSheet（底部弹出）
- (void)showActionSheet {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"选择操作"
                                                                         message:@"请选择你要执行的操作"
                                                                  preferredStyle:UIAlertControllerStyleActionSheet];

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"拍照"
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * _Nonnull action) {
        self.resultLabel.text = @"选择了「拍照」";
    }]];

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"从相册选择"
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * _Nonnull action) {
        self.resultLabel.text = @"选择了「从相册选择」";
    }]];

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"取消"
                                                    style:UIAlertActionStyleCancel
                                                  handler:nil]];

    // iPad 需要设置 popover
    if (actionSheet.popoverPresentationController) {
        actionSheet.popoverPresentationController.sourceView = self.view;
        actionSheet.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2, 0, 0);
    }

    [self presentViewController:actionSheet animated:YES completion:nil];
}

// 6. 破坏性操作
- (void)showDestructiveAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"危险操作"
                                                                   message:@"此操作不可撤销，确定要继续吗？"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    // 破坏性按钮（红色）
    [alert addAction:[UIAlertAction actionWithTitle:@"删除所有数据"
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction * _Nonnull action) {
        self.resultLabel.text = @"点击了「删除所有数据」❌";
        self.resultLabel.textColor = [UIColor systemRedColor];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.resultLabel.textColor = [UIColor systemGreenColor];
        });
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];

    // iPad 需要设置 popover
    if (alert.popoverPresentationController) {
        alert.popoverPresentationController.sourceView = self.view;
        alert.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2, 0, 0);
    }

    [self presentViewController:alert animated:YES completion:nil];
}

@end

