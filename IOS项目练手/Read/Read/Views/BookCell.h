//
//  BookCell.h
//  Read
//
//  书籍列表 Cell
//

#import <UIKit/UIKit.h>
#import "BookModel.h"

@interface BookCell : UITableViewCell

@property (strong, nonatomic) UIImageView *coverImageView;  // 封面
@property (strong, nonatomic) UILabel *titleLabel;          // 书名
@property (strong, nonatomic) UILabel *authorLabel;         // 作者
@property (strong, nonatomic) UILabel *chapterLabel;        // 章节信息
@property (strong, nonatomic) UILabel *statusLabel;         // 状态标签
@property (strong, nonatomic) UILabel *badgeLabel;          // 角标（未读数量）

// 配置 Cell
- (void)configureWithBook:(BookModel *)book;

@end

