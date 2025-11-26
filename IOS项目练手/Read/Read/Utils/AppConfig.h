//
//  AppConfig.h
//  Read
//
//  应用统一配置 - 集中管理所有魔法数字和常量
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 应用配置管理器
 *
 * 职责：
 *   1. 集中管理所有常量配置
 *   2. 避免魔法数字分散
 *   3. 便于统一调整
 *
 * 使用示例：
 *   CGFloat padding = AppConfig.readingPadding;
 *   NSInteger maxCache = AppConfig.maxCacheChapters;
 */
@interface AppConfig : NSObject

#pragma mark - 缓存配置

/**
 * 最大内存缓存章节数（默认10章）
 */
@property (class, nonatomic, readonly) NSInteger maxCacheChapters;

/**
 * 预加载章节数（默认3章）
 */
@property (class, nonatomic, readonly) NSInteger preloadChapters;

/**
 * 本地缓存过期时间（默认7天，单位：秒）
 */
@property (class, nonatomic, readonly) NSTimeInterval localCacheExpiration;

#pragma mark - 网络配置

/**
 * 网络请求超时时间（默认15秒）
 */
@property (class, nonatomic, readonly) NSTimeInterval requestTimeout;

/**
 * 资源下载超时时间（默认30秒）
 */
@property (class, nonatomic, readonly) NSTimeInterval resourceTimeout;

/**
 * 最大重试次数（默认3次）
 */
@property (class, nonatomic, readonly) NSInteger maxRetryCount;

/**
 * 最大并发连接数（默认5）
 */
@property (class, nonatomic, readonly) NSInteger maxConcurrentConnections;

#pragma mark - UI配置

/**
 * 阅读页面左右边距（默认15.0）
 */
@property (class, nonatomic, readonly) CGFloat readingPadding;

/**
 * 阅读页面上边距（默认10.0）
 */
@property (class, nonatomic, readonly) CGFloat readingTopMargin;

/**
 * 阅读页面下边距（默认10.0）
 */
@property (class, nonatomic, readonly) CGFloat readingBottomMargin;

/**
 * 底部工具栏高度（默认60.0）
 */
@property (class, nonatomic, readonly) CGFloat toolbarHeight;

/**
 * 浮动标题高度（默认44.0）
 */
@property (class, nonatomic, readonly) CGFloat floatingTitleHeight;

/**
 * 按钮最小可点击区域（默认44.0）
 */
@property (class, nonatomic, readonly) CGFloat minTappableSize;

/**
 * 书架书籍封面宽度（默认85.0）
 */
@property (class, nonatomic, readonly) CGFloat bookCoverWidth;

/**
 * 书架书籍封面高度（默认115.0）
 */
@property (class, nonatomic, readonly) CGFloat bookCoverHeight;

/**
 * 书架Cell高度（默认135.0）
 */
@property (class, nonatomic, readonly) CGFloat bookCellHeight;

#pragma mark - 阅读设置

/**
 * 默认字体大小（默认17.0）
 */
@property (class, nonatomic, readonly) CGFloat defaultFontSize;

/**
 * 最小字体大小（默认12.0）
 */
@property (class, nonatomic, readonly) CGFloat minFontSize;

/**
 * 最大字体大小（默认30.0）
 */
@property (class, nonatomic, readonly) CGFloat maxFontSize;

/**
 * 字体调整步长（默认1.0）
 */
@property (class, nonatomic, readonly) CGFloat fontSizeStep;

#pragma mark - 性能配置

/**
 * 浮动标题更新节流间隔（默认0.1秒）
 */
@property (class, nonatomic, readonly) NSTimeInterval titleUpdateThrottleInterval;

/**
 * 进度保存防抖间隔（默认1.0秒）
 */
@property (class, nonatomic, readonly) NSTimeInterval progressSaveDebounceInterval;

/**
 * 滚动距离保存阈值（默认100.0）
 */
@property (class, nonatomic, readonly) CGFloat scrollSaveThreshold;

/**
 * 预加载触发比例（默认0.8，即80%）
 */
@property (class, nonatomic, readonly) CGFloat preloadTriggerRatio;

/**
 * 预加载延迟（默认2.0秒）
 */
@property (class, nonatomic, readonly) NSTimeInterval preloadDelay;

#pragma mark - 动画配置

/**
 * 工具栏显示/隐藏动画时长（默认0.3秒）
 */
@property (class, nonatomic, readonly) NSTimeInterval toolbarAnimationDuration;

/**
 * 页面切换动画时长（默认0.3秒）
 */
@property (class, nonatomic, readonly) NSTimeInterval pageTransitionDuration;

#pragma mark - 颜色配置

/**
 * 主题色（棕红色）
 */
@property (class, nonatomic, readonly) UIColor *themeColor;

/**
 * 分隔线颜色
 */
@property (class, nonatomic, readonly) UIColor *separatorColor;

/**
 * 占位符文本颜色
 */
@property (class, nonatomic, readonly) UIColor *placeholderTextColor;

@end

NS_ASSUME_NONNULL_END

