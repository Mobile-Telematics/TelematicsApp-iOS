//
//  CongratulationsPopupDelegate.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 31.07.19.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "CongratulationsPopupDelegate.h"
#import "CongratulationsPopup.h"
#import "GeneralButton.h"
#import "Helpers.h"

#define DefaultTitle localizeString(@"Congratulations!")
#define DefaultFixTitle localizeString(@"LET'S GO!")
#define DefaultIcon @"icon"
#define DefaultImage @"image"
#define DefaultTopMargin 140
#define DefaultBottomMargin 140
#define DefaultLeftMargin 25
#define DefaultRightMargin 25
#define DefaultDimmedLevel 0.85
#define DefaultCornerRadius 20
#define DefaultButtonRadius 16


@interface CongratulationsPopupDelegate()

@property (strong, nonatomic) CongratulationsPopup *customView;
@property (strong, nonatomic) UIView *view;
@property (strong, nonatomic) UIView *dimBG;
@property (strong, nonatomic) UIVisualEffectView *blurBG;

@property (strong, nonatomic) TelematicsAppModel *appModel;

@end

@implementation CongratulationsPopupDelegate


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
            self.topMargin = self.view.frame.size.height/5;
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
            self.bottomMargin = self.view.frame.size.height/6;
        } else if (IS_IPHONE_11_PROMAX || IS_IPHONE_12_PROMAX) {
            self.bottomMargin = self.view.frame.size.height/3.5;
        } else if (IS_IPHONE_11 || IS_IPHONE_12_PRO) {
            self.bottomMargin = self.view.frame.size.height/3.6;
        } else if (IS_IPHONE_8) {
            self.bottomMargin = self.view.frame.size.height/4.4;
        } else {
            self.bottomMargin = self.view.frame.size.height/4;
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
    if (!self.title) {
        self.title = DefaultTitle;
    }
    if (!self.message) {
        self.message = localizeString(@"You have given access to all permissions and now you can use full power of\nTelematicsApp app!");
    }
    if (!self.fixButtonTitle) {
        self.fixButtonTitle = DefaultFixTitle;
    }
    if (!self.iconName) {
        self.iconName = DefaultIcon;
    }
    if (!self.imgName) {
        self.imgName = DefaultImage;
    }
}


#pragma mark - Popup Build

- (void)setCongratulationsPopup {
    [self initialize];
    
    self.customView = [[[NSBundle mainBundle] loadNibNamed:@"CongratulationsPopup" owner:nil options:nil] firstObject];
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
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideCongratulationsPopup)];
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
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideCongratulationsPopup)];
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
    [self setupAd1Lbl];
    [self setupAd2Lbl];
    [self setupAd3Lbl];
}

- (void)setupAd1Lbl {
    NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
    imageAttachment.image = [UIImage imageNamed:@"net_ok"];
    
    CGFloat imageOffsetY = -4.0;
    if (IS_IPHONE_11_PROMAX || IS_IPHONE_12_PROMAX || IS_IPHONE_8P) {
        imageAttachment.bounds = CGRectMake(35, imageOffsetY, imageAttachment.image.size.width/1.5, imageAttachment.image.size.height/1.5);
    } else {
        imageAttachment.bounds = CGRectMake(15, imageOffsetY, imageAttachment.image.size.width/1.5, imageAttachment.image.size.height/1.5);
    }
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
    NSMutableAttributedString *completeText = [[NSMutableAttributedString alloc] initWithString:@""];
    [completeText appendAttributedString:attachmentString];
    NSMutableAttributedString *textAfterIcon = [[NSMutableAttributedString alloc] initWithString:localizeString(@"      Grow your Safe Driving Score")];
    if (IS_IPHONE_11_PROMAX || IS_IPHONE_12_PROMAX || IS_IPHONE_8P) {
        textAfterIcon = [[NSMutableAttributedString alloc] initWithString:localizeString(@"             Grow your Safe Driving Score")];
    }
    
    [completeText appendAttributedString:textAfterIcon];
    
    if (IS_IPHONE_5 || IS_IPHONE_4) {
        self.customView.ad1Text.font = [Font regular12];
    }
    self.customView.ad1Text.textAlignment = NSTextAlignmentLeft;
    self.customView.ad1Text.attributedText = completeText;
}

