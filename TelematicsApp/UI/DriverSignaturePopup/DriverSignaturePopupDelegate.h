//
//  DriverSignaturePopupDelegate.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 11.10.20.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;
#import "DriverSignaturePopupProtocol.h"

@interface DriverSignaturePopupDelegate: UIView

@property (nonatomic, strong) id <DriverSignaturePopupProtocol> delegate;

typedef enum {
    DriverSignatureFlyInAnimationDefault,
    DriverSignatureFlyInAnimationDirectionTop,
    DriverSignatureFlyInAnimationDirectionBottom,
    DriverSignatureFlyInAnimationDirectionLeft,
    DriverSignatureFlyInAnimationDirectionRight
} DriverSignatureFlyInAnimationDirection;


typedef enum {
    DriverSignatureFlyOutAnimationDefault,
    DriverSignatureFlyOutAnimationDirectionTop,
    DriverSignatureFlyOutAnimationDirectionBottom,
    DriverSignatureFlyOutAnimationDirectionLeft,
    DriverSignatureFlyOutAnimationDirectionRight
} DriverSignatureFlyOutAnimationDirection;


- (instancetype)initOnView:(UIView*)view;
- (void)showDriverSignaturePopup:(NSString *)eventType;
- (void)hideDriverSignaturePopup;

@property (assign, nonatomic) float animationDuration;
@property (assign, nonatomic) DriverSignatureFlyInAnimationDirection inAnimation;
@property (assign, nonatomic) DriverSignatureFlyOutAnimationDirection outAnimation;
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

@property (strong, nonatomic) NSString *signature_selectedEventTypeMarker;

@end
