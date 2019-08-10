//
//  UBEngine.m
//  UBLib
//
//  Created by qiuyoubo on 2019/8/9.
//

#import "UBEngine.h"

#import <AFNetworking/AFNetworking.h>

#import <LTCaptureKit/LTCameraKit.h>

@implementation UBEngine
+ (void)log {
    NSLog(@"log");
}

+ (void)callPrivateLibrary {
    [UIImage imageFromCMSampleBufferRef:NULL];
    NSLog(@"callPrivateLibrary");
}

+ (void)callPublicLibrary {
    NSLog(@"callPublicLibrary");
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:@"http://baidu.com" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
}
@end
