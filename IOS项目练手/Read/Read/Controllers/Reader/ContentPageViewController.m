//
//  ContentPageViewController.m
//  Read
//
//  内容页面视图控制器实现
//

#import "ContentPageViewController.h"
#import "ReadingPaginationService.h"  // 引入PageModel
#import "AppConfig.h"

@implementation ContentPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    [self setupUI];
}

- (void)setupUI {
    // ⭐ 章节标题（只在横向模式显示，竖向模式使用浮动标题）
    CGFloat scrollY = AppConfig.readingTopMargin;  // 使用统一配置

    // 只在横向模式（scrollEnabled = NO）时显示固定标题
    if (!self.scrollEnabled) {
        self.chapterTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(AppConfig.readingPadding,
                                                                           AppConfig.readingTopMargin,
                                                                           self.view.bounds.size.width - 2 * AppConfig.readingPadding,
                                                                           30)];
        self.chapterTitleLabel.font = [UIFont boldSystemFontOfSize:18];
        self.chapterTitleLabel.textColor = [UIColor labelColor];
        self.chapterTitleLabel.textAlignment = NSTextAlignmentCenter;

        if (self.pageModel) {
            self.chapterTitleLabel.text = self.pageModel.chapter.chapterName;
        } else if (self.chapter) {
            self.chapterTitleLabel.text = self.chapter.chapterName;
        }

        [self.view addSubview:self.chapterTitleLabel];
        scrollY = 50;  // 标题占用高度
    }

    // 滚动视图
    CGFloat bottomSpace = (!self.scrollEnabled && self.pageModel) ? 30 : AppConfig.readingBottomMargin;
    CGFloat scrollHeight = self.view.bounds.size.height - scrollY - bottomSpace;

    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, scrollY, self.view.bounds.size.width, scrollHeight)];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.scrollEnabled = self.scrollEnabled;  // 根据模式控制是否可滚动
    [self.view addSubview:self.scrollView];

    // 文本视图
    self.contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(AppConfig.readingPadding,
                                                                        AppConfig.readingTopMargin,
                                                                        self.view.bounds.size.width - 2 * AppConfig.readingPadding,
                                                                        100)];
    self.contentTextView.font = [UIFont systemFontOfSize:AppConfig.defaultFontSize];
    self.contentTextView.textColor = [UIColor labelColor];
    self.contentTextView.backgroundColor = [UIColor clearColor];
    self.contentTextView.editable = NO;  // 不可编辑
    self.contentTextView.selectable = YES;  // 可选择文本
    self.contentTextView.scrollEnabled = NO;  // 禁止内部滚动，由外层 ScrollView 控制
    self.contentTextView.textContainerInset = UIEdgeInsetsZero;  // 去除内边距
    self.contentTextView.textContainer.lineFragmentPadding = 0;  // 去除行间距
    [self.scrollView addSubview:self.contentTextView];

    self.currentContentHeight = 0;  // 初始化高度

    // 页码标签（横向模式显示）
    if (!self.scrollEnabled && self.pageModel) {
        self.pageInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                       self.view.bounds.size.height - 30,
                                                                       self.view.bounds.size.width,
                                                                       30)];
        self.pageInfoLabel.font = [UIFont systemFontOfSize:14];
        self.pageInfoLabel.textColor = [UIColor secondaryLabelColor];
        self.pageInfoLabel.textAlignment = NSTextAlignmentCenter;
        self.pageInfoLabel.text = [NSString stringWithFormat:@"%ld / %ld",
                                   (long)(self.pageModel.pageIndex + 1),
                                   (long)self.pageModel.totalPages];
        [self.view addSubview:self.pageInfoLabel];
    }

    // 加载指示器
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.loadingIndicator.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
    self.loadingIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                             UIViewAutoresizingFlexibleRightMargin |
                                             UIViewAutoresizingFlexibleTopMargin |
                                             UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.loadingIndicator];

    // 如果有内容就显示
    if (self.pageModel) {
        [self displayContent:self.pageModel.pageContent];
    } else if (self.content) {
        [self displayContent:self.content];
    }
}

- (void)displayContent:(NSString *)content {
    self.content = content;

    if (!self.contentTextView) {
        return;
    }

    // ⭐ 不再替换换行符，保持原文格式
    self.contentTextView.text = content;

    if (self.scrollEnabled) {
        // 竖向模式：允许滚动，使用 UITextView 的自动布局（性能更好）
        CGFloat width = self.view.bounds.size.width - 2 * AppConfig.readingPadding;
        CGSize size = [self.contentTextView sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];

        self.contentTextView.frame = CGRectMake(AppConfig.readingPadding,
                                                AppConfig.readingTopMargin,
                                                width,
                                                size.height);
        self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width,
                                                 size.height + 2 * AppConfig.readingTopMargin);
        self.currentContentHeight = size.height;  // 缓存高度
    } else {
        // 横向模式：禁止滚动，内容限制在一个页面内
        CGFloat maxHeight = self.scrollView.bounds.size.height - 2 * AppConfig.readingTopMargin;
        self.contentTextView.frame = CGRectMake(AppConfig.readingPadding,
                                                AppConfig.readingTopMargin,
                                                self.view.bounds.size.width - 2 * AppConfig.readingPadding,
                                                maxHeight);
        self.scrollView.contentSize = self.scrollView.bounds.size;  // contentSize 等于 scrollView 大小，不可滚动
    }

    // 滚动到顶部
    [self.scrollView setContentOffset:CGPointZero animated:NO];
}

- (void)showLoading {
    [self.loadingIndicator startAnimating];
    self.contentTextView.hidden = YES;
}

- (void)hideLoading {
    [self.loadingIndicator stopAnimating];
    self.contentTextView.hidden = NO;
}

@end

