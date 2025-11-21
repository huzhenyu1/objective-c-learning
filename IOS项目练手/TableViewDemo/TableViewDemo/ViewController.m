//
//  ViewController.m
//  TableViewDemo
//
//  Created by 胡振宇 on 2025/11/20.
//

#import "ViewController.h"
#import "BasicTableViewController.h"
#import "MultiSectionTableViewController.h"
#import "CustomCellTableViewController.h"
#import "EditableTableViewController.h"
#import "SearchTableViewController.h"
#import "RefreshTableViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"TableView 学习";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupUI];
}

- (void)setupUI {
    NSArray *demoTitles = @[
        @"基础列表",
        @"多 Section 列表",
        @"自定义 Cell",
        @"可编辑列表",
        @"搜索功能",
        @"下拉刷新/上拉加载"
    ];

    NSArray *colorNames = @[@"systemBlue", @"systemGreen", @"systemOrange",
                           @"systemPurple", @"systemPink", @"systemTeal"];

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
            targetVC = [[BasicTableViewController alloc] init];
            break;
        case 1:
            targetVC = [[MultiSectionTableViewController alloc] init];
            break;
        case 2:
            targetVC = [[CustomCellTableViewController alloc] init];
            break;
        case 3:
            targetVC = [[EditableTableViewController alloc] init];
            break;
        case 4:
            targetVC = [[SearchTableViewController alloc] init];
            break;
        case 5:
            targetVC = [[RefreshTableViewController alloc] init];
            break;
        default:
            break;
    }

    if (targetVC) {
        [self.navigationController pushViewController:targetVC animated:YES];
    }
}

@end
