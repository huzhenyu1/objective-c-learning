//
//  PerformanceTest.m
//  性能测试：字典映射 vs 嵌套循环
//

#import <Foundation/Foundation.h>

// 模拟工具栏项
@interface ToolBarItem : NSObject
@property (nonatomic, assign) NSInteger identifier;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *titleCode;
@property (nonatomic, copy) NSString *iconCode;
@end

@implementation ToolBarItem
@end

// 模拟工具栏数据
@interface ToolBarData : NSObject
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) NSArray<ToolBarItem *> *items;
@end

@implementation ToolBarData
@end

// 性能测试类
@interface PerformanceTest : NSObject
+ (void)runTest;
@end

@implementation PerformanceTest

// 生成测试数据
+ (NSArray<ToolBarData *> *)generateTestData:(NSInteger)typeCount itemsPerType:(NSInteger)itemCount {
    NSMutableArray *dataArray = [NSMutableArray array];

    for (NSInteger i = 0; i < typeCount; i++) {
        ToolBarData *data = [[ToolBarData alloc] init];
        data.type = i;

        NSMutableArray *items = [NSMutableArray array];
        for (NSInteger j = 0; j < itemCount; j++) {
            ToolBarItem *item = [[ToolBarItem alloc] init];
            item.identifier = j;
            item.title = [NSString stringWithFormat:@"Item %ld-%ld", (long)i, (long)j];
            item.titleCode = [NSString stringWithFormat:@"title_%ld_%ld", (long)i, (long)j];
            item.iconCode = [NSString stringWithFormat:@"icon_%ld_%ld", (long)i, (long)j];
            [items addObject:item];
        }
        data.items = items;
        [dataArray addObject:data];
    }

    return dataArray;
}

// 方法1: 字典映射（新方法，高效）
+ (NSArray<ToolBarData *> *)method1_DictionaryMapping:(NSArray<ToolBarData *> *)beeNestArray
                                            localData:(NSArray<ToolBarData *> *)localDataArray {
    // 构建本地数据映射: type -> (id -> item)
    NSMutableDictionary<NSNumber *, NSMutableDictionary<NSNumber *, ToolBarItem *> *> *localDataMap = [NSMutableDictionary dictionary];

    for (ToolBarData *toolBarData in localDataArray) {
        NSMutableDictionary<NSNumber *, ToolBarItem *> *itemMap = [NSMutableDictionary dictionary];
        for (ToolBarItem *item in toolBarData.items) {
            itemMap[@(item.identifier)] = item;
        }
        localDataMap[@(toolBarData.type)] = itemMap;
    }

    // 遍历蜂巢数据，从映射中查找并补充
    for (ToolBarData *toolBarData in beeNestArray) {
        NSMutableDictionary<NSNumber *, ToolBarItem *> *localItemMap = localDataMap[@(toolBarData.type)];
        if (!localItemMap) {
            continue;
        }

        for (ToolBarItem *item in toolBarData.items) {
            ToolBarItem *localItem = localItemMap[@(item.identifier)];
            if (localItem) {
                item.titleCode = localItem.titleCode;
                item.title = localItem.title;
                item.iconCode = localItem.iconCode;
            }
        }
    }

    return beeNestArray;
}

// 方法2: 嵌套循环（旧方法，低效）
+ (NSArray<ToolBarData *> *)method2_NestedLoop:(NSArray<ToolBarData *> *)beeNestArray
                                      localData:(NSArray<ToolBarData *> *)localDataArray {
    [beeNestArray enumerateObjectsUsingBlock:^(ToolBarData *beeNestToolBarData, NSUInteger idx, BOOL *stop1) {
        [localDataArray enumerateObjectsUsingBlock:^(ToolBarData *localToolBarData, NSUInteger idx, BOOL *stop2) {
            if (beeNestToolBarData.type == localToolBarData.type) {
                NSArray<ToolBarItem *> *beeNestItems = beeNestToolBarData.items;
                NSArray<ToolBarItem *> *localItems = localToolBarData.items;

                [beeNestItems enumerateObjectsUsingBlock:^(ToolBarItem *beeNestItem, NSUInteger idx, BOOL *stop3) {
                    [localItems enumerateObjectsUsingBlock:^(ToolBarItem *localItem, NSUInteger idx, BOOL *stop4) {
                        if (beeNestItem.identifier == localItem.identifier) {
                            beeNestItem.iconCode = localItem.iconCode;
                            beeNestItem.titleCode = localItem.titleCode;
                            *stop4 = YES;
                        }
                    }];
                }];
                *stop2 = YES;
            }
        }];
    }];

    return beeNestArray;
}

