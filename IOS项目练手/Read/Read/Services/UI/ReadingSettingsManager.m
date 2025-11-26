//
//  ReadingSettingsManager.m
//  Read
//
//  阅读设置管理器实现
//

#import "ReadingSettingsManager.h"

// 通知名称
NSString * const ReadingSettingsDidChangeNotification = @"ReadingSettingsDidChangeNotification";

// UserDefaults 存储键
static NSString * const kReadingFontSizeKey = @"ReadingFontSize";
static NSString * const kReadingThemeKey = @"ReadingTheme";
static NSString * const kReadingNightModeKey = @"ReadingNightMode";

// 字体大小常量
static const CGFloat kMinFontSize = 12.0;
static const CGFloat kMaxFontSize = 30.0;
static const CGFloat kDefaultFontSize = 17.0;

@implementation ReadingSettingsManager

#pragma mark - 单例

+ (instancetype)sharedManager {
    static ReadingSettingsManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ReadingSettingsManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 加载保存的设置
        [self loadSettings];
    }
    return self;
}

#pragma mark - 字体大小常量

+ (CGFloat)minFontSize {
    return kMinFontSize;
}

+ (CGFloat)maxFontSize {
    return kMaxFontSize;
}

+ (CGFloat)defaultFontSize {
    return kDefaultFontSize;
}

#pragma mark - 设置加载与保存

- (void)loadSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // 字体大小
    CGFloat savedFontSize = [defaults floatForKey:kReadingFontSizeKey];
    _fontSize = (savedFontSize > 0) ? savedFontSize : kDefaultFontSize;

    // 主题
    _theme = [defaults integerForKey:kReadingThemeKey];

    // 夜间模式
    _nightModeEnabled = [defaults boolForKey:kReadingNightModeKey];
}

- (void)saveSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setFloat:self.fontSize forKey:kReadingFontSizeKey];
    [defaults setInteger:self.theme forKey:kReadingThemeKey];
    [defaults setBool:self.nightModeEnabled forKey:kReadingNightModeKey];

    [defaults synchronize];
}

- (void)postSettingsChangedNotification {
    NSDictionary *userInfo = @{
        @"fontSize": @(self.fontSize),
        @"theme": @(self.theme),
        @"nightMode": @(self.nightModeEnabled)
    };

    [[NSNotificationCenter defaultCenter] postNotificationName:ReadingSettingsDidChangeNotification
                                                        object:self
                                                      userInfo:userInfo];
}

#pragma mark - 字体设置

- (void)setFontSize:(CGFloat)fontSize {
    // 限制范围
    fontSize = MAX(kMinFontSize, MIN(kMaxFontSize, fontSize));

    if (_fontSize != fontSize) {
        _fontSize = fontSize;
        [self saveSettings];
        [self postSettingsChangedNotification];
    }
}

- (void)increaseFontSize {
    self.fontSize = self.fontSize + 1.0;
}

- (void)decreaseFontSize {
    self.fontSize = self.fontSize - 1.0;
}

#pragma mark - 主题设置

- (void)setTheme:(ReadingTheme)theme {
    if (_theme != theme) {
        _theme = theme;
        [self saveSettings];
        [self postSettingsChangedNotification];
    }
}

- (void)setNightModeEnabled:(BOOL)nightModeEnabled {
    if (_nightModeEnabled != nightModeEnabled) {
        _nightModeEnabled = nightModeEnabled;
        [self saveSettings];
        [self postSettingsChangedNotification];
    }
}

- (void)toggleNightMode {
    self.nightModeEnabled = !self.nightModeEnabled;
}

#pragma mark - 颜色获取

- (UIColor *)currentBackgroundColor {
    if (self.nightModeEnabled) {
        // 夜间模式：深灰黑
        return [UIColor colorWithRed:30.0/255.0 green:30.0/255.0 blue:30.0/255.0 alpha:1.0];
    } else {
        return [self backgroundColorForTheme:self.theme];
    }
}

- (UIColor *)currentTextColor {
    if (self.nightModeEnabled) {
        // 夜间模式：浅灰白
        return [UIColor colorWithWhite:0.85 alpha:1.0];
    } else {
        return [UIColor blackColor];
    }
}

- (UIColor *)backgroundColorForTheme:(ReadingTheme)theme {
    switch (theme) {
        case ReadingThemeWhite:
            return [UIColor whiteColor];

        case ReadingThemeGreen:
            // 护眼绿
            return [UIColor colorWithRed:199.0/255.0 green:237.0/255.0 blue:204.0/255.0 alpha:1.0];

        case ReadingThemeParchment:
            // 羊皮纸
            return [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:220.0/255.0 alpha:1.0];

        case ReadingThemeGray:
            // 浅灰色
            return [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];

        case ReadingThemeNight:
            // 夜间模式
            return [UIColor colorWithRed:30.0/255.0 green:30.0/255.0 blue:30.0/255.0 alpha:1.0];

        default:
            return [UIColor whiteColor];
    }
}

#pragma mark - 设置应用

- (void)applyToTextView:(UITextView *)textView {
    if (!textView) {
        return;
    }

    UIColor *bgColor = [self currentBackgroundColor];
    UIColor *textColor = [self currentTextColor];

    // 应用背景色
    textView.backgroundColor = bgColor;

    // 应用文本颜色和字体
    if (textView.attributedText.length > 0) {
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:textView.attributedText];

        [attributedText addAttribute:NSFontAttributeName
                              value:[UIFont systemFontOfSize:self.fontSize]
                              range:NSMakeRange(0, attributedText.length)];

        [attributedText addAttribute:NSForegroundColorAttributeName
                              value:textColor
                              range:NSMakeRange(0, attributedText.length)];

        textView.attributedText = attributedText;
    } else {
        textView.font = [UIFont systemFontOfSize:self.fontSize];
        textView.textColor = textColor;
    }
}

- (void)applyToViewController:(UIViewController *)viewController textView:(UITextView *)textView {
    if (!viewController) {
        return;
    }

    // 应用背景色到视图控制器
    viewController.view.backgroundColor = [self currentBackgroundColor];

    // 应用到 TextView
    [self applyToTextView:textView];
}

- (void)applyBackgroundColorToView:(UIView *)view {
    if (!view) {
        return;
    }

    view.backgroundColor = [self currentBackgroundColor];
}

#pragma mark - 便捷方法

- (NSString *)themeDisplayName:(ReadingTheme)theme {
    switch (theme) {
        case ReadingThemeWhite:
            return @"默认白色";
        case ReadingThemeGreen:
            return @"护眼绿";
        case ReadingThemeParchment:
            return @"羊皮纸";
        case ReadingThemeGray:
            return @"浅灰色";
        case ReadingThemeNight:
            return @"夜间模式";
        default:
            return @"未知";
    }
}

@end

