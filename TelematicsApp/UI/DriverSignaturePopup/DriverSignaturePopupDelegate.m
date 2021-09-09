//
//  DriverSignaturePopupDelegate.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 11.10.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "DriverSignaturePopupDelegate.h"
#import "DriverSignaturePopup.h"
#import "GeneralButton.h"
#import "Helpers.h"

#define DefaultCancelTitle localizeString(@"Cancel")
#define DefaultTopMargin 140
#define DefaultBottomMargin 140
#define DefaultLeftMargin 35
#define DefaultRightMargin 35
#define DefaultDimmedLevel 0.85
#define DefaultCornerRadius 20
#define DefaultButtonRadius 16


@interface DriverSignaturePopupDelegate()

@property (strong, nonatomic) DriverSignaturePopup *customView;
@property (strong, nonatomic) UIView *view;
@property (strong, nonatomic) UIView *dimBG;
@property (strong, nonatomic) UIVisualEffectView *blurBG;

@property (strong, nonatomic) TelematicsAppModel *appModel;

@end

@implementation DriverSignaturePopupDelegate


#pragma mark - Initialization Methods

- (instancetype)initOnView:(UIView*)view {
    self.view = view;
    return self;
}

- (void)initialize {
    if (!self.inAnimation) {
        self.inAnimation = DefaultInAnimation;
    }
    if (!self.outAnimation) {
        self.outAnimation = DefaultOutAnimation;
    }
    if (!self.topMargin) {
        if (IS_IPHONE_5 || IS_IPHONE_4) {
            self.topMargin = self.view.frame.size.height/10;
        } else if (IS_IPHONE_11_PROMAX || IS_IPHONE_12_PROMAX) {
            self.topMargin = self.view.frame.size.height/3.5;
        } else if (IS_IPHONE_11 || IS_IPHONE_12_PRO) {
            self.topMargin = self.view.frame.size.height/3.6;
        } else if (IS_IPHONE_8) {
            self.topMargin = self.view.frame.size.height/4.2;
        } else {
            self.topMargin = self.view.frame.size.height/4;
        }
    }
    if (!self.bottomMargin) {
        if (IS_IPHONE_5 || IS_IPHONE_4) {
            self.bottomMargin = self.view.frame.size.height/54;
        } else if (IS_IPHONE_11_PROMAX || IS_IPHONE_12_PROMAX) {
            self.bottomMargin = self.view.frame.size.height/7;
        } else if (IS_IPHONE_11 || IS_IPHONE_12_PRO) {
            self.bottomMargin = self.view.frame.size.height/9.6;
        } else if (IS_IPHONE_8) {
            self.bottomMargin = self.view.frame.size.height/64;
        } else {
            self.bottomMargin = self.view.frame.size.height/21;
        }
    }
    if (!self.leftMargin) {
        self.leftMargin = DefaultLeftMargin;
        if (IS_IPHONE_5 || IS_IPHONE_4) {
            self.leftMargin = 20;
        }
    }
    if (!self.rightMargin) {
        self.rightMargin = DefaultRightMargin;
        if (IS_IPHONE_5 || IS_IPHONE_4) {
            self.rightMargin = 20;
        }
    }
    if (!self.cornerRadius) {
        self.cornerRadius = DefaultCornerRadius;
    }
    if (!self.buttonRadius) {
        self.buttonRadius = DefaultButtonRadius;
    }
    if (!self.animationDuration) {
        self.animationDuration = DefaultAnimationDuration;
    }
    if (!self.dimBackgroundLevel) {
        self.dimBackgroundLevel = DefaultDimmedLevel;
    }
    if (!self.message) {
        self.message = localizeString(@"You have given access to all permissions and now you can use full power of\nTelematicsApp app!");
    }
    if (!self.fixButtonTitle) {
        self.fixButtonTitle = DefaultCancelTitle;
    }
}


#pragma mark - Popup Build

- (void)setDriverSignaturePopup {
    [self initialize];
    
    self.customView = [[[NSBundle mainBundle] loadNibNamed:@"DriverSignaturePopup" owner:nil options:nil] firstObject];
    self.customView.frame = CGRectMake(0, 0, self.view.bounds.size.width - (self.leftMargin + self.rightMargin), self.view.bounds.size.height - (self.topMargin + self.bottomMargin));
    self.customView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.customView.center = self.view.center;
    self.customView.layer.cornerRadius = self.cornerRadius;
    [self setBlurredBackground];
    [self setupLabels];
}


