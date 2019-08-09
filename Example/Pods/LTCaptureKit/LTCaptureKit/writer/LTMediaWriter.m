//
//  LTMediaWriter.m
//  LenzBusiness
//
//  Created by Zero on 2019/2/13.
//  Copyright © 2019 LenzTech. All rights reserved.
//

#import "LTMediaWriter.h"

#import "LTMediaLibraryTool.h"

@interface LTMediaWriter ()
{
    
    CMTime _audioTimestamp;
    CMTime _videoTimestamp;
    
    NSURL *_outputURL;
    
    BOOL _saveToAlbum;
    
}

@property (nonatomic,assign) BOOL canWriting;

@property (nonatomic, strong) AVAssetWriter *assetWriter;

@property (nonatomic, strong) AVAssetWriterInput *assetWriterAudioInput;
@property (nonatomic, strong) AVAssetWriterInput *assetWriterVideoInput;

///缓冲区参数
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *adaptor;



@end

@implementation LTMediaWriter

- (instancetype)initWithOutputURL:(NSURL *)outputURL
{
    self = [super init];
    if (self) {
        
        _saveToAlbum = YES;
        
        _outputURL = outputURL;
        
        //上保险
        NSString *filePath = [[outputURL absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        BOOL isDirectory = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory])
        {
            if ([[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil])
            {
                NSLog(@"");
            }
        }
        
        NSError *error = nil;
        
        self.assetWriter = [AVAssetWriter assetWriterWithURL:outputURL fileType:AVFileTypeMPEG4 error:&error];
        if (error) {
            NSLog(@"asset writer error: %@",error);
            self.assetWriter = nil;
        }
        
        self.assetWriter.shouldOptimizeForNetworkUse = YES;
        self.assetWriter.metadata = [self _metadata];
        
        _audioTimestamp = kCMTimeInvalid;
        _videoTimestamp = kCMTimeInvalid;
        
    }
    return self;
}

- (BOOL)enableAudioWithSettings:(LTMediaWriterAudioSettings *)setting {
    
    NSDictionary *audioSettings = [setting settings];
    
    if (!_assetWriterAudioInput && [_assetWriter canApplyOutputSettings:audioSettings forMediaType:AVMediaTypeAudio]) {
        _assetWriterAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioSettings];
        
        _assetWriterAudioInput.expectsMediaDataInRealTime = YES;
        
        if (_assetWriterAudioInput && [_assetWriter canAddInput:_assetWriterAudioInput]) {
            [_assetWriter addInput:_assetWriterAudioInput];
            
            NSLog(@"setup audio input with settings sampleRate (%f) channels (%lu) bitRate (%ld)",[[audioSettings objectForKey:AVSampleRateKey] floatValue],
                  (unsigned long)[[audioSettings objectForKey:AVNumberOfChannelsKey] unsignedIntegerValue],
                  (long)[[audioSettings objectForKey:AVEncoderBitRateKey] integerValue]);
        }
        
    } else {
        _assetWriterAudioInput = nil;
    }
    return self.isAudioReady;
}

- (BOOL)enableVideoWithSettings:(LTMediaWriterVideoSettings *)setting {
    
    
    if (_assetWriterVideoInput) { //配置过了不用配置
        return self.isVideoReady;
    }
    
    
    
    NSDictionary *videoSettings = [setting settings];
    
    
    if (![_assetWriter canApplyOutputSettings:videoSettings forMediaType:AVMediaTypeVideo]) {
        _assetWriterVideoInput = nil;
        return self.isVideoReady;
    }
    
    _assetWriterVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    _assetWriterVideoInput.expectsMediaDataInRealTime = YES;
    
    if (setting.rotate == 0) {
        _assetWriterVideoInput.transform = CGAffineTransformIdentity;
    } else {
        _assetWriterVideoInput.transform = CGAffineTransformMakeRotation(setting.rotate);
    }
    
    if (!_assetWriterVideoInput) {
        return NO;
    }
    
    if (![_assetWriter canAddInput:_assetWriterVideoInput]) {
        return NO;
    }
    
    [_assetWriter addInput:_assetWriterVideoInput];
    
    
    //kCVPixelFormatType_32ARGB
    //配置缓冲区
    NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey, nil];
    
    self.adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_assetWriterVideoInput
                                                                                    sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    
    
    NSDictionary *videoCompressionProperties = videoSettings[AVVideoCompressionPropertiesKey];
    if (videoCompressionProperties) {
        NSLog(@"compression settings bps (%f) frameInterval(%ld)",[videoCompressionProperties[AVVideoAverageBitRateKey] floatValue],
              (long)[videoCompressionProperties[AVVideoMaxKeyFrameIntervalKey] integerValue]);
        
    }
    
    
    return self.isVideoReady;
}


