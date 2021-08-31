//
//  GeneralButton.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 09.12.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;

IB_DESIGNABLE

@interface GeneralButton : UIButton

typedef NS_ENUM(NSUInteger, GeneralButtonImagePosition)
{
    GeneralButtonImagePositionLeft   = 0,
    GeneralButtonImagePositionRight  = 1,
    GeneralButtonImagePositionTop    = 2,
    GeneralButtonImagePositionBottom = 3,
    GeneralButtonImagePositionCenter = 4
};

typedef NS_ENUM(NSUInteger, GeneralButtonTitlePosition)
{
    GeneralButtonTitlePositionRight  = 0,
    GeneralButtonTitlePositionLeft   = 1,
    GeneralButtonTitlePositionBottom = 2,
    GeneralButtonTitlePositionTop    = 3,
    GeneralButtonTitlePositionCenter = 4
};

@property (assign, nonatomic) IBInspectable GeneralButtonImagePosition imagePosition;
@property (assign, nonatomic) IBInspectable CGFloat imageSpacingFromTitle;
@property (assign, nonatomic) IBInspectable CGPoint imageOffset;

@property (assign, nonatomic) IBInspectable GeneralButtonTitlePosition titlePosition;
@property (assign, nonatomic) IBInspectable CGFloat titleSpacingFromImage;
@property (assign, nonatomic) IBInspectable CGPoint titleOffset;

@property (strong, nonatomic, readonly) IBInspectable UIImage *maskImage;

@property (assign, nonatomic, getter=isTitleLabelWidthUnlimited)    IBInspectable BOOL titleLabelWidthUnlimited;
@property (assign, nonatomic, getter=isAdjustsAlphaWhenHighlighted) IBInspectable BOOL adjustsAlphaWhenHighlighted;
@property (assign, nonatomic, getter=isAnimatedStateChanging)       IBInspectable BOOL animatedStateChanging;

- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state;

- (void)setMaskAlphaImage:(UIImage *)maskImage;
- (void)setMaskBlackAndWhiteImage:(UIImage *)maskImage;

+ (UIImage*)imageWithImage:(UIImage*) sourceImage scaledToHeight:(float) i_height;

@end
