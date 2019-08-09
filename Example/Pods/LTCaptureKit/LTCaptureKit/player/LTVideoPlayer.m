//
//  LTVideoPlayer.m
//  LenzBusiness
//
//  Created by Zero on 2019/2/14.
//  Copyright © 2019 LenzTech. All rights reserved.
//

#import "LTVideoPlayer.h"
#import <UIKit/UIKit.h>


@interface LTVideoPlayer ()

@property (nonatomic, strong) AVAsset *asset;

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) AVPlayerItem *item;

@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (copy,nonatomic) NSURL *url;

@property (nonatomic, strong) id timeObserver;

@end

@implementation LTVideoPlayer

- (void)dealloc {
    [self.item removeObserver:self forKeyPath:@"status" context:nil];
    [self.item removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
    [self.player removeTimeObserver:self.timeObserver];
    self.player = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (id)initWithURL:(NSURL *)url {
    if (self) {
        self.url = url;
        self.asset = [AVAsset assetWithURL:url];
        [self setupPlayer];
    }
    return self;
}

- (void)setupPlayer {
    
    NSParameterAssert(self.url);
    
    NSArray *keys = @[@"tracks",@"duration",@"commonMetadata"];
    
    self.item = [AVPlayerItem playerItemWithAsset:self.asset automaticallyLoadedAssetKeys:keys];
    
    self.player = [[AVPlayer alloc] initWithPlayerItem:self.item];
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.playerLayer = playerLayer;

    if ([[[UIDevice currentDevice] systemVersion] integerValue] >10)
    {
        self.player.automaticallyWaitsToMinimizeStalling = NO; // 在iOS10下，默认为YES，如果视频加载不出来，系统会一直等待加载，造成下一个视频也无法播放
    }
    
    [self.item addObserver:self
                forKeyPath:@"status"
                   options:NSKeyValueObservingOptionNew
                   context:nil];
    
    [self.item addObserver:self
                forKeyPath:@"loadedTimeRanges"
                   options:NSKeyValueObservingOptionNew
                   context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerDidFinished:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"])
    {
        if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay)
        {
            double durition = CMTimeGetSeconds(self.item.duration);
            [self addPlaterProgressTimer];
        }
        else if (self.player.currentItem.status == AVPlayerItemStatusFailed)
        {
            NSLog(@"播放视频失败");
        }
        else if (self.player.currentItem.status == AVPlayerItemStatusUnknown)
        {
            NSLog(@"未知状态");
        }
    }
    else if ([keyPath isEqualToString:@"loadedTimeRanges"])
    {
        NSLog(@"播放进度");
        CMTime duration = self.item.currentTime;
        double totalDuration = CMTimeGetSeconds(duration);
        NSLog(@"totalDuration == %f", totalDuration);
    }
}

- (void)addPlaterProgressTimer {
    __weak __typeof(&*self)weakSelf = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        NSTimeInterval currentTime = CMTimeGetSeconds(weakSelf.player.currentItem.currentTime);
        NSInteger cMin = currentTime / 60;
        NSInteger cSec = (NSInteger)currentTime % 60;
        NSString *currentString = [NSString stringWithFormat:@"%02ld:%02ld", cMin, cSec];
//        weakSelf.currentLabel.text = currentString;
        
        double currentValue = CMTimeGetSeconds(weakSelf.player.currentTime);
//        weakSelf.slider.value = currentValue;
    }];
}


- (void)seekToTime:(CGFloat)time {
    double totalTime   = CMTimeGetSeconds(self.item.duration);
    
    if (time < totalTime-0.01f)
    {
        [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
}


- (void)playerDidFinished:(NSNotification *)noti {
    
    if (self.loop) {
        // 播放完成后重复播放
        // 跳到最新的时间点开始播放
        [self.player seekToTime:CMTimeMake(0, 1)];
        [self.player play];
    }
}

- (void)pause {
    [self.player pause];
}

- (void)play {
    [self.player play];
}
@end
