//
//  WaterfallCollectionViewController.m
//  CollectionViewDemo
//
//  瀑布流布局 - 演示不等高网格布局
//

#import "WaterfallCollectionViewController.h"
#import "WaterfallLayout.h"
#import "PhotoCell.h"

@interface WaterfallCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, WaterfallLayoutDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *dataArray;
@property (strong, nonatomic) NSArray *colorArray;
@property (strong, nonatomic) NSArray *heightArray;  // 存储每个 item 的高度
@end

@implementation WaterfallCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"瀑布流布局";
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

    // 生成随机高度（模拟不同高度的图片）
    NSMutableArray *heights = [NSMutableArray array];
    for (int i = 0; i < self.dataArray.count; i++) {
        CGFloat randomHeight = 100 + arc4random_uniform(150);  // 100-250 之间的随机高度
        [heights addObject:@(randomHeight)];
    }
    self.heightArray = [heights copy];

    [self setupCollectionView];
}

- (void)setupCollectionView {
    // 创建自定义瀑布流布局
    WaterfallLayout *layout = [[WaterfallLayout alloc] init];
    layout.delegate = self;
    layout.numberOfColumns = 2;  // 2列
    layout.columnSpacing = 10;
    layout.lineSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);

    // 创建 CollectionView
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor systemBackgroundColor];

    // 注册 Cell
    [self.collectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:@"PhotoCell"];

    [self.view addSubview:self.collectionView];
}

#pragma mark - WaterfallLayoutDelegate

// 返回每个 item 的高度
- (CGFloat)waterfallLayout:(UICollectionViewLayout *)layout heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.heightArray[indexPath.item] floatValue];
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
    CGFloat height = [self.heightArray[indexPath.item] floatValue];

    NSString *message = [NSString stringWithFormat:@"%@\n高度: %.0f", title, height];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"照片信息"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end

