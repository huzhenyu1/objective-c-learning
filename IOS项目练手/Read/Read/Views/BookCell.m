//
//  BookCell.m
//  Read
//
//  书籍列表 Cell - 仿照截图样式
//

#import "BookCell.h"
#import "ScreenAdapter.h"

@implementation BookCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // 背景色设置为白色
    self.backgroundColor = [UIColor whiteColor];
    self.contentView.backgroundColor = [UIColor whiteColor];

    // ⭐ 获取适配尺寸
    CGSize coverSize = [ScreenAdapter bookCoverSize];
    CGFloat padding = [ScreenAdapter horizontalPadding];

    // ⭐ 封面图片（左侧）
    self.coverImageView = [[UIImageView alloc] init];
    self.coverImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverImageView.clipsToBounds = YES;
    self.coverImageView.layer.cornerRadius = 4;
    self.coverImageView.backgroundColor = [UIColor systemGray5Color];
    [self.contentView addSubview:self.coverImageView];

    // ⭐ 书名（右上）
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.titleLabel];

    // ⭐ 作者信息
    self.authorLabel = [[UILabel alloc] init];
    self.authorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.authorLabel.font = [UIFont systemFontOfSize:13];
    self.authorLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:self.authorLabel];

    // ⭐ 当前章节信息
    self.chapterLabel = [[UILabel alloc] init];
    self.chapterLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.chapterLabel.font = [UIFont systemFontOfSize:12];
    self.chapterLabel.textColor = [UIColor grayColor];
    self.chapterLabel.numberOfLines = 1;
    [self.contentView addSubview:self.chapterLabel];

    // ⭐ 最新章节信息
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.statusLabel.font = [UIFont systemFontOfSize:12];
    self.statusLabel.textColor = [UIColor grayColor];
    self.statusLabel.numberOfLines = 1;
    [self.contentView addSubview:self.statusLabel];

    // 角标（右上角）
    self.badgeLabel = [[UILabel alloc] init];
    self.badgeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.badgeLabel.font = [UIFont boldSystemFontOfSize:13];
    self.badgeLabel.textAlignment = NSTextAlignmentCenter;
    self.badgeLabel.textColor = [UIColor whiteColor];
    self.badgeLabel.backgroundColor = [UIColor systemRedColor];
    self.badgeLabel.layer.cornerRadius = 12;
    self.badgeLabel.clipsToBounds = YES;
    [self.contentView addSubview:self.badgeLabel];

    // 底部分隔线
    UIView *separatorLine = [[UIView alloc] init];
    separatorLine.translatesAutoresizingMaskIntoConstraints = NO;
    separatorLine.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.2];
    separatorLine.tag = 888;
    [self.contentView addSubview:separatorLine];
    
    // ⭐ AutoLayout 约束
    [self setupConstraints:coverSize padding:padding separatorLine:separatorLine];
}

// ⭐ 设置 AutoLayout 约束（支持横竖屏和iPad）
- (void)setupConstraints:(CGSize)coverSize padding:(CGFloat)padding separatorLine:(UIView *)separatorLine {
    [NSLayoutConstraint activateConstraints:@[
        // 封面图片约束
        [self.coverImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:padding],
        [self.coverImageView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:10],
        [self.coverImageView.widthAnchor constraintEqualToConstant:coverSize.width],
        [self.coverImageView.heightAnchor constraintEqualToConstant:coverSize.height],
        
        // 书名约束
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.coverImageView.trailingAnchor constant:10],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.badgeLabel.leadingAnchor constant:-10],
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:15],
        [self.titleLabel.heightAnchor constraintEqualToConstant:22],
        
        // 作者约束
        [self.authorLabel.leadingAnchor constraintEqualToAnchor:self.titleLabel.leadingAnchor],
        [self.authorLabel.trailingAnchor constraintEqualToAnchor:self.titleLabel.trailingAnchor],
        [self.authorLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:7],
        [self.authorLabel.heightAnchor constraintEqualToConstant:18],
        
        // 当前章节约束
        [self.chapterLabel.leadingAnchor constraintEqualToAnchor:self.titleLabel.leadingAnchor],
        [self.chapterLabel.trailingAnchor constraintEqualToAnchor:self.titleLabel.trailingAnchor],
        [self.chapterLabel.topAnchor constraintEqualToAnchor:self.authorLabel.bottomAnchor constant:7],
        [self.chapterLabel.heightAnchor constraintEqualToConstant:18],
        
        // 最新章节约束
        [self.statusLabel.leadingAnchor constraintEqualToAnchor:self.titleLabel.leadingAnchor],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:self.titleLabel.trailingAnchor],
        [self.statusLabel.topAnchor constraintEqualToAnchor:self.chapterLabel.bottomAnchor constant:7],
        [self.statusLabel.heightAnchor constraintEqualToConstant:18],
        
        // 角标约束
        [self.badgeLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-padding],
        [self.badgeLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:20],
        [self.badgeLabel.widthAnchor constraintGreaterThanOrEqualToConstant:24],
        [self.badgeLabel.heightAnchor constraintEqualToConstant:24],
        
        // 分隔线约束
        [separatorLine.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:padding],
        [separatorLine.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [separatorLine.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
        [separatorLine.heightAnchor constraintEqualToConstant:0.5]
    ]];
}

