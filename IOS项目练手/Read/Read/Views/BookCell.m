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
    // 背景色设置为白色
    self.backgroundColor = [UIColor whiteColor];
    self.contentView.backgroundColor = [UIColor whiteColor];

    // ⭐ 封面图片（左侧）- 缩小高度
    self.coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 85, 115)];
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverImageView.clipsToBounds = YES;
    self.coverImageView.layer.cornerRadius = 4;  // 小圆角
    self.coverImageView.backgroundColor = [UIColor systemGray5Color];
    [self.contentView addSubview:self.coverImageView];

    // ⭐ 书名（右上）- 加粗，最多显示1行
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 15, 200, 22)];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.titleLabel];

    // ⭐ 作者信息（书名下方）
    self.authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 42, 200, 18)];
    self.authorLabel.font = [UIFont systemFontOfSize:13];
    self.authorLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:self.authorLabel];

    // ⭐ 当前章节信息（完整章节名）
    self.chapterLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 65, 200, 18)];
    self.chapterLabel.font = [UIFont systemFontOfSize:12];
    self.chapterLabel.textColor = [UIColor grayColor];
    self.chapterLabel.numberOfLines = 1;
    [self.contentView addSubview:self.chapterLabel];

    // ⭐ 最新章节信息（完整章节名）
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 88, 200, 18)];
    self.statusLabel.font = [UIFont systemFontOfSize:12];
    self.statusLabel.textColor = [UIColor grayColor];
    self.statusLabel.numberOfLines = 1;
    [self.contentView addSubview:self.statusLabel];

    // 角标（右上角，显示未读数量）- 圆形红底白字
    self.badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(320, 20, 50, 24)];
    self.badgeLabel.font = [UIFont boldSystemFontOfSize:13];
    self.badgeLabel.textAlignment = NSTextAlignmentCenter;
    self.badgeLabel.textColor = [UIColor whiteColor];
    self.badgeLabel.backgroundColor = [UIColor systemRedColor];
    self.badgeLabel.layer.cornerRadius = 12;
    self.badgeLabel.clipsToBounds = YES;
    [self.contentView addSubview:self.badgeLabel];

    // ⭐ 添加底部分隔线（调整位置）
    UIView *separatorLine = [[UIView alloc] initWithFrame:CGRectMake(15, 134, [UIScreen mainScreen].bounds.size.width - 15, 0.5)];
    separatorLine.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.2];
    separatorLine.tag = 888;  // 标记以便后续更新
    [self.contentView addSubview:separatorLine];
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

    // ⭐ 更新布局（适配不同屏幕，调整后的位置）
    CGFloat screenWidth = self.contentView.bounds.size.width;
    self.titleLabel.frame = CGRectMake(110, 15, screenWidth - 180, 22);
    self.authorLabel.frame = CGRectMake(110, 42, screenWidth - 180, 18);
    self.chapterLabel.frame = CGRectMake(110, 65, screenWidth - 180, 18);
    self.statusLabel.frame = CGRectMake(110, 88, screenWidth - 180, 18);
    self.badgeLabel.frame = CGRectMake(screenWidth - 70, 15, 50, 24);

    // ⭐ 更新分隔线宽度和位置
    UIView *separatorLine = [self.contentView viewWithTag:888];
    if (separatorLine) {
        separatorLine.frame = CGRectMake(15, 134, screenWidth - 15, 0.5);
    }
}

@end

