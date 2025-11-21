//
//  ViewController.m
//  CollectionViewDemo
//
//  Created by 胡振宇 on 2025/11/20.
//

#import "ViewController.h"
#import "GridCollectionViewController.h"
#import "WaterfallCollectionViewController.h"
#import "HorizontalCollectionViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"CollectionView 学习";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupUI];
}

- (void)setupUI {
    NSArray *demoTitles = @[
        @"网格布局",
        @"瀑布流布局",
        @"横向滚动"
    ];

    NSArray *colorNames = @[@"systemBlue", @"systemGreen", @"systemOrange"];

    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat padding = 20;
    CGFloat buttonHeight = 50;
    CGFloat spacing = 15;
    CGFloat yOffset = 100;

    for (NSInteger i = 0; i < demoTitles.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(padding, yOffset, screenWidth - 2 * padding, buttonHeight);
        [button setTitle:demoTitles[i] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.layer.cornerRadius = 10;
        button.tag = i;
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];

        // 动态设置背景色
        NSString *colorName = colorNames[i];
        NSString *colorMethodName = [NSString stringWithFormat:@"%@Color", colorName];
        SEL colorSelector = NSSelectorFromString(colorMethodName);
        if ([UIColor respondsToSelector:colorSelector]) {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            button.backgroundColor = [UIColor performSelector:colorSelector];
            #pragma clang diagnostic pop
        }

        [self.view addSubview:button];
        yOffset += buttonHeight + spacing;
    }
}

- (void)buttonTapped:(UIButton *)sender {
    UIViewController *targetVC = nil;

    switch (sender.tag) {
        case 0:
            targetVC = [[GridCollectionViewController alloc] init];
            break;
        case 1:
            targetVC = [[WaterfallCollectionViewController alloc] init];
            break;
        case 2:
            targetVC = [[HorizontalCollectionViewController alloc] init];
            break;
        default:
            break;
    }

    if (targetVC) {
        [self.navigationController pushViewController:targetVC animated:YES];
    }
}

@end