- (void)configureWithBook:(BookModel *)book {
    // 书名
    self.titleLabel.text = book.title;

    // ⭐ 作者（保留 ⊙ 图标）
    self.authorLabel.text = [NSString stringWithFormat:@"⊙ %@", book.author ?: @"佚名"];

    // ⭐ 当前章节（显示完整章节名，无图标）
    if (book.currentChapterName && book.currentChapterName.length > 0) {
        self.chapterLabel.text = book.currentChapterName;
    } else if (book.totalChapters > 0) {
        self.chapterLabel.text = [NSString stringWithFormat:@"第%ld章", (long)(book.currentChapter + 1)];
    } else {
        self.chapterLabel.text = @"未开始阅读";
    }

    // ⭐ 最新章节（显示完整章节名，无图标）
    if (book.latestChapterName && book.latestChapterName.length > 0) {
        self.statusLabel.text = book.latestChapterName;
    } else if (book.totalChapters > 0) {
        self.statusLabel.text = [NSString stringWithFormat:@"共%ld章", (long)book.totalChapters];
    } else {
        self.statusLabel.text = @"章节待加载";
    }

    // 角标（未读数量）- 仅显示数字
    if (book.unreadCount > 0) {
        self.badgeLabel.text = [NSString stringWithFormat:@"%ld", (long)book.unreadCount];
        self.badgeLabel.hidden = NO;
    } else {
        self.badgeLabel.hidden = YES;
    }

    // 封面（使用渐变色背景）
    NSArray *colors = @[
        [UIColor colorWithRed:0.28 green:0.47 blue:0.78 alpha:1.0],  // 蓝色
        [UIColor colorWithRed:0.32 green:0.64 blue:0.53 alpha:1.0],  // 青色
        [UIColor colorWithRed:0.82 green:0.46 blue:0.32 alpha:1.0],  // 橙色
        [UIColor colorWithRed:0.53 green:0.42 blue:0.75 alpha:1.0],  // 紫色
        [UIColor colorWithRed:0.85 green:0.42 blue:0.52 alpha:1.0],  // 粉色
        [UIColor colorWithRed:0.28 green:0.67 blue:0.71 alpha:1.0]   // 青绿色
    ];

    UIColor *bgColor = colors[[book.title hash] % colors.count];
    self.coverImageView.backgroundColor = bgColor;

    // 复用已有的 initialLabel（性能优化）
    UILabel *initialLabel = (UILabel *)[self.coverImageView viewWithTag:999];
    if (!initialLabel) {
        initialLabel = [[UILabel alloc] initWithFrame:self.coverImageView.bounds];
        initialLabel.tag = 999;
        initialLabel.font = [UIFont boldSystemFontOfSize:40];
        initialLabel.textColor = [UIColor whiteColor];
        initialLabel.textAlignment = NSTextAlignmentCenter;
        [self.coverImageView addSubview:initialLabel];
    }

    // 只更新文本（显示书名首字）
    initialLabel.text = book.title.length > 0 ? [book.title substringToIndex:1] : @"书";
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // ⭐ 使用 AutoLayout 后不需要手动调整 Frame
    // AutoLayout 会自动处理横竖屏和不同设备的布局
}

@end

