//
//  UIImage+ImageEffects.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 12.12.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;

@interface UIImage (ImageEffects)

- (UIImage *)applyLightEffect;
- (UIImage *)applyExtraLightEffect;
- (UIImage *)applyDarkEffect;
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor;

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;

@end
