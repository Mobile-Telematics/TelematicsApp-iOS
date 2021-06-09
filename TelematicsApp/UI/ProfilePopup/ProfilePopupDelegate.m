//
//  ProfilePopupDelegate.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 10.12.18.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ProfilePopupDelegate.h"
#import <objc/runtime.h>
#import "UIImage+ImageEffects.h"
#import "UIView+Snapshot.h"
#import "UIView+parentViewController.h"

#define kLPPURotationAngle 70.0
#define kLPPUAnimationDuration 0.3
#define kLPPUPopUpViewTag 90701
#define kLPPUPopUpOverlayViewTag 90702
#define kLPPUPopUpBluredViewTag 90703
#define kLPPUPopUpBlurRadius 10.0
#define kLPPUPopUpBlurColor [[UIColor blackColor] colorWithAlphaComponent:0.3]

@implementation UIViewController (PopUp)

- (void)presentPopUpViewController:(UIViewController *)viewController
{
    [self presentPopUpViewController:viewController completion:nil];
}

- (void)presentPopUpViewController:(UIViewController *)viewController completion:(void(^)(void))completion
{
    self.enPopupViewController = viewController;
    [self presentPopUpView:viewController.view completion:completion];
}

- (void)dismissPopUpViewController
{
    [self dismissPopUpViewController:nil];
}

- (void)dismissPopUpViewController:(void(^)(void))completion
{
    UIView *sourceView  = [self topView];
    UIView *popupView   = [sourceView viewWithTag:kLPPUPopUpViewTag];
    UIView *overlayView = [sourceView viewWithTag:kLPPUPopUpOverlayViewTag];
    UIView *blurView  = [sourceView viewWithTag:kLPPUPopUpBluredViewTag];
    [self performDismissAnimation:sourceView blurView:blurView popupView:popupView overlayView:overlayView completion:completion];
}

- (void)dissmissBtnEvent
{
    [self dismissPopUpViewController];
}

- (void)presentPopUpView:(UIView *)popUpView completion:(void(^)(void))completion
{
    UIView *sourceView = [self topView];
    if ([sourceView.subviews containsObject:popUpView]) {
        return;
    }
    UIView *overlayView          = [[UIView alloc] initWithFrame:sourceView.bounds];
    overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    overlayView.tag              = kLPPUPopUpOverlayViewTag;
    overlayView.backgroundColor  = [UIColor clearColor];
    
    if (!self.disableBlur) {
        UIView *bluredView = [[UIView alloc] initWithFrame:sourceView.bounds];
        bluredView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        bluredView.tag              = kLPPUPopUpBluredViewTag;
        UIImageView *bluredImgView = [[UIImageView alloc] initWithFrame:sourceView.bounds];
        bluredImgView.image = [[sourceView snapshot] applyBlurWithRadius:self.blurRadius tintColor:self.blurColor saturationDeltaFactor:1.0 maskImage:nil];
        [bluredView addSubview:bluredImgView];
        [sourceView addSubview:bluredView];
    }
    
    UIButton *dismissButton        = [UIButton buttonWithType:UIButtonTypeCustom];
    dismissButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    dismissButton.backgroundColor  = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    dismissButton.frame            = sourceView.bounds;
    [dismissButton addTarget:self action:@selector(dissmissBtnEvent) forControlEvents:UIControlEventTouchUpInside];
    [overlayView addSubview:dismissButton];
    
    popUpView.layer.zPosition     = 99;
    popUpView.layer.cornerRadius = 20;
    popUpView.tag                 = kLPPUPopUpViewTag;
    popUpView.center              = overlayView.center;
    [popUpView setNeedsLayout];
    [popUpView setNeedsDisplay];
    [overlayView addSubview:popUpView];
    [sourceView addSubview:overlayView];
    
    [self performAppearAnimation:popUpView completion:completion];
}

- (void)performAppearAnimation:(UIView *)popupView completion:(void(^)(void))completion
{
    popupView.layer.transform = [self transform3d];
    CATransform3D transform = CATransform3DIdentity;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:kLPPUAnimationDuration animations:^{
        [weakSelf.enPopupViewController viewWillAppear:NO];
        popupView.layer.transform = transform;
    } completion:^(BOOL finished) {
        [weakSelf.enPopupViewController viewDidAppear:NO];
        if (completion) {
            completion();
        }
    }];
}

