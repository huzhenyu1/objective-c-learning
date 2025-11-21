//
//  RuleParser.h
//  Read
//
//  通用规则解析器 - 支持 HTML 和 JSON
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RuleParser : NSObject

/**
 * 从内容中提取数据（自动检测 HTML 或 JSON）
 * @param content 内容（HTML 或 JSON 字符串）
 * @param rule 提取规则
 * @return 提取的结果（字符串、数组或字典）
 */
+ (nullable id)extractFromContent:(NSString *)content withRule:(NSString *)rule;

/**
 * 从内容中提取多个字段
 * @param content 内容（HTML 或 JSON 字符串）
 * @param rules 规则字典（key: 字段名, value: 提取规则）
 * @return 提取的结果字典
 */
+ (NSDictionary *)extractFieldsFromContent:(NSString *)content withRules:(NSDictionary<NSString *, NSString *> *)rules;

/**
 * 从 JSON 对象中提取数据
 * @param jsonObject JSON 对象（NSDictionary 或 NSArray）
 * @param rule JSON 路径规则
 * @return 提取的结果
 */
+ (nullable id)extractFromJSON:(id)jsonObject withRule:(NSString *)rule;

/**
 * 应用模板替换
 * @param template 模板字符串（如 "/novel/{{$.novelId}}"）
 * @param data 数据对象
 * @return 替换后的字符串
 */
+ (NSString *)applyTemplate:(NSString *)template withData:(id)data;

@end

NS_ASSUME_NONNULL_END

