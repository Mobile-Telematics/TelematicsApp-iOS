//
//  UIView+Extension.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 27.06.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;
#import "Color.h"
#import "Helpers.h"


@interface UIView (Extension)

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGPoint origin;

@property (nonatomic,assign)  CGFloat bottom;
@property (nonatomic,assign)  CGFloat right;

@end
