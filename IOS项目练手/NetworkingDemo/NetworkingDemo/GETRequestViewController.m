//
//  GETRequestViewController.m
//  NetworkingDemo
//
//  GET 请求示例 - 演示基本的 GET 请求
//

#import "GETRequestViewController.h"

@interface GETRequestViewController ()
@property (strong, nonatomic) UITextView *resultTextView;
@property (strong, nonatomic) UIActivityIndicatorView *loadingIndicator;
@end

@implementation GETRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"GET 请求";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupUI];
}

- (void)setupUI {
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat screenHeight = self.view.bounds.size.height;

    // 请求按钮
    UIButton *requestButton = [UIButton buttonWithType:UIButtonTypeSystem];
    requestButton.frame = CGRectMake(20, 100, screenWidth - 40, 50);
    [requestButton setTitle:@"发送 GET 请求" forState:UIControlStateNormal];
    requestButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [requestButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    requestButton.backgroundColor = [UIColor systemBlueColor];
    requestButton.layer.cornerRadius = 10;
    [requestButton addTarget:self action:@selector(sendGETRequest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:requestButton];

    // 加载指示器
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.loadingIndicator.center = CGPointMake(screenWidth / 2, 200);
    self.loadingIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.loadingIndicator];

    // 结果显示区域
    self.resultTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, 250, screenWidth - 40, screenHeight - 300)];
    self.resultTextView.font = [UIFont systemFontOfSize:14];
    self.resultTextView.backgroundColor = [UIColor secondarySystemBackgroundColor];
    self.resultTextView.layer.cornerRadius = 10;
    self.resultTextView.editable = NO;
    self.resultTextView.text = @"点击上方按钮发送请求...";
    [self.view addSubview:self.resultTextView];
}

- (void)sendGETRequest {
    // 显示加载状态
    [self.loadingIndicator startAnimating];
    self.resultTextView.text = @"正在请求...";

    // 创建 URL
    NSString *urlString = @"https://jsonplaceholder.typicode.com/posts/1";
    NSURL *url = [NSURL URLWithString:urlString];

    // 创建 URLRequest
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    request.timeoutInterval = 10.0;  // 超时时间 10 秒

    // 设置请求头（可选）
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    // 创建 URLSession
    NSURLSession *session = [NSURLSession sharedSession];

    // 创建 dataTask
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // 回到主线程更新 UI
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingIndicator stopAnimating];

            if (error) {
                // 请求失败
                self.resultTextView.text = [NSString stringWithFormat:@"❌ 请求失败\n\n错误信息：\n%@", error.localizedDescription];
                NSLog(@"请求失败：%@", error);
                return;
            }

            // 检查 HTTP 状态码
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSLog(@"状态码：%ld", (long)httpResponse.statusCode);

            if (httpResponse.statusCode == 200) {
                // 请求成功，解析数据
                if (data) {
                    // 将 NSData 转换为字符串
                    NSString *resultString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

                    // 格式化 JSON（使其更易读）
                    NSError *jsonError;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                    if (jsonObject) {
                        NSData *prettyData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:nil];
                        NSString *prettyString = [[NSString alloc] initWithData:prettyData encoding:NSUTF8StringEncoding];

                        self.resultTextView.text = [NSString stringWithFormat:@"✅ 请求成功\n\n状态码：%ld\n\n返回数据：\n%@", (long)httpResponse.statusCode, prettyString];
                    } else {
                        self.resultTextView.text = [NSString stringWithFormat:@"✅ 请求成功\n\n原始数据：\n%@", resultString];
                    }
                }
            } else {
                // HTTP 错误状态码
                self.resultTextView.text = [NSString stringWithFormat:@"❌ HTTP 错误\n\n状态码：%ld", (long)httpResponse.statusCode];
            }
        });
    }];

    // 启动任务
    [dataTask resume];

    NSLog(@"GET 请求已发送：%@", urlString);
}

@end

