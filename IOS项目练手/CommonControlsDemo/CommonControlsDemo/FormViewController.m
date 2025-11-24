//
//  FormViewController.m
//  CommonControlsDemo
//
//  综合表单演示：用户信息表单（综合运用各种控件）
//

#import "FormViewController.h"

@interface FormViewController () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UITextField *nameField;
@property (strong, nonatomic) UITextField *emailField;
@property (strong, nonatomic) UITextField *phoneField;

@property (strong, nonatomic) UISegmentedControl *genderControl;
@property (strong, nonatomic) UIDatePicker *birthdayPicker;
@property (strong, nonatomic) UIPickerView *cityPicker;
@property (strong, nonatomic) UISwitch *agreeSwitch;
@property (strong, nonatomic) UITextView *introTextView;
@property (strong, nonatomic) UILabel *introPlaceholder;

@property (strong, nonatomic) NSArray<NSString *> *cities;
@end

@implementation FormViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"用户信息表单";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    self.cities = @[@"北京", @"上海", @"广州", @"深圳", @"杭州", @"成都", @"西安"];

    [self setupUI];

    // 点击空白处收起键盘
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];

    // 监听键盘
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)setupUI {
    CGFloat padding = 20;
    CGFloat yOffset = 20;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;

    // ScrollView
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    self.scrollView.backgroundColor = [UIColor systemBackgroundColor];
    [self.view addSubview:self.scrollView];

    // 1. 姓名
    [self addLabel:@"姓名" yOffset:&yOffset];
    self.nameField = [self createTextField:@"请输入姓名" yOffset:&yOffset];

    // 2. 邮箱
    [self addLabel:@"邮箱" yOffset:&yOffset];
    self.emailField = [self createTextField:@"example@email.com" yOffset:&yOffset];
    self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;

    // 3. 手机号
    [self addLabel:@"手机号" yOffset:&yOffset];
    self.phoneField = [self createTextField:@"请输入手机号" yOffset:&yOffset];
    self.phoneField.keyboardType = UIKeyboardTypePhonePad;

    // 4. 性别
    [self addLabel:@"性别" yOffset:&yOffset];
    self.genderControl = [[UISegmentedControl alloc] initWithItems:@[@"男", @"女", @"保密"]];
    self.genderControl.frame = CGRectMake(padding, yOffset, screenWidth - 2 * padding, 32);
    self.genderControl.selectedSegmentIndex = 0;
    [self.scrollView addSubview:self.genderControl];
    yOffset += 52;

    // 5. 生日
    [self addLabel:@"生日" yOffset:&yOffset];
    self.birthdayPicker = [[UIDatePicker alloc] init];
    self.birthdayPicker.frame = CGRectMake(padding, yOffset, screenWidth - 2 * padding, 200);
    self.birthdayPicker.datePickerMode = UIDatePickerModeDate;
    self.birthdayPicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    self.birthdayPicker.maximumDate = [NSDate date];
    [self.scrollView addSubview:self.birthdayPicker];
    yOffset += 220;

    // 6. 城市
    [self addLabel:@"所在城市" yOffset:&yOffset];
    self.cityPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, yOffset, screenWidth, 150)];
    self.cityPicker.dataSource = self;
    self.cityPicker.delegate = self;
    [self.scrollView addSubview:self.cityPicker];
    yOffset += 170;

    // 7. 自我介绍
    [self addLabel:@"自我介绍" yOffset:&yOffset];
    UIView *introContainer = [[UIView alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 120)];
    introContainer.backgroundColor = [[UIColor systemGrayColor] colorWithAlphaComponent:0.1];
    introContainer.layer.cornerRadius = 8;
    [self.scrollView addSubview:introContainer];

    self.introTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, introContainer.frame.size.width - 20, 100)];
    self.introTextView.font = [UIFont systemFontOfSize:16];
    self.introTextView.backgroundColor = [UIColor clearColor];
    self.introTextView.delegate = (id)self;
    [introContainer addSubview:self.introTextView];

    self.introPlaceholder = [[UILabel alloc] initWithFrame:CGRectMake(15, 18, self.introTextView.frame.size.width - 10, 30)];
    self.introPlaceholder.text = @"请输入自我介绍...";
    self.introPlaceholder.font = [UIFont systemFontOfSize:16];
    self.introPlaceholder.textColor = [UIColor placeholderTextColor];
    [introContainer addSubview:self.introPlaceholder];
    yOffset += 140;

    // 8. 同意协议
    [self addLabel:@"服务协议" yOffset:&yOffset];
    UIView *agreeContainer = [[UIView alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 40)];
    [self.scrollView addSubview:agreeContainer];

    self.agreeSwitch = [[UISwitch alloc] init];
    self.agreeSwitch.frame = CGRectMake(0, 5, 51, 31);
    [agreeContainer addSubview:self.agreeSwitch];

    UILabel *agreeLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, agreeContainer.frame.size.width - 60, 40)];
    agreeLabel.text = @"我已阅读并同意《用户协议》";
    agreeLabel.font = [UIFont systemFontOfSize:14];
    [agreeContainer addSubview:agreeLabel];
    yOffset += 60;

    // 9. 提交按钮
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    submitButton.frame = CGRectMake(padding, yOffset, screenWidth - 2 * padding, 50);
    [submitButton setTitle:@"提交" forState:UIControlStateNormal];
    submitButton.backgroundColor = [UIColor systemBlueColor];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    submitButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    submitButton.layer.cornerRadius = 10;
    [submitButton addTarget:self action:@selector(submitForm) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:submitButton];
    yOffset += 70;

    // 设置 contentSize
    self.scrollView.contentSize = CGSizeMake(screenWidth, yOffset);
}

