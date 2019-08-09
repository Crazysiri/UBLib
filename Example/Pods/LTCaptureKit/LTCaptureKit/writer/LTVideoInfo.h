//
//  LTVideoInfo.h
//  LenzBusiness
//
//  Created by Zero on 2018/12/18.
//  Copyright © 2018年 LenzTech. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface LTVideoInfo : NSObject
// 获取视频第一帧
+ (UIImage*) getVideoPreViewImage:(NSURL *)path;

+ (CGFloat) getVideoDuration:(NSURL*) URL;

+ (NSInteger)getFileSize:(NSString*) path;


/**
 *  截取指定时间的视频缩略图
 *
 *  @param timeBySecond 时间点，单位：s
 */
+ (UIImage *)thumbnailImageRequestWithVideoUrl:(NSURL *)videoUrl time:(CGFloat)timeBySecond;


/**
 videoUrl 路径url
 startTime 从哪开始
 endTime 到哪结束
 maxTime 最长时间
 outputURL 输出路径url
 */
+ (void)cropWithVideoUrl:(NSURL *)videoUrl
                   start:(CGFloat)startTime
                 maxTime:(CGFloat)maxTime
               outputURL:(NSURL *)outputURL
              completion:(void (^)(NSURL *outputURL, Float64 videoDuration, BOOL isSuccess))completionHandle;
@end

NS_ASSUME_NONNULL_END