- (void)setupAd2Lbl {
    NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
    imageAttachment.image = [UIImage imageNamed:@"net_ok"];
    
    CGFloat imageOffsetY = -4.0;
    if (IS_IPHONE_11_PROMAX || IS_IPHONE_12_PROMAX || IS_IPHONE_8P) {
        imageAttachment.bounds = CGRectMake(35, imageOffsetY, imageAttachment.image.size.width/1.5, imageAttachment.image.size.height/1.5);
    } else {
        imageAttachment.bounds = CGRectMake(15, imageOffsetY, imageAttachment.image.size.width/1.5, imageAttachment.image.size.height/1.5);
    }
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
    NSMutableAttributedString *completeText = [[NSMutableAttributedString alloc] initWithString:@""];
    [completeText appendAttributedString:attachmentString];
    NSMutableAttributedString *textAfterIcon = [[NSMutableAttributedString alloc] initWithString:localizeString(@"      Complete with your Friends")];
    if (IS_IPHONE_11_PROMAX || IS_IPHONE_12_PROMAX || IS_IPHONE_8P) {
        textAfterIcon = [[NSMutableAttributedString alloc] initWithString:localizeString(@"             Complete with your Friends")];
    }
    
    [completeText appendAttributedString:textAfterIcon];
    
    if (IS_IPHONE_5 || IS_IPHONE_4) {
        self.customView.ad2Text.font = [Font regular12];
    }
    self.customView.ad2Text.textAlignment = NSTextAlignmentLeft;
    self.customView.ad2Text.attributedText = completeText;
}

- (void)setupAd3Lbl {
    NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
    imageAttachment.image = [UIImage imageNamed:@"net_ok"];
    
    CGFloat imageOffsetY = -4.0;
    if (IS_IPHONE_11_PROMAX || IS_IPHONE_12_PROMAX || IS_IPHONE_8P) {
        imageAttachment.bounds = CGRectMake(35, imageOffsetY, imageAttachment.image.size.width/1.5, imageAttachment.image.size.height/1.5);
    } else {
        imageAttachment.bounds = CGRectMake(15, imageOffsetY, imageAttachment.image.size.width/1.5, imageAttachment.image.size.height/1.5);
    }
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
    NSMutableAttributedString *completeText = [[NSMutableAttributedString alloc] initWithString:@""];
    [completeText appendAttributedString:attachmentString];
    NSMutableAttributedString *textAfterIcon = [[NSMutableAttributedString alloc] initWithString:localizeString(@"      Complete Challenges & Gain Coins")];
    if (IS_IPHONE_11_PROMAX || IS_IPHONE_12_PROMAX || IS_IPHONE_8P) {
        textAfterIcon = [[NSMutableAttributedString alloc] initWithString:localizeString(@"             Complete Challenges & Gain Coins")];
    }
    
    [completeText appendAttributedString:textAfterIcon];
    
    if (IS_IPHONE_5 || IS_IPHONE_4) {
        self.customView.ad3Text.font = [Font regular11];
    }
    self.customView.ad3Text.textAlignment = NSTextAlignmentLeft;
    self.customView.ad3Text.attributedText = completeText;
}


#pragma mark - Setup Buttons

- (void)setupButtons {
    self.customView.okBtn.layer.cornerRadius = self.buttonRadius;
    self.customView.okBtn.backgroundColor = [Color officialMainAppColor];
    [self.customView.okBtn setTitle:localizeString(@"LET'S GO!") forState:UIControlStateNormal];
    [self.customView.okBtn addTarget:self action:@selector(okButtonAction) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - Actions

- (void)okButtonAction {
    [_delegate okButtonAction:self.customView button:self.customView.okBtn];
}


#pragma mark - Hide/Show Methods

- (void)showCongratulationsPopup {
    [self setCongratulationsPopup];
    [self animateIn];
}

- (void)hideCongratulationsPopup {
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