- (void)performDismissAnimation:(UIView *)sourceView blurView:(UIView *)blurView popupView:(UIView *)popupView overlayView:(UIView *)overlayView completion:(void(^)(void))completion
{
    CATransform3D transform = [self transform3d];
    __weak typeof(self) weakSelf = self;
    UIViewController *topVcParentVc = [[self topView] parentViewController];
    UIViewController *topVc =  topVcParentVc ? topVcParentVc : weakSelf;
    [UIView animateWithDuration:kLPPUAnimationDuration animations:^{
        [topVc.enPopupViewController viewWillDisappear:NO];
        if (popupView) {
            popupView.layer.transform = transform;
        }
    } completion:^(BOOL finished) {
        if (popupView) {
            [popupView removeFromSuperview];
        }
        if (blurView) {
            [blurView removeFromSuperview];
        }
        if (overlayView) {
            [overlayView removeFromSuperview];
        }
        [topVc.enPopupViewController viewDidDisappear:NO];
        topVc.enPopupViewController = nil;
        if (completion) {
            completion();
        }
    }];
}

- (CATransform3D)transform3d
{
    UIViewController *topVcParentVc = [[self topView] parentViewController];
    UIViewController *topVc =  topVcParentVc ? topVcParentVc : self;
    switch (topVc.popUpEffectType) {
        case UIViewControllerPopUpEffectTypeFlipUp:{
            CATransform3D transform = CATransform3DIdentity;
            transform               = CATransform3DTranslate(transform, 0.0, 200.0, 0.0);
            transform.m34           = 1.0 / 800.0;
            transform               = CATransform3DRotate(transform, kLPPURotationAngle * M_PI / 180.0, 1.0, 0.0, 0.0);
            CATransform3D scale     = CATransform3DMakeScale(0.7, 0.7, 0.7);
            return CATransform3DConcat(transform, scale);
            break;
        }
        case UIViewControllerPopUpEffectTypeFlipDown:{
            CATransform3D transform = CATransform3DIdentity;
            transform               = CATransform3DTranslate(transform, 0.0, -200.0, 0.0);
            transform.m34           = 1.0 / 800.0;
            transform               = CATransform3DRotate(transform, kLPPURotationAngle * M_PI / 180.0 + 180.0, 1.0, 0.0, 0.0);
            CATransform3D scale     = CATransform3DMakeScale(0.7, 0.7, 0.7);
            return CATransform3DConcat(transform, scale);
            break;
        }
        case UIViewControllerPopUpEffectTypeZoomIn:
            return CATransform3DMakeScale(0.01, 0.01, 1.0);
            break;
        case UIViewControllerPopUpEffectTypeZoomOut:
            return CATransform3DMakeScale(1.50, 1.50, 1.50);
            break;
    }
}

- (UIView *)topView
{
    UIViewController *recentViewController = self;
    return recentViewController.view.superview != nil ? (recentViewController.view.superview.parentViewController != nil ? recentViewController.view.superview.parentViewController.view : recentViewController.view) : recentViewController.view;
}

- (UIViewController *)enPopupViewController
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setEnPopupViewController:(UIViewController *)enPopupViewController
{
    objc_setAssociatedObject(self, @selector(enPopupViewController), enPopupViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIViewControllerPopUpEffectType)popUpEffectType
{
    NSNumber *t = objc_getAssociatedObject(self, _cmd);
    return t.unsignedIntegerValue >= 1 ? t.unsignedIntegerValue : UIViewControllerPopUpEffectTypeZoomIn;
}

- (void)setPopUpEffectType:(UIViewControllerPopUpEffectType)popUpEffectType
{
    objc_setAssociatedObject(self, @selector(popUpEffectType), [NSNumber numberWithUnsignedInteger:popUpEffectType], OBJC_ASSOCIATION_ASSIGN);
}

- (CGFloat)blurRadius
{
    NSNumber *n = objc_getAssociatedObject(self, _cmd);
    return n.floatValue <= 0.0 ? kLPPUPopUpBlurRadius : n.floatValue;
}

- (void)setBlurRadius:(CGFloat)blurRadius
{
    objc_setAssociatedObject(self, @selector(blurRadius), [NSNumber numberWithFloat:blurRadius], OBJC_ASSOCIATION_ASSIGN);
}

- (UIColor *)blurColor
{
    UIColor *c = objc_getAssociatedObject(self, _cmd);
    return c ? c : kLPPUPopUpBlurColor;
}

- (void)setBlurColor:(UIColor *)blurColor
{
    objc_setAssociatedObject(self, @selector(blurColor), blurColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)disableBlur
{
    BOOL s = (BOOL)objc_getAssociatedObject(self, _cmd);
    return s ? s : NO;
}

- (void)setDisableBlur:(BOOL)disableBlur
{
    objc_setAssociatedObject(self, @selector(disableBlur), @(disableBlur), OBJC_ASSOCIATION_ASSIGN);
}

@end
