//
//  LenzImageSourceObject.h
//  Pods
//
//  Created by Zero on 2019/2/23.
//

#ifndef LenzImageSourceObject_h
#define LenzImageSourceObject_h

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger,LenzSourceObjectType) {
    LenzSourceObjectTypeUnknown = 0,
    LenzSourceObjectTypeImage,
    LenzSourceObjectTypeVideo
};

@protocol LenzImageSourceObject <NSObject>

@property (nonatomic,assign) LenzSourceObjectType type;

#pragma mark - for video

@property (copy,nonatomic) NSString *videoTime;

- (void)getVideoPlayerItem:(void(^)(AVPlayerItem *item))completion;

@end

@protocol LenzImageSourceURLObject <LenzImageSourceObject>

@property (nonatomic,copy) NSURL *mediaUrl;

@end

@protocol LenzImageSourcePathObject <LenzImageSourceObject>

///这个是全的路径
@property (nonatomic,copy) NSString *mediaPath;


@end


#endif /* LenzImageSourceObject_h */
