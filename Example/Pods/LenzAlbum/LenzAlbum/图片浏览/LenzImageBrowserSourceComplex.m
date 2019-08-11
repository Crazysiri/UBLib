//
//  LenzImageBrowserSourceComplex.m
//  LenzPictureQuestionModule
//
//  Created by Zero on 2019/3/1.
//  Copyright © 2019 Zero. All rights reserved.
//

#import "LenzImageBrowserSourceComplex.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation LenzImageBrowserSourceComplex
- (void)fetchImage:(LenzImageFetchParams *)params completion:(void (^)(UIImage * _Nullable))completion {
    id <LenzImageSourceObject> model = [self objectAtIndex:params.index];
    
    if ([model conformsToProtocol:@protocol(LenzImageSourceURLObject)]) {
        id <LenzImageSourceURLObject> model_ = (id <LenzImageSourceURLObject>)model;
        [params.imageView sd_setImageWithURL:model_.mediaUrl placeholderImage:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (completion) {
                completion(image);
            }
        }];
    } else if ([model conformsToProtocol:@protocol(LenzImageSourcePathObject)]) {
        id <LenzImageSourcePathObject> model_ = (id <LenzImageSourcePathObject>)model;

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage imageWithContentsOfFile:model_.mediaPath];
            dispatch_async(dispatch_get_main_queue(), ^{
                params.imageView.image = image;
                if (completion) {
                    completion(image);
                }
            });
        });
    } else if ([model conformsToProtocol:@protocol(LenzImageSourceObject)]){
        PHAsset *asset = (PHAsset *)model;
        
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.synchronous = NO;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.networkAccessAllowed=YES;
        [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:params.size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(),^{//主线程更新ui
                params.imageView.image = result;
                if (completion) {
                    completion(result);
                }
            });
        }];
    }
}

- (void)deleteObjectAtIndex:(NSInteger)index completion:(void (^)(NSDictionary *))completion {
    id <LenzImageSourceObject> model = [self objectAtIndex:index];
    
    if ([model conformsToProtocol:@protocol(LenzImageSourceURLObject)]) {

        [self deleteObjectAtIndex:index];
        if (completion) {
            completion(@{@"index":@(index),@"object":model});
        }
        
    } else if ([model conformsToProtocol:@protocol(LenzImageSourcePathObject)]) {
        id <LenzImageSourcePathObject> model_ = (id <LenzImageSourcePathObject>)model;
        NSString *path = model_.mediaPath;
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm removeItemAtPath:path error:nil]) {
        [self deleteObjectAtIndex:index];
            if (completion) {
                completion(@{@"index":@(index),@"object":model});
            }
        } else {
            if (completion) {
                completion(nil);
            }
        }

    } else if ([model conformsToProtocol:@protocol(LenzImageSourceObject)]){
        PHAsset *asset = (PHAsset *)model;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            
            PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[asset.localIdentifier] options:nil];
            if (result.count > 0) {
                [PHAssetChangeRequest deleteAssets:result];
            }
            
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
        [self deleteObjectAtIndex:index];
            if (success) {
                
                //返回删除的index 和 object
                if (completion) {
                    completion(@{@"index":@(index),@"object":asset});
                }
            } else {
                if (completion) {
                    completion(nil);
                }
            }
        }];
    }
}
@end
