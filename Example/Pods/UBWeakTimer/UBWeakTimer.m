//
//  UBWeakTimerTarget.m
//  Dandanjia
//
//  Created by qiuyoubo on 15/7/23.
//  Copyright (c) 2015年 xiandanjia.com. All rights reserved.
//

#import "UBWeakTimer.h"
@interface UBWeakTimerTarget : NSObject
@property (nonatomic, weak) NSTimer *timer;
- (id)initWithTarget:(id)target selector:(SEL)selector;

@end

@interface UBWeakTimerTarget ()
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;
@end
@implementation UBWeakTimerTarget

- (void) fire:(id)userInfo
{
    if(self.target)
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:self.selector withObject:userInfo];
#pragma clang diagnostic pop
    }
    else
    {
        [self.timer invalidate];
    }
}

- (id)initWithTarget:(id)target selector:(SEL)selector{
    self = [super init];
    if (self) {
        self.target = target;
        self.selector = selector;
    }
    return self;
}

@end


@implementation UBWeakTimer
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo {

    UBWeakTimerTarget* timerTarget = [[UBWeakTimerTarget alloc] initWithTarget:aTarget selector:aSelector];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:ti target:timerTarget selector:@selector(fire:) userInfo:userInfo repeats:yesOrNo];
    timerTarget.timer = timer;
    return timerTarget.timer;
}
@end
