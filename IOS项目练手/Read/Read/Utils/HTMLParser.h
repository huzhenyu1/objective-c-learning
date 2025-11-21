//
//  HTMLParser.h
//  Read
//
//  HTML 解析器 - 根据规则从 HTML 中提取数据
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HTMLParser : NSObject

/**
 * 根据规则从 HTML 中提取数据
 * @param html HTML 字符串
 * @param rule 提取规则（如 "class.list@li@a@href"）
 * @return 提取的结果（可能是字符串或数组）
 */
+ (nullable id)extractFromHTML:(NSString *)html withRule:(NSString *)rule;

/**
 * 从 HTML 中提取多个字段
 * @param html HTML 字符串
 * @param rules 规则字典（key: 字段名, value: 提取规则）
 * @return 提取的结果字典
 */
+ (NSDictionary *)extractFieldsFromHTML:(NSString *)html withRules:(NSDictionary<NSString *, NSString *> *)rules;

@end

#pragma mark - 规则语法说明

/*
 支持的规则语法：

 1. 基本选择器：
    - class.类名          通过 class 选择元素
    - id.ID名             通过 id 选择元素
    - tag.标签名          通过标签名选择元素
    - text.文本内容       通过文本内容查找元素

 2. 属性提取：
    - @属性名             获取元素的属性值
    - @text              获取元素的文本内容
    - @textNodes         获取所有文本节点
    - @html              获取元素的 HTML

 3. 组合语法：
    - A@B                先选择 A，再提取 B（链式）
    - A||B               如果 A 失败，则尝试 B（或）
    - A.数字             获取数组的第 N 个元素
    - ##正则表达式       对结果应用正则过滤

 示例：
    "class.list@li"                    选择 class="list" 的元素，获取所有 li
    "class.list@li@a@href"             选择列表中的所有链接的 href
    "tag.span.0@text"                  获取第一个 span 的文本
    "b@text##\\[.*\\]"                 获取 b 标签的文本，去除方括号内容
    "text.下一页@href||text.下一节@href"  查找"下一页"或"下一节"的链接
 */

NS_ASSUME_NONNULL_END

