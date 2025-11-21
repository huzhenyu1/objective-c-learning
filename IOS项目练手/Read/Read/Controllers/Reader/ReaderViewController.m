//
//  ReaderViewController.m
//  Read
//
//  阅读页面实现
//

#import "ReaderViewController.h"
#import "BookContentService.h"
#import "BookshelfManager.h"

@interface ReaderViewController ()
@property (strong, nonatomic) BookModel *book;
@property (strong, nonatomic) ChapterModel *currentChapter;
@property (strong, nonatomic) NSArray<ChapterModel *> *chapters;
@property (strong, nonatomic) BookSource *bookSource;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UILabel *contentLabel;
@property (strong, nonatomic) UIActivityIndicatorView *loadingIndicator;
@property (strong, nonatomic) UIButton *prevButton;
@property (strong, nonatomic) UIButton *nextButton;
@property (strong, nonatomic) UILabel *chapterTitleLabel;
@end

@implementation ReaderViewController

- (instancetype)initWithBook:(BookModel *)book
                     chapter:(ChapterModel *)chapter
                    chapters:(NSArray<ChapterModel *> *)chapters
                  bookSource:(BookSource *)bookSource {
    self = [super init];
    if (self) {
        _book = book;
        _currentChapter = chapter;
        _chapters = chapters;
        _bookSource = bookSource;
        // 隐藏底部 TabBar
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // 直接使用章节名作为标题
    self.title = self.currentChapter.chapterName;
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupUI];
    [self loadChapterContent];
}

- (void)setupUI {
    // 滚动视图（不再需要单独的章节标题 Label）
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat topOffset = statusBarHeight + navBarHeight;

    CGFloat scrollHeight = self.view.bounds.size.height - topOffset - 60; // 底部留60给按钮

    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, topOffset, self.view.bounds.size.width, scrollHeight)];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.scrollView];

    // 内容标签
    self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, self.view.bounds.size.width - 30, 100)];
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.font = [UIFont systemFontOfSize:17];
    self.contentLabel.textColor = [UIColor labelColor];
    [self.scrollView addSubview:self.contentLabel];

    // Loading 指示器
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.loadingIndicator.center = self.view.center;
    [self.view addSubview:self.loadingIndicator];

    // 底部导航按钮
    CGFloat buttonY = self.view.bounds.size.height - 50;
    CGFloat buttonWidth = (self.view.bounds.size.width - 40) / 2;

    self.prevButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.prevButton.frame = CGRectMake(10, buttonY, buttonWidth, 40);
    [self.prevButton setTitle:@"上一章" forState:UIControlStateNormal];
    self.prevButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.prevButton addTarget:self action:@selector(loadPreviousChapter) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.prevButton];

    self.nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.nextButton.frame = CGRectMake(buttonWidth + 20, buttonY, buttonWidth, 40);
    [self.nextButton setTitle:@"下一章" forState:UIControlStateNormal];
    self.nextButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.nextButton addTarget:self action:@selector(loadNextChapter) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nextButton];

    [self updateNavigationButtons];
}

- (void)loadChapterContent {
    NSLog(@"📖 开始加载章节内容");
    NSLog(@"   章节: %@", self.currentChapter.chapterName);
    NSLog(@"   URL: %@", self.currentChapter.chapterUrl);
    NSLog(@"   书源: %@", self.bookSource.bookSourceName);

    [self.loadingIndicator startAnimating];
    self.contentLabel.text = @"";
    self.scrollView.scrollEnabled = NO;

    [[BookContentService sharedService] fetchChapterContent:self.currentChapter.chapterUrl
                                                 bookSource:self.bookSource
                                                    success:^(ChapterContent *content) {
        [self handleContentSuccess:content];
    } failure:^(NSError *error) {
        [self handleContentFailure:error];
    }];
}

- (void)handleContentSuccess:(ChapterContent *)content {
    [self.loadingIndicator stopAnimating];
    self.scrollView.scrollEnabled = YES;

    NSLog(@"✅ 章节内容加载成功");
    NSLog(@"   内容长度: %ld 字", (long)content.content.length);
    NSLog(@"   内容预览: %@", [content.content substringToIndex:MIN(100, content.content.length)]);

    // 更新当前章节进度并保存
    self.book.currentChapter = self.currentChapter.chapterIndex;
    [[BookshelfManager sharedManager] updateBook:self.book];
    NSLog(@"💾 已更新阅读进度: 第 %ld 章", (long)(self.currentChapter.chapterIndex + 1));

    // 处理正文内容（添加段落间距）
    NSString *formattedContent = [content.content stringByReplacingOccurrencesOfString:@"\n" withString:@"\n\n"];
    self.contentLabel.text = formattedContent;

    // 计算内容高度
    CGSize maxSize = CGSizeMake(self.view.bounds.size.width - 30, CGFLOAT_MAX);
    CGRect textRect = [formattedContent boundingRectWithSize:maxSize
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName: self.contentLabel.font}
                                                     context:nil];

    self.contentLabel.frame = CGRectMake(15, 10, self.view.bounds.size.width - 30, textRect.size.height + 20);
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, textRect.size.height + 40);

    // 滚动到顶部
    [self.scrollView setContentOffset:CGPointZero animated:NO];
}

- (void)handleContentFailure:(NSError *)error {
    [self.loadingIndicator stopAnimating];
    self.scrollView.scrollEnabled = YES;

    NSLog(@"❌ 章节内容加载失败: %@", error.localizedDescription);

    NSString *errorMessage = [NSString stringWithFormat:@"❌ 加载失败\n\n%@", error.localizedDescription];
    self.contentLabel.text = errorMessage;
    self.contentLabel.textColor = [UIColor secondaryLabelColor];
    self.contentLabel.textAlignment = NSTextAlignmentCenter;

    // 恢复默认样式（为下次加载准备）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.contentLabel.textAlignment = NSTextAlignmentLeft;
        self.contentLabel.textColor = [UIColor labelColor];
    });
}

- (void)updateNavigationButtons {
    // 更新按钮状态
    NSInteger currentIndex = self.currentChapter.chapterIndex;
    self.prevButton.enabled = (currentIndex > 0);
    self.nextButton.enabled = (currentIndex < self.chapters.count - 1);

    self.prevButton.alpha = self.prevButton.enabled ? 1.0 : 0.3;
    self.nextButton.alpha = self.nextButton.enabled ? 1.0 : 0.3;
}

#pragma mark - 导航

- (void)loadPreviousChapter {
    NSInteger currentIndex = self.currentChapter.chapterIndex;
    if (currentIndex > 0) {
        self.currentChapter = self.chapters[currentIndex - 1];
        // 更新导航栏标题
        self.title = self.currentChapter.chapterName;
        [self updateNavigationButtons];
        [self loadChapterContent];
    }
}

- (void)loadNextChapter {
    NSInteger currentIndex = self.currentChapter.chapterIndex;
    if (currentIndex < self.chapters.count - 1) {
        self.currentChapter = self.chapters[currentIndex + 1];
        // 更新导航栏标题
        self.title = self.currentChapter.chapterName;
        [self updateNavigationButtons];
        [self loadChapterContent];
    }
}

- (void)dealloc {
    // 返回时通知书架刷新
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BookReadProgressUpdated" object:nil];
}

@end

