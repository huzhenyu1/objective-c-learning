//
//  MeViewController.m
//  NavigationDemo
//
//  Created by 胡振宇 on 2025/11/20.
//  我的页面 - TabBar 第三个标签
//

#import "MeViewController.h"

@interface MeViewController ()

@end

@implementation MeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupUI];
}

- (void)setupUI {
    CGFloat padding = 20;
    CGFloat screenWidth = self.view.bounds.size.width;

    // 头像
    UIView *avatarView = [[UIView alloc] initWithFrame:CGRectMake((screenWidth - 80) / 2, 120, 80, 80)];
    avatarView.backgroundColor = [UIColor systemPurpleColor];
    avatarView.layer.cornerRadius = 40;
    [self.view addSubview:avatarView];

    UILabel *avatarLabel = [[UILabel alloc] initWithFrame:avatarView.bounds];
    avatarLabel.text = @"👤";
    avatarLabel.font = [UIFont systemFontOfSize:40];
    avatarLabel.textAlignment = NSTextAlignmentCenter;
    [avatarView addSubview:avatarLabel];

    // 用户名
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 220, screenWidth - 2 * padding, 30)];
    nameLabel.text = @"用户名";
    nameLabel.font = [UIFont boldSystemFontOfSize:22];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:nameLabel];

    // 说明
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 270, screenWidth - 2 * padding, 80)];
    infoLabel.text = @"这是 TabBar 的第三个标签页\n个人信息和设置";
    infoLabel.font = [UIFont systemFontOfSize:16];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.numberOfLines = 0;
    infoLabel.textColor = [UIColor secondaryLabelColor];
    [self.view addSubview:infoLabel];
}

@end

