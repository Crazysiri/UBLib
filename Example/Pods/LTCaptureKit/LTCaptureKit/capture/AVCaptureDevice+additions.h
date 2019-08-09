//
//  AVCaptureDevice+additions.h
//  LenzTechCaptureKit
//
//  Created by Zero on 2019/4/28.
//  Copyright © 2019 Zero. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

//高帧率 捕捉
@interface AVCaptureDevice (additions)

- (BOOL)supportsHighFrameRateCapture;

- (BOOL)enableHighFrameRateCapture:(NSError **)error;

@end