- (void)addLabel:(NSString *)title yOffset:(CGFloat *)yOffset {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, *yOffset, 200, 30)];
    label.text = title;
    label.font = [UIFont boldSystemFontOfSize:16];
    [self.scrollView addSubview:label];
    *yOffset += 35;
}

- (UITextField *)createTextField:(NSString *)placeholder yOffset:(CGFloat *)yOffset {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(20, *yOffset, screenWidth - 40, 44)];
    textField.placeholder = placeholder;
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.font = [UIFont systemFontOfSize:16];
    textField.delegate = self;
    textField.returnKeyType = UIReturnKeyNext;
    [self.scrollView addSubview:textField];
    *yOffset += 64;
    return textField;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.nameField) {
        [self.emailField becomeFirstResponder];
    } else if (textField == self.emailField) {
        [self.phoneField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // 限制手机号11位
    if (textField == self.phoneField) {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        return newString.length <= 11;
    }
    return YES;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    self.introPlaceholder.hidden = textView.text.length > 0;
}

#pragma mark - UIPickerViewDataSource & Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.cities.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.cities[row];
}

#pragma mark - Actions

- (void)submitForm {
    [self dismissKeyboard];

    // 验证必填项
    if (self.nameField.text.length == 0) {
        [self showAlert:@"请输入姓名"];
        return;
    }

    if (self.emailField.text.length == 0) {
        [self showAlert:@"请输入邮箱"];
        return;
    }

    if (self.phoneField.text.length == 0) {
        [self showAlert:@"请输入手机号"];
        return;
    }

    if (!self.agreeSwitch.isOn) {
        [self showAlert:@"请同意用户协议"];
        return;
    }

    // 收集表单数据
    NSString *name = self.nameField.text;
    NSString *email = self.emailField.text;
    NSString *phone = self.phoneField.text;
    NSString *gender = [self.genderControl titleForSegmentAtIndex:self.genderControl.selectedSegmentIndex];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *birthday = [formatter stringFromDate:self.birthdayPicker.date];

    NSInteger cityIndex = [self.cityPicker selectedRowInComponent:0];
    NSString *city = self.cities[cityIndex];

    NSString *intro = self.introTextView.text.length > 0 ? self.introTextView.text : @"无";

    NSString *message = [NSString stringWithFormat:@"姓名：%@\n邮箱：%@\n手机：%@\n性别：%@\n生日：%@\n城市：%@\n介绍：%@",
                        name, email, phone, gender, birthday, city, intro];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提交成功"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showAlert:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardFrame.size.height;

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

