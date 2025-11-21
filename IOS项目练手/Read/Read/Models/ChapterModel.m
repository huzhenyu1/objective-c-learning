//
//  ChapterModel.m
//  Read
//
//  章节数据模型实现
//

#import "ChapterModel.h"

@implementation ChapterModel

+ (instancetype)chapterWithName:(NSString *)name
                            url:(NSString *)url
                          index:(NSInteger)index {
    ChapterModel *chapter = [[ChapterModel alloc] init];
    chapter.chapterName = name;
    chapter.chapterUrl = url;
    chapter.chapterIndex = index;
    chapter.isDownloaded = NO;
    return chapter;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Chapter %ld: %@ (%@)",
            (long)self.chapterIndex, self.chapterName, self.chapterUrl];
}

@end

