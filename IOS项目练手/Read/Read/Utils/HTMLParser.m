//
//  HTMLParser.m
//  Read
//
//  HTML 解析器实现（简化版，使用正则表达式）
//

#import "HTMLParser.h"

@implementation HTMLParser

#pragma mark - 公共接口

+ (nullable id)extractFromHTML:(NSString *)html withRule:(NSString *)rule {
    if (!html || html.length == 0 || !rule || rule.length == 0) {
        return nil;
    }

    // 处理 || 语法（或操作）
    if ([rule containsString:@"||"]) {
        NSArray<NSString *> *alternatives = [rule componentsSeparatedByString:@"||"];
        for (NSString *alternativeRule in alternatives) {
            id result = [self extractFromHTML:html withRule:[alternativeRule stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            if (result) {
                return result;
            }
        }
        return nil;
    }

    // 处理 ## 语法（正则过滤）
    NSString *regexPattern = nil;
    if ([rule containsString:@"##"]) {
        NSArray<NSString *> *parts = [rule componentsSeparatedByString:@"##"];
        rule = parts[0];
        if (parts.count > 1) {
            regexPattern = parts[1];
        }
    }

    // 处理 @ 语法（链式操作）
    NSArray<NSString *> *steps = [rule componentsSeparatedByString:@"@"];

    id result = html;

    for (NSString *step in steps) {
        if ([step isEqualToString:@"text"]) {
            // 提取文本内容
            if ([result isKindOfClass:[NSString class]]) {
                result = [self extractTextFromHTML:result];
            } else if ([result isKindOfClass:[NSArray class]]) {
                NSMutableArray *texts = [NSMutableArray array];
                for (NSString *item in result) {
                    [texts addObject:[self extractTextFromHTML:item]];
                }
                result = texts;
            }
        } else if ([step isEqualToString:@"textNodes"]) {
            // 提取所有文本节点
            if ([result isKindOfClass:[NSString class]]) {
                result = [self extractAllTextFromHTML:result];
            }
        } else if ([step isEqualToString:@"html"]) {
            // 保持 HTML
            // 不做处理
        } else if ([step hasPrefix:@"class."]) {
            // 通过 class 选择
            NSString *className = [step substringFromIndex:6];
            result = [self selectByClass:className fromHTML:result];
        } else if ([step hasPrefix:@"id."]) {
            // 通过 id 选择
            NSString *idName = [step substringFromIndex:3];
            result = [self selectByID:idName fromHTML:result];
        } else if ([step hasPrefix:@"tag."]) {
            // 通过标签名选择
            NSString *tagName = [step substringFromIndex:4];
            result = [self selectByTag:tagName fromHTML:result];
        } else if ([step hasPrefix:@"text."]) {
            // 通过文本内容查找
            NSString *text = [step substringFromIndex:5];
            result = [self selectByText:text fromHTML:result];
        } else if ([step rangeOfString:@"."].location != NSNotFound) {
            // 数组索引（如 "0", "1"）
            NSArray *parts = [step componentsSeparatedByString:@"."];
            if (parts.count == 2) {
                NSInteger index = [parts[1] integerValue];
                if ([result isKindOfClass:[NSArray class]] && index < [result count]) {
                    result = result[index];
                }
            }
        } else {
            // 提取属性（如 "href", "src"）
            if ([result isKindOfClass:[NSString class]]) {
                result = [self extractAttribute:step fromHTML:result];
            } else if ([result isKindOfClass:[NSArray class]]) {
                NSMutableArray *attributes = [NSMutableArray array];
                for (NSString *item in result) {
                    id attr = [self extractAttribute:step fromHTML:item];
                    if (attr) {
                        [attributes addObject:attr];
                    }
                }
                result = attributes;
            }
        }

        if (!result) {
            break;
        }
    }

    // 应用正则过滤
    if (regexPattern && result) {
        if ([result isKindOfClass:[NSString class]]) {
            result = [self applyRegex:regexPattern toString:result];
        } else if ([result isKindOfClass:[NSArray class]]) {
            NSMutableArray *filtered = [NSMutableArray array];
            for (id item in result) {
                if ([item isKindOfClass:[NSString class]]) {
                    [filtered addObject:[self applyRegex:regexPattern toString:item]];
                }
            }
            result = filtered;
        }
    }

    return result;
}

+ (NSDictionary *)extractFieldsFromHTML:(NSString *)html withRules:(NSDictionary<NSString *, NSString *> *)rules {
    NSMutableDictionary *results = [NSMutableDictionary dictionary];

    for (NSString *key in rules) {
        NSString *rule = rules[key];
        id value = [self extractFromHTML:html withRule:rule];
        if (value) {
            results[key] = value;
        }
    }

    return results;
}

#pragma mark - 选择器实现

+ (id)selectByClass:(NSString *)className fromHTML:(id)html {
    if ([html isKindOfClass:[NSString class]]) {
        NSString *pattern = [NSString stringWithFormat:@"<[^>]*class=[\"'][^\"']*\\b%@\\b[^\"']*[\"'][^>]*>.*?</[^>]+>", className];
        return [self findAllMatches:pattern inHTML:html];
    }
    return nil;
}

+ (id)selectByID:(NSString *)idName fromHTML:(id)html {
    if ([html isKindOfClass:[NSString class]]) {
        NSString *pattern = [NSString stringWithFormat:@"<[^>]*id=[\"']%@[\"'][^>]*>.*?</[^>]+>", idName];
        NSArray *matches = [self findAllMatches:pattern inHTML:html];
        return matches.count > 0 ? matches[0] : nil;
    }
    return nil;
}

+ (id)selectByTag:(NSString *)tagName fromHTML:(id)html {
    if ([html isKindOfClass:[NSString class]]) {
        NSString *pattern = [NSString stringWithFormat:@"<%@[^>]*>.*?</%@>", tagName, tagName];
        return [self findAllMatches:pattern inHTML:html];
    } else if ([html isKindOfClass:[NSArray class]]) {
        NSMutableArray *results = [NSMutableArray array];
        for (NSString *item in html) {
            NSArray *matches = [self selectByTag:tagName fromHTML:item];
            if (matches) {
                [results addObjectsFromArray:matches];
            }
        }
        return results;
    }
    return nil;
}

+ (id)selectByText:(NSString *)text fromHTML:(id)html {
    if ([html isKindOfClass:[NSString class]]) {
        NSString *pattern = [NSString stringWithFormat:@"<a[^>]*>%@</a>", text];
        NSArray *matches = [self findAllMatches:pattern inHTML:html];
        return matches.count > 0 ? matches[0] : nil;
    }
    return nil;
}

#pragma mark - 属性提取

+ (id)extractAttribute:(NSString *)attrName fromHTML:(NSString *)html {
    if (!html || html.length == 0) {
        return nil;
    }

    NSString *pattern = [NSString stringWithFormat:@"%@=[\"']([^\"']*)[\"']", attrName];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:html options:0 range:NSMakeRange(0, html.length)];

    if (match && match.numberOfRanges > 1) {
        return [html substringWithRange:[match rangeAtIndex:1]];
    }

    return nil;
}

+ (NSString *)extractTextFromHTML:(NSString *)html {
    if (!html || html.length == 0) {
        return @"";
    }

    // 移除 HTML 标签
    NSString *pattern = @"<[^>]+>";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:0
                                                                             error:nil];
    NSString *text = [regex stringByReplacingMatchesInString:html
                                                      options:0
                                                        range:NSMakeRange(0, html.length)
                                                   withTemplate:@""];

    // 去除多余空白
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    return text;
}

+ (NSString *)extractAllTextFromHTML:(NSString *)html {
    return [self extractTextFromHTML:html];
}

#pragma mark - 正则匹配

+ (NSArray<NSString *> *)findAllMatches:(NSString *)pattern inHTML:(NSString *)html {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionDotMatchesLineSeparators
                                                                             error:nil];
    NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:html options:0 range:NSMakeRange(0, html.length)];

    NSMutableArray<NSString *> *results = [NSMutableArray array];
    for (NSTextCheckingResult *match in matches) {
        NSString *matchedString = [html substringWithRange:match.range];
        [results addObject:matchedString];
    }

    return results;
}

+ (NSString *)applyRegex:(NSString *)pattern toString:(NSString *)string {
    if (!pattern || !string) {
        return string;
    }

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:0
                                                                             error:nil];
    return [regex stringByReplacingMatchesInString:string
                                           options:0
                                             range:NSMakeRange(0, string.length)
                                        withTemplate:@""];
}

@end

