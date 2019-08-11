//
//  LenzImageBrowserSource.h
//  LenzBusiness
//
//  Created by Zero on 2018/12/25.
//  Copyright © 2018年 LenzTech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import "LenzImageSourceObject.h"


//获取图片的参数
@interface LenzImageFetchParams : NSObject

@property (nonatomic,assign) NSInteger index;

@property (nonatomic, weak) UIImageView *imageView;

@property (nonatomic,assign) CGSize size;

@end

#import <Photos/Photos.h>
/*
 v0.0.1:
 支持图片浏览：
 1.从 网络url
 2.从本地path
 3.从相册（包括所有相册 和 指定 相册图片）
 4.删除
 
 v0.0.2:（未完成）
 支持视频浏览
 */


///数组值有变化 例如 调用 appendObjects 和 setObjects 或 deleteObject 会发送该通知
extern NSString * const kLenzImageBrowserSourceObjectsChangedNotification;

@interface LenzImageBrowserSource : NSObject

- (id)initWithSourceObjects:(NSArray <id<LenzImageSourceObject>> *)objects;

/*
 查
 */
@property (nonatomic,assign,readonly) NSInteger count;

- (void)fetchImage:(LenzImageFetchParams *)params completion:(void (^)(UIImage * _Nullable))completion;

- (id<LenzImageSourceObject>)objectAtIndex:(NSInteger)index;


/*
 增
 */
- (void)appendObjects:(NSArray<id<LenzImageSourceObject>> *)objects;

- (void)setObjects:(NSArray<id<LenzImageSourceObject>> *)objects;

/*
 删
 completion： @{
                @"index":@(index)
                ,@"object":id<LenzImageSourceObject>
               }
 */
- (void)deleteObjectAtIndex:(NSInteger)index completion:(void(^)(NSDictionary *result))completion;

///内部调用直接删除的接口
/*
 一般在 deleteObjectAtIndex:(NSInteger)index completion:(void(^)(NSDictionary *result))completion 之后调用 deleteObjectAtIndex
 */
- (void)deleteObjectAtIndex:(NSInteger)index;

@end


///URL用的数据源
/*
 */
@interface LenzImageBrowserSourceURL : LenzImageBrowserSource

//对应id <LenzImageSourceObject> -> mediaUrl
- (id)initWithURLs:(NSArray <NSString *> *)urls;

- (id<LenzImageSourceURLObject>)objectAtIndex:(NSInteger)index;

///异步 判断是否能删除(一般用于网络数据删除后)，点击删除时调用（deleteObjectAtIndex:ompletion:）
@property (nonatomic,copy) void (^canDeleteAsynBlock)(id <LenzImageSourceURLObject> model,void(^completion)(BOOL canDelete));

@end


///本地路径用的数据源
/*
 */
@interface LenzImageBrowserSourcePath : LenzImageBrowserSource

//路径数组
- (id)initWithPaths:(NSArray <NSString *> *)paths;

- (id<LenzImageSourcePathObject>)objectAtIndex:(NSInteger)index;

//基础路径+文件名字数组
- (id)initWithBasePath:(NSString *)basePath filenames:(NSArray *)filenames;

@end

///相册用的数据源 PHAsset（Photo Library）
@interface LenzImageBrowserSourceAlbum : LenzImageBrowserSource

///默认初始化，全部相册中的图片
- (id)init;

- (id)initWithType:(PHAssetMediaType)type;

- (id)initWithAll;


- (id)initWithResult:(PHFetchResult *)result;

///PHAsset.localIdentifier的数组
- (id)initWithLocalIdentifiers:(NSArray *)identifiers;



//暂时不支持，后期得看苹果api

- (void)appendObjects:(NSArray *)objects UNAVAILABLE_ATTRIBUTE;

- (void)setObjects:(NSArray *)objects UNAVAILABLE_ATTRIBUTE;

@end
