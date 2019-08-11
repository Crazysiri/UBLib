//
//  PHAsset+toLenzImageSourceObject.h
//  LenzAlbum
//
//  Created by Zero on 2019/2/23.
//

#import <Photos/Photos.h>

#import "LenzImageSourceObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface PHAsset (toLenzImageSourceObject) <LenzImageSourceObject>

- (void)setVideoTime:(NSString *)videoTime UNAVAILABLE_ATTRIBUTE;

- (void)setType:(LenzSourceObjectType)type UNAVAILABLE_ATTRIBUTE;

@end

NS_ASSUME_NONNULL_END
