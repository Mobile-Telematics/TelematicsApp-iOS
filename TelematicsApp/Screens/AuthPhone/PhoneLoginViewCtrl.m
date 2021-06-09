//
//  PhoneLoginViewCtrl.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 14.06.18.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "PhoneLoginViewCtrl.h"
#import "RestorePhoneViewCtrl.h"
#import "UIViewController+Preloader.h"
#import "UITextField+Form.h"
#import "UIImageView+WebCache.h"
#import "Helpers.h"
#import "LogSetup.h"

@interface PhoneLoginViewCtrl () <UITextFieldDelegate> {
    int currSeconds;
}

@property (nonatomic, strong) LoginResponse         *loginData;

@property (weak, nonatomic) IBOutlet UITextField    *passField;
@property (weak, nonatomic) IBOutlet UIButton       *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton       *getNewPassword;
@property (weak, nonatomic) IBOutlet UIButton       *backButton;
@property (weak, nonatomic) IBOutlet UIImageView    *userAvatarImg;
@property (weak, nonatomic) IBOutlet UIImageView    *linesGreenBackground;
@property (weak, nonatomic) IBOutlet UILabel        *loggedNameLbl;
@property (weak, nonatomic) IBOutlet UILabel        *enterPassLbl;

@property (weak, nonatomic) IBOutlet UILabel        *repeatPasswordLbl;
@property (strong, nonatomic) NSTimer               *passwordAlertTimer;

@end

@implementation PhoneLoginViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.loggedNameLbl.textColor = [Color officialMainAppColor];
    
    self.passField.delegate = self;
    [self.passField makeFormFieldZero];
    self.passField.textColor = [UIColor blackColor];
    [self.passField setBackgroundColor:[Color lightSeparatorColor]];
    [self.passField.layer setMasksToBounds:YES];
    [self.passField.layer setCornerRadius:15.0f];
    [self.passField.layer setBorderColor:[[Color officialMainAppColor] CGColor]];
    [self.passField.layer setBorderWidth:1.5];
    self.passField.placeholder = localizeString(@"enter password");
    self.passField.secureTextEntry = YES;
    if (@available(iOS 12.0, *)) {
        self.passField.textContentType = UITextContentTypeOneTimeCode;
    }
    
    [self.loginBtn setBackgroundColor:[Color officialMainAppColor]];
    [self.loginBtn.layer setMasksToBounds:YES];
    [self.loginBtn.layer setCornerRadius:15.0f];
    [self.loginBtn.titleLabel setFont:[Font medium13]];
    [self.loginBtn setTitle:localizeString(@"SIGN IN") forState:UIControlStateNormal];
    
    self.enterPassLbl.text = localizeString(@"Enter your password");
    
    [self.linesGreenBackground setImage:[UIImage imageNamed:@"zigzag"]];
    
    [self.userAvatarImg sd_setImageWithURL:[NSURL URLWithString:_userPhotoUrl] placeholderImage:[UIImage imageNamed:@"no_avatar"]];
    self.userAvatarImg.layer.cornerRadius = self.userAvatarImg.layer.frame.size.width/2;
    self.userAvatarImg.layer.masksToBounds = YES;
    self.userAvatarImg.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.getNewPassword setTintColor:[UIColor lightGrayColor]];
    NSMutableAttributedString *newPass = [[NSMutableAttributedString alloc] initWithString:localizeString(@"Get a new password")];
    [newPass addAttribute:NSFontAttributeName value:[Font regular11] range:NSMakeRange(0, [newPass length])];
    [newPass addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [newPass length])];
    [self.getNewPassword setAttributedTitle:newPass forState:UIControlStateNormal];
    
    [self.backButton setTintColor:[UIColor lightGrayColor]];
    NSMutableAttributedString *backOtherPhone = [[NSMutableAttributedString alloc] initWithString:localizeString(@"Sign in with another phone")];
    [backOtherPhone addAttribute:NSFontAttributeName value:[Font regular11] range:NSMakeRange(0, [backOtherPhone length])];
    [backOtherPhone addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [backOtherPhone length])];
    [self.backButton setAttributedTitle:backOtherPhone forState:UIControlStateNormal];
    
    [self setRepeatPasswordLabel];
    
    if (_userName.length > 0) {
        [self.loggedNameLbl setText:[NSString stringWithFormat:localizeString(@"You were logged in as %@"), _userName]];
    } else {
        [self.loggedNameLbl setText:localizeString(@"Login to your account")];
    }
    
    self.shiftHeight = -1;
    [self registerForKeyboardNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showKeyboard];
    });
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}


