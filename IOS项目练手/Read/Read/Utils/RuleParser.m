//
//  RuleParser.m
//  Read
//
//  通用规则解析器实现
//

#import "RuleParser.h"
#import "HTMLParser.h"

@implementation RuleParser

#pragma mark - 公共接口

+ (nullable id)extractFromContent:(NSString *)content withRule:(NSString *)rule {
    if (!content || content.length == 0 || !rule || rule.length == 0) {
        return nil;
    }

    // 尝试解析为 JSON
    NSData *jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];

    if (!error && jsonObject) {
        // 是 JSON，使用 JSON 路径解析
        id result = [self extractFromJSON:jsonObject withRule:rule];
        return result;
    } else {
        // 是 HTML，使用 HTML 解析
        id result = [HTMLParser extractFromHTML:content withRule:rule];
        return result;
    }
}

+ (NSDictionary *)extractFieldsFromContent:(NSString *)content withRules:(NSDictionary<NSString *, NSString *> *)rules {
    NSMutableDictionary *results = [NSMutableDictionary dictionary];

    // 先检测是 JSON 还是 HTML
    NSData *jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];

    BOOL isJSON = (!error && jsonObject);

    for (NSString *key in rules) {
        NSString *rule = rules[key];
        id value = nil;

        if (isJSON) {
            value = [self extractFromJSON:jsonObject withRule:rule];
        } else {
            value = [HTMLParser extractFromHTML:content withRule:rule];
        }

        if (value) {
            results[key] = value;
        }
    }

    return results;
}

#pragma mark - JSON 解析

+ (nullable id)extractFromJSON:(id)jsonObject withRule:(NSString *)rule {
    if (!jsonObject || !rule || rule.length == 0) {
        return nil;
    }

    // 处理空规则或 "." (返回整个对象)
    if ([rule isEqualToString:@"."] || [rule isEqualToString:@""]) {
        return jsonObject;
    }

    // 按 . 分割路径
    NSArray<NSString *> *components = [rule componentsSeparatedByString:@"."];
    id currentObject = jsonObject;

    for (NSString *component in components) {
        if (!currentObject) {
            break;
        }

        // 处理数组索引 [0] 或 [*]
        if ([component containsString:@"["]) {
            currentObject = [self processArrayComponent:component onObject:currentObject];
        } else {
            // 普通字段访问
            if ([currentObject isKindOfClass:[NSDictionary class]]) {
                currentObject = currentObject[component];
            } else {
                return nil;
            }
        }
    }

    return currentObject;
}

+ (id)processArrayComponent:(NSString *)component onObject:(id)object {
    // 处理类似 "categoryNames[*]" 或 "list[0]" 的规则
    NSString *pattern = @"([^\\[]+)\\[([^\\]]+)\\]";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:component options:0 range:NSMakeRange(0, component.length)];

    if (!match || match.numberOfRanges < 3) {
        return object;
    }

    NSString *fieldName = [component substringWithRange:[match rangeAtIndex:1]];
    NSString *indexStr = [component substringWithRange:[match rangeAtIndex:2]];

    // 先获取字段
    id fieldValue = nil;
    if ([object isKindOfClass:[NSDictionary class]]) {
        fieldValue = object[fieldName];
    } else {
        fieldValue = object;
    }

    if (![fieldValue isKindOfClass:[NSArray class]]) {
        return fieldValue;
    }

    NSArray *array = (NSArray *)fieldValue;

    // 处理索引
    if ([indexStr isEqualToString:@"*"]) {
        // 返回整个数组
        return array;
    } else {
        // 返回特定索引
        NSInteger index = [indexStr integerValue];
        if (index >= 0 && index < array.count) {
            return array[index];
        }
    }

    return nil;
}

#pragma mark - 模板替换

+ (NSString *)applyTemplate:(NSString *)template withData:(id)data {
    if (!template || !data) {
        return template;
    }

    NSString *result = template;

    // 查找所有 {{$.xxx}} 模板
    NSString *pattern = @"\\{\\{\\$\\.([^}]+)\\}\\}";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:template options:0 range:NSMakeRange(0, template.length)];

    // 从后往前替换（避免索引变化）
    for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
        if (match.numberOfRanges >= 2) {
            NSString *fullMatch = [template substringWithRange:match.range];
            NSString *fieldPath = [template substringWithRange:[match rangeAtIndex:1]];

            // 从 data 中提取值
            id value = [self extractFromJSON:data withRule:fieldPath];

            if (value) {
                NSString *valueString = [value description];
                result = [result stringByReplacingOccurrencesOfString:fullMatch withString:valueString];
            }
        }
    }

    return result;
}

@end

