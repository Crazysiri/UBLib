//
//  LenzImageSourceURLModel.h
//  demo
//
//  Created by qiuyoubo on 2019/2/23.
//  Copyright © 2019 Zero. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LenzImageSourceObject.h"
NS_ASSUME_NONNULL_BEGIN

@interface LenzImageSourceModel : NSObject<LenzImageSourceObject>
@end

@interface LenzImageSourceURLModel : LenzImageSourceModel<LenzImageSourceURLObject>
@end

@interface LenzImageSourcePathModel : LenzImageSourceModel<LenzImageSourcePathObject>
@end
NS_ASSUME_NONNULL_END
