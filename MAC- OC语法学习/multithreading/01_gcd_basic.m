//
//  01_gcd_basic.m
//  GCD 基础 - dispatch_async, dispatch_sync, dispatch_after
//
//  编译运行: clang -fobjc-arc -framework Foundation 01_gcd_basic.m -o 01_gcd_basic && ./01_gcd_basic
//

#import <Foundation/Foundation.h>

void log_message(NSString *message) {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm:ss.SSS";
    NSString *timeStr = [formatter stringFromDate:[NSDate date]];
    NSString *threadInfo = [NSThread isMainThread] ? @"[主线程]" : @"[后台线程]";
    printf("%s %s %s\n", [timeStr UTF8String], [threadInfo UTF8String], [message UTF8String]);
}

// 1. 异步执行 - 不阻塞当前线程 ⭐
void demo_dispatch_async() {
    printf("\n========== 1. 异步执行 ==========\n");
    log_message(@"🚀 开始异步任务");

    // 在全局队列中异步执行
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        log_message(@"→ 异步任务正在后台执行");

        // 模拟耗时操作
        for (int i = 1; i <= 3; i++) {
            sleep(1);
            log_message([NSString stringWithFormat:@"  进度: %d/3", i]);
        }

        log_message(@"✅ 异步任务完成");
    });

    log_message(@"→ 主线程继续执行（不等待异步任务）");

    // 主线程等待一下，让异步任务完成
    sleep(4);
}

// 2. 同步执行 - 阻塞当前线程
void demo_dispatch_sync() {
    printf("\n========== 2. 同步执行 ==========\n");
    log_message(@"⏳ 开始同步任务");

    // 在全局队列中同步执行
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        log_message(@"→ 同步任务正在执行");

        // 模拟耗时操作
        for (int i = 1; i <= 3; i++) {
            sleep(1);
            log_message([NSString stringWithFormat:@"  进度: %d/3", i]);
        }

        log_message(@"✅ 同步任务完成");
    });

    log_message(@"→ 主线程等待同步任务完成后才执行这里");
}

// 3. 主队列 - 主线程执行
void demo_main_queue() {
    printf("\n========== 3. 主队列演示 ==========\n");
    log_message(@"🔄 演示主队列");

    // 在后台线程执行耗时操作
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        log_message(@"→ 后台线程：开始下载数据");
        sleep(2);
        log_message(@"→ 后台线程：数据下载完成");

        // 回到主线程（模拟更新 UI）
        dispatch_async(dispatch_get_main_queue(), ^{
            log_message(@"→ 主线程：处理下载的数据");
            log_message(@"✅ 主线程：数据处理完成");
        });
    });

    // 主线程等待
    sleep(3);
}

// 4. 延迟执行 - dispatch_after
void demo_dispatch_after() {
    printf("\n========== 4. 延迟执行 ==========\n");
    log_message(@"⏰ 2秒后执行任务");

    // 2秒后在主线程执行
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        log_message(@"✅ 延迟任务执行");
    });

    log_message(@"→ 主线程继续执行");

    // 等待延迟任务完成
    sleep(3);
}

// 5. 模拟下载（带进度）
void demo_download_with_progress() {
    printf("\n========== 5. 模拟下载进度 ==========\n");
    log_message(@"📥 开始下载");

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 1; i <= 100; i++) {
            usleep(20000); // 0.02 秒

            if (i % 25 == 0) {
                log_message([NSString stringWithFormat:@"→ 下载进度: %d%%", i]);
            }
        }

        log_message(@"✅ 下载完成");
    });

    sleep(3);
}

// 6. 异步 vs 同步对比
void demo_async_vs_sync() {
    printf("\n========== 6. 异步 vs 同步对比 ==========\n");

    NSDate *startTime = [NSDate date];

    // 异步执行 3 个任务（并行）
    log_message(@"📌 异步执行 3 个任务（同时进行）");
    dispatch_group_t group = dispatch_group_create();

    for (int i = 1; i <= 3; i++) {
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            log_message([NSString stringWithFormat:@"→ 异步任务 %d 开始", i]);
            sleep(1);
            log_message([NSString stringWithFormat:@"✅ 异步任务 %d 完成", i]);
        });
    }

    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSTimeInterval asyncTime = [[NSDate date] timeIntervalSinceDate:startTime];
    log_message([NSString stringWithFormat:@"⏱️  异步总耗时: %.2f 秒", asyncTime]);

    // 同步执行 3 个任务（串行）
    log_message(@"📌 同步执行 3 个任务（依次进行）");
    startTime = [NSDate date];

    for (int i = 1; i <= 3; i++) {
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            log_message([NSString stringWithFormat:@"→ 同步任务 %d 开始", i]);
            sleep(1);
            log_message([NSString stringWithFormat:@"✅ 同步任务 %d 完成", i]);
        });
    }

    NSTimeInterval syncTime = [[NSDate date] timeIntervalSinceDate:startTime];
    log_message([NSString stringWithFormat:@"⏱️  同步总耗时: %.2f 秒", syncTime]);

    printf("\n结论: 异步执行节省了 %.2f 秒\n", syncTime - asyncTime);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        printf("═══════════════════════════════════════\n");
        printf("  GCD 基础 - Grand Central Dispatch\n");
        printf("═══════════════════════════════════════\n");

        // 演示 1: 异步执行
        demo_dispatch_async();

        // 演示 2: 同步执行
        demo_dispatch_sync();

        // 演示 3: 主队列
        demo_main_queue();

        // 演示 4: 延迟执行
        demo_dispatch_after();

        // 演示 5: 下载进度
        demo_download_with_progress();

        // 演示 6: 异步 vs 同步对比
        demo_async_vs_sync();

        printf("\n═══════════════════════════════════════\n");
        printf("  所有演示完成\n");
        printf("═══════════════════════════════════════\n");
    }
    return 0;
}

