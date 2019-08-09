//
//  AVCaptureDevice+additions.m
//  LenzTechCaptureKit
//
//  Created by Zero on 2019/4/28.
//  Copyright © 2019 Zero. All rights reserved.
//

#import "AVCaptureDevice+additions.h"

@interface LTQualityOfService : NSObject

@property (nonatomic, strong, readonly) AVCaptureDeviceFormat *format;

@property (nonatomic, strong, readonly) AVFrameRateRange *frameRateRange;

@property (nonatomic, assign, readonly) BOOL isHighFrameRate;


+ (instancetype)qosWithFormat:(AVCaptureDeviceFormat *)format
               frameRateRange:(AVFrameRateRange *)range;

- (BOOL)isHighFrameRate;

@end


@implementation LTQualityOfService

+ (instancetype)qosWithFormat:(AVCaptureDeviceFormat *)format frameRateRange:(AVFrameRateRange *)range {
    return [[self alloc] initWithFormat:format frameRateRange:range];
}

- (instancetype)initWithFormat:(AVCaptureDeviceFormat *)format
                frameRateRange:(AVFrameRateRange *)range
{
    self = [super init];
    if (self) {
        _format = format;
        _frameRateRange = range;
    }
    return self;
}

- (BOOL)isHighFrameRate {
    return self.frameRateRange.maxFrameRate > 30.0f;
}

@end

@implementation AVCaptureDevice (additions)

- (BOOL)supportsHighFrameRateCapture {
    if (![self hasMediaType:AVMediaTypeVideo]) {
        return NO;
    }
    
    return [self findHighestQualityOfService].isHighFrameRate;
}

- (LTQualityOfService *)findHighestQualityOfService {
    AVCaptureDeviceFormat *maxFormat = nil;
    AVFrameRateRange *maxFrameRateRange = nil;
    
    for (AVCaptureDeviceFormat *format in self.formats) {
        FourCharCode codecType = CMVideoFormatDescriptionGetCodecType(format.formatDescription);
        
        if (codecType == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {
            NSArray *frameRateRanges = format.videoSupportedFrameRateRanges;
            
            for (AVFrameRateRange *range in frameRateRanges) {
                if (range.maxFrameRate > maxFrameRateRange.maxFrameRate) {
                    maxFormat = format;
                    maxFrameRateRange = range;
                }
            }
        }
    }
    
    return [LTQualityOfService qosWithFormat:maxFormat frameRateRange:maxFrameRateRange];
}


- (BOOL)enableHighFrameRateCapture:(NSError * _Nullable __autoreleasing *)error {
    LTQualityOfService *qos = [self findHighestQualityOfService];
    if (!qos.isHighFrameRate) {
        
        if (error) {
            NSString *message = @"Device does not support high FPS capture";
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:message};
            NSUInteger code = -1;
            *error = [NSError errorWithDomain:@"capture high frame error" code:code userInfo:userInfo];
        }
        
        return NO;
    }
    
    
    
    if (![self lockForConfiguration:error]) {
        
        CMTime minFrameDuration = qos.frameRateRange.minFrameDuration;
        
        self.activeFormat = qos.format;
        self.activeVideoMaxFrameDuration = minFrameDuration;
        self.activeVideoMinFrameDuration = minFrameDuration;
        
        [self unlockForConfiguration];
        return YES;
    }
    return NO;
}

@end
