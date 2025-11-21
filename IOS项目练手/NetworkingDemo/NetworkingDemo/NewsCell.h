//
//  NewsCell.h
//  NetworkingDemo
//
//  新闻列表 Cell
//

#import <UIKit/UIKit.h>
#import "NewsModel.h"

@interface NewsCell : UITableViewCell

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *authorLabel;
@property (strong, nonatomic) UILabel *timeLabel;

// 配置 Cell
- (void)configureWithNews:(NewsModel *)news;

@end