#pragma mark - Blur Background

- (void)setBlurredBackground {
    if (!UIAccessibilityIsReduceTransparencyEnabled() && self.blurBackground) {
        UIBlurEffect *burEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.blurBG = [[UIVisualEffectView alloc] initWithEffect:burEffect];
        self.blurBG.frame = self.view.bounds;
        self.blurBG.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        if (self.dismissOnBackgroundTap) {
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideDriverSignaturePopup)];
            tapGesture.numberOfTapsRequired = 1;
            [self.blurBG addGestureRecognizer:tapGesture];
        }
        [self.view addSubview:self.blurBG];
    } else {
        [self setDimBackground];
    }
}


#pragma mark - Background

- (void)setDimBackground {
    self.dimBG = [[UIView alloc]initWithFrame:self.view.bounds];
    self.dimBG.alpha = self.dimBackgroundLevel;
    self.dimBG.backgroundColor = [UIColor blackColor];
    self.dimBG.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (self.dismissOnBackgroundTap) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideDriverSignaturePopup)];
        tapGesture.numberOfTapsRequired = 1;
        [self.dimBG addGestureRecognizer:tapGesture];
    }
    [self.view addSubview:self.dimBG];
}


#pragma mark - Setup Labels

- (void)setupLabels {
    [self setupButtons];
    [self setupButtonsColors];
}


#pragma mark - Setup Buttons

