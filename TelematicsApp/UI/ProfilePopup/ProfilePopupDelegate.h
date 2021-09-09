//
//  ProfilePopupDelegate.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 10.12.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;

@interface UIViewController (PopUp)

typedef NS_ENUM(NSUInteger, UIViewControllerPopUpEffectType)
{
    UIViewControllerPopUpEffectTypeZoomIn = 1,
    UIViewControllerPopUpEffectTypeZoomOut,
    UIViewControllerPopUpEffectTypeFlipUp,
    UIViewControllerPopUpEffectTypeFlipDown
};

@property (nonatomic, strong) UIViewController *enPopupViewController;
@property (nonatomic, assign) UIViewControllerPopUpEffectType popUpEffectType;
@property (nonatomic, assign) BOOL disableBlur;
@property (nonatomic, assign) CGFloat blurRadius;
@property (nonatomic, strong) UIColor *blurColor;

- (void)presentPopUpViewController:(UIViewController *)viewController;
- (void)presentPopUpViewController:(UIViewController *)viewController completion:(void(^)(void))completion;
- (void)dismissPopUpViewController;
- (void)dismissPopUpViewController:(void(^)(void))completion;

@end
