//
//  LTCaptureTimerTool.m
//  LenzTechCaptureKit
//
//  Created by Zero on 2019/5/17.
//  Copyright © 2019 Zero. All rights reserved.
//

#import "LTCaptureTimerTool.h"

#import "UBWeakTimer.h"

@interface LTCaptureTimerTool ()

@property (nonatomic, weak) NSTimer *timer;

@property (nonatomic,assign) NSInteger coolDown;
@end

@implementation LTCaptureTimerTool

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.step = 1.0;
    }
    return self;
}

- (void)startTimer {
    
    [self endTimer];
    
    _timer = [UBWeakTimer scheduledTimerWithTimeInterval:self.step target:self selector:@selector(fire) userInfo:nil repeats:YES];
    
    self.coolDown = self.continuesInterval;
    
    self.isContinues_status = YES;
    
    if (self.fireWhenStart) {
        self.fireWhenStart(self.coolDown);
    }
}

- (void)endTimer {
    if (self.timer) {
        self.isContinues_status = NO;
        _currentCount = 0;
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)fire {
    
    self.coolDown --;
    
    //每次减一，然后回调
    if (self.fireEveryStep) {
        self.fireEveryStep (self.coolDown);
    }
    
    //如果到达指定的间隔
    if (self.coolDown == 0) {
        
        //重置时间
        self.coolDown = self.continuesInterval;
        
        BOOL canCount = YES;
        
        if (self.fireWhenReachInterval) {
            canCount = self.fireWhenReachInterval(self.currentCount,self.maxCount);
        }
        
        if (canCount) {
            self.currentCount++;
        }
        
        if (self.maxCount != 0) {
            if (self.currentCount == self.maxCount) {
                [self endTimer];
            }
        }
        
    }
    
    
}//执行相机拍照功能


- (void)pause {
    if (self.timer) {
        self.timer.fireDate = [NSDate distantFuture];
    }
}


- (void)resume {
    if (self.timer) {
        self.timer.fireDate = [NSDate date];
    }
}
@end
