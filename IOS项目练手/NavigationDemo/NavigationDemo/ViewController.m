//
//  ViewController.m
//  NavigationDemo
//
//  Created by 胡振宇 on 2025/11/20.
//  主菜单 - 交互与导航演示
//

#import "ViewController.h"
#import "NavigationStackDemoViewController.h"
#import "TabBarDemoViewController.h"
#import "TableViewDemoViewController.h"
#import "GestureDemoViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"交互与导航";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupUI];
}

- (void)setupUI {
    CGFloat padding = 20;
    CGFloat buttonHeight = 60;
    CGFloat spacing = 15;
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat yOffset = 100;

    // 标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 60, screenWidth - 2 * padding, 40)];
    titleLabel.text = @"🚀 交互与导航演示";
    titleLabel.font = [UIFont boldSystemFontOfSize:28];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];

    // 按钮配置
    NSArray *buttonConfigs = @[
        @{@"title": @"导航控制器 (UINavigationController)", @"color": @"systemBlue", @"selector": @"showNavStackDemo"},
        @{@"title": @"标签栏控制器 (UITabBarController)", @"color": @"systemGreen", @"selector": @"showTabBarDemo"},
        @{@"title": @"列表视图 (UITableView)", @"color": @"systemOrange", @"selector": @"showTableViewDemo"},
        @{@"title": @"手势识别 (UIGestureRecognizer)", @"color": @"systemPurple", @"selector": @"showGestureDemo"}
    ];

    for (NSDictionary *config in buttonConfigs) {
        UIButton *button = [self createMenuButton:config
                                            frame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, buttonHeight)];
        [self.view addSubview:button];
        yOffset += buttonHeight + spacing;
    }
}

- (UIButton *)createMenuButton:(NSDictionary *)config frame:(CGRect)frame {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = frame;

    // 设置背景色 - 使用字符串转方法调用
    NSString *colorName = config[@"color"];
    NSString *colorMethodName = [NSString stringWithFormat:@"%@Color", colorName];
    SEL colorSelector = NSSelectorFromString(colorMethodName);

    // 调用类方法获取颜色
    if ([UIColor respondsToSelector:colorSelector]) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        button.backgroundColor = [UIColor performSelector:colorSelector];
        #pragma clang diagnostic pop
    }

    button.layer.cornerRadius = 12;
    button.layer.shadowColor = [UIColor blackColor].CGColor;
    button.layer.shadowOffset = CGSizeMake(0, 2);
    button.layer.shadowOpacity = 0.2;
    button.layer.shadowRadius = 4;

    [button setTitle:config[@"title"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    button.titleLabel.numberOfLines = 0;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;

    SEL selector = NSSelectorFromString(config[@"selector"]);
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];

    return button;
}

#pragma mark - 按钮事件

- (void)showNavStackDemo {
    NavigationStackDemoViewController *vc = [[NavigationStackDemoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showTabBarDemo {
    TabBarDemoViewController *vc = [[TabBarDemoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showTableViewDemo {
    TableViewDemoViewController *vc = [[TableViewDemoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showGestureDemo {
    GestureDemoViewController *vc = [[GestureDemoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
