//
//  HomeViewController.m
//  NavigationDemo
//
//  Created by 胡振宇 on 2025/11/20.
//  首页 - TabBar 第一个标签
//

#import "HomeViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupUI];
}

- (void)setupUI {
    CGFloat padding = 20;
    CGFloat screenWidth = self.view.bounds.size.width;

    // 图标
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((screenWidth - 80) / 2, 150, 80, 80)];
    iconView.image = [UIImage systemImageNamed:@"house.fill"];
    iconView.tintColor = [UIColor systemBlueColor];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:iconView];

    // 标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 250, screenWidth - 2 * padding, 40)];
    titleLabel.text = @"首页";
    titleLabel.font = [UIFont boldSystemFontOfSize:28];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];

    // 说明
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 310, screenWidth - 2 * padding, 80)];
    infoLabel.text = @"这是 TabBar 的第一个标签页\n点击底部的标签可以切换页面";
    infoLabel.font = [UIFont systemFontOfSize:16];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.numberOfLines = 0;
    infoLabel.textColor = [UIColor secondaryLabelColor];
    [self.view addSubview:infoLabel];

    // 关闭按钮
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    closeButton.frame = CGRectMake(padding, 420, screenWidth - 2 * padding, 50);
    [closeButton setTitle:@"关闭 TabBar" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    closeButton.backgroundColor = [UIColor systemRedColor];
    closeButton.layer.cornerRadius = 12;
    closeButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [closeButton addTarget:self action:@selector(closeTabBar) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
}

- (void)closeTabBar {
    [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
}

@end

