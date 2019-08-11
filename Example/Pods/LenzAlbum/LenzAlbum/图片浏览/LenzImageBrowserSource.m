//
//  LenzImageBrowserSource.m
//  LenzBusiness
//
//  Created by Zero on 2018/12/25.
//  Copyright © 2018年 LenzTech. All rights reserved.
//

#import "LenzImageBrowserSource.h"

NSString * const kLenzImageBrowserSourceObjectsChangedNotification = @"kLenzImageBrowserSourceObjectsChangedNotification";

@interface LenzImageBrowserSource ()

@property (nonatomic, strong) NSMutableArray *objectsArray;

@end

@implementation LenzImageBrowserSource

- (id)initWithSourceObjects:(NSArray <id<LenzImageSourceObject>> *)objects {
    self = [super init];
    if (self) {
        [self setObjects:objects];
    }
    return self;
}

- (void)fetchImage:(LenzImageFetchParams *)params completion:(void (^)(UIImage * _Nullable))completion {
    
}

- (id<LenzImageSourceObject>)objectAtIndex:(NSInteger)index {
    if (index >= self.objectsArray.count) {
        return nil;
    }
    return self.objectsArray[index];
}

- (NSInteger)count {
    return self.objectsArray.count;
}

- (void)appendObjects:(NSArray<id<LenzImageSourceObject>> *)objects {
    [self.objectsArray addObjectsFromArray:objects];
    //发送数据变化通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kLenzImageBrowserSourceObjectsChangedNotification object:nil];

}

- (void)setObjects:(NSArray<id<LenzImageSourceObject>> *)objects {
    [self.objectsArray removeAllObjects];
    [self.objectsArray addObjectsFromArray:objects];
    //发送数据变化通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kLenzImageBrowserSourceObjectsChangedNotification object:nil];

}

/*
 删
 */
- (void)deleteObjectAtIndex:(NSInteger)index {
    [self.objectsArray removeObjectAtIndex:index];
    //发送数据变化通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kLenzImageBrowserSourceObjectsChangedNotification object:nil];
}

- (void)deleteObjectAtIndex:(NSInteger)index completion:(void (^)(NSDictionary *result))completion {
    
}

- (NSMutableArray *)objectsArray {
    if (!_objectsArray) {
        _objectsArray = [NSMutableArray array];
    }
    return _objectsArray;
}

@end


#import <SDWebImage/UIImageView+WebCache.h>
#import "LenzImageSourceModel.h"
@interface LenzImageBrowserSourceURL ()

@end

@implementation LenzImageBrowserSourceURL

- (id)initWithURLs:(NSArray <NSString *> *)urls {
    if (self = [super init]) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSString *url in urls) {
            LenzImageSourceURLModel *model = [[LenzImageSourceURLModel alloc] init];
            model.mediaUrl = [NSURL URLWithString:url];
            [array addObject:model];
        }
        [self setObjects:array];
    }
    return self;
}

- (id<LenzImageSourceURLObject>)objectAtIndex:(NSInteger)index {
    return (id<LenzImageSourceURLObject>)[super objectAtIndex:index];
}

- (void)fetchImage:(LenzImageFetchParams *)params completion:(void (^)(UIImage * _Nullable))completion {

    id <LenzImageSourceURLObject> model = self.objectsArray[params.index];
    
    [params.imageView sd_setImageWithURL:model.mediaUrl placeholderImage:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (completion) completion(image);
    }];
}

- (void)deleteObjectAtIndex:(NSInteger)index completion:(void (^)(NSDictionary *))completion {
    
    //校验 外部 是否能删除，因为url一般都是接口获取，可能需要先删除服务端的数据 再删除本地
    
    __weak typeof(self) weakself = self;
    
    id <LenzImageSourceURLObject> model = [self objectAtIndex:index];
    
    //待执行 真正删除的 block
    void (^deleteBlock)(BOOL) = ^ (BOOL canDelete){
        
        NSDictionary *result = nil;
        
        if (canDelete) {
            [weakself deleteObjectAtIndex:index];
            result = @{@"index":@(index),@"object":model};
        }
        
        if (completion) {
            completion(result);
        }
    };
    

    
    if (self.canDeleteAsynBlock) { //如果需要异步校验，先异步校验（网络请求删除等。。）
        
        void (^completion)(BOOL) = ^(BOOL canDelete) {
            deleteBlock(canDelete);
        };
        
        self.canDeleteAsynBlock(model,completion);
    } else { //否则 直接删除
        deleteBlock(YES);
    }
    

    

}

@end





#import "PHAsset+toLenzImageSourceObject.h"

@interface LenzImageBrowserSourceAlbum () <PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) PHFetchResult *result;


@end

@implementation LenzImageBrowserSourceAlbum

///默认初始化，全部相册中的图片
- (id)init {
    if (self = [super init]) {
//        PHFetchOptions *options = [[PHFetchOptions alloc] init];
//        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        self.result =  [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:nil];
        
        ///注册 照片 变更通知
        [PHPhotoLibrary.sharedPhotoLibrary registerChangeObserver:self];
    }
    return self;
}