- (void)setupButtons {
    
    [self.customView.event1Btn addTarget:self action:@selector(event1_DriverSignatureButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.customView.event2Btn addTarget:self action:@selector(event2_PassengerSignatureButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.customView.event3Btn addTarget:self action:@selector(event3_BusSignatureButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.customView.event4Btn addTarget:self action:@selector(event4_MotorcycleSignatureButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.customView.event5Btn addTarget:self action:@selector(event5_TrainSignatureButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.customView.event6Btn addTarget:self action:@selector(event6_TaxiSignatureButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.customView.event7Btn addTarget:self action:@selector(event7_BicycleSignatureButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.customView.event8Btn addTarget:self action:@selector(event8_OtherSignatureButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.customView.cancelBtn.layer.cornerRadius = self.buttonRadius;
    self.customView.cancelBtn.layer.borderWidth = 1.0;
    self.customView.cancelBtn.layer.borderColor = [Color lightGrayColor].CGColor;
    self.customView.cancelBtn.backgroundColor = [Color officialWhiteColor];
    [self.customView.cancelBtn setTitle:localizeString(@"CANCEL") forState:UIControlStateNormal];
    [self.customView.cancelBtn addTarget:self action:@selector(cancelDriverSignatureButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.customView.submitBtn.layer.cornerRadius = self.buttonRadius;
    self.customView.submitBtn.layer.borderWidth = 1.0;
    self.customView.submitBtn.layer.borderColor = [Color officialGreenColor].CGColor;
    self.customView.submitBtn.backgroundColor = [Color officialGreenColor];
    [self.customView.submitBtn setTitle:localizeString(@"CONFIRM") forState:UIControlStateNormal];
    [self.customView.submitBtn addTarget:self action:@selector(submitDriverSignatureButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    if (IS_IPHONE_5 || IS_IPHONE_4) {
        self.customView.event1Lbl.font = [Font bold14];
        self.customView.event2Lbl.font = [Font bold14];
        self.customView.event3Lbl.font = [Font bold14];
        self.customView.event4Lbl.font = [Font bold14];
        self.customView.event5Lbl.font = [Font bold14];
        self.customView.event6Lbl.font = [Font bold14];
        self.customView.event7Lbl.font = [Font bold14];
        self.customView.event8Lbl.font = [Font bold14];
    }
}

- (void)setupButtonsColors {
    
    if ([self.signature_selectedEventTypeMarker isEqualToString:@"OriginalDriver"]) {
        [self.customView.event1Btn setBackgroundImage:[UIImage imageNamed:@"driver_green"] forState:UIControlStateNormal];
    } else if ([self.signature_selectedEventTypeMarker isEqualToString:@"Passanger"]) {
        [self.customView.event2Btn setBackgroundImage:[UIImage imageNamed:@"passenger_green"] forState:UIControlStateNormal];
    } else if ([self.signature_selectedEventTypeMarker isEqualToString:@"Bus"]) {
        [self.customView.event3Btn setBackgroundImage:[UIImage imageNamed:@"bus_green"] forState:UIControlStateNormal];
    } else if ([self.signature_selectedEventTypeMarker isEqualToString:@"Motorcycle"]) {
        [self.customView.event4Btn setBackgroundImage:[UIImage imageNamed:@"motorcycle_green"] forState:UIControlStateNormal];
    } else if ([self.signature_selectedEventTypeMarker isEqualToString:@"Train"]) {
        [self.customView.event5Btn setBackgroundImage:[UIImage imageNamed:@"train_green"] forState:UIControlStateNormal];
    } else if ([self.signature_selectedEventTypeMarker isEqualToString:@"Taxi"]) {
        [self.customView.event6Btn setBackgroundImage:[UIImage imageNamed:@"taxi_green"] forState:UIControlStateNormal];
    } else if ([self.signature_selectedEventTypeMarker isEqualToString:@"Bicycle"]) {
        [self.customView.event7Btn setBackgroundImage:[UIImage imageNamed:@"bicycle_green"] forState:UIControlStateNormal];
    } else if ([self.signature_selectedEventTypeMarker isEqualToString:@"Other"]) {
        [self.customView.event8Btn setBackgroundImage:[UIImage imageNamed:@"other_green"] forState:UIControlStateNormal];
    } else {
        [self.customView.event1Btn setBackgroundImage:[UIImage imageNamed:@"driver_green"] forState:UIControlStateNormal];
    }
}


#pragma mark - Actions

- (void)event1_DriverSignatureButtonAction {
    [_delegate event1_Driver_ButtonAction:self.customView newType:@"OriginalDriver" button:self.customView.event1Btn];
}

- (void)event2_PassengerSignatureButtonAction {
    [_delegate event2_Passenger_ButtonAction:self.customView newType:@"Passanger" button:self.customView.event2Btn];
}

- (void)event3_BusSignatureButtonAction {
    [_delegate event3_Bus_ButtonAction:self.customView newType:@"Bus" button:self.customView.event3Btn];
}

- (void)event4_MotorcycleSignatureButtonAction {
    [_delegate event4_Motorcycle_ButtonAction:self.customView newType:@"Motorcycle" button:self.customView.event4Btn];
}

- (void)event5_TrainSignatureButtonAction {
    [_delegate event5_Train_ButtonAction:self.customView newType:@"Train" button:self.customView.event5Btn];
}

- (void)event6_TaxiSignatureButtonAction {
    [_delegate event6_Taxi_ButtonAction:self.customView newType:@"Taxi" button:self.customView.event6Btn];
}

- (void)event7_BicycleSignatureButtonAction {
    [_delegate event7_Bicycle_ButtonAction:self.customView newType:@"Bicycle" button:self.customView.event7Btn];
}

- (void)event8_OtherSignatureButtonAction {
    [_delegate event8_Other_ButtonAction:self.customView newType:@"Other" button:self.customView.event8Btn];
}

- (void)submitDriverSignatureButtonAction {
    [_delegate submitSignatureButtonAction:self.customView button:self.customView.submitBtn];
}

- (void)cancelDriverSignatureButtonAction {
    [_delegate cancelSignatureButtonAction:self.customView button:self.customView.cancelBtn];
}


#pragma mark - Hide/Show Methods

- (void)showDriverSignaturePopup:(NSString *)signatureType {
    
    self.signature_selectedEventTypeMarker = signatureType;
    
    [self setDriverSignaturePopup];
    [self animateIn];
}

- (void)hideDriverSignaturePopup {
    [self animateOut];
}


#pragma mark - Animations

- (void)animateIn {
    switch (self.inAnimation) {
        case 1:
        {
            self.customView.frame = CGRectOffset(self.customView.frame, 0, -self.view.center.y);
            [self.view addSubview:self.customView];
            [UIView animateWithDuration:self.animationDuration animations:^{
                self.customView.frame = CGRectOffset(self.customView.frame, 0, self.view.center.y);
            }];
        }
            break;
        case 2:
        {
            self.customView.frame = CGRectOffset(self.customView.frame, 0, SCREEN_HEIGHT+self.view.center.y);
            [self.view addSubview:self.customView];
            [UIView animateWithDuration:self.animationDuration animations:^{
                self.customView.frame = CGRectOffset(self.customView.frame, 0, -SCREEN_HEIGHT-self.view.center.y);
            }];
        }
            break;
        case 3:
        {
            self.customView.frame = CGRectOffset(self.customView.frame, -self.view.center.x, 0);
            [self.view addSubview:self.customView];
            [UIView animateWithDuration:self.animationDuration animations:^{
                self.customView.frame = CGRectOffset(self.customView.frame, self.view.center.x, 0);
            }];
        }
            break;
        case 4:
        {
            self.customView.frame = CGRectOffset(self.customView.frame, SCREEN_WIDTH+self.view.center.x, 0);
            [self.view addSubview:self.customView];
            [UIView animateWithDuration:self.animationDuration animations:^{
                self.customView.frame = CGRectOffset(self.customView.frame, -SCREEN_WIDTH-self.view.center.x, 0);
            }];
        }
            break;
        default:
        {
            self.customView.transform = CGAffineTransformMakeScale(0.5, 0.5);
            [self.view addSubview:self.customView];
            [UIView animateWithDuration:self.animationDuration animations:^{
                self.customView.transform = CGAffineTransformIdentity;
            }];
        }
            break;
    }
}

- (void)animateOut {
    switch (self.outAnimation) {
        case 1:
        {
            [UIView animateWithDuration:self.animationDuration animations:^{
                self.customView.frame = CGRectOffset(self.customView.frame, 0, -self.view.center.y);
                [self.view layoutIfNeeded];
                self.customView.alpha = 0;
                self.dimBG.alpha = 0;
                self.blurBG.alpha = 0;
            } completion:^(BOOL finished) {
                [self removeFromView];
            }];
        }
            break;
        case 2:
        {
            [UIView animateWithDuration:self.animationDuration animations:^{
                self.customView.frame = CGRectOffset(self.customView.frame, 0, SCREEN_HEIGHT+self.view.center.y);
                [self.view layoutIfNeeded];
                self.customView.alpha = 0;
                self.dimBG.alpha = 0;
                self.blurBG.alpha = 0;
            } completion:^(BOOL finished) {
                [self removeFromView];
            }];
        }
            break;
        case 3:
        {
            [UIView animateWithDuration:self.animationDuration animations:^{
                self.customView.frame = CGRectOffset(self.customView.frame, -SCREEN_WIDTH-self.view.center.x, 0);
                [self.view layoutIfNeeded];
                self.customView.alpha = 0;
                self.dimBG.alpha = 0;
                self.blurBG.alpha = 0;
            } completion:^(BOOL finished) {
                [self removeFromView];
            }];
        }
            break;
        case 4:
        {
            [UIView animateWithDuration:self.animationDuration animations:^{
                self.customView.frame = CGRectOffset(self.customView.frame, SCREEN_WIDTH+self.view.center.x, 0);
                [self.view layoutIfNeeded];
                self.customView.alpha = 0;
                self.dimBG.alpha = 0;
                self.blurBG.alpha = 0;
            } completion:^(BOOL finished) {
                [self removeFromView];
            }];
        }
            break;
        default:
        {
            [UIView animateWithDuration:self.animationDuration animations:^{
                self.customView.transform = CGAffineTransformMakeScale(1.5, 1.5);
                [self.view layoutIfNeeded];
                self.customView.alpha = 0;
                self.dimBG.alpha = 0;
                self.blurBG.alpha = 0;
            } completion:^(BOOL finished) {
                [self removeFromView];
            }];
        }
            break;
    }
}

- (void)removeFromView {
    [self.customView removeFromSuperview];
    [self.dimBG removeFromSuperview];
    [self.blurBG removeFromSuperview];
    
    [self cleanCode];
}


#pragma mark - Cleaning

- (void)cleanCode {
    self.customView = nil;
    self.dimBG = nil;
    self.blurBG = nil;
}

@end
