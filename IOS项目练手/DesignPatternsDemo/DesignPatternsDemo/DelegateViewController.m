//
//  DelegateViewController.m
//  DesignPatternsDemo
//
//  Delegate 委托模式演示：协议 + 代理
//

#import "DelegateViewController.h"

#pragma mark - 1. 定义协议（Protocol）

@protocol ColorPickerDelegate <NSObject>
@required
- (void)colorPicker:(id)picker didSelectColor:(UIColor *)color;

@optional
- (void)colorPickerDidCancel:(id)picker;
@end

#pragma mark - 2. 自定义View（有代理）

@interface ColorPickerView : UIView
@property (weak, nonatomic) id<ColorPickerDelegate> delegate;  // ⭐ weak 防止循环引用
@end

@implementation ColorPickerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        self.frame = frame;
        self.backgroundColor = [UIColor systemGroupedBackgroundColor];
        self.layer.cornerRadius = 10;

        [self setupColorButtons];
    }
    return self;
}

- (void)setupColorButtons {
    NSArray *colors = @[
        [UIColor systemRedColor],
        [UIColor systemOrangeColor],
        [UIColor systemYellowColor],
        [UIColor systemGreenColor],
        [UIColor systemBlueColor],
        [UIColor systemPurpleColor]
    ];

    NSArray *colorNames = @[@"红色", @"橙色", @"黄色", @"绿色", @"蓝色", @"紫色"];

    CGFloat buttonWidth = 80;
    CGFloat buttonHeight = 80;
    CGFloat padding = 10;
    CGFloat startX = (self.frame.size.width - (buttonWidth * 3 + padding * 2)) / 2;

    for (NSInteger i = 0; i < colors.count; i++) {
        NSInteger row = i / 3;
        NSInteger col = i % 3;

        CGFloat x = startX + col * (buttonWidth + padding);
        CGFloat y = 20 + row * (buttonHeight + padding + 30);

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(x, y, buttonWidth, buttonHeight);
        button.backgroundColor = colors[i];
        button.layer.cornerRadius = 10;
        button.tag = i;
        [button addTarget:self action:@selector(colorButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];

        // 标签
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, y + buttonHeight + 5, buttonWidth, 20)];
        label.text = colorNames[i];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:12];
        [self addSubview:label];
    }
}

- (void)colorButtonTapped:(UIButton *)sender {
    // ⭐ 通过代理通知外部
    if ([self.delegate respondsToSelector:@selector(colorPicker:didSelectColor:)]) {
        [self.delegate colorPicker:self didSelectColor:sender.backgroundColor];
    }
}

@end

#pragma mark - 3. Controller（实现代理协议）

@interface DelegateViewController () <ColorPickerDelegate>
@property (strong, nonatomic) ColorPickerView *colorPicker;
@property (strong, nonatomic) UIView *previewView;
@property (strong, nonatomic) UILabel *resultLabel;
@end

@implementation DelegateViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Delegate 委托模式";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupUI];
}

- (void)setupUI {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat yOffset = 100;

    // 说明
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, yOffset, screenWidth - 40, 80)];
    descLabel.text = @"Delegate 委托模式：\n1. 定义协议（Protocol）\n2. 设置代理（weak 引用）\n3. 通过代理回调通知";
    descLabel.numberOfLines = 0;
    descLabel.font = [UIFont systemFontOfSize:14];
    descLabel.textColor = [UIColor secondaryLabelColor];
    [self.view addSubview:descLabel];
    yOffset += 100;

    // 颜色选择器
    self.colorPicker = [[ColorPickerView alloc] initWithFrame:CGRectMake(20, yOffset, screenWidth - 40, 250)];
    self.colorPicker.delegate = self;  // ⭐ 设置代理
    [self.view addSubview:self.colorPicker];
    yOffset += 270;

    // 预览区域
    self.previewView = [[UIView alloc] initWithFrame:CGRectMake(20, yOffset, screenWidth - 40, 100)];
    self.previewView.backgroundColor = [UIColor lightGrayColor];
    self.previewView.layer.cornerRadius = 10;
    self.previewView.layer.borderWidth = 2;
    self.previewView.layer.borderColor = [UIColor systemGrayColor].CGColor;
    [self.view addSubview:self.previewView];
    yOffset += 110;

    // 结果标签
    self.resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, yOffset, screenWidth - 40, 60)];
    self.resultLabel.text = @"点击上方颜色按钮\n将通过 Delegate 回调选择的颜色";
    self.resultLabel.numberOfLines = 0;
    self.resultLabel.textAlignment = NSTextAlignmentCenter;
    self.resultLabel.font = [UIFont systemFontOfSize:16];
    self.resultLabel.textColor = [UIColor systemGreenColor];
    [self.view addSubview:self.resultLabel];
}

#pragma mark - ColorPickerDelegate（⭐ 实现代理方法）

- (void)colorPicker:(id)picker didSelectColor:(UIColor *)color {
    // 代理回调：更新 UI
    self.previewView.backgroundColor = color;

    NSString *colorName = [self colorNameFromColor:color];
    self.resultLabel.text = [NSString stringWithFormat:@"通过 Delegate 回调\n选择了：%@", colorName];

    // 动画效果
    [UIView animateWithDuration:0.3 animations:^{
        self.previewView.transform = CGAffineTransformMakeScale(1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.previewView.transform = CGAffineTransformIdentity;
        }];
    }];
}

- (void)colorPickerDidCancel:(id)picker {
    // Optional 方法（可选实现）
    self.resultLabel.text = @"取消选择";
}

- (NSString *)colorNameFromColor:(UIColor *)color {
    NSDictionary *colorMap = @{
        @"systemRed": @"红色",
        @"systemOrange": @"橙色",
        @"systemYellow": @"黄色",
        @"systemGreen": @"绿色",
        @"systemBlue": @"蓝色",
        @"systemPurple": @"紫色"
    };

    if (CGColorEqualToColor(color.CGColor, [UIColor systemRedColor].CGColor)) return colorMap[@"systemRed"];
    if (CGColorEqualToColor(color.CGColor, [UIColor systemOrangeColor].CGColor)) return colorMap[@"systemOrange"];
    if (CGColorEqualToColor(color.CGColor, [UIColor systemYellowColor].CGColor)) return colorMap[@"systemYellow"];
    if (CGColorEqualToColor(color.CGColor, [UIColor systemGreenColor].CGColor)) return colorMap[@"systemGreen"];
    if (CGColorEqualToColor(color.CGColor, [UIColor systemBlueColor].CGColor)) return colorMap[@"systemBlue"];
    if (CGColorEqualToColor(color.CGColor, [UIColor systemPurpleColor].CGColor)) return colorMap[@"systemPurple"];

    return @"未知颜色";
}

@end

