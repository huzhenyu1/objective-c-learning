//
//  ContactCell.h
//  TableViewDemo
//
//  自定义联系人 Cell
//

#import <UIKit/UIKit.h>

@interface ContactCell : UITableViewCell

@property (strong, nonatomic) UIImageView *avatarImageView;  // 头像
@property (strong, nonatomic) UILabel *nameLabel;            // 姓名
@property (strong, nonatomic) UILabel *phoneLabel;           // 电话
@property (strong, nonatomic) UILabel *companyLabel;         // 公司

// 配置 Cell 的便捷方法
- (void)configureWithName:(NSString *)name phone:(NSString *)phone company:(NSString *)company;

@end

