//
//  UIImage+FixOrientation.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 09.01.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;

@interface UIImage (FixOrientation)

- (UIImage *)fixOrientation;
+ (UIImage *)imageWithImageHelper:(UIImage *)image scale:(CGFloat)scale;
+ (NSData *)scaleImage:(UIImage*)image;
+ (NSData *)scaleImageForAvatar:(UIImage*)image;

@end
