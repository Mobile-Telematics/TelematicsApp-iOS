//
//  CongratulationsPopupDelegate.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 31.07.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;
#import "CongratulationsPopupProtocol.h"

@interface CongratulationsPopupDelegate: UIView

@property (nonatomic, strong) id <CongratulationsPopupProtocol> delegate;

typedef enum {
    WizardFlyInAnimationDefault,
    WizardFlyInAnimationDirectionTop,
    WizardFlyInAnimationDirectionBottom,
    WizardFlyInAnimationDirectionLeft,
    WizardFlyInAnimationDirectionRight
} WizardFlyInAnimationDirection;


typedef enum {
    WizardFlyOutAnimationDefault,
    WizardFlyOutAnimationDirectionTop,
    WizardFlyOutAnimationDirectionBottom,
    WizardFlyOutAnimationDirectionLeft,
    WizardFlyOutAnimationDirectionRight
} WizardFlyOutAnimationDirection;


- (instancetype)initOnView:(UIView*)view;
- (void)showCongratulationsPopup;
- (void)hideCongratulationsPopup;

@property (assign, nonatomic) float animationDuration;
@property (assign, nonatomic) WizardFlyInAnimationDirection inAnimation;
@property (assign, nonatomic) WizardFlyOutAnimationDirection outAnimation;
@property (assign, nonatomic) BOOL blurBackground;
@property (assign, nonatomic) BOOL dismissOnBackgroundTap;
@property (assign, nonatomic) float dimBackgroundLevel;
@property (assign, nonatomic) float topMargin;
@property (assign, nonatomic) float bottomMargin;
@property (assign, nonatomic) float leftMargin;
@property (assign, nonatomic) float rightMargin;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *fixButtonTitle;
@property (strong, nonatomic) NSString *continueButtonTitle;
@property (strong, nonatomic) NSString *pushButtonTitle;
@property (assign, nonatomic) float buttonRadius;
@property (assign, nonatomic) float cornerRadius;
@property (strong, nonatomic) NSString *iconName;
@property (strong, nonatomic) NSString *imgName;


@end
