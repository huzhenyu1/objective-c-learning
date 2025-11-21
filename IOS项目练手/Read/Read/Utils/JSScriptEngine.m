//
//  JSScriptEngine.m
//  Read
//
//  JavaScript 脚本执行引擎实现
//

#import "JSScriptEngine.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <CommonCrypto/CommonCrypto.h>

@implementation JSScriptEngine

+ (BOOL)containsJavaScript:(NSString *)rule {
    if (!rule) return NO;
    return [rule containsString:@"@js:"];
}

+ (NSString *)extractJavaScriptFromRule:(NSString *)rule {
    if (!rule) return nil;

    NSRange jsRange = [rule rangeOfString:@"@js:"];
    if (jsRange.location == NSNotFound) {
        return nil;
    }

    // 提取 @js: 之后的所有内容
    NSString *jsCode = [rule substringFromIndex:jsRange.location + jsRange.length];

    // 移除换行符，保持为单行（方便调试）
    jsCode = [jsCode stringByReplacingOccurrencesOfString:@"\n" withString:@"\n"];

    return jsCode;
}

+ (NSString *)extractNormalRuleFromRule:(NSString *)rule {
    if (!rule) return nil;

    NSRange jsRange = [rule rangeOfString:@"@js:"];
    if (jsRange.location == NSNotFound) {
        return rule;
    }

    // 提取 @js: 之前的内容
    NSString *normalRule = [rule substringToIndex:jsRange.location];

    // 移除前后空白
    normalRule = [normalRule stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    return normalRule.length > 0 ? normalRule : nil;
}

+ (id)executeScript:(NSString *)script withContext:(NSDictionary *)context {
    if (!script || script.length == 0) {
        return nil;
    }

    NSLog(@"🔧 执行 JavaScript 脚本");
    NSLog(@"   脚本长度: %ld", (long)script.length);

    // 创建 JavaScript 上下文
    JSContext *jsContext = [[JSContext alloc] init];

    // 设置异常处理
    jsContext.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        NSLog(@"❌ JavaScript 执行错误: %@", exception);
    };

    // 注入上下文变量
    if (context) {
        for (NSString *key in context) {
            jsContext[key] = context[key];
        }
    }

    // 注入自定义函数（用于 AES 解密等）
    [self injectCustomFunctions:jsContext];

    // 执行脚本
    JSValue *result = [jsContext evaluateScript:script];

    // 转换结果
    if ([result isString]) {
        NSString *resultString = [result toString];
        NSLog(@"✅ JavaScript 执行成功，结果: %@", resultString);
        return resultString;
    } else if ([result isNumber]) {
        return [result toNumber];
    } else if ([result isArray]) {
        return [result toArray];
    } else if ([result isObject]) {
        return [result toDictionary];
    }

    return nil;
}

#pragma mark - 自定义函数注入

+ (void)injectCustomFunctions:(JSContext *)context {
    // 注入 String 构造函数
    context[@"String"] = ^id(id value) {
        if ([value isKindOfClass:[NSString class]]) {
            return value;
        }
        return [NSString stringWithFormat:@"%@", value];
    };

    // 注入 java 对象（模拟 Java 的加密库）
    context[@"java"] = @{
        @"createSymmetricCrypto": ^id(NSString *type, NSString *key, NSString *iv) {
            // 返回一个加密对象
            return @{
                @"decryptStr": ^id(NSString *encryptedData) {
                    // 执行 AES 解密
                    return [JSScriptEngine aesDecrypt:encryptedData key:key iv:iv];
                }
            };
        }
    };
}

#pragma mark - AES 解密

+ (NSString *)aesDecrypt:(NSString *)base64String key:(NSString *)keyString iv:(NSString *)ivString {
    if (!base64String || !keyString || !ivString) {
        return nil;
    }

    NSLog(@"🔐 开始 AES 解密");
    NSLog(@"   密文: %@", base64String);
    NSLog(@"   密钥: %@", keyString);
    NSLog(@"   IV: %@", ivString);

    // Base64 解码
    NSData *encryptedData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    if (!encryptedData) {
        NSLog(@"❌ Base64 解码失败");
        return nil;
    }

    // 密钥和 IV
    NSData *keyData = [keyString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *ivData = [ivString dataUsingEncoding:NSUTF8StringEncoding];

    // 创建缓冲区
    size_t bufferSize = encryptedData.length + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);

    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                         kCCAlgorithmAES,
                                         kCCOptionPKCS7Padding,
                                         keyData.bytes,
                                         keyData.length,
                                         ivData.bytes,
                                         encryptedData.bytes,
                                         encryptedData.length,
                                         buffer,
                                         bufferSize,
                                         &numBytesDecrypted);

    if (cryptStatus == kCCSuccess) {
        NSData *decryptedData = [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
        NSString *result = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
        NSLog(@"✅ AES 解密成功: %@", result);
        return result;
    } else {
        free(buffer);
        NSLog(@"❌ AES 解密失败，状态码: %d", cryptStatus);
        return nil;
    }
}

@end

