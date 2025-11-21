//
//  ImageLoadViewController.m
//  NetworkingDemo
//
//  图片加载示例 - 演示异步加载网络图片
//

#import "ImageLoadViewController.h"

@interface ImageLoadViewController ()
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIActivityIndicatorView *loadingIndicator;
@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) NSCache *imageCache;  // 图片缓存
@end

@implementation ImageLoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"图片加载";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    // 初始化缓存
    self.imageCache = [[NSCache alloc] init];
    self.imageCache.countLimit = 10;  // 最多缓存 10 张图片

    [self setupUI];
}

- (void)setupUI {
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat yOffset = 100;

    // 图片显示区域
    CGFloat imageSize = screenWidth - 40;
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, yOffset, imageSize, imageSize)];
    self.imageView.backgroundColor = [UIColor secondarySystemBackgroundColor];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.cornerRadius = 10;
    [self.view addSubview:self.imageView];
    yOffset += imageSize + 20;

    // 加载指示器
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.loadingIndicator.center = self.imageView.center;
    self.loadingIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.loadingIndicator];

    // 状态标签
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, yOffset, screenWidth - 40, 30)];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.font = [UIFont systemFontOfSize:14];
    self.statusLabel.textColor = [UIColor secondaryLabelColor];
    self.statusLabel.text = @"点击下方按钮加载图片";
    [self.view addSubview:self.statusLabel];
    yOffset += 40;

    // 按钮容器
    NSArray *buttonTitles = @[@"加载图片 1", @"加载图片 2", @"加载图片 3", @"清除缓存"];
    NSArray *buttonColors = @[
        [UIColor systemBlueColor],
        [UIColor systemGreenColor],
        [UIColor systemOrangeColor],
        [UIColor systemRedColor]
    ];

    for (NSInteger i = 0; i < buttonTitles.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(20, yOffset, screenWidth - 40, 50);
        [button setTitle:buttonTitles[i] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.backgroundColor = buttonColors[i];
        button.layer.cornerRadius = 10;
        button.tag = i;
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        yOffset += 60;
    }
}

- (void)buttonTapped:(UIButton *)sender {
    if (sender.tag == 3) {
        // 清除缓存
        [self.imageCache removeAllObjects];
        self.imageView.image = nil;
        self.statusLabel.text = @"缓存已清除";
        NSLog(@"图片缓存已清除");
        return;
    }

    // 图片 URL 列表
    NSArray *imageURLs = @[
        @"https://picsum.photos/400/400?random=1",
        @"https://picsum.photos/400/400?random=2",
        @"https://picsum.photos/400/400?random=3"
    ];

    NSString *urlString = imageURLs[sender.tag];
    [self loadImageFromURL:urlString];
}

- (void)loadImageFromURL:(NSString *)urlString {
    // 检查缓存
    UIImage *cachedImage = [self.imageCache objectForKey:urlString];
    if (cachedImage) {
        self.imageView.image = cachedImage;
        self.statusLabel.text = @"✅ 从缓存加载";
        NSLog(@"从缓存加载图片：%@", urlString);
        return;
    }

    // 显示加载状态
    [self.loadingIndicator startAnimating];
    self.statusLabel.text = @"正在加载...";
    self.imageView.image = nil;

    NSURL *url = [NSURL URLWithString:urlString];

    // 创建 URLSession
    NSURLSession *session = [NSURLSession sharedSession];

    // 创建 downloadTask（也可以用 dataTask）
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.loadingIndicator stopAnimating];
                self.statusLabel.text = @"❌ 加载失败";
                NSLog(@"图片加载失败：%@", error);
            });
            return;
        }

        // 读取下载的图片
        NSData *imageData = [NSData dataWithContentsOfURL:location];
        UIImage *image = [UIImage imageWithData:imageData];

        if (image) {
            // 缓存图片
            [self.imageCache setObject:image forKey:urlString];

            // 回到主线程更新 UI
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.loadingIndicator stopAnimating];
                self.imageView.image = image;
                self.statusLabel.text = [NSString stringWithFormat:@"✅ 加载成功（%ld KB）", (long)(imageData.length / 1024)];

                // 添加淡入动画
                self.imageView.alpha = 0;
                [UIView animateWithDuration:0.3 animations:^{
                    self.imageView.alpha = 1.0;
                }];

                NSLog(@"图片加载成功：%@，大小：%ld KB", urlString, (long)(imageData.length / 1024));
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.loadingIndicator stopAnimating];
                self.statusLabel.text = @"❌ 图片解析失败";
            });
        }
    }];

    // 启动下载任务
    [downloadTask resume];

    NSLog(@"开始加载图片：%@", urlString);
}

@end

