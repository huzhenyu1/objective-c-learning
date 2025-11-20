//
//  DiscoverViewController.m
//  NavigationDemo
//
//  Created by 胡振宇 on 2025/11/20.
//  发现页 - TabBar 第二个标签
//

#import "DiscoverViewController.h"

@interface DiscoverViewController ()

@end

@implementation DiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];

    [self setupUI];
}

- (void)setupUI {
    CGFloat padding = 20;
    CGFloat screenWidth = self.view.bounds.size.width;

    // 图标
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((screenWidth - 80) / 2, 150, 80, 80)];
    iconView.image = [UIImage systemImageNamed:@"magnifyingglass.circle.fill"];
    iconView.tintColor = [UIColor systemGreenColor];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:iconView];

    // 标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 250, screenWidth - 2 * padding, 40)];
    titleLabel.text = @"发现";
    titleLabel.font = [UIFont boldSystemFontOfSize:28];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];

    // 说明
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 310, screenWidth - 2 * padding, 80)];
    infoLabel.text = @"这是 TabBar 的第二个标签页\n发现更多精彩内容";
    infoLabel.font = [UIFont systemFontOfSize:16];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.numberOfLines = 0;
    infoLabel.textColor = [UIColor secondaryLabelColor];
    [self.view addSubview:infoLabel];
}

@end

