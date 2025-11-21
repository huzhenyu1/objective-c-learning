//
//  PhotoCell.m
//  CollectionViewDemo
//
//  自定义照片 Cell - 模拟照片展示
//

#import "PhotoCell.h"

@implementation PhotoCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // 创建图片视图
    self.imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.cornerRadius = 8;
    [self.contentView addSubview:self.imageView];

    // 创建标题标签
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.contentView.bounds.size.height - 30, self.contentView.bounds.size.width, 30)];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.contentView addSubview:self.titleLabel];

    // 添加阴影
    self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.contentView.layer.shadowOffset = CGSizeMake(0, 2);
    self.contentView.layer.shadowOpacity = 0.3;
    self.contentView.layer.shadowRadius = 4;
}

- (void)configureWithTitle:(NSString *)title color:(UIColor *)color {
    self.titleLabel.text = title;
    self.imageView.backgroundColor = color;
}

// 确保 Cell 重用时布局正确
- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.contentView.bounds;
    self.titleLabel.frame = CGRectMake(0, self.contentView.bounds.size.height - 30, self.contentView.bounds.size.width, 30);
}

@end

