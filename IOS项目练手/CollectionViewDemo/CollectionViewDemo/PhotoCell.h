//
//  PhotoCell.h
//  CollectionViewDemo
//
//  自定义照片 Cell
//

#import <UIKit/UIKit.h>

@interface PhotoCell : UICollectionViewCell

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *titleLabel;

// 配置 Cell
- (void)configureWithTitle:(NSString *)title color:(UIColor *)color;

@end

