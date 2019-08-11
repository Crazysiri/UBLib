//
//  LenzAlbumTool.h
//  demo
//
//  Created by qiuyoubo on 2019/2/23.
//  Copyright © 2019 Zero. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LenzAlbumTool : NSObject
/**
 获取视频的时长 00:00
 */
+ (NSString *)transformVideoTimeToString:(NSTimeInterval)duration;
@end

NS_ASSUME_NONNULL_END
