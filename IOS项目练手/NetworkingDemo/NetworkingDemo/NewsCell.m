//
//  NewsCell.m
//  NetworkingDemo
//
//  新闻列表 Cell
//

#import "NewsCell.h"

@implementation NewsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // 标题
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, self.contentView.bounds.size.width - 30, 50)];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.titleLabel.numberOfLines = 2;
    [self.contentView addSubview:self.titleLabel];

    // 作者
    self.authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 65, 150, 20)];
    self.authorLabel.font = [UIFont systemFontOfSize:14];
    self.authorLabel.textColor = [UIColor secondaryLabelColor];
    [self.contentView addSubview:self.authorLabel];

    // 时间
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.bounds.size.width - 150, 65, 135, 20)];
    self.timeLabel.font = [UIFont systemFontOfSize:14];
    self.timeLabel.textColor = [UIColor secondaryLabelColor];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.timeLabel];
}

- (void)configureWithNews:(NewsModel *)news {
    self.titleLabel.text = news.title;
    self.authorLabel.text = [NSString stringWithFormat:@"作者：%@", news.author];
    self.timeLabel.text = news.publishTime;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    // 更新布局
    self.titleLabel.frame = CGRectMake(15, 10, self.contentView.bounds.size.width - 30, 50);
    self.timeLabel.frame = CGRectMake(self.contentView.bounds.size.width - 150, 65, 135, 20);
}

@end

