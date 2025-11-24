//
//  TextViewViewController.m
//  CommonControlsDemo
//
//  UITextView 演示：多行文本编辑
//

#import "TextViewViewController.h"

@interface TextViewViewController () <UITextViewDelegate>
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UILabel *placeholderLabel;
@property (strong, nonatomic) UILabel *countLabel;
@end

@implementation TextViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"UITextView 演示";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupUI];

    // 点击空白处收起键盘
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];

    // 监听键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)setupUI {
    CGFloat padding = 20;
    CGFloat yOffset = 100;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;

    // 说明文本
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 40)];
    descLabel.text = @"演示多行文本编辑，支持 Placeholder 和字数统计";
    descLabel.numberOfLines = 0;
    descLabel.font = [UIFont systemFontOfSize:14];
    descLabel.textColor = [UIColor secondaryLabelColor];
    descLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:descLabel];
    yOffset += 60;

    // TextView 容器
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 300)];
    container.backgroundColor = [UIColor systemGroupedBackgroundColor];
    container.layer.cornerRadius = 10;
    container.layer.borderWidth = 1;
    container.layer.borderColor = [UIColor systemGrayColor].CGColor;
    [self.view addSubview:container];

    // TextView
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, container.frame.size.width - 20, container.frame.size.height - 20)];
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.delegate = self;
    self.textView.returnKeyType = UIReturnKeyDefault;
    [container addSubview:self.textView];

    // Placeholder（UITextView 没有内置 placeholder，需要自己实现）
    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 18, self.textView.frame.size.width - 10, 30)];
    self.placeholderLabel.text = @"请输入长文本内容...";
    self.placeholderLabel.font = [UIFont systemFontOfSize:16];
    self.placeholderLabel.textColor = [UIColor placeholderTextColor];
    [container addSubview:self.placeholderLabel];

    yOffset += 320;

    // 字数统计
    self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 30)];
    self.countLabel.text = @"字数: 0 / 200";
    self.countLabel.font = [UIFont systemFontOfSize:14];
    self.countLabel.textColor = [UIColor secondaryLabelColor];
    self.countLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:self.countLabel];
    yOffset += 40;

    // 按钮
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
    clearButton.frame = CGRectMake(padding, yOffset, (screenWidth - 3 * padding) / 2, 44);
    [clearButton setTitle:@"清空" forState:UIControlStateNormal];
    clearButton.backgroundColor = [UIColor systemRedColor];
    [clearButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    clearButton.layer.cornerRadius = 8;
    [clearButton addTarget:self action:@selector(clearButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clearButton];

    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    submitButton.frame = CGRectMake(CGRectGetMaxX(clearButton.frame) + padding, yOffset, (screenWidth - 3 * padding) / 2, 44);
    [submitButton setTitle:@"提交" forState:UIControlStateNormal];
    submitButton.backgroundColor = [UIColor systemBlueColor];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    submitButton.layer.cornerRadius = 8;
    [submitButton addTarget:self action:@selector(submitButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submitButton];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    // 隐藏/显示 placeholder
    self.placeholderLabel.hidden = textView.text.length > 0;

    // 限制字数
    if (textView.text.length > 200) {
        textView.text = [textView.text substringToIndex:200];
    }

    // 更新字数统计
    self.countLabel.text = [NSString stringWithFormat:@"字数: %lu / 200", (unsigned long)textView.text.length];

    // 字数超过 180 时变红提醒
    if (textView.text.length > 180) {
        self.countLabel.textColor = [UIColor systemRedColor];
    } else {
        self.countLabel.textColor = [UIColor secondaryLabelColor];
    }
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardFrame.size.height;
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    [UIView animateWithDuration:duration animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, -keyboardHeight / 2);
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    [UIView animateWithDuration:duration animations:^{
        self.view.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark - Actions

- (void)clearButtonTapped {
    self.textView.text = @"";
    [self textViewDidChange:self.textView];
}

- (void)submitButtonTapped {
    [self dismissKeyboard];

    if (self.textView.text.length == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                       message:@"请输入内容"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    NSString *message = [NSString stringWithFormat:@"您输入了 %lu 个字:\n\n%@",
                        (unsigned long)self.textView.text.length,
                        self.textView.text];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提交成功"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

