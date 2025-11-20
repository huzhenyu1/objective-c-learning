//
//  DetailViewController.m
//  NavigationDemo
//
//  Created by 胡振宇 on 2025/11/20.
//  详情页 - 演示数据传递
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"详情";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupUI];
}

- (void)setupUI {
    CGFloat padding = 20;
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat yOffset = 120;

    // 产品名称
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 40)];
    nameLabel.text = self.productName ?: @"未知产品";
    nameLabel.font = [UIFont boldSystemFontOfSize:28];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:nameLabel];
    yOffset += 60;

    // 产品描述
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 30)];
    descLabel.text = self.productDescription ?: @"暂无描述";
    descLabel.font = [UIFont systemFontOfSize:18];
    descLabel.textAlignment = NSTextAlignmentCenter;
    descLabel.textColor = [UIColor secondaryLabelColor];
    [self.view addSubview:descLabel];
    yOffset += 50;

    // 分隔线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 1)];
    lineView.backgroundColor = [UIColor separatorColor];
    [self.view addSubview:lineView];
    yOffset += 30;

    // 详细说明
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 120)];
    infoLabel.text = @"这是一个详情页面\n\n演示了如何从列表页\n传递数据到详情页\n\n使用 property 传递数据";
    infoLabel.font = [UIFont systemFontOfSize:16];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.numberOfLines = 0;
    infoLabel.textColor = [UIColor secondaryLabelColor];
    [self.view addSubview:infoLabel];
    yOffset += 140;

    // 数据传递说明卡片
    UIView *cardView = [[UIView alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 100)];
    cardView.backgroundColor = [UIColor systemBlueColor];
    cardView.layer.cornerRadius = 12;
    [self.view addSubview:cardView];

    UILabel *cardLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, cardView.bounds.size.width - 30, cardView.bounds.size.height)];
    cardLabel.text = [NSString stringWithFormat:@"📦 接收到的数据：\n\n名称: %@\n描述: %@",
                     self.productName ?: @"空",
                     self.productDescription ?: @"空"];
    cardLabel.font = [UIFont systemFontOfSize:14];
    cardLabel.textColor = [UIColor whiteColor];
    cardLabel.numberOfLines = 0;
    [cardView addSubview:cardLabel];
}

@end