#pragma mark - sample buffer writing

- (void)writeSampleBuffer:(CMSampleBufferRef)sampleBuffer mediaType:(int)type // 1 video 2 audio
{
    if (!CMSampleBufferDataIsReady(sampleBuffer)) {
        return;
    }
    
    // setup the writer
    if ( _assetWriter.status == AVAssetWriterStatusUnknown ) {
        
        if ([_assetWriter startWriting]) {
            CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            [_assetWriter startSessionAtSourceTime:timestamp];
            _canWriting = YES;
            NSLog(@"started writing with status (%ld)", (long)_assetWriter.status);
        } else {
            NSLog(@"error when starting to write (%@)", [_assetWriter error]);
            return;
        }
        
    }
    
    // check for completion state
    if ( _assetWriter.status == AVAssetWriterStatusFailed ) {
        NSLog(@"writer failure, (%@)", _assetWriter.error.localizedDescription);
        return;
    }
    
    if (_assetWriter.status == AVAssetWriterStatusCancelled) {
        NSLog(@"writer cancelled");
        return;
    }
    
    if ( _assetWriter.status == AVAssetWriterStatusCompleted) {
        NSLog(@"writer finished and completed");
        return;
    }
    
    // perform write
    if ( _assetWriter.status == AVAssetWriterStatusWriting && _canWriting ) {
        
        CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        CMTime duration = CMSampleBufferGetDuration(sampleBuffer);
        if (duration.value > 0) {
            timestamp = CMTimeAdd(timestamp, duration);
        }
        
        if (type == 1) { //video
            if (_assetWriterVideoInput.readyForMoreMediaData) {
                if ([_assetWriterVideoInput appendSampleBuffer:sampleBuffer]) {
                    _videoTimestamp = timestamp;
                } else {
                    NSLog(@"writer error appending video (%@)", _assetWriter.error);
                }
            }
        } else if (type == 2) { //audio
            if (_assetWriterAudioInput.readyForMoreMediaData) {
                if ([_assetWriterAudioInput appendSampleBuffer:sampleBuffer]) {
                    _audioTimestamp = timestamp;
                } else {
                    NSLog(@"writer error appending audio (%@)", _assetWriter.error);
                }
            }
        }
        
    }
}

- (BOOL)finishWriting
{
    _canWriting = NO;
    
    if (_assetWriter.status == AVAssetWriterStatusUnknown ||
        _assetWriter.status == AVAssetWriterStatusCompleted) {
        NSLog(@"asset writer was in an unexpected state (%@)", @(_assetWriter.status));
        return NO;
    }
    
    @try {
        [_assetWriterVideoInput markAsFinished];
        [_assetWriterAudioInput markAsFinished];
        
        __weak typeof(self) weakself = self;
        
        [_assetWriter endSessionAtSourceTime:_videoTimestamp];
        
        [_assetWriter finishWritingWithCompletionHandler:^{
            NSLog(@"finishWritingWithCompletionHandler");
            __strong typeof(weakself) sSelf = weakself;
            
            if (!sSelf) {
                return;
            }
            
            if (sSelf.writingCompletion) {
                sSelf.writingCompletion();
            }
            if (sSelf->_saveToAlbum) {
                [LTMediaLibraryTool saveVideoWithVideoUrl:sSelf->_outputURL assetCollectionName:nil completion:weakself.saveToAlbumCompletion];
            }
        }];
    } @catch (NSException *exception) {
        return NO;
    }
    
    return YES;
}


#pragma mark - optional

