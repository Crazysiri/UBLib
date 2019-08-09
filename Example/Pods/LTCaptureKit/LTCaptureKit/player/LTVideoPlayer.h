//
//  LTVideoPlayer.h
//  LenzBusiness
//
//  Created by Zero on 2019/2/14.
//  Copyright © 2019 LenzTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface LTVideoPlayer : NSObject

@property (nonatomic, strong,readonly) AVPlayerLayer *playerLayer;

@property (nonatomic,assign) BOOL loop;

- (id)initWithURL:(NSURL *)url;

- (void)pause;

- (void)play;

@end

