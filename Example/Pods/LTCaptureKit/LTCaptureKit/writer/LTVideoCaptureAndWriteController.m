//
//  LTVideoCaptureAndWriteController.m
//  LenzBusiness
//
//  Created by Zero on 2019/1/23.
//  Copyright © 2019 LenzTech. All rights reserved.
//

#import "LTVideoCaptureAndWriteController.h"

@interface LTVideoCaptureAndWriteController () <AVCaptureVideoDataOutputSampleBufferDelegate>{
    
}

@property (nonatomic, strong) LTVideoCapture *capture;

@property (nonatomic, strong) LTMediaWriter *writer;

@property (nonatomic, strong) LTVideoDataOutput *output;


@property (copy,nonatomic) NSURL *fileUrl;
@property (nonatomic,assign) BOOL canWrite;

@end

@implementation LTVideoCaptureAndWriteController

- (id)initWithOutputURL:(NSURL *)url {
    self = [super init];
    if (self) {
        self.fileUrl = url;
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.capture start];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.capture stop];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    AVCaptureVideoDataOutput *output = self.output.output;
    output.alwaysDiscardsLateVideoFrames = YES;
    [self.capture addOutput:output];
    /*
     AVCaptureConnection *connection = [output connectionWithMediaType:AVMediaTypeVideo];
     if (connection.isVideoStabilizationSupported)
     {
     connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
     }
     
     UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
     AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
     if (statusBarOrientation != UIInterfaceOrientationUnknown)
     {
     initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
     }
     connection.videoOrientation = initialVideoOrientation;
     */
    
    
    self.capture.previewLayer.frame = self.view.bounds;
    
    [self.view.layer addSublayer:self.capture.previewLayer];
    
    // Do any additional setup after loading the view.
}

#pragma mark - 视频录制


- (void)startVideoRecorder {
    [self setupWriterWithUrl:self.fileUrl];
    self.canWrite = YES;
}

- (void)stopVideoRecorder {
    if (self.writer && ![self.writer finishWriting]) {
        self.writer = nil;
    }
    self.canWrite = NO;
}


- (void)setupWriterWithUrl:(NSURL *)url {
    
    if (self.writer) {
        
        [self stopVideoRecorder];
        
        self.writer = nil;
    }
    
    self.writer = [[LTMediaWriter alloc] initWithOutputURL:url];
    
    LTMediaWriterVideoSettings *setting = [[LTMediaWriterVideoSettings alloc] init];
    [self.writer enableVideoWithSettings:setting];
    
    self.writer.saveToAlbum = NO;
    
}

- (void)clear {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtURL:self.fileUrl error:nil];
    
}

- (void)reset {
    
    self.writer = nil;
    self.canWrite = NO;
    
}

#pragma mark - delegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    //    if (connection == [self.videoOutput connectionWithMediaType:AVMediaTypeVideo])
    if (self.canWrite) {
        [self.writer writeSampleBuffer:sampleBuffer mediaType:1];
    }
}

#pragma mark - private



#pragma mark - getters/setters

- (LTVideoDataOutput *)output {
    if (!_output) {
        __weak typeof(self) weakself = self;
        _output = [[LTVideoDataOutput alloc] initWithBuilder:^(LTVideoDataOutputBuilder *buidler) {
            NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey,
                                      nil];
            buidler.videoSettings = settings;
            buidler.delegate = weakself;
        }];
    }
    return _output;
}


- (LTVideoCapture *)capture {
    if (!_capture) {
        _capture = [[LTVideoCapture alloc] init];
    }
    return _capture;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
