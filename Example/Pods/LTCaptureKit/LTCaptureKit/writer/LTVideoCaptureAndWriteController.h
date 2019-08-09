//
//  LTVideoCaptureAndWriteController.h
//  LenzBusiness
//
//  Created by Zero on 2019/1/23.
//  Copyright © 2019 LenzTech. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LTMediaWriter.h"

#import "LTCameraKit.h"

@interface LTVideoCaptureAndWriteController : UIViewController

@property (nonatomic, strong,readonly) LTVideoCapture *capture;

@property (nonatomic, strong,readonly) LTMediaWriter *writer;

@property (copy,nonatomic,readonly) NSURL *fileUrl;

- (id)initWithOutputURL:(NSURL *)url;

//一般用于继承，在这个方法拿到的self.writer并设置响应属性 才是最合适的
- (void)setupWriterWithUrl:(NSURL *)url;

- (void)startVideoRecorder;

- (void)stopVideoRecorder;

- (void)reset;

@end
