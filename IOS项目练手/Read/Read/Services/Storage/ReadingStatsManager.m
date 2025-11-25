//
//  ReadingStatsManager.m
//  Read
//
//  阅读统计管理器实现
//

#import "ReadingStatsManager.h"

// 阅读记录模型实现
@implementation ReadingRecord

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _bookUrl = [coder decodeObjectForKey:@"bookUrl"];
        _bookTitle = [coder decodeObjectForKey:@"bookTitle"];
        _chapterName = [coder decodeObjectForKey:@"chapterName"];
        _chapterIndex = [coder decodeIntegerForKey:@"chapterIndex"];
        _readTime = [coder decodeObjectForKey:@"readTime"];
        _duration = [coder decodeIntegerForKey:@"duration"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_bookUrl forKey:@"bookUrl"];
    [coder encodeObject:_bookTitle forKey:@"bookTitle"];
    [coder encodeObject:_chapterName forKey:@"chapterName"];
    [coder encodeInteger:_chapterIndex forKey:@"chapterIndex"];
    [coder encodeObject:_readTime forKey:@"readTime"];
    [coder encodeInteger:_duration forKey:@"duration"];
}

@end

// 阅读统计管理器实现
@interface ReadingStatsManager ()
@property (strong, nonatomic) NSDate *sessionStartTime;  // 当前阅读会话开始时间
@property (copy, nonatomic) NSString *currentBookUrl;
@property (copy, nonatomic) NSString *currentBookTitle;
@end

@implementation ReadingStatsManager

+ (instancetype)sharedManager {
    static ReadingStatsManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ReadingStatsManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 初始化时清理过期数据（超过30天的记录）
        [self cleanupOldRecords];
    }
    return self;
}

#pragma mark - 阅读时长统计

- (void)startReadingSession:(NSString *)bookUrl bookTitle:(NSString *)bookTitle {
    self.sessionStartTime = [NSDate date];
    self.currentBookUrl = bookUrl;
    self.currentBookTitle = bookTitle;
}

- (void)endReadingSession {
    if (!self.sessionStartTime) {
        return;
    }

    // 计算本次阅读时长
    NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:self.sessionStartTime];
    NSInteger durationSeconds = (NSInteger)duration;

    // 只记录超过5秒的阅读时长
    if (durationSeconds >= 5) {
        [self saveDuration:durationSeconds forDate:[NSDate date]];
    }

    self.sessionStartTime = nil;
    self.currentBookUrl = nil;
    self.currentBookTitle = nil;
}

- (void)saveDuration:(NSInteger)duration forDate:(NSDate *)date {
    NSString *dateKey = [self dateKeyFromDate:date];
    NSString *key = [NSString stringWithFormat:@"ReadingDuration_%@", dateKey];

    NSInteger existingDuration = [[NSUserDefaults standardUserDefaults] integerForKey:key];
    [[NSUserDefaults standardUserDefaults] setInteger:existingDuration + duration forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)getTodayReadingDuration {
    return [self getDurationForDate:[NSDate date]];
}

- (NSInteger)getThisWeekReadingDuration {
    NSInteger total = 0;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *today = [NSDate date];

    for (NSInteger i = 0; i < 7; i++) {
        NSDate *date = [calendar dateByAddingUnit:NSCalendarUnitDay value:-i toDate:today options:0];
        total += [self getDurationForDate:date];
    }

    return total;
}

- (NSInteger)getTotalReadingDuration {
    NSInteger total = [[NSUserDefaults standardUserDefaults] integerForKey:@"TotalReadingDuration"];
    return total;
}

- (NSInteger)getDurationForDate:(NSDate *)date {
    NSString *dateKey = [self dateKeyFromDate:date];
    NSString *key = [NSString stringWithFormat:@"ReadingDuration_%@", dateKey];
    return [[NSUserDefaults standardUserDefaults] integerForKey:key];
}

- (NSString *)dateKeyFromDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    return [formatter stringFromDate:date];
}

#pragma mark - 阅读记录

