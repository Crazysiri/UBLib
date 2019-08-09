//
//  LTPhoneButtonsObserver.m
//  LenzTechCaptureKit
//
//  Created by Zero on 2019/5/17.
//  Copyright © 2019 Zero. All rights reserved.
//

#import "LTPhoneButtonsObserver.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface LTPhoneButtonsObserver ()
{
    MPVolumeView *_volumeView; //替换系统音量的view
    float myvolume;  //音量键大小
}

@end

@implementation LTPhoneButtonsObserver

- (void)dealloc
{
    [_volumeView removeFromSuperview];
    _volumeView = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        float volume = [[AVAudioSession sharedInstance] outputVolume];
        myvolume = volume;
    }
    return self;
}

- (void)viewWillAppear {
    //隐藏系统音量提示。
    _volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(0, -100, 0, 0)];
    [[UIApplication sharedApplication].windows[0] addSubview:_volumeView];
    //告诉系统，我们要接受远程控制事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    //音量键控制方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(systemVolumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
}

- (void)viewWillDisappear {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

- (void)systemVolumeChanged:(NSNotification *)x {
    
    NSDictionary *dic =[x valueForKey:@"userInfo"];
    NSLog(@"音量键%@",dic);
    NSString *type=dic[@"AVSystemController_AudioVolumeChangeReasonNotificationParameter"];
    if ([type isEqualToString:@"RouteChange"]) return;//线路事件
    
    float volume =[dic[@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    NSLog(@"myvolume:%f--volume:%f ",myvolume,volume);
    
    if ((myvolume<volume || volume==1) && volume != 0) {
        if (self.keyObservered) {
            self.keyObservered(1);
        }
    }else{
        //监听到下键
        if (self.keyObservered) {
            self.keyObservered(2);
        }
    }
    myvolume=volume;

}

@end
