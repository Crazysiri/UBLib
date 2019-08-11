//
//  PHAsset+toLenzImageSourceObject.m
//  LenzAlbum
//
//  Created by Zero on 2019/2/23.
//

#import "PHAsset+toLenzImageSourceObject.h"
#import "LenzAlbumTool.h"

#include <objc/runtime.h>

//static NSString *const kLenzVideoTimeKey;


@implementation PHAsset (toLenzImageSourceObject)

- (LenzSourceObjectType)type {
    return (LenzSourceObjectType)self.mediaType;
}


- (NSString *)videoTime {

    return [LenzAlbumTool transformVideoTimeToString:self.duration];
}

- (void)getVideoPlayerItem:(void (^)(AVPlayerItem *))completion {
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.networkAccessAllowed=YES;
    [[PHCachingImageManager defaultManager] requestPlayerItemForVideo:self options:options resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
        if (completion) {
            completion(playerItem);
        }
    }];
}
@end