- (void)setMetadata:(NSArray<AVMutableMetadataItem *> *)meta {
    self.assetWriter.metadata = meta;
}

#pragma mark - private

- (NSArray *)_metadata {
    UIDevice *currentDevice = [UIDevice currentDevice];
    //device model
    AVMutableMetadataItem *modelItem = [[AVMutableMetadataItem alloc]init];
    [modelItem setKeySpace:AVMetadataKeySpaceCommon];
    [modelItem setKey:AVMetadataCommonKeyModel];
    [modelItem setValue:currentDevice.localizedModel];
    
    //software
    AVMutableMetadataItem *softwareItem = [[AVMutableMetadataItem alloc] init];
    [softwareItem setKeySpace:AVMetadataKeySpaceCommon];
    [softwareItem setKey:AVMetadataCommonKeySoftware];
    [softwareItem setValue:@"Lenz"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSString *currentStr = [dateFormatter stringFromDate:[NSDate date]];
    //creation date
    AVMutableMetadataItem *creationDateItem = [[AVMutableMetadataItem alloc]init];
    [creationDateItem setKeySpace:AVMetadataKeySpaceCommon];
    [creationDateItem setKey:AVMetadataQuickTimeMetadataKeyCreationDate];
    [creationDateItem setValue:currentStr];
    
    return @[modelItem,softwareItem,creationDateItem];
}


#pragma mark - getters/setters

- (BOOL)isAudioReady
{
    AVAuthorizationStatus audioAuthorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    BOOL isAudioNotAuthorized = (audioAuthorizationStatus == AVAuthorizationStatusNotDetermined || audioAuthorizationStatus == AVAuthorizationStatusDenied);
    BOOL isAudioSetup = (_assetWriterAudioInput != nil) || isAudioNotAuthorized;
    
    return isAudioSetup;
}

- (BOOL)isVideoReady
{
    AVAuthorizationStatus videoAuthorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    BOOL isVideoNotAuthorized = (videoAuthorizationStatus == AVAuthorizationStatusNotDetermined || videoAuthorizationStatus == AVAuthorizationStatusDenied);
    BOOL isVideoSetup = (_assetWriterVideoInput != nil) || isVideoNotAuthorized;
    
    return isVideoSetup;
}
@end









@implementation LTMediaWriterVideoSettings

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.videoSize = CGSizeMake(640,360);
        self.bitsPerPixel = 6.0f;
        self.frameRate = 25;
        //        self.rotate = 0;
        self.rotate = M_PI / 2.0;
        self.AVVideoProfileLevelH264 = AVVideoProfileLevelH264MainAutoLevel;
        
    }
    return self;
}

- (NSDictionary *)settings {
    NSInteger bitesPerSecond = self.videoSize.width * self.videoSize.height * self.bitsPerPixel;
    
    //码率 帧率
    NSDictionary *compressionProperties =
    @{
      AVVideoAverageBitRateKey:@(bitesPerSecond),
      AVVideoExpectedSourceFrameRateKey:@(self.frameRate),
      AVVideoMaxKeyFrameIntervalKey:@(self.frameRate),
      AVVideoProfileLevelKey:self.AVVideoProfileLevelH264
      
      };
    
    
    NSDictionary *settings =
    @{
      AVVideoCodecKey:AVVideoCodecH264,
      AVVideoScalingModeKey:AVVideoScalingModeResizeAspectFill,
      AVVideoWidthKey:@(self.videoSize.width),
      AVVideoHeightKey:@(self.videoSize.height),
      AVVideoCompressionPropertiesKey:compressionProperties
      };
    
    return settings;
}

@end




@implementation LTMediaWriterAudioSettings
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.bitratePerChannel = 28000;
        self.numberOfChannels = 1;
        self.sampleRate = 22050;
    }
    return self;
}

- (NSDictionary *)settings {
    return @{
             AVEncoderBitRatePerChannelKey:@(self.bitratePerChannel),
             AVFormatIDKey:@(kAudioFormatMPEG4AAC),
             AVNumberOfChannelsKey:@(self.numberOfChannels),
             AVSampleRateKey:@(self.sampleRate)
             };
}

@end
