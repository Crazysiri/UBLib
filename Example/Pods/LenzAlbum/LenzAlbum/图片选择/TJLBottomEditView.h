//
//  TJLBottomEditView.h
//  PhotoManagement
//
//  Created by Oma-002 on 17/1/18.
//  Copyright © 2017年 com.oma.matec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LenzImagePickerBottomView.h"

@interface TJLBottomEditView : UIView <LenzImagePickerBottomView>


@property (strong, nonatomic,readonly) UIView *lineView;

@property (strong, nonatomic,readonly) UILabel *selectedCountLabel;

@end
