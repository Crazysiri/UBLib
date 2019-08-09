#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "LTCameraKit.h"
#import "LTCameraKitDefines.h"
#import "LTCustomCameraViewDelegate.h"
#import "LTImageCaptureController.h"
#import "UIImage+capture.h"
#import "AVCaptureDevice+additions.h"
#import "LTVideoCapture.h"
#import "LTVideoDataOutput.h"
#import "LTVideoCompress.h"
#import "LTMotion.h"
#import "LTVideoPlayer.h"
#import "LTCaptureTimerTool.h"
#import "LTPhoneButtonsObserver.h"
#import "LTMediaLibraryTool.h"
#import "LTMediaWriter.h"
#import "LTVideoCaptureAndWriteController.h"
#import "LTVideoInfo.h"

FOUNDATION_EXPORT double LTCaptureKitVersionNumber;
FOUNDATION_EXPORT const unsigned char LTCaptureKitVersionString[];

