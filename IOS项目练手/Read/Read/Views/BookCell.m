//
//  BookCell.m
//  Read
//
//  书籍列表 Cell - 仿照截图样式
//

#import "BookCell.h"

@implementation BookCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // 封面图片（左侧）
    self.coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 100, 140)];
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverImageView.clipsToBounds = YES;
    self.coverImageView.layer.cornerRadius = 8;
    self.coverImageView.backgroundColor = [UIColor systemGray5Color];
    [self.contentView addSubview:self.coverImageView];

    // 书名（右上）
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(125, 15, 230, 25)];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.titleLabel.numberOfLines = 2;
    [self.contentView addSubview:self.titleLabel];

    // 作者信息（书名下方）
    self.authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(125, 45, 150, 18)];
    self.authorLabel.font = [UIFont systemFontOfSize:14];
    self.authorLabel.textColor = [UIColor secondaryLabelColor];
    [self.contentView addSubview:self.authorLabel];

    // 章节信息（中间）
    self.chapterLabel = [[UILabel alloc] initWithFrame:CGRectMake(125, 70, 230, 18)];
    self.chapterLabel.font = [UIFont systemFontOfSize:14];
    self.chapterLabel.textColor = [UIColor secondaryLabelColor];
    [self.contentView addSubview:self.chapterLabel];

    // 状态信息（底部）
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(125, 95, 230, 18)];
    self.statusLabel.font = [UIFont systemFontOfSize:14];
    self.statusLabel.textColor = [UIColor tertiaryLabelColor];
    [self.contentView addSubview:self.statusLabel];

    // 角标（右上角，显示未读数量）
    self.badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(330, 15, 40, 25)];
    self.badgeLabel.font = [UIFont boldSystemFontOfSize:14];
    self.badgeLabel.textAlignment = NSTextAlignmentCenter;
    self.badgeLabel.textColor = [UIColor whiteColor];
    self.badgeLabel.backgroundColor = [UIColor systemRedColor];
    self.badgeLabel.layer.cornerRadius = 12;
    self.badgeLabel.clipsToBounds = YES;
    [self.contentView addSubview:self.badgeLabel];
}

- (void)configureWithBook:(BookModel *)book {
    self.titleLabel.text = book.title;
    self.authorLabel.text = [NSString stringWithFormat:@"📝 %@", book.author];

    // 显示阅读进度
    if (book.totalChapters > 0) {
        self.chapterLabel.text = [NSString stringWithFormat:@"📖 第%ld章", (long)(book.currentChapter + 1)];
        self.statusLabel.text = [NSString stringWithFormat:@"📊 共%ld章", (long)book.totalChapters];
    } else {
        self.chapterLabel.text = @"📖 未开始阅读";
        self.statusLabel.text = @"📊 章节未知";
    }

    // 角标（未读数量）
    if (book.unreadCount > 0) {
        self.badgeLabel.text = [NSString stringWithFormat:@"%ld", (long)book.unreadCount];
        self.badgeLabel.hidden = NO;
    } else {
        self.badgeLabel.hidden = YES;
    }

    // 封面（使用占位颜色）
    NSArray *colors = @[
        [UIColor systemBlueColor],
        [UIColor systemGreenColor],
        [UIColor systemOrangeColor],
        [UIColor systemPurpleColor],
        [UIColor systemPinkColor],
        [UIColor systemTealColor]
    ];
    self.coverImageView.backgroundColor = colors[[book.title hash] % colors.count];

    // 复用已有的 initialLabel（性能优化）
    UILabel *initialLabel = (UILabel *)[self.coverImageView viewWithTag:999];
    if (!initialLabel) {
        initialLabel = [[UILabel alloc] initWithFrame:self.coverImageView.bounds];
        initialLabel.tag = 999;
        initialLabel.font = [UIFont boldSystemFontOfSize:48];
        initialLabel.textColor = [UIColor whiteColor];
        initialLabel.textAlignment = NSTextAlignmentCenter;
        [self.coverImageView addSubview:initialLabel];
    }

    // 只更新文本（避免重复创建视图）
    initialLabel.text = book.title.length > 0 ? [book.title substringToIndex:1] : @"";
}

- (void)layoutSubviews {
    [super layoutSubviews];

    // 更新布局（适配不同屏幕）
    CGFloat screenWidth = self.contentView.bounds.size.width;
    self.titleLabel.frame = CGRectMake(125, 15, screenWidth - 170, 25);
    self.badgeLabel.frame = CGRectMake(screenWidth - 60, 15, 40, 25);
}

@end

