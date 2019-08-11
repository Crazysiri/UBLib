//
//  NSAttributedString+LenzAlbumAddition.m
//  demo
//
//  Created by Zero on 2019/1/18.
//  Copyright © 2019 Zero. All rights reserved.
//

#import "NSAttributedString+LenzAlbumAddition.h"

@implementation NSAttributedString (LenzAlbumAddition)
+ (NSMutableAttributedString *)lenz_attributedStringCustomWithStrings:(NSArray *)strings Attribute:(NSArray *)attris {
    NSMutableAttributedString *attriStringContainer = [[NSMutableAttributedString alloc]init];
    NSInteger count = 0;
    for (NSString *string in strings) {
        NSDictionary *att = attris[count];
        NSAttributedString *attriS = [[NSAttributedString alloc]initWithString:string attributes:att];
        count++;
        
        [attriStringContainer appendAttributedString:attriS];
    }
    return attriStringContainer;
}
@end
