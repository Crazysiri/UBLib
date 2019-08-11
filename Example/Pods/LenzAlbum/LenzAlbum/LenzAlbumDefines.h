//
//  LenzAlbumDefines.h
//  demo
//
//  Created by Zero on 2019/1/17.
//  Copyright © 2019 Zero. All rights reserved.
//

#ifndef LenzAlbumDefines_h
#define LenzAlbumDefines_h

#define UIColorFromHex_lenzAlbum(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define RGBCOLOR_lenzAlbum(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]

#endif /* LenzAlbumDefines_h */