+ (void)runTest {
    NSLog(@"========================================");
    NSLog(@"性能测试：字典映射 vs 嵌套循环");
    NSLog(@"========================================\n");

    // 测试不同规模的数据
    NSArray *testCases = @[
        @{@"types": @5, @"items": @10},      // 小规模：5种类型，每种10个项
        @{@"types": @10, @"items": @20},     // 中等规模：10种类型，每种20个项
        @{@"types": @20, @"items": @50},     // 大规模：20种类型，每种50个项
        @{@"types": @50, @"items": @100},    // 超大规模：50种类型，每种100个项
    ];

    for (NSDictionary *testCase in testCases) {
        NSInteger typeCount = [testCase[@"types"] integerValue];
        NSInteger itemCount = [testCase[@"items"] integerValue];

        NSLog(@"📊 测试规模：%ld 种类型，每种 %ld 个项（共 %ld 个项）",
              (long)typeCount, (long)itemCount, (long)(typeCount * itemCount));

        // 生成测试数据
        NSArray *beeNestData = [self generateTestData:typeCount itemsPerType:itemCount];
        NSArray *localData = [self generateTestData:typeCount itemsPerType:itemCount];

        // 测试方法1：字典映射
        NSArray *beeNestCopy1 = [self generateTestData:typeCount itemsPerType:itemCount];
        CFAbsoluteTime start1 = CFAbsoluteTimeGetCurrent();
        [self method1_DictionaryMapping:beeNestCopy1 localData:localData];
        CFAbsoluteTime end1 = CFAbsoluteTimeGetCurrent();
        double time1 = (end1 - start1) * 1000.0;

        // 测试方法2：嵌套循环
        NSArray *beeNestCopy2 = [self generateTestData:typeCount itemsPerType:itemCount];
        CFAbsoluteTime start2 = CFAbsoluteTimeGetCurrent();
        [self method2_NestedLoop:beeNestCopy2 localData:localData];
        CFAbsoluteTime end2 = CFAbsoluteTimeGetCurrent();
        double time2 = (end2 - start2) * 1000.0;

        // 输出结果
        NSLog(@"  ✅ 方法1（字典映射）: %.4f ms", time1);
        NSLog(@"  ❌ 方法2（嵌套循环）: %.4f ms", time2);
        NSLog(@"  📈 性能提升：%.2f 倍", time2 / time1);
        NSLog(@"  ⚡ 时间节省：%.2f%%\n", ((time2 - time1) / time2) * 100);
    }

    // 复杂度分析
    NSLog(@"========================================");
    NSLog(@"算法复杂度分析：");
    NSLog(@"========================================");
    NSLog(@"方法1（字典映射）：");
    NSLog(@"  • 构建映射：O(n*m) - n个类型，每个m个项");
    NSLog(@"  • 查找匹配：O(n*m) - 遍历所有项，字典查找O(1)");
    NSLog(@"  • 总复杂度：O(n*m)");
    NSLog(@"");
    NSLog(@"方法2（嵌套循环）：");
    NSLog(@"  • 遍历蜂巢类型：O(n)");
    NSLog(@"  • 遍历本地类型：O(n)");
    NSLog(@"  • 遍历蜂巢项：O(m)");
    NSLog(@"  • 遍历本地项：O(m)");
    NSLog(@"  • 总复杂度：O(n²*m²) - 四层嵌套循环！");
    NSLog(@"");
    NSLog(@"结论：数据量越大，字典映射的优势越明显！");
    NSLog(@"========================================");
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        [PerformanceTest runTest];
    }
    return 0;
}

