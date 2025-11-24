//
//  ScrollViewViewController.m
//  CommonControlsDemo
//
//  UIScrollView 演示：滚动、缩放、分页
//

#import "ScrollViewViewController.h"

@interface ScrollViewViewController () <UIScrollViewDelegate>
@property (strong, nonatomic) UISegmentedControl *segmentControl;
@property (strong, nonatomic) UIScrollView *normalScrollView;
@property (strong, nonatomic) UIScrollView *zoomScrollView;
@property (strong, nonatomic) UIScrollView *pageScrollView;
@property (strong, nonatomic) UIImageView *zoomImageView;
@property (strong, nonatomic) UIPageControl *pageControl;
@end

@implementation ScrollViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"UIScrollView 演示";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupSegmentControl];
    [self setupNormalScrollView];
    [self setupZoomScrollView];
    [self setupPageScrollView];

    [self segmentChanged:self.segmentControl];
}

- (void)setupSegmentControl {
    self.segmentControl = [[UISegmentedControl alloc] initWithItems:@[@"普通滚动", @"缩放", @"分页"]];
    self.segmentControl.frame = CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width - 40, 32);
    self.segmentControl.selectedSegmentIndex = 0;
    [self.segmentControl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.segmentControl];
}

#pragma mark - 1. 普通滚动

- (void)setupNormalScrollView {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;

    self.normalScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 150, screenWidth, screenHeight - 150)];
    self.normalScrollView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.normalScrollView.showsVerticalScrollIndicator = YES;
    self.normalScrollView.showsHorizontalScrollIndicator = YES;

    // 添加大量内容（模拟长页面）
    CGFloat contentHeight = 0;
    for (int i = 0; i < 20; i++) {
        UIView *box = [[UIView alloc] initWithFrame:CGRectMake(20, contentHeight + 20, screenWidth - 40, 100)];
        box.backgroundColor = [self randomColor];
        box.layer.cornerRadius = 10;

        UILabel *label = [[UILabel alloc] initWithFrame:box.bounds];
        label.text = [NSString stringWithFormat:@"内容区域 %d", i + 1];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:20];
        label.textColor = [UIColor whiteColor];
        [box addSubview:label];

        [self.normalScrollView addSubview:box];
        contentHeight += 120;
    }

    // 设置 contentSize（重要！）
    self.normalScrollView.contentSize = CGSizeMake(screenWidth, contentHeight + 20);

    [self.view addSubview:self.normalScrollView];
}

#pragma mark - 2. 缩放功能

