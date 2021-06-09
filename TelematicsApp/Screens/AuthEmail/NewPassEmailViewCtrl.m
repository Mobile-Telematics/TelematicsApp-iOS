//
//  NewPassEmailViewCtrl.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 15.06.20.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "NewPassEmailViewCtrl.h"
#import "CoreTabBarController.h"
#import "UIViewController+Preloader.h"
#import "UITextField+Form.h"
#import "RegResponse.h"
#import "TelematicsAppRegPopup.h"
#import "NSDate+UI.h"
#import "NSDate+ISO8601.h"
#import "LogSetup.h"
#import "Helpers.h"

@interface NewPassEmailViewCtrl () <UITextFieldDelegate> {
    int currSeconds;
}

@property (nonatomic, strong) LoginResponse         *loginData;
@property (nonatomic, strong) RegResponse           *regData;

@property (weak, nonatomic) IBOutlet UIImageView    *zrLogo;
@property (weak, nonatomic) IBOutlet UITextField    *createPassField;
@property (weak, nonatomic) IBOutlet UIButton       *loginNewPassBtn;
@property (weak, nonatomic) IBOutlet UIButton       *backButton;
@property (weak, nonatomic) IBOutlet UILabel        *userDesc;

@end

@implementation NewPassEmailViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.zrLogo.image = [UIImage imageNamed:[Configurator sharedInstance].mainLogoColor];
    
    self.createPassField.delegate = self;
    [self.createPassField makeFormFieldZero];
    [self.createPassField setBackgroundColor:[Color lightSeparatorColor]];
    self.createPassField.textColor = [UIColor darkGrayColor];
    [self.createPassField.layer setMasksToBounds:YES];
    [self.createPassField.layer setCornerRadius:15.0f];
    [self.createPassField.layer setBorderColor:[[Color officialMainAppColor] CGColor]];
    [self.createPassField.layer setBorderWidth:0.5];
    self.createPassField.placeholder = localizeString(@"enter new password");
    
    self.userDesc.text = localizeString(@"Сreate a new password for your account");
    
    [self.loginNewPassBtn setTintColor:[Color officialWhiteColor]];
    [self.loginNewPassBtn setBackgroundColor:[Color officialMainAppColor]];
    [self.loginNewPassBtn.layer setMasksToBounds:YES];
    [self.loginNewPassBtn.layer setCornerRadius:15.0f];
    NSMutableAttributedString *nextText = [[NSMutableAttributedString alloc] initWithString:localizeString(@"SIGN IN")];
    [nextText addAttribute:NSFontAttributeName value:[Font medium13] range:NSMakeRange(0, [nextText length])];
    [nextText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleNone] range:NSMakeRange(0, [nextText length])];
    [nextText addAttribute:NSForegroundColorAttributeName value:[Color officialWhiteColor] range:NSMakeRange(0, [nextText length])];
    [self.loginNewPassBtn setAttributedTitle:nextText forState:UIControlStateNormal];
    
    [self.backButton setTintColor:[UIColor lightGrayColor]];
    NSMutableAttributedString *backOtherPhone = [[NSMutableAttributedString alloc] initWithString:localizeString(@"Sign in with another email or phone")];
    [backOtherPhone addAttribute:NSFontAttributeName value:[Font regular11] range:NSMakeRange(0, [backOtherPhone length])];
    [backOtherPhone addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [backOtherPhone length])];
    [self.backButton setAttributedTitle:backOtherPhone forState:UIControlStateNormal];
    
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

- (IBAction)nextBtnAction:(id)sender {
    
    if (self.createPassField.text.length <= 4) {
        [self errorNewPassFunctionLow];
        return;
    }
    
//    RegPhoneRequestData* regData = [[RegPhoneRequestData alloc] init];
//    regData.value = self.enteredEmail;
//    regData.confirmationCode = self.enteredCode;
//    regData.password = self.createPassField.text;
//    regData.resetType = @"Email";
//
//    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
//        [self hidePreloader];
//        if ([response isSuccesful]) {
//            self.regData = ((RegResponse *)response);
//            if (self.regData.Result != nil) {
//                if ([self.regData.Result.ConfirmationResult isEqualToString:@"0"]) {
//                    [self errorNewPassFunctionInvalidCode];
//                } else {
//                    [self loginUserInApp:sender];
//                }
//            } else {
//                [self errorNewPassFunctionInvalidCode];
//            }
//        } else {
//            if ([error.localizedDescription isEqualToString:@"Request failed: bad request (400)"]) {
//                [self.errorHandler showErrorMessages:@[localizeString(@"Verification code is not valid")]];
//            } else {
//                [self.errorHandler handleError:error response:response];
//            }
//            if (self.regData.Result.ConfirmationResult.boolValue) {
//
//            }
//        }
//    }] verifyPassAndChange:regData];
}

