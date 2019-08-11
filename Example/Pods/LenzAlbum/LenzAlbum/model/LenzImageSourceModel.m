//
//  LenzImageSourceURLModel.m
//  demo
//
//  Created by qiuyoubo on 2019/2/23.
//  Copyright © 2019 Zero. All rights reserved.
//

#import "LenzImageSourceModel.h"

@implementation LenzImageSourceModel

@synthesize type,videoTime;

- (void)getVideoPlayerItem:(void (^)(AVPlayerItem *))completion {
    
}

@end

@implementation LenzImageSourceURLModel

@synthesize mediaUrl;

- (void)getVideoPlayerItem:(void (^)(AVPlayerItem *))completion {
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:mediaUrl];
    if (completion)
    completion(item);
}

@end

@implementation LenzImageSourcePathModel

@synthesize mediaPath;


- (void)getVideoPlayerItem:(void (^)(AVPlayerItem *))completion {
    NSURL *fileUrl = [NSURL fileURLWithPath:mediaPath];
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:fileUrl];
    if (completion)
        completion(item);
}

@end
