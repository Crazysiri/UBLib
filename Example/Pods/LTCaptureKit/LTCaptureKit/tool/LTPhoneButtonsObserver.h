//
//  LTPhoneButtonsObserver.h
//  LenzTechCaptureKit
//
//  Created by Zero on 2019/5/17.
//  Copyright © 2019 Zero. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LTPhoneButtonsObserver : NSObject

- (void)viewWillAppear;

- (void)viewWillDisappear;

//int key 1 上键 2 下键
@property (nonatomic,copy) void (^keyObservered)(int key);

@end

NS_ASSUME_NONNULL_END
