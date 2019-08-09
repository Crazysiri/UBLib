//
//  XDJCustomCameraViewDelegate.h
//  Dandanjia
//
//  Created by qiuyoubo on 2018/4/28.
//  Copyright © 2018年 xiandanjia.com. All rights reserved.
//

#ifndef LTCustomCameraViewDelegate_h
#define LTCustomCameraViewDelegate_h
#import "LTCameraKitDefines.h"


@protocol LTCustomCameraViewDelegate <NSObject>
- (void)setTakePhotoBlock:(void (^)(void))takePhotoBlock;
- (void)setBackBlock:(void (^)(void))backoBlock;
- (void)setSelectFromAlbumBlock:(void(^)(void))selectFromAlbumBlock;
@optional
- (void)setFlashChangeBlock:(XDCameraFlashMode (^)(void))flashChangeBlock; //切换模式（开，关，自动）
- (void)setFlashSwitchBlock:(XDCameraFlashMode (^)(void))flashSwitchBlock; //打开或关闭（开，关）

//- (void)back;
//- (void)switchCamera;
@end

#endif /* XDJCustomCameraViewDelegate_h */
