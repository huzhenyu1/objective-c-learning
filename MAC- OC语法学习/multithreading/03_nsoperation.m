//
//  03_nsoperation.m
//  NSOperation 和 NSOperationQueue
//
//  编译运行: clang -fobjc-arc -framework Foundation 03_nsoperation.m -o 03_nsoperation && ./03_nsoperation
//

#import <Foundation/Foundation.h>

void log_message(NSString *message) {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm:ss.SSS";
    NSString *timeStr = [formatter stringFromDate:[NSDate date]];
    printf("%s %s\n", [timeStr UTF8String], [message UTF8String]);
}

// 1. NSOperation 基础 ⭐
void demo_basic_operation() {
    printf("\n========== 1. NSOperation 基础 ==========\n");

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"com.demo.operationQueue";

    log_message(@"📝 创建 3 个操作并添加到队列");

    for (int i = 1; i <= 3; i++) {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            log_message([NSString stringWithFormat:@"→ 操作 %d 执行", i]);
            sleep(1);
            log_message([NSString stringWithFormat:@"✅ 操作 %d 完成", i]);
        }];

        [queue addOperation:operation];
    }

    // 等待所有操作完成
    [queue waitUntilAllOperationsAreFinished];
    log_message(@"🎉 所有操作完成");
}

// 2. 依赖关系 - addDependency ⭐⭐⭐
void demo_dependency() {
    printf("\n========== 2. 操作依赖关系 ==========\n");
    printf("场景: 下载 → 解析 → 显示（必须按顺序）\n\n");

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];

    // 操作 1: 下载
    NSBlockOperation *downloadOp = [NSBlockOperation blockOperationWithBlock:^{
        log_message(@"📥 操作1: 下载数据");
        sleep(2);
        log_message(@"✅ 操作1: 下载完成");
    }];

    // 操作 2: 解析（依赖下载）
    NSBlockOperation *parseOp = [NSBlockOperation blockOperationWithBlock:^{
        log_message(@"📊 操作2: 解析数据");
        sleep(1);
        log_message(@"✅ 操作2: 解析完成");
    }];
    [parseOp addDependency:downloadOp]; // 解析依赖下载 ⭐

    // 操作 3: 显示（依赖解析）
    NSBlockOperation *displayOp = [NSBlockOperation blockOperationWithBlock:^{
        log_message(@"🖼️  操作3: 显示界面");
        sleep(1);
        log_message(@"✅ 操作3: 显示完成");
    }];
    [displayOp addDependency:parseOp]; // 显示依赖解析 ⭐

    log_message(@"→ 添加 3 个操作（下载 → 解析 → 显示）");

    // 添加到队列（顺序无关，依赖关系决定执行顺序）
    [queue addOperation:displayOp];  // 故意先添加最后的操作
    [queue addOperation:parseOp];
    [queue addOperation:downloadOp];

    [queue waitUntilAllOperationsAreFinished];
    log_message(@"🎉 所有操作按依赖顺序完成");
}

// 3. 取消操作 - cancel ⭐⭐
void demo_cancellation() {
    printf("\n========== 3. 取消操作 ==========\n");
    printf("场景: 长时间任务，用户中途取消\n\n");

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];

    __block NSBlockOperation *longOperation = nil;
    longOperation = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 1; i <= 10; i++) {
            // 检查是否被取消 ⭐
            if (longOperation.isCancelled) {
                log_message(@"❌ 操作被取消");
                return;
            }

            log_message([NSString stringWithFormat:@"→ 进度: %d/10", i]);
            sleep(1);
        }
        log_message(@"✅ 操作完成");
    }];

    log_message(@"→ 启动长时间操作（10秒）");
    [queue addOperation:longOperation];

    // 3秒后取消
    sleep(3);
    if (!longOperation.isFinished && !longOperation.isCancelled) {
        log_message(@"⚠️  用户取消操作");
        [longOperation cancel]; // 取消操作 ⭐
    }

    [queue waitUntilAllOperationsAreFinished];
    log_message(@"🎉 演示完成");
}

// 4. 最大并发数 - maxConcurrentOperationCount ⭐⭐
void demo_max_concurrent() {
    printf("\n========== 4. 控制最大并发数 ==========\n");

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 2; // 最多同时执行 2 个操作 ⭐

    log_message([NSString stringWithFormat:@"→ 设置最大并发数: %ld", (long)queue.maxConcurrentOperationCount]);
    log_message(@"→ 提交 5 个操作，观察执行情况");

    for (int i = 1; i <= 5; i++) {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            log_message([NSString stringWithFormat:@"→ 操作 %d 开始", i]);
            sleep(2);
            log_message([NSString stringWithFormat:@"✅ 操作 %d 完成", i]);
        }];

        [queue addOperation:operation];
    }

    [queue waitUntilAllOperationsAreFinished];
    log_message(@"🎉 所有操作完成（每次最多2个同时执行）");
}