- (void)setupZoomScrollView {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;

    self.zoomScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 150, screenWidth, screenHeight - 150)];
    self.zoomScrollView.backgroundColor = [UIColor blackColor];
    self.zoomScrollView.delegate = self;
    self.zoomScrollView.minimumZoomScale = 1.0;  // 最小缩放比例
    self.zoomScrollView.maximumZoomScale = 3.0;  // 最大缩放比例
    self.zoomScrollView.showsVerticalScrollIndicator = NO;
    self.zoomScrollView.showsHorizontalScrollIndicator = NO;

    // 添加图片（用颜色块模拟）
    self.zoomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenWidth)];
    self.zoomImageView.backgroundColor = [UIColor systemBlueColor];
    self.zoomImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.zoomImageView.userInteractionEnabled = YES;

    // 添加文字说明
    UILabel *hintLabel = [[UILabel alloc] initWithFrame:self.zoomImageView.bounds];
    hintLabel.text = @"双指缩放\n双击放大/缩小";
    hintLabel.numberOfLines = 0;
    hintLabel.textAlignment = NSTextAlignmentCenter;
    hintLabel.font = [UIFont boldSystemFontOfSize:30];
    hintLabel.textColor = [UIColor whiteColor];
    [self.zoomImageView addSubview:hintLabel];

    [self.zoomScrollView addSubview:self.zoomImageView];

    // 双击手势
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.zoomScrollView addGestureRecognizer:doubleTap];

    [self.view addSubview:self.zoomScrollView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (scrollView == self.zoomScrollView) {
        return self.zoomImageView;
    }
    return nil;
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture {
    if (self.zoomScrollView.zoomScale > 1.0) {
        [self.zoomScrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint tapPoint = [gesture locationInView:self.zoomImageView];
        CGFloat newZoom = self.zoomScrollView.maximumZoomScale;
        CGFloat zoomWidth = self.zoomScrollView.frame.size.width / newZoom;
        CGFloat zoomHeight = self.zoomScrollView.frame.size.height / newZoom;
        CGRect zoomRect = CGRectMake(tapPoint.x - zoomWidth / 2, tapPoint.y - zoomHeight / 2, zoomWidth, zoomHeight);
        [self.zoomScrollView zoomToRect:zoomRect animated:YES];
    }
}

#pragma mark - 3. 分页滚动

- (void)setupPageScrollView {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;

    self.pageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 150, screenWidth, screenHeight - 200)];
    self.pageScrollView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.pageScrollView.pagingEnabled = YES;  // 开启分页
    self.pageScrollView.delegate = self;
    self.pageScrollView.showsHorizontalScrollIndicator = NO;

    // 添加 5 个页面
    NSInteger pageCount = 5;
    for (int i = 0; i < pageCount; i++) {
        UIView *page = [[UIView alloc] initWithFrame:CGRectMake(i * screenWidth, 0, screenWidth, self.pageScrollView.frame.size.height)];
        page.backgroundColor = [self randomColor];

        UILabel *label = [[UILabel alloc] initWithFrame:page.bounds];
        label.text = [NSString stringWithFormat:@"第 %d 页\n\n← 左右滑动 →", i + 1];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:30];
        label.textColor = [UIColor whiteColor];
        [page addSubview:label];

        [self.pageScrollView addSubview:page];
    }

    // 设置 contentSize
    self.pageScrollView.contentSize = CGSizeMake(screenWidth * pageCount, self.pageScrollView.frame.size.height);

    // UIPageControl（页面指示器）
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, screenHeight - 50, screenWidth, 30)];
    self.pageControl.numberOfPages = pageCount;
    self.pageControl.currentPage = 0;
    self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor systemBlueColor];
    [self.pageControl addTarget:self action:@selector(pageControlChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.pageControl];

    [self.view addSubview:self.pageScrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.pageScrollView) {
        CGFloat pageWidth = scrollView.frame.size.width;
        NSInteger page = (NSInteger)(scrollView.contentOffset.x / pageWidth + 0.5);
        self.pageControl.currentPage = page;
    }
}

- (void)pageControlChanged:(UIPageControl *)pageControl {
    CGFloat x = pageControl.currentPage * self.pageScrollView.frame.size.width;
    [self.pageScrollView setContentOffset:CGPointMake(x, 0) animated:YES];
}

#pragma mark - Actions

- (void)segmentChanged:(UISegmentedControl *)segment {
    self.normalScrollView.hidden = YES;
    self.zoomScrollView.hidden = YES;
    self.pageScrollView.hidden = YES;
    self.pageControl.hidden = YES;

    switch (segment.selectedSegmentIndex) {
        case 0:
            self.normalScrollView.hidden = NO;
            break;
        case 1:
            self.zoomScrollView.hidden = NO;
            self.zoomScrollView.zoomScale = 1.0;  // 重置缩放
            break;
        case 2:
            self.pageScrollView.hidden = NO;
            self.pageControl.hidden = NO;
            break;
    }
}

- (UIColor *)randomColor {
    NSArray *colors = @[
        [UIColor systemRedColor],
        [UIColor systemGreenColor],
        [UIColor systemBlueColor],
        [UIColor systemOrangeColor],
        [UIColor systemPurpleColor],
        [UIColor systemTealColor],
        [UIColor systemIndigoColor]
    ];
    return colors[arc4random_uniform((uint32_t)colors.count)];
}

@end

