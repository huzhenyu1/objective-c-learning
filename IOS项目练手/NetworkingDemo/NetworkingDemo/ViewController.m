//
//  ViewController.m
//  NetworkingDemo
//
//  网络请求学习 - 主菜单
//

#import "ViewController.h"
#import "GETRequestViewController.h"
#import "POSTRequestViewController.h"
#import "JSONParseViewController.h"
#import "ImageLoadViewController.h"
#import "NewsListViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"网络请求学习";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupUI];
}

- (void)setupUI {
    NSArray *demoTitles = @[
        @"GET 请求",
        @"POST 请求",
        @"JSON 解析",
        @"图片加载",
        @"新闻列表（综合）"
    ];

    NSArray *colorNames = @[@"systemBlue", @"systemGreen", @"systemOrange",
                           @"systemPurple", @"systemPink"];

    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat padding = 20;
    CGFloat buttonHeight = 50;
    CGFloat spacing = 15;
    CGFloat yOffset = 100;

    for (NSInteger i = 0; i < demoTitles.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(padding, yOffset, screenWidth - 2 * padding, buttonHeight);
        [button setTitle:demoTitles[i] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.layer.cornerRadius = 10;
        button.tag = i;
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];

        // 动态设置背景色
        NSString *colorName = colorNames[i];
        NSString *colorMethodName = [NSString stringWithFormat:@"%@Color", colorName];
        SEL colorSelector = NSSelectorFromString(colorMethodName);
        if ([UIColor respondsToSelector:colorSelector]) {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            button.backgroundColor = [UIColor performSelector:colorSelector];
            #pragma clang diagnostic pop
        }

        [self.view addSubview:button];
        yOffset += buttonHeight + spacing;
    }
}

- (void)buttonTapped:(UIButton *)sender {
    UIViewController *targetVC = nil;

    switch (sender.tag) {
        case 0:
            targetVC = [[GETRequestViewController alloc] init];
            break;
        case 1:
            targetVC = [[POSTRequestViewController alloc] init];
            break;
        case 2:
            targetVC = [[JSONParseViewController alloc] init];
            break;
        case 3:
            targetVC = [[ImageLoadViewController alloc] init];
            break;
        case 4:
            targetVC = [[NewsListViewController alloc] init];
            break;
        default:
            break;
    }

    if (targetVC) {
        [self.navigationController pushViewController:targetVC animated:YES];
    }
}

@end
