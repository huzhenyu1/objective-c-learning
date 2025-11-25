//
//  BookCell.m
//  TestDemo
//
//  自定义书籍 Cell
//

#import "BookCell.h"

@implementation BookCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViews];
        [self setupConstraints];
    }
    return self;
}

- (void)setupViews {
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:16];
    self.titleLabel.numberOfLines = 0;  // 允许多行
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.titleLabel];
}

- (void)setupConstraints {
    // ⭐ 完整的约束：从 top 到 bottom
    [NSLayoutConstraint activateConstraints:@[
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:12],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [self.titleLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-12]
    ]];
}

- (void)setBookTitle:(NSString *)bookTitle {
    _bookTitle = [bookTitle copy];
    self.titleLabel.text = bookTitle;
}

@end

