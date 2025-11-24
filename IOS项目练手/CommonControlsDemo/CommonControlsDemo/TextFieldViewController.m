//
//  TextFieldViewController.m
//  CommonControlsDemo
//
//  UITextField 演示：各种输入框样式和功能
//

#import "TextFieldViewController.h"

@interface TextFieldViewController () <UITextFieldDelegate>
@property (strong, nonatomic) UITextField *normalTextField;
@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong, nonatomic) UITextField *emailTextField;
@property (strong, nonatomic) UITextField *phoneTextField;
@property (strong, nonatomic) UITextField *numberTextField;
@property (strong, nonatomic) UILabel *resultLabel;
@end

@implementation TextFieldViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"UITextField 演示";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupUI];

    // 点击空白处收起键盘
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)setupUI {
    CGFloat padding = 20;
    CGFloat yOffset = 100;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;

    // 说明文本
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 60)];
    descLabel.text = @"演示不同类型的文本输入框\n点击输入框开始输入，点击空白处收起键盘";
    descLabel.numberOfLines = 0;
    descLabel.font = [UIFont systemFontOfSize:14];
    descLabel.textColor = [UIColor secondaryLabelColor];
    descLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:descLabel];
    yOffset += 80;

    // 1. 普通文本框
    yOffset = [self addLabelWithTitle:@"普通文本:" yOffset:yOffset];
    self.normalTextField = [self createTextFieldWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 44)
                                              placeholder:@"请输入用户名"
                                             keyboardType:UIKeyboardTypeDefault];
    self.normalTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:self.normalTextField];
    yOffset += 60;

    // 2. 密码框
    yOffset = [self addLabelWithTitle:@"密码输入:" yOffset:yOffset];
    self.passwordTextField = [self createTextFieldWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 44)
                                                 placeholder:@"请输入密码"
                                                keyboardType:UIKeyboardTypeDefault];
    self.passwordTextField.secureTextEntry = YES; // 密码模式
    [self.view addSubview:self.passwordTextField];
    yOffset += 60;

    // 3. 邮箱框
    yOffset = [self addLabelWithTitle:@"邮箱输入:" yOffset:yOffset];
    self.emailTextField = [self createTextFieldWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 44)
                                              placeholder:@"example@email.com"
                                             keyboardType:UIKeyboardTypeEmailAddress];
    self.emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone; // 禁用首字母大写
    [self.view addSubview:self.emailTextField];
    yOffset += 60;

    // 4. 手机号框
    yOffset = [self addLabelWithTitle:@"手机号:" yOffset:yOffset];
    self.phoneTextField = [self createTextFieldWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 44)
                                              placeholder:@"请输入手机号"
                                             keyboardType:UIKeyboardTypePhonePad];
    [self.view addSubview:self.phoneTextField];
    yOffset += 60;

    // 5. 数字框
    yOffset = [self addLabelWithTitle:@"数字输入:" yOffset:yOffset];
    self.numberTextField = [self createTextFieldWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 44)
                                               placeholder:@"请输入数字"
                                              keyboardType:UIKeyboardTypeNumberPad];
    [self.view addSubview:self.numberTextField];
    yOffset += 60;

    // 结果显示
    self.resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 60)];
    self.resultLabel.text = @"输入内容将在这里显示";
    self.resultLabel.numberOfLines = 0;
    self.resultLabel.font = [UIFont systemFontOfSize:14];
    self.resultLabel.textColor = [UIColor systemGreenColor];
    self.resultLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.resultLabel];
    yOffset += 80;

    // 提交按钮
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    submitButton.frame = CGRectMake(padding, yOffset, screenWidth - 2 * padding, 44);
    [submitButton setTitle:@"提交" forState:UIControlStateNormal];
    submitButton.backgroundColor = [UIColor systemBlueColor];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    submitButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    submitButton.layer.cornerRadius = 8;
    [submitButton addTarget:self action:@selector(submitButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submitButton];
}

- (CGFloat)addLabelWithTitle:(NSString *)title yOffset:(CGFloat)yOffset {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, yOffset, 200, 20)];
    label.text = title;
    label.font = [UIFont boldSystemFontOfSize:14];
    label.textColor = [UIColor labelColor];
    [self.view addSubview:label];
    return yOffset + 25;
}

- (UITextField *)createTextFieldWithFrame:(CGRect)frame placeholder:(NSString *)placeholder keyboardType:(UIKeyboardType)keyboardType {
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    textField.placeholder = placeholder;
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.keyboardType = keyboardType;
    textField.returnKeyType = UIReturnKeyNext;
    textField.delegate = self;
    textField.font = [UIFont systemFontOfSize:15];

    // 添加左侧图标
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
    iconView.contentMode = UIViewContentModeCenter;
    iconView.image = [UIImage systemImageNamed:@"text.cursor"];
    iconView.tintColor = [UIColor systemGrayColor];
    textField.leftView = iconView;
    textField.leftViewMode = UITextFieldViewModeAlways;

    return textField;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // 按下 Return 键时切换到下一个输入框
    if (textField == self.normalTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        [self.emailTextField becomeFirstResponder];
    } else if (textField == self.emailTextField) {
        [self.phoneTextField becomeFirstResponder];
    } else if (textField == self.phoneTextField) {
        [self.numberTextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // 限制手机号只能输入11位数字
    if (textField == self.phoneTextField) {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if (newString.length > 11) {
            return NO;
        }
    }

    // 实时显示输入内容
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateResultLabel];
    });

    return YES;
}

#pragma mark - Actions

- (void)submitButtonTapped {
    [self dismissKeyboard];

    NSMutableString *result = [NSMutableString string];
    if (self.normalTextField.text.length > 0) {
        [result appendFormat:@"用户名: %@\n", self.normalTextField.text];
    }
    if (self.passwordTextField.text.length > 0) {
        [result appendFormat:@"密码: %@\n", [@"" stringByPaddingToLength:self.passwordTextField.text.length withString:@"*" startingAtIndex:0]];
    }
    if (self.emailTextField.text.length > 0) {
        [result appendFormat:@"邮箱: %@\n", self.emailTextField.text];
    }
    if (self.phoneTextField.text.length > 0) {
        [result appendFormat:@"手机号: %@\n", self.phoneTextField.text];
    }
    if (self.numberTextField.text.length > 0) {
        [result appendFormat:@"数字: %@", self.numberTextField.text];
    }

    if (result.length > 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提交成功"
                                                                       message:result
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)updateResultLabel {
    NSMutableString *result = [NSMutableString string];
    if (self.normalTextField.text.length > 0) [result appendFormat:@"用户名: %@ ", self.normalTextField.text];
    if (self.emailTextField.text.length > 0) [result appendFormat:@"邮箱: %@ ", self.emailTextField.text];
    if (self.phoneTextField.text.length > 0) [result appendFormat:@"手机: %@", self.phoneTextField.text];

    self.resultLabel.text = result.length > 0 ? result : @"输入内容将在这里显示";
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

@end

