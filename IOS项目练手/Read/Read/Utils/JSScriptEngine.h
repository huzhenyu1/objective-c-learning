//
//  JSScriptEngine.h
//  Read
//
//  JavaScript 脚本执行引擎
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JSScriptEngine : NSObject

/**
 * 执行 JavaScript 代码
 * @param script JavaScript 代码
 * @param context 上下文变量（如 result）
 * @return 执行结果
 */
+ (nullable id)executeScript:(NSString *)script withContext:(nullable NSDictionary *)context;

/**
 * 检查规则是否包含 JavaScript 代码
 * @param rule 规则字符串
 * @return YES 包含 @js, NO 不包含
 */
+ (BOOL)containsJavaScript:(NSString *)rule;

/**
 * 从规则中提取 JavaScript 代码
 * @param rule 包含 @js 的规则字符串
 * @return JavaScript 代码部分
 */
+ (nullable NSString *)extractJavaScriptFromRule:(NSString *)rule;

/**
 * 从规则中提取普通规则部分（@js 之前的部分）
 * @param rule 包含 @js 的规则字符串
 * @return 普通规则部分
 */
+ (nullable NSString *)extractNormalRuleFromRule:(NSString *)rule;

@end

NS_ASSUME_NONNULL_END

