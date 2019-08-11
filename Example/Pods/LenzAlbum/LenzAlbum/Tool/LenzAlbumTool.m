//
//  LenzAlbumTool.m
//  demo
//
//  Created by qiuyoubo on 2019/2/23.
//  Copyright © 2019 Zero. All rights reserved.
//

#import "LenzAlbumTool.h"

@implementation LenzAlbumTool
/**
 获取视频的时长
 */
+ (NSString *)transformVideoTimeToString:(NSTimeInterval)duration {
    NSInteger time = roundf(duration);
    NSString *newTime;
    if (time < 10) {
        newTime = [NSString stringWithFormat:@"00:0%zd",time];
    } else if (time < 60) {
        newTime = [NSString stringWithFormat:@"00:%zd",time];
    } else {
        NSInteger min = roundf(time / 60);
        NSInteger sec = time - (min * 60);
        if (sec < 10) {
            newTime = [NSString stringWithFormat:@"%zd:0%zd",min,sec];
        } else {
            newTime = [NSString stringWithFormat:@"%zd:%zd",min,sec];
        }
    }
    return newTime;
}
@end
