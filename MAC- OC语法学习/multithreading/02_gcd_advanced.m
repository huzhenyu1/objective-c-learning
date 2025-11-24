//
//  02_gcd_advanced.m
//  GCD 高级 - 串行队列、并行队列、Dispatch Group、Barrier
//
//  编译运行: clang -fobjc-arc -framework Foundation 02_gcd_advanced.m -o 02_gcd_advanced && ./02_gcd_advanced
//

#import <Foundation/Foundation.h>

void log_message(NSString *message) {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm:ss.SSS";
    NSString *timeStr = [formatter stringFromDate:[NSDate date]];
    NSString *threadName = [NSThread currentThread].name ?: @"匿名";
    if ([NSThread isMainThread]) threadName = @"主线程";
    printf("%s [%s] %s\n", [timeStr UTF8String], [threadName UTF8String], [message UTF8String]);
}

// 1. 串行队列 - 按顺序执行 ⭐
void demo_serial_queue() {
    printf("\n========== 1. 串行队列（Serial Queue）==========\n");
    printf("特点: 任务按提交顺序依次执行，一个接一个\n\n");

    // 创建串行队列
    dispatch_queue_t serialQueue = dispatch_queue_create("com.demo.serialQueue", DISPATCH_QUEUE_SERIAL);

    log_message(@"📝 提交 5 个任务到串行队列");

    for (int i = 1; i <= 5; i++) {
        dispatch_async(serialQueue, ^{
            log_message([NSString stringWithFormat:@"→ 任务 %d 开始", i]);
            sleep(1);
            log_message([NSString stringWithFormat:@"✅ 任务 %d 完成", i]);
        });
    }

    // 等待所有任务完成
    dispatch_barrier_sync(serialQueue, ^{
        log_message(@"🎉 串行队列所有任务完成");
    });
}

// 2. 并行队列 - 同时执行 ⭐
void demo_concurrent_queue() {
    printf("\n========== 2. 并行队列（Concurrent Queue）==========\n");
    printf("特点: 多个任务同时执行，谁先完成不确定\n\n");

    // 创建并行队列
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.demo.concurrentQueue", DISPATCH_QUEUE_CONCURRENT);

    log_message(@"🔀 提交 5 个任务到并行队列");

    dispatch_group_t group = dispatch_group_create();

    for (int i = 1; i <= 5; i++) {
        dispatch_group_async(group, concurrentQueue, ^{
            log_message([NSString stringWithFormat:@"→ 任务 %d 开始", i]);
            sleep(1);
            log_message([NSString stringWithFormat:@"✅ 任务 %d 完成", i]);
        });
    }

    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    log_message(@"🎉 并行队列所有任务完成");
}

// 3. 串行 vs 并行对比 ⭐⭐⭐
void demo_serial_vs_concurrent() {
    printf("\n========== 3. 串行 vs 并行 性能对比 ==========\n");

    // 串行队列计时
    NSDate *startTime = [NSDate date];
    dispatch_queue_t serialQueue = dispatch_queue_create("com.demo.serial", DISPATCH_QUEUE_SERIAL);

    log_message(@"📝 串行队列执行 5 个任务（每个1秒）");
    for (int i = 1; i <= 5; i++) {
        dispatch_sync(serialQueue, ^{
            sleep(1);
        });
    }
    NSTimeInterval serialTime = [[NSDate date] timeIntervalSinceDate:startTime];
    log_message([NSString stringWithFormat:@"⏱️  串行耗时: %.2f 秒", serialTime]);

    // 并行队列计时
    startTime = [NSDate date];
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.demo.concurrent", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();

    log_message(@"🔀 并行队列执行 5 个任务（每个1秒）");
    for (int i = 1; i <= 5; i++) {
        dispatch_group_async(group, concurrentQueue, ^{
            sleep(1);
        });
    }
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSTimeInterval concurrentTime = [[NSDate date] timeIntervalSinceDate:startTime];
    log_message([NSString stringWithFormat:@"⏱️  并行耗时: %.2f 秒", concurrentTime]);

    printf("\n💡 结论: 并行队列比串行队列快 %.2f 秒（%.1f倍）\n",
           serialTime - concurrentTime, serialTime / concurrentTime);
}

// 4. Dispatch Group - 等待多个任务完成 ⭐⭐⭐
void demo_dispatch_group() {
    printf("\n========== 4. Dispatch Group（任务组）==========\n");
    printf("场景: 同时下载 3 张图片，全部完成后刷新界面\n\n");

    dispatch_group_t group = dispatch_group_create();

    log_message(@"📥 开始下载 3 张图片");

    // 图片 1 - 2秒
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        log_message(@"→ 图片1: 开始下载");
        sleep(2);
        log_message(@"✅ 图片1: 下载完成");
    });

    // 图片 2 - 3秒
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        log_message(@"→ 图片2: 开始下载");
        sleep(3);
        log_message(@"✅ 图片2: 下载完成");
    });

    // 图片 3 - 1秒
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        log_message(@"→ 图片3: 开始下载");
        sleep(1);
        log_message(@"✅ 图片3: 下载完成");
    });

    log_message(@"→ 等待所有图片下载完成...");

    // 方式 1: 阻塞等待
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    log_message(@"🎉 所有图片下载完成，可以刷新 UI 了");

    // 方式 2: 非阻塞回调（实际开发更常用）
    printf("\n--- 方式2: 使用 dispatch_group_notify ---\n");
    dispatch_group_t group2 = dispatch_group_create();

    for (int i = 1; i <= 3; i++) {
        dispatch_group_async(group2, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            log_message([NSString stringWithFormat:@"→ 任务 %d 执行", i]);
            sleep(1);
        });
    }

    // 所有任务完成后的回调
    dispatch_group_notify(group2, dispatch_get_main_queue(), ^{
        log_message(@"🎉 notify: 所有任务完成");
    });

    log_message(@"→ notify 不阻塞，主线程继续执行");
    sleep(2);
}

