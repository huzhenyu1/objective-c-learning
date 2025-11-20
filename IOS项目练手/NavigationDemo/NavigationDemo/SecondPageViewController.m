//
//  SecondPageViewController.m
//  NavigationDemo
//
//  Created by 胡振宇 on 2025/11/20.
//  第二层页面
//

#import "SecondPageViewController.h"
#import "ThirdPageViewController.h"

@interface SecondPageViewController ()

@end

@implementation SecondPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"第 2 层";
    self.view.backgroundColor = [UIColor systemGreenColor];

    [self setupUI];
}

- (void)setupUI {
    CGFloat padding = 20;
    CGFloat screenWidth = self.view.bounds.size.width;

    // 标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 150, screenWidth - 2 * padding, 60)];
    titleLabel.text = @"第 2 层页面";
    titleLabel.font = [UIFont boldSystemFontOfSize:32];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:titleLabel];

    // 说明
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 230, screenWidth - 2 * padding, 80)];
    infoLabel.text = @"点击左上角返回按钮或\n向右滑动可以返回上一层";
    infoLabel.font = [UIFont systemFontOfSize:16];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.numberOfLines = 0;
    infoLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    [self.view addSubview:infoLabel];

    // Push 到第三层
    UIButton *pushButton = [UIButton buttonWithType:UIButtonTypeSystem];
    pushButton.frame = CGRectMake(padding, 340, screenWidth - 2 * padding, 50);
    [pushButton setTitle:@"继续 Push 到第 3 层" forState:UIControlStateNormal];
    [pushButton setTitleColor:[UIColor systemGreenColor] forState:UIControlStateNormal];
    pushButton.backgroundColor = [UIColor whiteColor];
    pushButton.layer.cornerRadius = 12;
    pushButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [pushButton addTarget:self action:@selector(pushToThirdPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pushButton];

    // 导航栈信息
    UILabel *stackLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 420, screenWidth - 2 * padding, 40)];
    stackLabel.text = [NSString stringWithFormat:@"当前导航栈: %lu 层", (unsigned long)self.navigationController.viewControllers.count];
    stackLabel.font = [UIFont boldSystemFontOfSize:16];
    stackLabel.textAlignment = NSTextAlignmentCenter;
    stackLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    [self.view addSubview:stackLabel];
}

- (void)pushToThirdPage {
    ThirdPageViewController *thirdVC = [[ThirdPageViewController alloc] init];
    [self.navigationController pushViewController:thirdVC animated:YES];
}

@end

