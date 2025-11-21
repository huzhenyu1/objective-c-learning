//
//  HorizontalCollectionViewController.m
//  CollectionViewDemo
//
//  横向滚动 - 演示横向滚动的 CollectionView
//

#import "HorizontalCollectionViewController.h"
#import "PhotoCell.h"

@interface HorizontalCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *dataArray;
@property (strong, nonatomic) NSArray *colorArray;
@end

@implementation HorizontalCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"横向滚动";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    // 准备数据
    self.dataArray = @[
        @"推荐 1", @"推荐 2", @"推荐 3", @"推荐 4", @"推荐 5",
        @"推荐 6", @"推荐 7", @"推荐 8", @"推荐 9", @"推荐 10"
    ];

    self.colorArray = @[
        [UIColor systemRedColor], [UIColor systemOrangeColor], [UIColor systemYellowColor],
        [UIColor systemGreenColor], [UIColor systemTealColor], [UIColor systemBlueColor],
        [UIColor systemIndigoColor], [UIColor systemPurpleColor], [UIColor systemPinkColor],
        [UIColor systemRedColor]
    ];

    [self setupCollectionView];
}

- (void)setupCollectionView {
    // 创建布局（横向滚动）
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];

    // 设置为横向滚动
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    // 设置 item 大小（宽高比例类似 App Store）
    CGFloat itemWidth = self.view.bounds.size.width * 0.7;  // 占屏幕宽度的 70%
    CGFloat itemHeight = itemWidth * 1.2;  // 高度是宽度的 1.2 倍
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);

    // 设置间距
    layout.minimumLineSpacing = 20;  // item 之间的间距
    layout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);

    // 创建 CollectionView
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, itemHeight + 40) collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;  // 隐藏水平滚动条

    // 注册 Cell
    [self.collectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:@"PhotoCell"];

    [self.view addSubview:self.collectionView];

    // 添加说明文字
    [self addDescriptionLabel];
}

- (void)addDescriptionLabel {
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, self.collectionView.frame.origin.y + self.collectionView.frame.size.height + 30, self.view.bounds.size.width - 40, 120)];
    descLabel.numberOfLines = 0;
    descLabel.font = [UIFont systemFontOfSize:16];
    descLabel.textColor = [UIColor secondaryLabelColor];
    descLabel.text = @"💡 横向滚动的 CollectionView\n\n• 设置 scrollDirection = Horizontal\n• item 宽度为屏幕 70%\n• 类似 App Store 的横向卡片效果\n• 可以无限滚动";
    [self.view addSubview:descLabel];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];

    // 配置 Cell
    NSString *title = self.dataArray[indexPath.item];
    UIColor *color = self.colorArray[indexPath.item % self.colorArray.count];
    [cell configureWithTitle:title color:color];

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.dataArray[indexPath.item];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择了"
                                                                   message:title
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];

    NSLog(@"点击了: %@", title);
}

#pragma mark - UICollectionViewDelegateFlowLayout

// 高亮效果
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = (PhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.2 animations:^{
        cell.transform = CGAffineTransformMakeScale(0.95, 0.95);
    }];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = (PhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.2 animations:^{
        cell.transform = CGAffineTransformIdentity;
    }];
}

// 滚动时的缩放效果（可选，类似 App Store）
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat centerX = scrollView.contentOffset.x + scrollView.bounds.size.width / 2;

    for (PhotoCell *cell in self.collectionView.visibleCells) {
        CGFloat cellCenterX = cell.center.x;
        CGFloat distance = fabs(centerX - cellCenterX);
        CGFloat maxDistance = scrollView.bounds.size.width;
        CGFloat scale = 1.0 - (distance / maxDistance) * 0.2;  // 最多缩小到 0.8

        cell.transform = CGAffineTransformMakeScale(scale, scale);
    }
}

@end

