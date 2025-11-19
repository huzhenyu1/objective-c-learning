//
//  01_delegate_pattern.m
//  实际工程中的设计模式：委托模式（Delegate）
//
//  重点：委托模式是 Cocoa 框架的核心设计模式
//

#import <Foundation/Foundation.h>

// ========== 协议定义 ==========
@protocol DownloadDelegate <NSObject>

@required
- (void)downloadDidFinish:(NSString *)filePath;

@optional
- (void)downloadDidStart;
- (void)downloadProgress:(float)progress;
- (void)downloadDidFailWithError:(NSString *)error;

@end

// ========== 下载器类 ==========
@interface Downloader : NSObject

@property (weak) id<DownloadDelegate> delegate;  // 使用 weak 避免循环引用

- (void)startDownload:(NSString *)url;

@end

@implementation Downloader

- (void)startDownload:(NSString *)url {
    // 通知委托下载开始
    if ([self.delegate respondsToSelector:@selector(downloadDidStart)]) {
        [self.delegate downloadDidStart];
    }

    // 模拟下载过程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i <= 100; i += 25) {
            // 通知进度
            if ([self.delegate respondsToSelector:@selector(downloadProgress:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate downloadProgress:i / 100.0f];
                });
            }
            usleep(500000);  // 模拟延迟
        }

        // 下载完成
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate downloadDidFinish:@"/path/to/file.zip"];
        });
    });
}

@end

// ========== 委托实现类 ==========
@interface ViewController : NSObject <DownloadDelegate>

@property NSString *name;

@end

@implementation ViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _name = @"ViewController";
    }
    return self;
}

// 实现必需方法
- (void)downloadDidFinish:(NSString *)filePath {
    NSLog(@"%@: 下载完成，文件路径: %@", self.name, filePath);
}

// 实现可选方法
- (void)downloadDidStart {
    NSLog(@"%@: 下载开始", self.name);
}

- (void)downloadProgress:(float)progress {
    NSLog(@"%@: 下载进度: %.0f%%", self.name, progress * 100);
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // ========== 使用委托模式 ==========
        Downloader *downloader = [[Downloader alloc] init];
        ViewController *viewController = [[ViewController alloc] init];

        // 设置委托
        downloader.delegate = viewController;

        // 开始下载
        [downloader startDownload:@"http://example.com/file.zip"];

        // 等待下载完成（实际应用中不需要）
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:3]];

        // ========== 委托模式的关键点 ==========
        // 1. 使用协议定义委托接口
        // 2. 委托属性使用 weak（避免循环引用）
        // 3. 使用 respondsToSelector: 检查可选方法
        // 4. 委托对象实现协议方法

        // ========== 对比其他语言 ==========
        // C++: 使用函数指针或 std::function
        // Java: 使用接口（Interface）
        // Swift: 使用协议（Protocol）和扩展

        // ========== Cocoa 框架中的委托 ==========
        // UITableViewDelegate, UITextFieldDelegate 等
        // 都是使用委托模式实现的
    }
    return 0;
}

