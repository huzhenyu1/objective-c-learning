//
//  AppConfig.m
//  Read
//
//  应用统一配置实现
//

#import "AppConfig.h"

@implementation AppConfig

#pragma mark - 缓存配置

+ (NSInteger)maxCacheChapters {
    return 10;
}

+ (NSInteger)preloadChapters {
    return 3;
}

+ (NSTimeInterval)localCacheExpiration {
    return 7 * 24 * 60 * 60;  // 7天
}

#pragma mark - 网络配置

+ (NSTimeInterval)requestTimeout {
    return 15.0;
}

+ (NSTimeInterval)resourceTimeout {
    return 30.0;
}

+ (NSInteger)maxRetryCount {
    return 3;
}

+ (NSInteger)maxConcurrentConnections {
    return 5;
}

#pragma mark - UI配置

+ (CGFloat)readingPadding {
    return 15.0;
}

+ (CGFloat)readingTopMargin {
    return 10.0;
}

+ (CGFloat)readingBottomMargin {
    return 10.0;
}

+ (CGFloat)toolbarHeight {
    return 60.0;
}

+ (CGFloat)floatingTitleHeight {
    return 44.0;
}

+ (CGFloat)minTappableSize {
    return 44.0;
}

+ (CGFloat)bookCoverWidth {
    return 85.0;
}

+ (CGFloat)bookCoverHeight {
    return 115.0;
}

+ (CGFloat)bookCellHeight {
    return 135.0;
}

#pragma mark - 阅读设置

+ (CGFloat)defaultFontSize {
    return 17.0;
}

+ (CGFloat)minFontSize {
    return 12.0;
}

+ (CGFloat)maxFontSize {
    return 30.0;
}

+ (CGFloat)fontSizeStep {
    return 1.0;
}

#pragma mark - 性能配置

+ (NSTimeInterval)titleUpdateThrottleInterval {
    return 0.1;
}

+ (NSTimeInterval)progressSaveDebounceInterval {
    return 1.0;
}

+ (CGFloat)scrollSaveThreshold {
    return 100.0;
}

+ (CGFloat)preloadTriggerRatio {
    return 0.8;
}

+ (NSTimeInterval)preloadDelay {
    return 2.0;
}

#pragma mark - 动画配置

+ (NSTimeInterval)toolbarAnimationDuration {
    return 0.3;
}

+ (NSTimeInterval)pageTransitionDuration {
    return 0.3;
}

#pragma mark - 颜色配置

+ (UIColor *)themeColor {
    // 棕红色
    return [UIColor colorWithRed:139.0/255.0 green:69.0/255.0 blue:19.0/255.0 alpha:1.0];
}

+ (UIColor *)separatorColor {
    return [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0];
}

+ (UIColor *)placeholderTextColor {
    return [UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:1.0];
}

@end

