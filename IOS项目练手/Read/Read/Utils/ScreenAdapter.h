//
//  ScreenAdapter.h
//  Read
//
//  屏幕适配工具 - 支持横竖屏切换和iPad
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 设备类型
 */
typedef NS_ENUM(NSInteger, DeviceType) {
    DeviceTypePhone,        // iPhone
    DeviceTypePad           // iPad
};

/**
 * 屏幕方向类型
 */
typedef NS_ENUM(NSInteger, OrientationType) {
    OrientationTypePortrait,   // 竖屏
    OrientationTypeLandscape   // 横屏
};

/**
 * 屏幕适配工具
 * 
 * 职责：
 *   1. 判断设备类型（iPhone/iPad）
 *   2. 判断屏幕方向（竖屏/横屏）
 *   3. 提供适配的尺寸和边距
 *   4. 提供分栏布局支持（iPad）
 * 
 * 使用示例：
 *   BOOL isIPad = ScreenAdapter.isIPad;
 *   CGFloat padding = ScreenAdapter.horizontalPadding;
 *   NSInteger columns = [ScreenAdapter numberOfColumnsForGridLayout];
 */
@interface ScreenAdapter : NSObject

#pragma mark - 设备判断

/**
 * 是否是 iPad
 */
@property (class, nonatomic, readonly) BOOL isIPad;

/**
 * 是否是 iPhone
 */
@property (class, nonatomic, readonly) BOOL isIPhone;

/**
 * 设备类型
 */
@property (class, nonatomic, readonly) DeviceType deviceType;

#pragma mark - 屏幕方向

/**
 * 是否是横屏
 */
@property (class, nonatomic, readonly) BOOL isLandscape;

/**
 * 是否是竖屏
 */
@property (class, nonatomic, readonly) BOOL isPortrait;

/**
 * 屏幕方向类型
 */
@property (class, nonatomic, readonly) OrientationType orientationType;

#pragma mark - 屏幕尺寸

/**
 * 屏幕宽度
 */
@property (class, nonatomic, readonly) CGFloat screenWidth;

/**
 * 屏幕高度
 */
@property (class, nonatomic, readonly) CGFloat screenHeight;

/**
 * 安全区域边距
 */
@property (class, nonatomic, readonly) UIEdgeInsets safeAreaInsets;

#pragma mark - 适配尺寸

/**
 * 水平边距（根据设备和方向自动调整）
 */
@property (class, nonatomic, readonly) CGFloat horizontalPadding;

/**
 * 垂直边距（根据设备和方向自动调整）
 */
@property (class, nonatomic, readonly) CGFloat verticalPadding;

/**
 * 网格布局列数（书架等）
 * iPhone竖屏: 2列
 * iPhone横屏: 3列
 * iPad竖屏: 3列
 * iPad横屏: 4列
 */
+ (NSInteger)numberOfColumnsForGridLayout;

/**
 * 书籍封面尺寸（根据设备自适应）
 */
+ (CGSize)bookCoverSize;

/**
 * 书架Cell高度（根据设备自适应）
 */
+ (CGFloat)bookCellHeight;

/**
 * 阅读页面内容宽度（考虑iPad大屏阅读体验）
 */
+ (CGFloat)readingContentWidth;

/**
 * 阅读页面最大内容宽度（iPad上限制宽度，提升可读性）
 */
+ (CGFloat)readingMaxContentWidth;

#pragma mark - iPad 分屏支持

/**
 * 是否处于分屏模式（iPad）
 */
@property (class, nonatomic, readonly) BOOL isInSplitView;

/**
 * 分屏模式下的宽度比例（0.0 - 1.0）
 */
@property (class, nonatomic, readonly) CGFloat splitViewWidthRatio;

@end

NS_ASSUME_NONNULL_END

