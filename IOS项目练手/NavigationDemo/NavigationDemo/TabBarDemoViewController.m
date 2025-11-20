//
//  TabBarDemoViewController.m
//  NavigationDemo
//
//  Created by 胡振宇 on 2025/11/20.
//  TabBar 控制器演示
//

#import "TabBarDemoViewController.h"
#import "HomeViewController.h"
#import "DiscoverViewController.h"
#import "MeViewController.h"

@interface TabBarDemoViewController ()

@end

@implementation TabBarDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"TabBar 演示";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupUI];
}

- (void)setupUI {
    CGFloat padding = 20;
    CGFloat screenWidth = self.view.bounds.size.width;

    // 说明标签
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 120, screenWidth - 2 * padding, 100)];
    infoLabel.text = @"UITabBarController\n\n管理多个并列的页面\n适用于应用主界面导航\n点击下方按钮查看效果";
    infoLabel.font = [UIFont systemFontOfSize:16];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.numberOfLines = 0;
    infoLabel.textColor = [UIColor secondaryLabelColor];
    [self.view addSubview:infoLabel];

    // 展示 TabBar 按钮
    UIButton *showTabBarButton = [UIButton buttonWithType:UIButtonTypeSystem];
    showTabBarButton.frame = CGRectMake(padding, 250, screenWidth - 2 * padding, 50);
    [showTabBarButton setTitle:@"展示 TabBar 控制器" forState:UIControlStateNormal];
    [showTabBarButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    showTabBarButton.backgroundColor = [UIColor systemGreenColor];
    showTabBarButton.layer.cornerRadius = 12;
    showTabBarButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [showTabBarButton addTarget:self action:@selector(showTabBar) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showTabBarButton];
}

- (void)showTabBar {
    // 创建三个页面
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    homeVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"首页" image:[UIImage systemImageNamed:@"house"] tag:0];

    DiscoverViewController *discoverVC = [[DiscoverViewController alloc] init];
    discoverVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"发现" image:[UIImage systemImageNamed:@"magnifyingglass"] tag:1];

    MeViewController *meVC = [[MeViewController alloc] init];
    meVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我的" image:[UIImage systemImageNamed:@"person"] tag:2];

    // 创建 TabBar 控制器
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[homeVC, discoverVC, meVC];
    tabBarController.modalPresentationStyle = UIModalPresentationFullScreen;

    // 展示
    [self presentViewController:tabBarController animated:YES completion:nil];
}

@end

