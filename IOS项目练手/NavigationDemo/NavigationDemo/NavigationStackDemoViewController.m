//
//  NavigationStackDemoViewController.m
//  NavigationDemo
//
//  Created by 胡振宇 on 2025/11/20.
//  导航控制器演示 - push/pop 操作
//

#import "NavigationStackDemoViewController.h"
#import "SecondPageViewController.h"

@interface NavigationStackDemoViewController ()
@property (strong, nonatomic) UILabel *infoLabel;
@end

@implementation NavigationStackDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"导航控制器";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupUI];
}

- (void)setupUI {
    CGFloat padding = 20;
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat yOffset = 100;

    // 说明标签
    self.infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 120)];
    self.infoLabel.text = @"UINavigationController\n\n管理页面栈，实现层级导航\n• Push: 推入新页面\n• Pop: 返回上一页\n• 导航栏自动管理";
    self.infoLabel.font = [UIFont systemFontOfSize:16];
    self.infoLabel.textAlignment = NSTextAlignmentCenter;
    self.infoLabel.numberOfLines = 0;
    self.infoLabel.textColor = [UIColor secondaryLabelColor];
    [self.view addSubview:self.infoLabel];
    yOffset += 140;

    // 当前层级显示
    UILabel *stackLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 60)];
    stackLabel.text = [NSString stringWithFormat:@"当前导航栈层级: %lu\n这是第 1 层", (unsigned long)self.navigationController.viewControllers.count];
    stackLabel.font = [UIFont boldSystemFontOfSize:18];
    stackLabel.textAlignment = NSTextAlignmentCenter;
    stackLabel.numberOfLines = 0;
    stackLabel.textColor = [UIColor systemBlueColor];
    [self.view addSubview:stackLabel];
    yOffset += 80;

    // Push 按钮
    UIButton *pushButton = [UIButton buttonWithType:UIButtonTypeSystem];
    pushButton.frame = CGRectMake(padding, yOffset, screenWidth - 2 * padding, 50);
    [pushButton setTitle:@"Push 到第 2 层" forState:UIControlStateNormal];
    [pushButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    pushButton.backgroundColor = [UIColor systemGreenColor];
    pushButton.layer.cornerRadius = 12;
    pushButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [pushButton addTarget:self action:@selector(pushToSecondPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pushButton];
    yOffset += 65;

    // Pop 按钮（返回）
    UIButton *popButton = [UIButton buttonWithType:UIButtonTypeSystem];
    popButton.frame = CGRectMake(padding, yOffset, screenWidth - 2 * padding, 50);
    [popButton setTitle:@"Pop 返回上一层" forState:UIControlStateNormal];
    [popButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    popButton.backgroundColor = [UIColor systemOrangeColor];
    popButton.layer.cornerRadius = 12;
    popButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [popButton addTarget:self action:@selector(popToPreviousPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:popButton];
    yOffset += 65;

    // 显示导航栈信息按钮
    UIButton *showStackButton = [UIButton buttonWithType:UIButtonTypeSystem];
    showStackButton.frame = CGRectMake(padding, yOffset, screenWidth - 2 * padding, 50);
    [showStackButton setTitle:@"查看导航栈信息" forState:UIControlStateNormal];
    [showStackButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    showStackButton.backgroundColor = [UIColor systemPurpleColor];
    showStackButton.layer.cornerRadius = 12;
    showStackButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [showStackButton addTarget:self action:@selector(showStackInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showStackButton];
}

- (void)pushToSecondPage {
    SecondPageViewController *secondVC = [[SecondPageViewController alloc] init];
    [self.navigationController pushViewController:secondVC animated:YES];
}

- (void)popToPreviousPage {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showStackInfo {
    NSInteger count = self.navigationController.viewControllers.count;
    NSMutableString *info = [NSMutableString stringWithFormat:@"导航栈层数: %ld\n\n", (long)count];

    for (NSInteger i = 0; i < count; i++) {
        UIViewController *vc = self.navigationController.viewControllers[i];
        [info appendFormat:@"第 %ld 层: %@\n", (long)(i + 1), NSStringFromClass([vc class])];
    }

    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"导航栈信息"
        message:info
        preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end