// 5. 操作优先级 - queuePriority
void demo_priority() {
    printf("\n========== 5. 操作优先级 ==========\n");

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1; // 串行，方便观察优先级

    log_message(@"→ 提交 5 个操作，不同优先级");

    // 低优先级
    NSBlockOperation *lowOp = [NSBlockOperation blockOperationWithBlock:^{
        log_message(@"🔵 低优先级任务执行");
    }];
    lowOp.queuePriority = NSOperationQueuePriorityLow;

    // 高优先级
    NSBlockOperation *highOp = [NSBlockOperation blockOperationWithBlock:^{
        log_message(@"🔴 高优先级任务执行");
    }];
    highOp.queuePriority = NSOperationQueuePriorityHigh;

    // 普通优先级
    NSBlockOperation *normalOp = [NSBlockOperation blockOperationWithBlock:^{
        log_message(@"⚪️ 普通优先级任务执行");
    }];
    normalOp.queuePriority = NSOperationQueuePriorityNormal;

    // 故意乱序添加
    [queue addOperation:lowOp];
    [queue addOperation:normalOp];
    [queue addOperation:highOp];

    [queue waitUntilAllOperationsAreFinished];
    log_message(@"💡 执行顺序: 高 → 普通 → 低");
}

// 6. NSOperation vs GCD 对比
void demo_nsoperation_vs_gcd() {
    printf("\n========== 6. NSOperation vs GCD 对比 ==========\n");

    printf("📌 NSOperation 优点:\n");
    printf("  ✅ 支持依赖关系（addDependency）\n");
    printf("  ✅ 支持取消操作（cancel）\n");
    printf("  ✅ 支持优先级（queuePriority）\n");
    printf("  ✅ 可以监听操作状态（isExecuting, isFinished）\n");
    printf("  ✅ 面向对象，易于封装\n\n");

    printf("📌 GCD 优点:\n");
    printf("  ✅ 更轻量级，性能更好\n");
    printf("  ✅ 语法更简洁\n");
    printf("  ✅ C 语言 API，跨平台\n\n");

    printf("📌 使用建议:\n");
    printf("  • 简单异步任务 → GCD\n");
    printf("  • 需要取消/依赖/优先级 → NSOperation\n");
    printf("  • 批量下载、任务管理 → NSOperation\n\n");
}

// 7. 实际案例：批量图片下载（可取消）⭐⭐⭐
void demo_batch_download_with_cancel() {
    printf("\n========== 7. 实际案例：批量下载（可取消）==========\n");

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 3; // 最多同时下载 3 张

    NSMutableArray *operations = [NSMutableArray array];

    log_message(@"📥 开始下载 10 张图片（最多同时3个）");

    for (int i = 1; i <= 10; i++) {
        NSBlockOperation *downloadOp = [NSBlockOperation blockOperationWithBlock:^{
            log_message([NSString stringWithFormat:@"→ 下载图片 %d", i]);

            // 模拟下载（分段检查取消）
            for (int j = 0; j < 5; j++) {
                if ([NSThread currentThread].isCancelled) {
                    log_message([NSString stringWithFormat:@"❌ 图片 %d 下载被取消", i]);
                    return;
                }
                usleep(200000); // 0.2秒
            }

            log_message([NSString stringWithFormat:@"✅ 图片 %d 下载完成", i]);
        }];

        [operations addObject:downloadOp];
        [queue addOperation:downloadOp];
    }

    // 2秒后取消所有下载
    sleep(2);
    log_message(@"⚠️  用户取消下载");
    [queue cancelAllOperations];

    [queue waitUntilAllOperationsAreFinished];
    log_message(@"🎉 演示完成");
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        printf("═══════════════════════════════════════\n");
        printf("  NSOperation & NSOperationQueue\n");
        printf("═══════════════════════════════════════\n");

        // 1. 基础用法
        demo_basic_operation();

        // 2. 依赖关系
        demo_dependency();

        // 3. 取消操作
        demo_cancellation();

        // 4. 最大并发数
        demo_max_concurrent();

        // 5. 操作优先级
        demo_priority();

        // 6. NSOperation vs GCD
        demo_nsoperation_vs_gcd();

        // 7. 实际案例
        demo_batch_download_with_cancel();

        printf("\n═══════════════════════════════════════\n");
        printf("  所有演示完成\n");
        printf("═══════════════════════════════════════\n");
    }
    return 0;
}

