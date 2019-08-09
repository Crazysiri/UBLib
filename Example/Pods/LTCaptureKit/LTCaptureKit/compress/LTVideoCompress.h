//
//  LTVideoCompress.h
//  LenzBusiness
//
//  Created by Zero on 2019/2/23.
//  Copyright © 2019 LenzTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface LTVideoCompress : NSObject

@property (nonatomic,assign) BOOL saveToAlbum;

@property (nonatomic,copy) void (^completionHandler)(AVAssetExportSession *session,NSString *toPath);

- (void)compressFromPath:(NSURL *)from toPath:(NSString *)to;



@end

NS_ASSUME_NONNULL_END
