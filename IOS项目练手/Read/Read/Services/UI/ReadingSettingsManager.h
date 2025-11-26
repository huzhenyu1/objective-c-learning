//
//  ReadingSettingsManager.h
//  Read
//
//  阅读设置管理器 - 统一管理字体、主题、夜间模式等设置
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 阅读主题枚举
 */
typedef NS_ENUM(NSInteger, ReadingTheme) {
    ReadingThemeWhite,      // 默认白色
    ReadingThemeGreen,      // 护眼绿
    ReadingThemeParchment,  // 羊皮纸
    ReadingThemeGray,       // 浅灰色
    ReadingThemeNight       // 夜间模式（深灰黑）
};

/**
 * 阅读设置管理器
 *
 * 职责：
 *   1. 管理阅读设置（字体大小、主题、夜间模式）
 *   2. 持久化存储设置
 *   3. 提供统一的设置应用接口
 *   4. 通知设置变更
 *
 * 使用示例：
 *   ReadingSettingsManager *manager = [ReadingSettingsManager sharedManager];
 *   manager.fontSize = 18.0;
 *   manager.theme = ReadingThemeGreen;
 *   [manager applyToTextView:textView];
 */
@interface ReadingSettingsManager : NSObject

#pragma mark - 单例

+ (instancetype)sharedManager;

#pragma mark - 字体设置

/**
 * 字体大小（12.0 - 30.0，默认 17.0）
 */
@property (assign, nonatomic) CGFloat fontSize;

/**
 * 字体大小常量
 */
@property (class, readonly) CGFloat minFontSize;      // 12.0
@property (class, readonly) CGFloat maxFontSize;      // 30.0
@property (class, readonly) CGFloat defaultFontSize;  // 17.0

/**
 * 增大字体（+1.0）
 */
- (void)increaseFontSize;

/**
 * 减小字体（-1.0）
 */
- (void)decreaseFontSize;

#pragma mark - 主题设置

/**
 * 当前主题
 */
@property (assign, nonatomic) ReadingTheme theme;

/**
 * 夜间模式开关（优先级高于 theme）
 */
@property (assign, nonatomic) BOOL nightModeEnabled;

/**
 * 切换夜间模式
 */
- (void)toggleNightMode;

#pragma mark - 颜色获取

/**
 * 获取当前背景颜色
 */
- (UIColor *)currentBackgroundColor;

/**
 * 获取当前文本颜色
 */
- (UIColor *)currentTextColor;

/**
 * 获取主题对应的背景颜色
 */
- (UIColor *)backgroundColorForTheme:(ReadingTheme)theme;

#pragma mark - 设置应用

/**
 * 应用设置到 UITextView
 * @param textView 目标文本视图
 */
- (void)applyToTextView:(UITextView *)textView;

/**
 * 应用设置到 ViewController（背景色 + TextView）
 * @param viewController 目标视图控制器
 * @param textView 目标文本视图
 */
- (void)applyToViewController:(UIViewController *)viewController textView:(UITextView *)textView;

/**
 * 应用背景色到视图
 * @param view 目标视图
 */
- (void)applyBackgroundColorToView:(UIView *)view;

#pragma mark - 通知

/**
 * 设置变更通知（userInfo 包含 @"fontSize", @"theme", @"nightMode"）
 */
extern NSString * const ReadingSettingsDidChangeNotification;

@end

NS_ASSUME_NONNULL_END