- (id)initWithType:(PHAssetMediaType)type {
    if (self = [super init]) {
        self.result =  [PHAsset fetchAssetsWithMediaType:type options:nil];
        ///注册 照片 变更通知
        [PHPhotoLibrary.sharedPhotoLibrary registerChangeObserver:self];
    }
    return self;
}

- (id)initWithAll {
    if (self = [super init]) {
        self.result =  [PHAsset fetchAssetsWithOptions:nil];
        ///注册 照片 变更通知
        [PHPhotoLibrary.sharedPhotoLibrary registerChangeObserver:self];
    }
    return self;
}

- (id)initWithResult:(PHFetchResult *)result {
    if (self = [super init]) {
        self.result = result;
        
        ///注册 照片 变更通知
        [PHPhotoLibrary.sharedPhotoLibrary registerChangeObserver:self];
    }
    return self;
}

///PHAsset.localIdentifier的数组
- (id)initWithLocalIdentifiers:(NSArray *)identifiers {
    if (self = [super init]) {
        
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        self.result = [PHAsset fetchAssetsWithLocalIdentifiers:identifiers options:nil];
        ///注册 照片 变更通知
        [PHPhotoLibrary.sharedPhotoLibrary registerChangeObserver:self];
    }
    return self;
}

- (NSInteger)count {
    return self.result.count;
}

- (PHAsset<LenzImageSourceObject>*)objectAtIndex:(NSInteger)index {
    return self.result[index];
}


- (void)fetchImage:(LenzImageFetchParams *)params completion:(void (^)(UIImage * _Nullable))completion {

    PHAsset *asset = self.result[params.index];

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

- (void)deleteObjectAtIndex:(NSInteger)index completion:(void(^)(NSDictionary *result))completion {
    
    id object = [self objectAtIndex:index];
    
    PHAsset *asset = object;
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[asset.localIdentifier] options:nil];
        if (result.count > 0) {
            [PHAssetChangeRequest deleteAssets:result];
        }
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
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
    

#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    
    PHFetchResultChangeDetails *details = [changeInstance changeDetailsForFetchResult:self.result];
    ///有detail 并且 习惯前后不一样
    if (details && details.fetchResultAfterChanges.count != details.fetchResultBeforeChanges.count) {
        self.result = details.fetchResultAfterChanges;
        
        //发送数据变化通知
        [[NSNotificationCenter defaultCenter] postNotificationName:kLenzImageBrowserSourceObjectsChangedNotification object:nil];
    }

}

@end






@interface LenzImageBrowserSourcePath ()

@property (copy,nonatomic) NSString *basePath;

@end

@implementation LenzImageBrowserSourcePath

- (id)initWithBasePath:(NSString *)basePath filenames:(NSArray *)filenames {
    if (self = [super init]) {
        
        NSMutableArray *array = [NSMutableArray array];
        for (NSString *filename in filenames) {
            LenzImageSourcePathModel *model = [[LenzImageSourcePathModel alloc] init];
            model.mediaPath = [NSString stringWithFormat:@"%@/%@",basePath,filename];
            [array addObject:model];
        }
        [self setObjects:array];
        self.basePath = basePath;
    }
    return self;
}

- (id)initWithPaths:(NSArray <NSString *> *)paths {
    if (self = [super init]) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSString *path in paths) {
            LenzImageSourcePathModel *model = [[LenzImageSourcePathModel alloc] init];
            model.mediaPath = path;
            [array addObject:model];
        }
        [self setObjects:array];
    }
    return self;
}

- (id<LenzImageSourcePathObject>)objectAtIndex:(NSInteger)index {
    return (id<LenzImageSourcePathObject>)[super objectAtIndex:index];
}


- (void)fetchImage:(LenzImageFetchParams *)params completion:(void (^)(UIImage * _Nullable))completion {

    __weak typeof(self) weakself = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlString = [weakself pathForIndex:params.index];
        UIImage *image = [UIImage imageWithContentsOfFile:urlString];
        dispatch_async(dispatch_get_main_queue(), ^{
            params.imageView.image = image;
            if (completion) {
                completion(image);
            }
        });
    });
  

}

- (NSString *)pathForIndex:(NSInteger)index {
    id <LenzImageSourcePathObject> object = [self objectAtIndex:index];
    NSString *urlString = object.mediaPath;
    if (!urlString) {
        urlString = @"";
    }
    return urlString;
}


- (void)deleteObjectAtIndex:(NSInteger)index completion:(void(^)(NSDictionary *result))completion {
    
    //获取 路径
    NSString *path = [self pathForIndex:index];
    //获取object
    id <LenzImageSourceObject> object = [self objectAtIndex:index];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm removeItemAtPath:path error:nil]) {
        
        //从内存数组中删除
        [self deleteObjectAtIndex:index];
        
        //返回删除的index 和 object
        if (completion) {
            completion(@{@"index":@(index),@"object":object});
        }
    } else {
        if (completion) {
            completion(nil);
        }
    }
}


@end



@implementation LenzImageFetchParams
@end