#pragma mark Actions

- (IBAction)loginBtnClick:(id)sender {
    
//    LoginPhoneRequestData* loginData = [[LoginPhoneRequestData alloc] init];
//    
//    NSString *delPhoneChar = [[self.enteredPhone componentsSeparatedByCharactersInSet:
//                               [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
//                              componentsJoinedByString:@""];
//    NSString *plusPhone = [NSString stringWithFormat:@"+%@", delPhoneChar];
//    
//    loginData.loginFields = @{@"Phone": plusPhone};
//    loginData.password = self.passField.text;
//    
//    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
//        //[self hidePreloader];
//        if ([response isSuccesful]) {
//            self.loginData = ((LoginResponse*)response);
//            if (self.loginData.Status.integerValue != 200 && self.loginData.Status != nil) {
//                NSString *err = [NSString stringWithFormat:@"%@", [self.loginData.Errors.firstObject valueForKey:@"Message"]];
//                if ([err isEqual:@""]) {
//                    [self errorPhoneLoginFunction];
//                } else {
//                    [self errorPhoneLoginFunction];
//                }
//                return;
//            } else {
//                [self showPreloader];
//                [self dismissKeyboard];
//                //[[GeneralService sharedInstance] loginAfterRigistration:response];
//            }
//        } else {
//            [self.errorHandler handleError:error response:response];
//        }
//    }] loginInApp:loginData];
}

- (void)errorPhoneLoginFunction {
    if (IS_IPHONE_5 || IS_IPHONE_4)
        self.enterPassLbl.font = [Font medium10];
    
    self.enterPassLbl.text = localizeString(@"validation_invalid_password");
    self.enterPassLbl.textColor = [Color officialRedColor];
    [self.loginBtn setTitle:localizeString(@"TRY AGAIN") forState:UIControlStateNormal];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (IS_IPHONE_5 || IS_IPHONE_4)
            self.enterPassLbl.font = [Font regular12];
        
        self.enterPassLbl.text = localizeString(@"Enter your password");
        self.enterPassLbl.textColor = [Color darkGrayColor];
    });
}

- (IBAction)getNewPassword:(id)sender {
    
//    RegPhoneRequestData* regData = [[RegPhoneRequestData alloc] init];
//    
//    NSString *delPhoneChar = [[self.enteredPhone componentsSeparatedByCharactersInSet:
//                               [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
//                              componentsJoinedByString:@""];
//    
//    regData.value = [NSString stringWithFormat:@"+%@", delPhoneChar];
//    regData.resetTypeDataContract = @"Phone";
//    
//    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
//        [self hidePreloader];
//        if ([response isSuccesful]) {
//            
////            RestorePhoneViewCtrl* restorePhone = [self.storyboard instantiateViewControllerWithIdentifier:@"RestorePhoneViewCtrl"];
////            restorePhone.enteredPhone = [NSString stringWithFormat:@"+%@", delPhoneChar];
////            [self.navigationController pushViewController:restorePhone animated:YES];
//            
//        } else {
//            if ([error.localizedDescription isEqualToString:@"Request failed: bad request (400)"]) {
//                [self.errorHandler showErrorMessages:@[localizeString(@"Phone number isn't correct.")]];
//            } else {
//                [self.errorHandler handleError:error response:response];
//            }
//        }
//    }] resendPasswordWithPhone:regData];
}

