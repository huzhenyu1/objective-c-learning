//
//  JSONParseViewController.m
//  NetworkingDemo
//
//  JSON 解析示例 - 演示 JSON 数据的解析和模型转换
//

#import "JSONParseViewController.h"

@interface JSONParseViewController ()
@property (strong, nonatomic) UITextView *jsonTextView;
@property (strong, nonatomic) UITextView *resultTextView;
@end

@implementation JSONParseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"JSON 解析";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupUI];
    [self loadSampleJSON];
}

- (void)setupUI {
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat yOffset = 100;

    // JSON 数据展示
    UILabel *jsonLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, yOffset, screenWidth - 40, 30)];
    jsonLabel.text = @"原始 JSON 数据：";
    jsonLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.view addSubview:jsonLabel];
    yOffset += 35;

    self.jsonTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, yOffset, screenWidth - 40, 200)];
    self.jsonTextView.font = [UIFont systemFontOfSize:14];
    self.jsonTextView.backgroundColor = [UIColor secondarySystemBackgroundColor];
    self.jsonTextView.layer.cornerRadius = 10;
    self.jsonTextView.editable = NO;
    [self.view addSubview:self.jsonTextView];
    yOffset += 210;

    // 解析按钮
    UIButton *parseButton = [UIButton buttonWithType:UIButtonTypeSystem];
    parseButton.frame = CGRectMake(20, yOffset, screenWidth - 40, 50);
    [parseButton setTitle:@"解析 JSON" forState:UIControlStateNormal];
    parseButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [parseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    parseButton.backgroundColor = [UIColor systemOrangeColor];
    parseButton.layer.cornerRadius = 10;
    [parseButton addTarget:self action:@selector(parseJSON) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:parseButton];
    yOffset += 60;

    // 解析结果展示
    UILabel *resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, yOffset, screenWidth - 40, 30)];
    resultLabel.text = @"解析结果：";
    resultLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.view addSubview:resultLabel];
    yOffset += 35;

    self.resultTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, yOffset, screenWidth - 40, 200)];
    self.resultTextView.font = [UIFont systemFontOfSize:14];
    self.resultTextView.backgroundColor = [UIColor secondarySystemBackgroundColor];
    self.resultTextView.layer.cornerRadius = 10;
    self.resultTextView.editable = NO;
    self.resultTextView.text = @"点击上方按钮解析 JSON...";
    [self.view addSubview:self.resultTextView];
}

- (void)loadSampleJSON {
    // 示例 JSON 数据
    NSDictionary *sampleData = @{
        @"id": @1,
        @"title": @"iOS 开发",
        @"author": @{
            @"name": @"张三",
            @"email": @"zhangsan@example.com",
            @"age": @28
        },
        @"tags": @[@"Swift", @"Objective-C", @"UIKit"],
        @"published": @YES,
        @"views": @1250
    };

    // 转换为格式化的 JSON 字符串
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sampleData
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];

    if (jsonData) {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        self.jsonTextView.text = jsonString;
    }
}

- (void)parseJSON {
    NSString *jsonString = self.jsonTextView.text;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];

    if (!jsonData) {
        self.resultTextView.text = @"❌ 无效的 JSON 数据";
        return;
    }

    NSError *error;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingMutableContainers
                                                      error:&error];

    if (error) {
        self.resultTextView.text = [NSString stringWithFormat:@"❌ JSON 解析失败：\n%@", error.localizedDescription];
        return;
    }

    // 解析成功，提取数据
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)jsonObject;

        NSMutableString *result = [NSMutableString stringWithString:@"✅ JSON 解析成功\n\n"];

        // 提取基本数据
        NSNumber *idNumber = dict[@"id"];
        NSString *title = dict[@"title"];
        NSNumber *views = dict[@"views"];
        NSNumber *published = dict[@"published"];

        [result appendFormat:@"ID: %@\n", idNumber];
        [result appendFormat:@"标题: %@\n", title];
        [result appendFormat:@"浏览量: %@\n", views];
        [result appendFormat:@"已发布: %@\n\n", published.boolValue ? @"是" : @"否"];

        // 提取嵌套对象
        NSDictionary *author = dict[@"author"];
        if (author && [author isKindOfClass:[NSDictionary class]]) {
            [result appendString:@"作者信息：\n"];
            [result appendFormat:@"  姓名: %@\n", author[@"name"]];
            [result appendFormat:@"  邮箱: %@\n", author[@"email"]];
            [result appendFormat:@"  年龄: %@\n\n", author[@"age"]];
        }

        // 提取数组
        NSArray *tags = dict[@"tags"];
        if (tags && [tags isKindOfClass:[NSArray class]]) {
            [result appendString:@"标签：\n"];
            for (NSString *tag in tags) {
                [result appendFormat:@"  • %@\n", tag];
            }
        }

        self.resultTextView.text = result;

        // 打印类型信息
        NSLog(@"数据类型：");
        NSLog(@"  id: %@", NSStringFromClass([idNumber class]));
        NSLog(@"  title: %@", NSStringFromClass([title class]));
        NSLog(@"  author: %@", NSStringFromClass([author class]));
        NSLog(@"  tags: %@", NSStringFromClass([tags class]));

    } else if ([jsonObject isKindOfClass:[NSArray class]]) {
        // 如果是数组
        NSArray *array = (NSArray *)jsonObject;
        self.resultTextView.text = [NSString stringWithFormat:@"✅ 解析成功\n\n这是一个数组，包含 %lu 个元素", (unsigned long)array.count];
    }
}

@end

