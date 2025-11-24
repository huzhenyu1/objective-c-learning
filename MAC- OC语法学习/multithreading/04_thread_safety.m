//
//  04_thread_safety.m
//  线程安全 - 竞态条件、NSLock、@synchronized
//
//  编译运行: clang -fobjc-arc -framework Foundation 04_thread_safety.m -o 04_thread_safety && ./04_thread_safety
//

#import <Foundation/Foundation.h>

void log_message(NSString *message) {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm:ss.SSS";
    NSString *timeStr = [formatter stringFromDate:[NSDate date]];
    printf("%s %s\n", [timeStr UTF8String], [message UTF8String]);
}

// 1. 竞态条件（Race Condition）- 危险示例 ⚠️
void demo_race_condition() {
    printf("\n========== 1. 竞态条件（Race Condition）==========\n");
    printf("⚠️  警告: 这是一个错误示例，展示线程不安全的后果\n\n");

    __block int counter = 0; // 共享变量

    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    log_message(@"→ 10 个线程，每个对 counter 累加 1000 次");
    log_message(@"→ 预期结果: 10000");

    // 10个线程同时对 counter 累加
    for (int i = 0; i < 10; i++) {
        dispatch_group_async(group, queue, ^{
            for (int j = 0; j < 1000; j++) {
                counter++; // ⚠️ 线程不安全！
            }
        });
    }

    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);

    log_message([NSString stringWithFormat:@"❌ 实际结果: %d（错误！）", counter]);
    log_message(@"💡 原因: counter++ 不是原子操作，被多线程打断");
}

// 2. NSLock 解决竞态条件 ⭐⭐⭐
void demo_nslock() {
    printf("\n========== 2. NSLock（互斥锁）==========\n");

    __block int counter = 0;
    NSLock *lock = [[NSLock alloc] init]; // 创建锁 ⭐

    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    log_message(@"→ 10 个线程，每个对 counter 累加 1000 次");
    log_message(@"→ 使用 NSLock 保护共享变量");

    // 10个线程同时对 counter 累加（加锁保护）
    for (int i = 0; i < 10; i++) {
        dispatch_group_async(group, queue, ^{
            for (int j = 0; j < 1000; j++) {
                [lock lock];   // 加锁 ⭐
                counter++;     // 临界区
                [lock unlock]; // 解锁 ⭐
            }
        });
    }

    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);

    log_message([NSString stringWithFormat:@"✅ 实际结果: %d（正确！）", counter]);
    log_message(@"💡 NSLock 确保同一时刻只有一个线程访问 counter");
}

// 3. @synchronized 解决竞态条件 ⭐⭐⭐
void demo_synchronized() {
    printf("\n========== 3. @synchronized（同步锁）==========\n");

    __block int counter = 0;
    NSObject *lockObj = [[NSObject alloc] init]; // 锁对象

    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    log_message(@"→ 10 个线程，每个对 counter 累加 1000 次");
    log_message(@"→ 使用 @synchronized 保护共享变量");

    // 10个线程同时对 counter 累加（@synchronized 保护）
    for (int i = 0; i < 10; i++) {
        dispatch_group_async(group, queue, ^{
            for (int j = 0; j < 1000; j++) {
                @synchronized (lockObj) { // 同步块 ⭐
                    counter++; // 临界区
                }
            }
        });
    }

    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);

    log_message([NSString stringWithFormat:@"✅ 实际结果: %d（正确！）", counter]);
    log_message(@"💡 @synchronized 更简洁，但性能略低于 NSLock");
}

// 4. NSLock vs @synchronized 性能对比
void demo_lock_performance() {
    printf("\n========== 4. NSLock vs @synchronized 性能对比 ==========\n");

    const int iterations = 100000;

    // NSLock 性能测试
    NSDate *startTime = [NSDate date];
    NSLock *lock = [[NSLock alloc] init];
    int counter1 = 0;

    for (int i = 0; i < iterations; i++) {
        [lock lock];
        counter1++;
        [lock unlock];
    }

    NSTimeInterval nslockTime = [[NSDate date] timeIntervalSinceDate:startTime];
    log_message([NSString stringWithFormat:@"⏱️  NSLock: %.4f 秒", nslockTime]);

    // @synchronized 性能测试
    startTime = [NSDate date];
    NSObject *lockObj = [[NSObject alloc] init];
    int counter2 = 0;

    for (int i = 0; i < iterations; i++) {
        @synchronized (lockObj) {
            counter2++;
        }
    }

    NSTimeInterval syncTime = [[NSDate date] timeIntervalSinceDate:startTime];
    log_message([NSString stringWithFormat:@"⏱️  @synchronized: %.4f 秒", syncTime]);

    printf("\n💡 结论: NSLock 比 @synchronized 快 %.2f%%\n",
           (syncTime - nslockTime) / nslockTime * 100);
}

