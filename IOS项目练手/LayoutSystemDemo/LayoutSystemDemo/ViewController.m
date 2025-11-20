//
//  ViewController.m
//  LayoutSystemDemo
//
//  Created by 胡振宇 on 2025/11/20.
//  主菜单页面 - 展示各种布局方式的入口
//

#import "ViewController.h"
#import "FrameLayoutVC.h"
#import "AutoLayoutVC.h"
#import "StackViewVC.h"
#import "SafeAreaVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"布局系统";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupUI];
}

- (void)setupUI {
    CGFloat padding = 20;
    CGFloat buttonHeight = 60;
    CGFloat spacing = 15;
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat yOffset = 120;

    // 标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 60, screenWidth - 2 * padding, 50)];
    titleLabel.text = @"📐 布局系统演示";
    titleLabel.font = [UIFont boldSystemFontOfSize:32];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];

    // 按钮配置
    NSArray *buttonConfigs = @[
        @{@"title": @"Frame 布局", @"icon": @"📏", @"color": @"systemBlue", @"selector": @"showFrameLayout"},
        @{@"title": @"Auto Layout 布局", @"icon": @"🔧", @"color": @"systemGreen", @"selector": @"showAutoLayout"},
        @{@"title": @"StackView 布局", @"icon": @"📚", @"color": @"systemOrange", @"selector": @"showStackView"},
        @{@"title": @"Safe Area 演示", @"icon": @"🛡️", @"color": @"systemPurple", @"selector": @"showSafeArea"}
    ];

    for (NSDictionary *config in buttonConfigs) {
        UIButton *button = [self createMenuButton:config
                                            frame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, buttonHeight)];
        [self.view addSubview:button];
        yOffset += buttonHeight + spacing;
    }

    // 提示文字
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset + 20, screenWidth - 2 * padding, 60)];
    tipLabel.text = @"点击按钮查看不同的布局方式\n旋转设备测试自适应效果";
    tipLabel.font = [UIFont systemFontOfSize:14];
    tipLabel.textColor = [UIColor secondaryLabelColor];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.numberOfLines = 0;
    [self.view addSubview:tipLabel];
}

- (UIButton *)createMenuButton:(NSDictionary *)config frame:(CGRect)frame {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = frame;

    // 设置背景色
    NSString *colorName = config[@"color"];
    if ([colorName isEqualToString:@"systemBlue"]) {
        button.backgroundColor = [UIColor systemBlueColor];
    } else if ([colorName isEqualToString:@"systemGreen"]) {
        button.backgroundColor = [UIColor systemGreenColor];
    } else if ([colorName isEqualToString:@"systemOrange"]) {
        button.backgroundColor = [UIColor systemOrangeColor];
    } else if ([colorName isEqualToString:@"systemPurple"]) {
        button.backgroundColor = [UIColor systemPurpleColor];
    }

    // 按钮样式
    button.layer.cornerRadius = 12;
    button.layer.shadowColor = [UIColor blackColor].CGColor;
    button.layer.shadowOffset = CGSizeMake(0, 2);
    button.layer.shadowOpacity = 0.2;
    button.layer.shadowRadius = 4;

    // 标题
    NSString *title = [NSString stringWithFormat:@"%@ %@", config[@"icon"], config[@"title"]];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:20];

    // 添加事件
    SEL selector = NSSelectorFromString(config[@"selector"]);
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];

    return button;
}

#pragma mark - 按钮事件

- (void)showFrameLayout {
    FrameLayoutVC *vc = [[FrameLayoutVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showAutoLayout {
    AutoLayoutVC *vc = [[AutoLayoutVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showStackView {
    StackViewVC *vc = [[StackViewVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showSafeArea {
    SafeAreaVC *vc = [[SafeAreaVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
