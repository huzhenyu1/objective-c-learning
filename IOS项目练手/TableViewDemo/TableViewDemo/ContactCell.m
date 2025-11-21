//
//  ContactCell.m
//  TableViewDemo
//
//  自定义联系人 Cell - 演示自定义 Cell 布局
//

#import "ContactCell.h"

@implementation ContactCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // 创建头像
    self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 60, 60)];
    self.avatarImageView.layer.cornerRadius = 30;
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.backgroundColor = [UIColor systemGray5Color];
    self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.avatarImageView];

    // 创建姓名标签
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 15, 200, 25)];
    self.nameLabel.font = [UIFont boldSystemFontOfSize:18];
    self.nameLabel.textColor = [UIColor labelColor];
    [self.contentView addSubview:self.nameLabel];

    // 创建电话标签
    self.phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 45, 200, 18)];
    self.phoneLabel.font = [UIFont systemFontOfSize:15];
    self.phoneLabel.textColor = [UIColor secondaryLabelColor];
    [self.contentView addSubview:self.phoneLabel];

    // 创建公司标签
    self.companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 15, 150, 18)];
    self.companyLabel.font = [UIFont systemFontOfSize:14];
    self.companyLabel.textColor = [UIColor systemBlueColor];
    self.companyLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.companyLabel];

    // 添加右侧箭头
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

// 配置 Cell 数据
- (void)configureWithName:(NSString *)name phone:(NSString *)phone company:(NSString *)company {
    self.nameLabel.text = name;
    self.phoneLabel.text = phone;
    self.companyLabel.text = company;

    // 根据姓名生成头像背景色（模拟头像）
    NSUInteger hash = [name hash];
    NSArray *colors = @[
        [UIColor systemBlueColor],
        [UIColor systemGreenColor],
        [UIColor systemOrangeColor],
        [UIColor systemPurpleColor],
        [UIColor systemPinkColor],
        [UIColor systemTealColor]
    ];
    self.avatarImageView.backgroundColor = colors[hash % colors.count];

    // 添加姓名首字母到头像
    UILabel *initialLabel = [[UILabel alloc] initWithFrame:self.avatarImageView.bounds];
    initialLabel.text = [name substringToIndex:1];
    initialLabel.font = [UIFont boldSystemFontOfSize:24];
    initialLabel.textColor = [UIColor whiteColor];
    initialLabel.textAlignment = NSTextAlignmentCenter;
    initialLabel.tag = 999;  // 用于移除旧的标签

    // 移除旧的首字母标签
    UIView *oldLabel = [self.avatarImageView viewWithTag:999];
    [oldLabel removeFromSuperview];

    [self.avatarImageView addSubview:initialLabel];
}

@end

