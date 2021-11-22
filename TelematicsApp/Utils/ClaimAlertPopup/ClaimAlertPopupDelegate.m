//
//  ClaimAlertPopupDelegate.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.05.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ClaimAlertPopupDelegate.h"
#import "ClaimAlertPopup.h"
#import "GeneralButton.h"
#import "Helpers.h"

#define DefaultCancelTitle localizeString(@"Cancel")
#define DefaultTopMargin 140
#define DefaultBottomMargin 140
#define DefaultLeftMargin 35
#define DefaultRightMargin 35
#define DefaultDimmedLevel 0.85
#define DefaultCornerRadius 20
#define DefaultButtonRadius 20


@interface ClaimAlertPopupDelegate()

@property (strong, nonatomic) ClaimAlertPopup *customView;
@property (strong, nonatomic) UIView *view;
@property (strong, nonatomic) UIView *dimBG;
@property (strong, nonatomic) UIVisualEffectView *blurBG;

@property (strong, nonatomic) TelematicsAppModel *appModel;

@end

@implementation ClaimAlertPopupDelegate


#pragma mark - Initialization Methods

- (instancetype)initOnView:(UIView*)view {
    self.view = view;
    return self;
}

- (void)initialize {
    if (!self.inAnimation) {
        self.inAnimation = DELAY_IMMEDIATELY_03_SEC;
    }
    if (!self.outAnimation) {
        self.outAnimation = DELAY_IMMEDIATELY_03_SEC;
    }
    if (!self.topMargin) {
        if (IS_IPHONE_5 || IS_IPHONE_4) {
            self.topMargin = self.view.frame.size.height/10;
        } else if (IS_IPHONE_11_PROMAX || IS_IPHONE_13_PROMAX) {
            self.topMargin = self.view.frame.size.height/3.5;
        } else if (IS_IPHONE_11 || IS_IPHONE_13_PRO) {
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
        } else if (IS_IPHONE_11_PROMAX || IS_IPHONE_13_PROMAX) {
            self.bottomMargin = self.view.frame.size.height/6;
        } else if (IS_IPHONE_11 || IS_IPHONE_13_PRO) {
            self.bottomMargin = self.view.frame.size.height/8.2;
        } else if (IS_IPHONE_8) {
            self.bottomMargin = self.view.frame.size.height/54;
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
        self.animationDuration = DELAY_IMMEDIATELY_03_SEC;
    }
    if (!self.dimBackgroundLevel) {
        self.dimBackgroundLevel = DefaultDimmedLevel;
    }
    if (!self.message) {
        self.message = localizeString(@"You have given access to all permissions and now you can use full power of\nTelematicsApp!");
    }
    if (!self.fixButtonTitle) {
        self.fixButtonTitle = DefaultCancelTitle;
    }
}


#pragma mark - Popup Build

- (void)setClaimAlertPopup {
    [self initialize];
    
    self.customView = [[[NSBundle mainBundle] loadNibNamed:@"ClaimAlertPopup" owner:nil options:nil] firstObject];
    self.customView.frame = CGRectMake(0, 0, self.view.bounds.size.width - (self.leftMargin + self.rightMargin), self.view.bounds.size.height - (self.topMargin + self.bottomMargin));
    self.customView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.customView.center = self.view.center;
    self.customView.layer.cornerRadius = self.cornerRadius;
    [self setBlurredBackground];
    [self setupLabels];
    [self setupButtons];
}


#pragma mark - Blur Background

- (void)setBlurredBackground {
    if (!UIAccessibilityIsReduceTransparencyEnabled() && self.blurBackground) {
        UIBlurEffect *burEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.blurBG = [[UIVisualEffectView alloc] initWithEffect:burEffect];
        self.blurBG.frame = self.view.bounds;
        self.blurBG.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        if (self.dismissOnBackgroundTap) {
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideClaimAlertPopup)];
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
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideClaimAlertPopup)];
        tapGesture.numberOfTapsRequired = 1;
        [self.dimBG addGestureRecognizer:tapGesture];
    }
    [self.view addSubview:self.dimBG];
}


#pragma mark - Setup Labels

- (void)setupLabels {
    self.customView.titleLabel.text = self.title;
    self.customView.titleLabel.textColor = [Color officialMainAppColor];
    
    self.customView.messageLabel.text = self.message;
    [self setupNoEventLbl];
    [self setupEvent1Lbl];
    [self setupEvent2Lbl];
    [self setupEvent3Lbl];
}

