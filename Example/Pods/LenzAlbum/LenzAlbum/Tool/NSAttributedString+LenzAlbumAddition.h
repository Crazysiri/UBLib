//
//  NSAttributedString+LenzAlbumAddition.h
//  demo
//
//  Created by Zero on 2019/1/18.
//  Copyright © 2019 Zero. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSAttributedString (LenzAlbumAddition)
+ (NSMutableAttributedString *)lenz_attributedStringCustomWithStrings:(NSArray *)strings Attribute:(NSArray *)attris;
@end