- (void)runPasswordAlert {
    if (currSeconds >= 1) {
        if (currSeconds == 1) {
            [self.passwordAlertTimer invalidate];
            [self setRepeatPasswordLabel];
            currSeconds = 30;
        } else if (currSeconds > 0) {
            currSeconds -= 1;
            
            self.getNewPassword.hidden = YES;
            
            NSString *seconds = [NSString stringWithFormat:NSLocalizedString(@"Resend password after %d sec", nil), currSeconds];
            self.repeatPasswordLbl.hidden = NO;
            self.repeatPasswordLbl.text = seconds;
        }
    } else {
        [self.passwordAlertTimer invalidate];
        [self setRepeatPasswordLabel];
    }
}

- (IBAction)backBtnClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [self.errorHandler dismissActiveNotifNow];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //ANIMATION VALUE
        double coefPhoto = 0.38;
        float coefLbl = 160.0f;
        if (IS_IPHONE_11 || IS_IPHONE_12_PRO) {
            coefPhoto = 0.55;
            coefLbl = 70.0f;
        } else if (IS_IPHONE_11_PROMAX || IS_IPHONE_12_PROMAX) {
            coefPhoto = 0.55;
            coefLbl = 50.0f;
        } else if (IS_IPHONE_5 || IS_IPHONE_4) {
            coefPhoto = 0.30;
            coefLbl = 210.0f;
        }

        CGAffineTransform translateAvatar = CGAffineTransformMakeTranslation(0, self.userAvatarImg.frame.origin.y + self.view.bounds.size.height * coefPhoto);
        CGAffineTransform scaleAvatar = CGAffineTransformMakeScale(0.5, 0.5);
        CGAffineTransform transformAvatar = CGAffineTransformConcat(translateAvatar, scaleAvatar);

        CGAffineTransform translateLabel = CGAffineTransformMakeTranslation(0, self.loggedNameLbl.frame.origin.y - coefLbl);
        CGAffineTransform scaleLabel = CGAffineTransformMakeScale(1.0, 1.0);
        CGAffineTransform transformLabel = CGAffineTransformConcat(translateLabel, scaleLabel);

        [UIView beginAnimations:@"LogoMoveAnimation" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.4];

        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut  animations:^{

            [self.view setFrame:CGRectMake(0.f, -160.0f, self.view.bounds.size.width, self.view.bounds.size.height)];
            self.userAvatarImg.transform = transformAvatar;
            self.loggedNameLbl.transform = transformLabel;
            [UIView commitAnimations];

        } completion:^(BOOL finished) {
            if (finished) {
                //
            }
        }];
    });
}

- (void)textFieldDidEndEditing:(UITextField *)codeField {
    
    float coefLbl = 320.0f;
    if (IS_IPHONE_11 || IS_IPHONE_12_PRO) {
        coefLbl = 463.0f;
    } else if (IS_IPHONE_11_PROMAX || IS_IPHONE_12_PROMAX) {
        coefLbl = 483.0f;
    } else if (IS_IPHONE_5 || IS_IPHONE_4)
        coefLbl = 274.0f;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.view setFrame:CGRectMake(0.f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height)];
        self.userAvatarImg.transform = CGAffineTransformMakeScale(1.0, 1.0);
        CGAffineTransform translateLabel = CGAffineTransformMakeTranslation(0, self.loggedNameLbl.frame.origin.y - coefLbl);
        CGAffineTransform scaleLabel = CGAffineTransformMakeScale(1.0, 1.0);
        CGAffineTransform transformLabel = CGAffineTransformConcat(translateLabel, scaleLabel);
        
        [UIView beginAnimations:@"zrLabelBackAnimation" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.3];
        self.loggedNameLbl.transform = transformLabel;
        [UIView commitAnimations];
        
    } completion:^(BOOL finished) {
        [self dismissKeyboard];
    }];
}

- (void)setRepeatPasswordLabel {
    self.repeatPasswordLbl.hidden = YES;
    self.getNewPassword.hidden = NO;
}

- (void)showKeyboard {
    [self.passField becomeFirstResponder];
}

- (void)dismissKeyboard {
    [self.passField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.passField) {
        [self.view endEditing:YES];
        [self loginBtnClick:self.loginBtn];
        return NO;
    } else {
        [self.view endEditing:YES];
        [self loginBtnClick:self.loginBtn];
    }
    return YES;
}


@end