- (void)setupNoEventLbl {
    
    if ([self.claim_selectedEventTypeMarker isEqualToString:@"Braking"]) {
        self.customView.noEventTextLbl.text = @"Braking";
        [self.customView.noEventBtn setBackgroundImage:[UIImage imageNamed:@"clpop_red_brake"] forState:UIControlStateNormal];
        [self.customView.noEventBtn addTarget:self action:@selector(noEventClaimButtonAction) forControlEvents:UIControlEventTouchUpInside];
    } else if ([self.claim_selectedEventTypeMarker isEqualToString:@"Acceleration"]) {
        self.customView.noEventTextLbl.text = @"Acceleration";
        [self.customView.noEventBtn setBackgroundImage:[UIImage imageNamed:@"clpop_red_acc"] forState:UIControlStateNormal];
        [self.customView.noEventBtn addTarget:self action:@selector(noEventClaimButtonAction) forControlEvents:UIControlEventTouchUpInside];
    } else if ([self.claim_selectedEventTypeMarker isEqualToString:@"Cornering"]) {
        self.customView.noEventTextLbl.text = @"Cornering";
        [self.customView.noEventBtn setBackgroundImage:[UIImage imageNamed:@"clpop_red_turn"] forState:UIControlStateNormal];
        [self.customView.noEventBtn addTarget:self action:@selector(noEventClaimButtonAction) forControlEvents:UIControlEventTouchUpInside];
    } else if ([self.claim_selectedEventTypeMarker isEqualToString:@"Phone Usage"]) {
        self.customView.noEventTextLbl.text = @"Phone Usage";
        [self.customView.noEventBtn setBackgroundImage:[UIImage imageNamed:@"clpop_red_phone"] forState:UIControlStateNormal];
        [self.customView.noEventBtn addTarget:self action:@selector(noEventClaimButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)setupEvent1Lbl {
    
    if (IS_IPHONE_5 || IS_IPHONE_4)
        self.customView.event1TextLbl.font = [Font bold11];
    
    if ([self.claim_selectedEventTypeMarker isEqualToString:@"Acceleration"]) {
        self.customView.event1TextLbl.text = @"Braking";
        [self.customView.event1Btn setBackgroundImage:[UIImage imageNamed:@"clpop_orange_brake"] forState:UIControlStateNormal];
        [self.customView.event1Btn addTarget:self action:@selector(event1ClaimButtonAction) forControlEvents:UIControlEventTouchUpInside];
    } else {
        self.customView.event1TextLbl.text = @"Acceleration";
        [self.customView.event1Btn setBackgroundImage:[UIImage imageNamed:@"clpop_orange_acc"] forState:UIControlStateNormal];
        [self.customView.event1Btn addTarget:self action:@selector(event1ClaimButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)setupEvent2Lbl {
    
    if (IS_IPHONE_5 || IS_IPHONE_4)
        self.customView.event2TextLbl.font = [Font bold11];
    
    if ([self.claim_selectedEventTypeMarker isEqualToString:@"Acceleration"] || [self.claim_selectedEventTypeMarker isEqualToString:@"Braking"]) {
        self.customView.event2TextLbl.text = @"Cornering";
        [self.customView.event2Btn setBackgroundImage:[UIImage imageNamed:@"clpop_orange_turn"] forState:UIControlStateNormal];
        [self.customView.event2Btn addTarget:self action:@selector(event2ClaimButtonAction) forControlEvents:UIControlEventTouchUpInside];
    } else {
        self.customView.event2TextLbl.text = @"Braking";
        [self.customView.event2Btn setBackgroundImage:[UIImage imageNamed:@"clpop_orange_brake"] forState:UIControlStateNormal];
        [self.customView.event2Btn addTarget:self action:@selector(event2ClaimButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)setupEvent3Lbl {
    
    if (IS_IPHONE_5 || IS_IPHONE_4)
        self.customView.event3TextLbl.font = [Font bold11];
    
    if ([self.claim_selectedEventTypeMarker isEqualToString:@"Phone Usage"]) {
        self.customView.event3TextLbl.text = @"Cornering";
        [self.customView.event3Btn setBackgroundImage:[UIImage imageNamed:@"clpop_orange_turn"] forState:UIControlStateNormal];
        [self.customView.event3Btn addTarget:self action:@selector(event3ClaimButtonAction) forControlEvents:UIControlEventTouchUpInside];
    } else {
        self.customView.event3TextLbl.text = @"Phone Usage";
        [self.customView.event3Btn setBackgroundImage:[UIImage imageNamed:@"clpop_orange_phone"] forState:UIControlStateNormal];
        [self.customView.event3Btn addTarget:self action:@selector(event3ClaimButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
}


#pragma mark - Setup Buttons

- (void)setupButtons {
    self.customView.cancelBtn.layer.cornerRadius = self.buttonRadius;
    self.customView.cancelBtn.layer.borderWidth = 1.0;
    self.customView.cancelBtn.layer.borderColor = [Color lightGrayColor].CGColor;
    self.customView.cancelBtn.backgroundColor = [Color officialWhiteColor];
    [self.customView.cancelBtn setTitle:localizeString(@"CANCEL") forState:UIControlStateNormal];
    [self.customView.cancelBtn addTarget:self action:@selector(cancelClaimButtonAction) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - Actions

- (void)noEventClaimButtonAction {
    [_delegate noEventButtonAction:self.customView button:self.customView.noEventBtn];
}

- (void)event1ClaimButtonAction {
    [_delegate event1ButtonAction:self.customView newType:self.customView.event1TextLbl.text button:self.customView.event1Btn];
}

- (void)event2ClaimButtonAction {
    [_delegate event2ButtonAction:self.customView newType:self.customView.event2TextLbl.text button:self.customView.event2Btn];
}

- (void)event3ClaimButtonAction {
    [_delegate event3ButtonAction:self.customView newType:self.customView.event3TextLbl.text button:self.customView.event3Btn];
}

- (void)cancelClaimButtonAction {
    [_delegate cancelClaimButtonAction:self.customView button:self.customView.cancelBtn];
}


#pragma mark - Hide/Show Methods

- (void)showClaimAlertPopup:(NSString *)eventType {
    
    self.claim_selectedEventTypeMarker = eventType;
    
    [self setClaimAlertPopup];
    [self animateIn];
}

- (void)hideClaimAlertPopup {
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