// 5. 死锁示例（Deadlock）⚠️
void demo_deadlock() {
    printf("\n========== 5. 死锁（Deadlock）示例 ==========\n");
    printf("⚠️  警告: 这是一个死锁示例，程序会卡住\n");
    printf("💡 按 Ctrl+C 退出\n\n");

    NSLock *lockA = [[NSLock alloc] init];
    NSLock *lockB = [[NSLock alloc] init];

    // 线程 1: 先锁 A 再锁 B
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        log_message(@"🔵 线程1: 尝试获取锁 A");
        [lockA lock];
        log_message(@"🔵 线程1: 获得锁 A");

        sleep(1); // 等待，让线程2获取锁B

        log_message(@"🔵 线程1: 尝试获取锁 B");
        [lockB lock]; // ⚠️ 死锁：等待线程2释放 B
        log_message(@"🔵 线程1: 获得锁 B");

        [lockB unlock];
        [lockA unlock];
    });

    // 线程 2: 先锁 B 再锁 A
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        log_message(@"🔴 线程2: 尝试获取锁 B");
        [lockB lock];
        log_message(@"🔴 线程2: 获得锁 B");

        sleep(1); // 等待，让线程1获取锁A

        log_message(@"🔴 线程2: 尝试获取锁 A");
        [lockA lock]; // ⚠️ 死锁：等待线程1释放 A
        log_message(@"🔴 线程2: 获得锁 A");

        [lockA unlock];
        [lockB unlock];
    });

    sleep(3);
    log_message(@"💀 死锁发生！两个线程互相等待");

    printf("\n💡 避免死锁的方法:\n");
    printf("  1. 统一加锁顺序（都先 A 后 B）\n");
    printf("  2. 使用 tryLock 避免无限等待\n");
    printf("  3. 设置超时时间\n");
}

// 6. 实际案例：银行转账（线程安全）⭐⭐⭐
void demo_bank_transfer() {
    printf("\n========== 6. 实际案例：银行转账 ==========\n");

    __block double accountA = 1000.0; // 账户 A
    __block double accountB = 1000.0; // 账户 B
    NSLock *lock = [[NSLock alloc] init];

    log_message([NSString stringWithFormat:@"→ 初始: 账户A = %.2f, 账户B = %.2f", accountA, accountB]);

    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    // 100 次转账：A → B
    for (int i = 0; i < 100; i++) {
        dispatch_group_async(group, queue, ^{
            [lock lock];
            double amount = 10.0;
            accountA -= amount;
            accountB += amount;
            [lock unlock];
        });
    }

    // 100 次转账：B → A
    for (int i = 0; i < 100; i++) {
        dispatch_group_async(group, queue, ^{
            [lock lock];
            double amount = 10.0;
            accountB -= amount;
            accountA += amount;
            [lock unlock];
        });
    }

    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);

    double total = accountA + accountB;
    log_message([NSString stringWithFormat:@"→ 最终: 账户A = %.2f, 账户B = %.2f", accountA, accountB]);
    log_message([NSString stringWithFormat:@"→ 总额: %.2f（应该是 2000.00）", total]);

    if (fabs(total - 2000.0) < 0.01) {
        log_message(@"✅ 线程安全：总额正确！");
    } else {
        log_message(@"❌ 线程不安全：总额错误！");
    }
}

// 7. 线程安全总结
void demo_thread_safety_summary() {
    printf("\n========== 7. 线程安全总结 ==========\n");

    printf("📌 什么时候需要线程安全？\n");
    printf("  • 多个线程访问同一个变量\n");
    printf("  • 至少有一个线程在写入\n\n");

    printf("📌 线程安全的方法:\n");
    printf("  1️⃣ NSLock（互斥锁）- 性能最好 ⭐⭐⭐\n");
    printf("  2️⃣ @synchronized - 语法最简单 ⭐⭐\n");
    printf("  3️⃣ 串行队列 - 适合 GCD 风格 ⭐⭐\n");
    printf("  4️⃣ 原子操作 - OSAtomic 系列函数 ⭐\n\n");

    printf("📌 常见线程不安全的操作:\n");
    printf("  ❌ counter++（读-改-写三步操作）\n");
    printf("  ❌ NSMutableArray 的 addObject/removeObject\n");
    printf("  ❌ NSMutableDictionary 的 setObject/removeObject\n\n");

    printf("📌 性能排序（快 → 慢）:\n");
    printf("  NSLock > 串行队列 > @synchronized\n\n");
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        printf("═══════════════════════════════════════\n");
        printf("  线程安全 - Race Condition & Lock\n");
        printf("═══════════════════════════════════════\n");

        // 1. 竞态条件（问题）
        demo_race_condition();

        // 2. NSLock（解决方案1）
        demo_nslock();

        // 3. @synchronized（解决方案2）
        demo_synchronized();

        // 4. 性能对比
        demo_lock_performance();

        // 5. 死锁（注意：会卡住）
        // demo_deadlock(); // 取消注释查看死锁效果

        // 6. 实际案例：银行转账
        demo_bank_transfer();

        // 7. 总结
        demo_thread_safety_summary();

        printf("\n═══════════════════════════════════════\n");
        printf("  所有演示完成\n");
        printf("═══════════════════════════════════════\n");
    }
    return 0;
}