// 5. Dispatch Barrier - 栅栏函数 ⭐⭐
void demo_dispatch_barrier() {
    printf("\n========== 5. Dispatch Barrier（栅栏）==========\n");
    printf("场景: 多线程读写文件，写操作需要独占\n\n");

    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.demo.barrier", DISPATCH_QUEUE_CONCURRENT);

    // 并发读取（3个读操作同时进行）
    for (int i = 1; i <= 3; i++) {
        dispatch_async(concurrentQueue, ^{
            log_message([NSString stringWithFormat:@"📖 读取操作 %d", i]);
            sleep(1);
        });
    }

    // Barrier - 等待前面的读操作完成，独占队列执行写操作
    dispatch_barrier_async(concurrentQueue, ^{
        log_message(@"🚧 Barrier: 写入操作（独占队列）");
        sleep(2);
        log_message(@"✅ Barrier: 写入完成");
    });

    // 继续并发读取（barrier 后的读操作）
    for (int i = 4; i <= 6; i++) {
        dispatch_async(concurrentQueue, ^{
            log_message([NSString stringWithFormat:@"📖 读取操作 %d", i]);
            sleep(1);
        });
    }

    log_message(@"→ 观察执行顺序：读1-3 → Barrier → 读4-6");

    // 等待所有任务完成
    dispatch_barrier_sync(concurrentQueue, ^{
        log_message(@"🎉 所有操作完成");
    });
}

// 6. 全局队列 vs 自定义队列
void demo_global_vs_custom_queue() {
    printf("\n========== 6. 全局队列 vs 自定义队列 ==========\n");

    // 全局队列（系统提供，共享）
    printf("📌 全局队列:\n");
    printf("  - 系统创建，全应用共享\n");
    printf("  - 并发队列\n");
    printf("  - 4个优先级: HIGH, DEFAULT, LOW, BACKGROUND\n");
    printf("  - 不需要创建和释放\n\n");

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        log_message(@"→ 全局队列任务");
    });

    // 自定义队列（自己创建，独立）
    printf("📌 自定义队列:\n");
    printf("  - 自己创建，可以命名\n");
    printf("  - 可以是串行或并行\n");
    printf("  - 适合需要精确控制的场景\n\n");

    dispatch_queue_t myQueue = dispatch_queue_create("com.myapp.task", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(myQueue, ^{
        log_message(@"→ 自定义队列任务");
    });

    sleep(1);
}

// 7. 实际案例：批量下载图片 ⭐⭐⭐
void demo_batch_download() {
    printf("\n========== 7. 实际案例：批量下载10张图片 ==========\n");

    NSArray *imageUrls = @[@"img1.jpg", @"img2.jpg", @"img3.jpg", @"img4.jpg", @"img5.jpg",
                           @"img6.jpg", @"img7.jpg", @"img8.jpg", @"img9.jpg", @"img10.jpg"];

    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    __block int successCount = 0;
    __block int failCount = 0;

    log_message([NSString stringWithFormat:@"📥 开始批量下载 %lu 张图片", (unsigned long)imageUrls.count]);

    for (NSString *url in imageUrls) {
        dispatch_group_async(group, queue, ^{
            log_message([NSString stringWithFormat:@"→ 下载: %@", url]);

            // 模拟下载（随机成功/失败）
            int randomTime = arc4random_uniform(2) + 1; // 1-2秒
            sleep(randomTime);

            BOOL success = arc4random_uniform(10) > 2; // 80% 成功率

            if (success) {
                @synchronized (@"counter") {
                    successCount++;
                }
                log_message([NSString stringWithFormat:@"✅ 成功: %@", url]);
            } else {
                @synchronized (@"counter") {
                    failCount++;
                }
                log_message([NSString stringWithFormat:@"❌ 失败: %@", url]);
            }
        });
    }

    // 等待所有下载完成
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);

    log_message([NSString stringWithFormat:@"📊 下载统计: 成功 %d，失败 %d", successCount, failCount]);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        printf("═══════════════════════════════════════\n");
        printf("  GCD 高级 - 串行/并行/Group/Barrier\n");
        printf("═══════════════════════════════════════\n");

        // 1. 串行队列
        demo_serial_queue();

        // 2. 并行队列
        demo_concurrent_queue();

        // 3. 串行 vs 并行对比
        demo_serial_vs_concurrent();

        // 4. Dispatch Group
        demo_dispatch_group();

        // 5. Dispatch Barrier
        demo_dispatch_barrier();

        // 6. 全局队列 vs 自定义队列
        demo_global_vs_custom_queue();

        // 7. 实际案例：批量下载
        demo_batch_download();

        printf("\n═══════════════════════════════════════\n");
        printf("  所有演示完成\n");
        printf("═══════════════════════════════════════\n");
    }
    return 0;
}

