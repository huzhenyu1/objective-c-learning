//
//  POSTRequestViewController.m
//  NetworkingDemo
//
//  POST 请求示例 - 演示如何发送 POST 请求
//

#import "POSTRequestViewController.h"

@interface POSTRequestViewController ()
@property (strong, nonatomic) UITextField *titleField;
@property (strong, nonatomic) UITextView *bodyTextView;
@property (strong, nonatomic) UITextView *resultTextView;
@property (strong, nonatomic) UIActivityIndicatorView *loadingIndicator;
@end

@implementation POSTRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"POST 请求";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupUI];
}

- (void)setupUI {
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat yOffset = 100;

    // 标题输入框
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, yOffset, screenWidth - 40, 30)];
    titleLabel.text = @"标题：";
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.view addSubview:titleLabel];
    yOffset += 35;

    self.titleField = [[UITextField alloc] initWithFrame:CGRectMake(20, yOffset, screenWidth - 40, 40)];
    self.titleField.placeholder = @"请输入标题";
    self.titleField.borderStyle = UITextBorderStyleRoundedRect;
    self.titleField.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:self.titleField];
    yOffset += 50;

    // 内容输入框
    UILabel *bodyLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, yOffset, screenWidth - 40, 30)];
    bodyLabel.text = @"内容：";
    bodyLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.view addSubview:bodyLabel];
    yOffset += 35;

    self.bodyTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, yOffset, screenWidth - 40, 100)];
    self.bodyTextView.font = [UIFont systemFontOfSize:16];
    self.bodyTextView.backgroundColor = [UIColor secondarySystemBackgroundColor];
    self.bodyTextView.layer.cornerRadius = 10;
    self.bodyTextView.layer.borderWidth = 1;
    self.bodyTextView.layer.borderColor = [UIColor systemGray4Color].CGColor;
    [self.view addSubview:self.bodyTextView];
    yOffset += 110;

    // 发送按钮
    UIButton *postButton = [UIButton buttonWithType:UIButtonTypeSystem];
    postButton.frame = CGRectMake(20, yOffset, screenWidth - 40, 50);
    [postButton setTitle:@"发送 POST 请求" forState:UIControlStateNormal];
    postButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [postButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    postButton.backgroundColor = [UIColor systemGreenColor];
    postButton.layer.cornerRadius = 10;
    [postButton addTarget:self action:@selector(sendPOSTRequest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:postButton];
    yOffset += 60;

    // 加载指示器
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.loadingIndicator.center = CGPointMake(screenWidth / 2, yOffset + 20);
    self.loadingIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.loadingIndicator];
    yOffset += 50;

    // 结果显示区域
    self.resultTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, yOffset, screenWidth - 40, 200)];
    self.resultTextView.font = [UIFont systemFontOfSize:14];
    self.resultTextView.backgroundColor = [UIColor secondarySystemBackgroundColor];
    self.resultTextView.layer.cornerRadius = 10;
    self.resultTextView.editable = NO;
    self.resultTextView.text = @"填写内容后点击按钮发送请求...";
    [self.view addSubview:self.resultTextView];

    // 点击空白处收起键盘
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)sendPOSTRequest {
    // 收起键盘
    [self dismissKeyboard];

    // 获取输入的数据
    NSString *title = self.titleField.text.length > 0 ? self.titleField.text : @"测试标题";
    NSString *body = self.bodyTextView.text.length > 0 ? self.bodyTextView.text : @"测试内容";

    // 显示加载状态
    [self.loadingIndicator startAnimating];
    self.resultTextView.text = @"正在发送...";

    // 创建 URL
    NSString *urlString = @"https://jsonplaceholder.typicode.com/posts";
    NSURL *url = [NSURL URLWithString:urlString];

    // 创建 URLRequest
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 10.0;

    // 设置请求头
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    // 创建请求体（JSON 格式）
    NSDictionary *parameters = @{
        @"title": title,
        @"body": body,
        @"userId": @1
    };

    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&jsonError];

    if (jsonError) {
        self.resultTextView.text = [NSString stringWithFormat:@"❌ JSON 转换失败：%@", jsonError.localizedDescription];
        [self.loadingIndicator stopAnimating];
        return;
    }

    request.HTTPBody = jsonData;

    // 创建 URLSession
    NSURLSession *session = [NSURLSession sharedSession];

    // 创建 dataTask
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingIndicator stopAnimating];

            if (error) {
                self.resultTextView.text = [NSString stringWithFormat:@"❌ 请求失败\n\n%@", error.localizedDescription];
                return;
            }

            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

            if (httpResponse.statusCode == 201 || httpResponse.statusCode == 200) {
                // POST 成功通常返回 201 Created
                if (data) {
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    NSData *prettyData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:nil];
                    NSString *prettyString = [[NSString alloc] initWithData:prettyData encoding:NSUTF8StringEncoding];

                    self.resultTextView.text = [NSString stringWithFormat:@"✅ POST 成功\n\n状态码：%ld\n\n服务器返回：\n%@", (long)httpResponse.statusCode, prettyString];
                }
            } else {
                self.resultTextView.text = [NSString stringWithFormat:@"❌ HTTP 错误\n\n状态码：%ld", (long)httpResponse.statusCode];
            }
        });
    }];

    [dataTask resume];

    NSLog(@"POST 请求已发送：%@\n参数：%@", urlString, parameters);
}

@end

