//
//  WaterfallLayout.h
//  CollectionViewDemo
//
//  自定义瀑布流布局
//

#import <UIKit/UIKit.h>

@protocol WaterfallLayoutDelegate <NSObject>
@required
// 询问每个 item 的高度
- (CGFloat)waterfallLayout:(UICollectionViewLayout *)layout heightForItemAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface WaterfallLayout : UICollectionViewLayout

@property (weak, nonatomic) id<WaterfallLayoutDelegate> delegate;
@property (assign, nonatomic) NSInteger numberOfColumns;  // 列数，默认 2
@property (assign, nonatomic) CGFloat columnSpacing;      // 列间距，默认 10
@property (assign, nonatomic) CGFloat lineSpacing;        // 行间距，默认 10
@property (assign, nonatomic) UIEdgeInsets sectionInset;  // 边距

@end