- (void)addReadingRecord:(NSString *)bookUrl
               bookTitle:(NSString *)bookTitle
             chapterName:(NSString *)chapterName
            chapterIndex:(NSInteger)chapterIndex {

    ReadingRecord *record = [[ReadingRecord alloc] init];
    record.bookUrl = bookUrl;
    record.bookTitle = bookTitle;
    record.chapterName = chapterName;
    record.chapterIndex = chapterIndex;
    record.readTime = [NSDate date];
    record.duration = self.sessionStartTime ? (NSInteger)[[NSDate date] timeIntervalSinceDate:self.sessionStartTime] : 0;

    // 获取现有记录
    NSMutableArray<ReadingRecord *> *records = [[self getRecentReadingRecords] mutableCopy];
    if (!records) {
        records = [NSMutableArray array];
    }

    // 添加到开头
    [records insertObject:record atIndex:0];

    // 只保留最近100条
    if (records.count > 100) {
        [records removeObjectsInRange:NSMakeRange(100, records.count - 100)];
    }

    // 保存
    [self saveReadingRecords:records];

    // 更新已读书籍集合
    [self addToReadBooks:bookUrl];
}

- (NSArray<ReadingRecord *> *)getRecentReadingRecords {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"ReadingRecords"];
    if (!data) {
        return @[];
    }

    NSArray *records = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    // 只返回最近20条
    if (records.count > 20) {
        return [records subarrayWithRange:NSMakeRange(0, 20)];
    }

    return records ?: @[];
}

- (void)saveReadingRecords:(NSArray<ReadingRecord *> *)records {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:records];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"ReadingRecords"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - 阅读统计

- (void)addToReadBooks:(NSString *)bookUrl {
    NSMutableSet *readBooks = [NSMutableSet setWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"ReadBooks"] ?: @[]];
    [readBooks addObject:bookUrl];
    [[NSUserDefaults standardUserDefaults] setObject:[readBooks allObjects] forKey:@"ReadBooks"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)getReadBooksCount {
    NSArray *readBooks = [[NSUserDefaults standardUserDefaults] arrayForKey:@"ReadBooks"];
    return readBooks.count;
}

- (NSInteger)getReadChaptersCount {
    NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:@"ReadChaptersCount"];
    return count;
}

- (NSInteger)getTodayReadingWords {
    NSString *dateKey = [self dateKeyFromDate:[NSDate date]];
    NSString *key = [NSString stringWithFormat:@"ReadingWords_%@", dateKey];
    return [[NSUserDefaults standardUserDefaults] integerForKey:key];
}

- (void)addReadingWords:(NSInteger)words {
    NSString *dateKey = [self dateKeyFromDate:[NSDate date]];
    NSString *key = [NSString stringWithFormat:@"ReadingWords_%@", dateKey];

    NSInteger existingWords = [[NSUserDefaults standardUserDefaults] integerForKey:key];
    [[NSUserDefaults standardUserDefaults] setInteger:existingWords + words forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - 数据清理

- (void)cleanupOldRecords {
    // 清理超过30天的阅读时长记录
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *today = [NSDate date];

    for (NSInteger i = 31; i < 60; i++) {  // 清理31-60天前的数据
        NSDate *date = [calendar dateByAddingUnit:NSCalendarUnitDay value:-i toDate:today options:0];
        NSString *dateKey = [self dateKeyFromDate:date];
        NSString *durationKey = [NSString stringWithFormat:@"ReadingDuration_%@", dateKey];
        NSString *wordsKey = [NSString stringWithFormat:@"ReadingWords_%@", dateKey];

        [[NSUserDefaults standardUserDefaults] removeObjectForKey:durationKey];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:wordsKey];
    }

    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)clearAllStats {
    // 清空所有统计数据
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ReadingRecords"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ReadBooks"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ReadChaptersCount"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TotalReadingDuration"];

    // 清空近30天的数据
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *today = [NSDate date];

    for (NSInteger i = 0; i < 30; i++) {
        NSDate *date = [calendar dateByAddingUnit:NSCalendarUnitDay value:-i toDate:today options:0];
        NSString *dateKey = [self dateKeyFromDate:date];
        NSString *durationKey = [NSString stringWithFormat:@"ReadingDuration_%@", dateKey];
        NSString *wordsKey = [NSString stringWithFormat:@"ReadingWords_%@", dateKey];

        [[NSUserDefaults standardUserDefaults] removeObjectForKey:durationKey];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:wordsKey];
    }

    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

