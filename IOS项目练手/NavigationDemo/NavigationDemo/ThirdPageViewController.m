//
//  ThirdPageViewController.m
//  NavigationDemo
//
//  Created by 胡振宇 on 2025/11/20.
//  第三层页面
//

#import "ThirdPageViewController.h"

@interface ThirdPageViewController ()

@end

@implementation ThirdPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"第 3 层";
    self.view.backgroundColor = [UIColor systemOrangeColor];

    [self setupUI];
}

- (void)setupUI {
    CGFloat padding = 20;
    CGFloat screenWidth = self.view.bounds.size.width;

    // 标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 150, screenWidth - 2 * padding, 60)];
    titleLabel.text = @"第 3 层页面";
    titleLabel.font = [UIFont boldSystemFontOfSize:32];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:titleLabel];

    // 说明
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 230, screenWidth - 2 * padding, 120)];
    infoLabel.text = @"这是导航栈的第3层\n\n可以通过以下方式返回：\n• 点击返回按钮\n• 右滑手势\n• 一次性返回到根页面";
    infoLabel.font = [UIFont systemFontOfSize:16];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.numberOfLines = 0;
    infoLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    [self.view addSubview:infoLabel];

    // 返回到根页面按钮
    UIButton *popToRootButton = [UIButton buttonWithType:UIButtonTypeSystem];
    popToRootButton.frame = CGRectMake(padding, 380, screenWidth - 2 * padding, 50);
    [popToRootButton setTitle:@"Pop 到根页面（第1层）" forState:UIControlStateNormal];
    [popToRootButton setTitleColor:[UIColor systemOrangeColor] forState:UIControlStateNormal];
    popToRootButton.backgroundColor = [UIColor whiteColor];
    popToRootButton.layer.cornerRadius = 12;
    popToRootButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [popToRootButton addTarget:self action:@selector(popToRoot) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:popToRootButton];

    // 返回上一层按钮
    UIButton *popButton = [UIButton buttonWithType:UIButtonTypeSystem];
    popButton.frame = CGRectMake(padding, 445, screenWidth - 2 * padding, 50);
    [popButton setTitle:@"Pop 到上一层（第2层）" forState:UIControlStateNormal];
    [popButton setTitleColor:[UIColor systemOrangeColor] forState:UIControlStateNormal];
    popButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    popButton.layer.cornerRadius = 12;
    popButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [popButton addTarget:self action:@selector(popToPrevious) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:popButton];

    // 导航栈信息
    UILabel *stackLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 520, screenWidth - 2 * padding, 40)];
    stackLabel.text = [NSString stringWithFormat:@"当前导航栈: %lu 层", (unsigned long)self.navigationController.viewControllers.count];
    stackLabel.font = [UIFont boldSystemFontOfSize:16];
    stackLabel.textAlignment = NSTextAlignmentCenter;
    stackLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    [self.view addSubview:stackLabel];
}

- (void)popToRoot {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)popToPrevious {
    [self.navigationController popViewControllerAnimated:YES];
}

@end

