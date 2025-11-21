//
//  WaterfallLayout.m
//  CollectionViewDemo
//
//  自定义瀑布流布局 - 实现不等高网格布局
//

#import "WaterfallLayout.h"

@interface WaterfallLayout ()
@property (strong, nonatomic) NSMutableArray *layoutAttributes;  // 所有 item 的布局属性
@property (strong, nonatomic) NSMutableArray *columnHeights;     // 每列的高度
@property (assign, nonatomic) CGFloat contentHeight;             // 内容总高度
@end

@implementation WaterfallLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        _numberOfColumns = 2;
        _columnSpacing = 10;
        _lineSpacing = 10;
        _sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    }
    return self;
}

// 准备布局（计算所有 item 的位置）
- (void)prepareLayout {
    [super prepareLayout];

    // 重置数据
    self.layoutAttributes = [NSMutableArray array];
    self.columnHeights = [NSMutableArray array];
    self.contentHeight = 0;

    // 初始化每列的高度
    for (int i = 0; i < self.numberOfColumns; i++) {
        [self.columnHeights addObject:@(self.sectionInset.top)];
    }

    // 计算每个 item 的布局
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    CGFloat collectionViewWidth = self.collectionView.bounds.size.width;
    CGFloat contentWidth = collectionViewWidth - self.sectionInset.left - self.sectionInset.right;
    CGFloat itemWidth = (contentWidth - (self.numberOfColumns - 1) * self.columnSpacing) / self.numberOfColumns;

    for (NSInteger i = 0; i < itemCount; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];

        // 找到最短的列
        NSInteger shortestColumn = 0;
        CGFloat minHeight = [self.columnHeights[0] floatValue];
        for (NSInteger j = 1; j < self.numberOfColumns; j++) {
            CGFloat height = [self.columnHeights[j] floatValue];
            if (height < minHeight) {
                minHeight = height;
                shortestColumn = j;
            }
        }

        // 计算 item 的位置
        CGFloat x = self.sectionInset.left + shortestColumn * (itemWidth + self.columnSpacing);
        CGFloat y = minHeight;

        // 获取 item 的高度
        CGFloat itemHeight = 100;  // 默认高度
        if ([self.delegate respondsToSelector:@selector(waterfallLayout:heightForItemAtIndexPath:)]) {
            itemHeight = [self.delegate waterfallLayout:self heightForItemAtIndexPath:indexPath];
        }

        // 创建布局属性
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.frame = CGRectMake(x, y, itemWidth, itemHeight);
        [self.layoutAttributes addObject:attributes];

        // 更新该列的高度
        self.columnHeights[shortestColumn] = @(y + itemHeight + self.lineSpacing);
    }

    // 计算内容总高度（找到最高的列）
    CGFloat maxHeight = [self.columnHeights[0] floatValue];
    for (NSInteger i = 1; i < self.numberOfColumns; i++) {
        CGFloat height = [self.columnHeights[i] floatValue];
        if (height > maxHeight) {
            maxHeight = height;
        }
    }
    self.contentHeight = maxHeight - self.lineSpacing + self.sectionInset.bottom;
}

// 返回内容大小
- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.collectionView.bounds.size.width, self.contentHeight);
}

// 返回指定区域内的所有布局属性
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *attributes = [NSMutableArray array];
    for (UICollectionViewLayoutAttributes *attr in self.layoutAttributes) {
        if (CGRectIntersectsRect(attr.frame, rect)) {
            [attributes addObject:attr];
        }
    }
    return attributes;
}

// 返回指定 indexPath 的布局属性
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item < self.layoutAttributes.count) {
        return self.layoutAttributes[indexPath.item];
    }
    return nil;
}

// 当 CollectionView 的 bounds 改变时，是否需要重新布局
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return NO;
}

@end

