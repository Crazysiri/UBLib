//
//  UBEngine.h
//  UBLib
//
//  Created by qiuyoubo on 2019/8/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UBEngine : NSObject
+ (void)log;

+ (void)callPrivateLibrary;

+ (void)callPublicLibrary;
@end

NS_ASSUME_NONNULL_END
