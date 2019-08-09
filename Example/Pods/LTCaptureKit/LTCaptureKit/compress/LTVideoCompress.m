//
//  LTVideoCompress.m
//  LenzBusiness
//
//  Created by Zero on 2019/2/23.
//  Copyright © 2019 LenzTech. All rights reserved.
//

#import "LTVideoCompress.h"
#import <Photos/Photos.h>

@interface LTVideoCompress ()
@property (copy,nonatomic) NSString *path;
@end

@implementation LTVideoCompress

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)compressFromPath:(NSURL *)from toPath:(NSString *)to {

    NSURL *videoURL = from;
    self.path = to;
    [self encodeToMP4:videoURL toPath:self.path];
}


//转化为MP4格式
- (void)encodeToMP4:(NSURL *)url toPath:(NSString *)path
{
//    LenzVideoQuestion *question = (LenzVideoQuestion *)self.question;
    
    __weak typeof(self) weakself = self;
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]){
        //TODO:hud 处理中
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:AVAssetExportPresetMediumQuality];
        
        __weak typeof(exportSession) weakSession = exportSession;
        
        [NSFileManager.defaultManager removeItemAtPath:path error:nil];
        exportSession.outputFileType = AVFileTypeMPEG4;
        
        NSLog(@"mp4Path = %@",path);
        exportSession.outputURL = [NSURL fileURLWithPath: path];
        exportSession.shouldOptimizeForNetworkUse = YES;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            if (weakself.saveToAlbum) {
                
                NSURL *fileUrl = [NSURL fileURLWithPath:path];
                
                NSLog(@"111222 = %i",UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(fileUrl.path));
                
                if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(fileUrl.path)) {
                    
                    NSError *error;
                    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:fileUrl];
                    } error:&error];
                }
                
            }

            
            if (weakself.completionHandler) {
                weakself.completionHandler(weakSession, path);
            }

        }];
    }
}

@end
