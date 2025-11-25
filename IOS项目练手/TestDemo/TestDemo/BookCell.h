//
//  BookCell.h
//  TestDemo
//
//  自定义书籍 Cell（用于演示自动高度）
//

#import <UIKit/UIKit.h>

#define CELL_HEIGHT 44

@interface BookCell : UITableViewCell

@property (strong, nonatomic) UILabel *titleLabel;
@property (copy, nonatomic) NSString *bookTitle;

@end

