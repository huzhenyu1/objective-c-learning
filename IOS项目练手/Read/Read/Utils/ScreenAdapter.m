//
//  ScreenAdapter.m
//  Read
//
//  屏幕适配工具实现
//

#import "ScreenAdapter.h"

@implementation ScreenAdapter

#pragma mark - 设备判断

+ (BOOL)isIPad {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

+ (BOOL)isIPhone {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
}

+ (DeviceType)deviceType {
    return [self isIPad] ? DeviceTypePad : DeviceTypePhone;
}

#pragma mark - 屏幕方向

+ (BOOL)isLandscape {
    CGSize size = [UIScreen mainScreen].bounds.size;
    return size.width > size.height;
}

+ (BOOL)isPortrait {
    return ![self isLandscape];
}

+ (OrientationType)orientationType {
    return [self isLandscape] ? OrientationTypeLandscape : OrientationTypePortrait;
}

#pragma mark - 屏幕尺寸

+ (CGFloat)screenWidth {
    return [UIScreen mainScreen].bounds.size.width;
}

+ (CGFloat)screenHeight {
    return [UIScreen mainScreen].bounds.size.height;
}

+ (UIEdgeInsets)safeAreaInsets {
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    if (window) {
        return window.safeAreaInsets;
    }
    return UIEdgeInsetsZero;
}

#pragma mark - 适配尺寸

+ (CGFloat)horizontalPadding {
    if ([self isIPad]) {
        // iPad：更大的边距
        return [self isLandscape] ? 40.0 : 30.0;
    } else {
        // iPhone：标准边距
        return 15.0;
    }
}

+ (CGFloat)verticalPadding {
    if ([self isIPad]) {
        return 20.0;
    } else {
        return 10.0;
    }
}

+ (NSInteger)numberOfColumnsForGridLayout {
    if ([self isIPad]) {
        // iPad
        return [self isLandscape] ? 4 : 3;
    } else {
        // iPhone
        return [self isLandscape] ? 3 : 2;
    }
}

+ (CGSize)bookCoverSize {
    if ([self isIPad]) {
        // iPad：更大的封面
        return CGSizeMake(120, 160);
    } else {
        // iPhone：标准封面
        return CGSizeMake(85, 115);
    }
}

+ (CGFloat)bookCellHeight {
    if ([self isIPad]) {
        return 180.0;
    } else {
        return 135.0;
    }
}

+ (CGFloat)readingContentWidth {
    CGFloat screenWidth = [self screenWidth];
    CGFloat padding = [self horizontalPadding];
    
    if ([self isIPad]) {
        // iPad：限制最大宽度，提升可读性
        CGFloat maxWidth = [self readingMaxContentWidth];
        CGFloat contentWidth = screenWidth - 2 * padding;
        return MIN(contentWidth, maxWidth);
    } else {
        // iPhone：使用全部宽度
        return screenWidth - 2 * padding;
    }
}

+ (CGFloat)readingMaxContentWidth {
    // iPad 横屏时限制最大阅读宽度（参考 iBooks）
    return 800.0;
}

#pragma mark - iPad 分屏支持

+ (BOOL)isInSplitView {
    if (![self isIPad]) {
        return NO;
    }
    
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    if (!window) {
        return NO;
    }
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat windowWidth = window.bounds.size.width;
    
    // 窗口宽度小于屏幕宽度，说明在分屏模式
    return windowWidth < screenWidth - 1.0;
}

+ (CGFloat)splitViewWidthRatio {
    if (![self isInSplitView]) {
        return 1.0;
    }
    
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    if (!window) {
        return 1.0;
    }
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat windowWidth = window.bounds.size.width;
    
    return windowWidth / screenWidth;
}

@end

