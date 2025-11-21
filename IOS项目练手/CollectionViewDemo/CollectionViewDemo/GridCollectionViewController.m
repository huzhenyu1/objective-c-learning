//
//  GridCollectionViewController.m
//  CollectionViewDemo
//
//  网格布局 - 演示基础的 CollectionView 使用
//

#import "GridCollectionViewController.h"
#import "PhotoCell.h"

@interface GridCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *dataArray;
@property (strong, nonatomic) NSArray *colorArray;
@end

@implementation GridCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"网格布局";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    // 准备数据
    self.dataArray = @[
        @"照片 1", @"照片 2", @"照片 3", @"照片 4", @"照片 5", @"照片 6",
        @"照片 7", @"照片 8", @"照片 9", @"照片 10", @"照片 11", @"照片 12",
        @"照片 13", @"照片 14", @"照片 15", @"照片 16", @"照片 17", @"照片 18",
        @"照片 19", @"照片 20", @"照片 21", @"照片 22", @"照片 23", @"照片 24"
    ];

    self.colorArray = @[
        [UIColor systemRedColor], [UIColor systemOrangeColor], [UIColor systemYellowColor],
        [UIColor systemGreenColor], [UIColor systemTealColor], [UIColor systemBlueColor],
        [UIColor systemIndigoColor], [UIColor systemPurpleColor], [UIColor systemPinkColor],
        [UIColor systemRedColor], [UIColor systemOrangeColor], [UIColor systemYellowColor],
        [UIColor systemGreenColor], [UIColor systemTealColor], [UIColor systemBlueColor],
        [UIColor systemIndigoColor], [UIColor systemPurpleColor], [UIColor systemPinkColor],
        [UIColor systemRedColor], [UIColor systemOrangeColor], [UIColor systemYellowColor],
        [UIColor systemGreenColor], [UIColor systemTealColor], [UIColor systemBlueColor]
    ];

    [self setupCollectionView];
}

- (void)setupCollectionView {
    // 创建布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];

    // 设置 item 大小
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat padding = 10;
    CGFloat itemSpacing = 10;
    CGFloat itemWidth = (screenWidth - 2 * padding - 2 * itemSpacing) / 3;  // 3列
    layout.itemSize = CGSizeMake(itemWidth, itemWidth);

    // 设置间距
    layout.minimumInteritemSpacing = itemSpacing;  // item 之间的间距
    layout.minimumLineSpacing = itemSpacing;       // 行之间的间距
    layout.sectionInset = UIEdgeInsetsMake(padding, padding, padding, padding);  // section 边距

    // 创建 CollectionView
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor systemBackgroundColor];

    // 注册 Cell
    [self.collectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:@"PhotoCell"];

    [self.view addSubview:self.collectionView];
}

#pragma mark - UICollectionViewDataSource

// 有多少个 item
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

// 每个 item 显示什么
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];

    // 配置 Cell
    NSString *title = self.dataArray[indexPath.item];
    UIColor *color = self.colorArray[indexPath.item % self.colorArray.count];
    [cell configureWithTitle:title color:color];

    return cell;
}

#pragma mark - UICollectionViewDelegate

// 点击 item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.dataArray[indexPath.item];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择了"
                                                                   message:title
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];

    NSLog(@"点击了 item %ld: %@", (long)indexPath.item, title);
}

#pragma mark - UICollectionViewDelegateFlowLayout

// 可选：动态设置 item 大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat padding = 10;
    CGFloat itemSpacing = 10;
    CGFloat itemWidth = (screenWidth - 2 * padding - 2 * itemSpacing) / 3;
    return CGSizeMake(itemWidth, itemWidth);
}

// 高亮状态
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = (PhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.1 animations:^{
        cell.transform = CGAffineTransformMakeScale(0.95, 0.95);
    }];
}

// 取消高亮
- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = (PhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.1 animations:^{
        cell.transform = CGAffineTransformIdentity;
    }];
}

@end