- (void)errorNewPassFunctionLow {
    if (IS_IPHONE_5 || IS_IPHONE_4)
        self.userDesc.font = [Font medium10];
    
    self.userDesc.text = localizeString(@"validation_invalid_password_small");
    self.userDesc.textColor = [Color officialRedColor];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (IS_IPHONE_5 || IS_IPHONE_4)
            self.userDesc.font = [Font regular12];
        
        [self.userDesc setText:localizeString(@"Сreate a new password for your account")];
        self.userDesc.textColor = [Color darkGrayColor];
    });
}

- (void)errorNewPassFunctionInvalidCode {
    if (IS_IPHONE_5 || IS_IPHONE_4)
        self.userDesc.font = [Font medium10];
    
    self.userDesc.text = localizeString(@"validation_invalid_code_email");
    self.userDesc.textColor = [Color officialRedColor];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (IS_IPHONE_5 || IS_IPHONE_4)
            self.userDesc.font = [Font regular12];
        
        [self.userDesc setText:localizeString(@"Сreate a new password for your account")];
        self.userDesc.textColor = [Color darkGrayColor];
    });
}


#pragma mark Login User in app after Restore

- (IBAction)loginUserInApp:(id)sender {
    
//    LoginPhoneRequestData* loginData = [[LoginPhoneRequestData alloc] init];
//    
//    loginData.loginFields = @{@"Email": self.enteredEmail};
//    loginData.password = self.createPassField.text;
//    
//    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
//        if ([response isSuccesful]) {
//            self.loginData = ((LoginResponse*)response);
//            if (self.loginData.Status.integerValue != 200 && self.loginData.Status != nil) {
//                [self errorEmailFunctionAfterResetPassword];
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

- (void)errorEmailFunctionAfterResetPassword {
    if (IS_IPHONE_5 || IS_IPHONE_4)
        self.userDesc.font = [Font medium10];
    
    self.userDesc.text = localizeString(@"An error occurred while changing the password. Try again please");
    self.userDesc.textColor = [Color officialRedColor];
    [self.loginNewPassBtn setTitle:localizeString(@"TRY AGAIN") forState:UIControlStateNormal];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (IS_IPHONE_5 || IS_IPHONE_4)
            self.userDesc.font = [Font regular12];
        
        self.userDesc.text = localizeString(@"An error occurred while changing the password. Try again please");
        self.userDesc.textColor = [Color darkGrayColor];
    });
}

- (IBAction)backBtnClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark UITextFieldDelegate

- (void)showKeyboard {
    [self.createPassField becomeFirstResponder];
}

- (void)dismissKeyboard {
    [self.createPassField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [self.errorHandler dismissActiveNotifNow];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        double coefPhoto = 0.2;
        
        CGAffineTransform translateAvatar = CGAffineTransformMakeTranslation(0, self.zrLogo.frame.origin.y + self.view.bounds.size.height * coefPhoto);
        CGAffineTransform scaleAvatar = CGAffineTransformMakeScale(0.8, 0.8);
        if (IS_IPHONE_5 || IS_IPHONE_4)
            scaleAvatar = CGAffineTransformMakeScale(0.4, 0.4);
        CGAffineTransform transformAvatar = CGAffineTransformConcat(translateAvatar, scaleAvatar);
        
        [UIView beginAnimations:@"TelematicsAppLogoMoveAnimation" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.4];
        
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut  animations:^{
            [self.view setFrame:CGRectMake(0.f, -160.0f, self.view.bounds.size.width, self.view.bounds.size.height)];
            self.zrLogo.transform = transformAvatar;
            [UIView commitAnimations];
            
        } completion:^(BOOL finished) {
            if (finished) {
                //
            }
        }];
    });
}

- (void)textFieldDidEndEditing:(UITextField *)codeField {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.view setFrame:CGRectMake(0.f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height)];
        self.zrLogo.transform = CGAffineTransformMakeScale(1.0, 1.0);
        [UIView commitAnimations];
    } completion:^(BOOL finished) {
        [self dismissKeyboard];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.createPassField) {
        [self.view endEditing:YES];
        [self nextBtnAction:self.loginNewPassBtn];
        return YES;
    }
    return YES;
}

- (IBAction)toMainPageAllBackAction:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:NO];
}

@end
