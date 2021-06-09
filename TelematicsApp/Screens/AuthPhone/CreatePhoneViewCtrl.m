//
//  CreatePhoneViewCtrl.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 14.11.18.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "CreatePhoneViewCtrl.h"
#import "CoreTabBarController.h"
#import "UIViewController+Preloader.h"
#import "UITextField+Form.h"
#import "TelematicsAppRegPopup.h"
#import "NSDate+UI.h"
#import "NSDate+ISO8601.h"
#import "LogSetup.h"
#import "Helpers.h"

@interface CreatePhoneViewCtrl () <UITextFieldDelegate> {
    int currSeconds;
}

@property (nonatomic, strong) LoginResponse *loginData;

@property (weak, nonatomic) IBOutlet UIImageView    *zrLogo;
@property (weak, nonatomic) IBOutlet UITextField    *passField;
@property (weak, nonatomic) IBOutlet UIButton       *enterBtn;
@property (weak, nonatomic) IBOutlet UIButton       *privacyBtn;
@property (weak, nonatomic) IBOutlet UIButton       *termsBtn;
@property (weak, nonatomic) IBOutlet UIButton       *repeatPasswordBtn;
@property (weak, nonatomic) IBOutlet UIButton       *backButton;
@property (weak, nonatomic) IBOutlet UILabel        *userDesc;
@property (weak, nonatomic) IBOutlet UILabel        *repeatPasswordLbl;
@property (strong, nonatomic) NSTimer               *passwordAlertTimer;

@end

@implementation CreatePhoneViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.zrLogo.image = [UIImage imageNamed:[Configurator sharedInstance].mainLogoColor];
    
    self.passField.delegate = self;
    [self.passField makeFormFieldZero];
    [self.passField setBackgroundColor:[Color lightSeparatorColor]];
    self.passField.textColor = [UIColor darkGrayColor];
    [self.passField.layer setMasksToBounds:YES];
    [self.passField.layer setCornerRadius:15.0f];
    [self.passField.layer setBorderColor:[[Color officialMainAppColor] CGColor]];
    [self.passField.layer setBorderWidth:0.5];
    self.passField.placeholder = localizeString(@"enter password");
    self.passField.secureTextEntry = YES;
    if (@available(iOS 12.0, *)) {
        self.passField.textContentType = UITextContentTypeOneTimeCode;
    }
    
    self.userDesc.text = localizeString(@"Enter the password from sms");
    
    //enter login button
    [self.enterBtn setTintColor:[Color officialWhiteColor]];
    [self.enterBtn setBackgroundColor:[Color officialMainAppColor]];
    [self.enterBtn.layer setMasksToBounds:YES];
    [self.enterBtn.layer setCornerRadius:15.0f];
    NSMutableAttributedString *loginText = [[NSMutableAttributedString alloc] initWithString:localizeString(@"log_in_text")];
    [loginText addAttribute:NSFontAttributeName value:[Font medium13] range:NSMakeRange(0, [loginText length])];
    [loginText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleNone] range:NSMakeRange(0, [loginText length])];
    [loginText addAttribute:NSForegroundColorAttributeName value:[Color officialWhiteColor] range:NSMakeRange(0, [loginText length])];
    [self.enterBtn setAttributedTitle:loginText forState:UIControlStateNormal];
    
    //repeat pass button
    [self.repeatPasswordBtn setTintColor:[UIColor lightGrayColor]];
    NSMutableAttributedString *newPass = [[NSMutableAttributedString alloc] initWithString:localizeString(@"Get a new password")];
    [newPass addAttribute:NSFontAttributeName value:[Font regular11] range:NSMakeRange(0, [newPass length])];
    [newPass addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [newPass length])];
    [self.repeatPasswordBtn setAttributedTitle:newPass forState:UIControlStateNormal];
    [self.repeatPasswordBtn addTarget:self action:@selector(resendPassword) forControlEvents:UIControlEventTouchUpInside];
    
    //back button
    [self.backButton setTintColor:[UIColor lightGrayColor]];
    NSMutableAttributedString *backOtherPhone = [[NSMutableAttributedString alloc] initWithString:localizeString(@"Sign in with another email or phone")];
    [backOtherPhone addAttribute:NSFontAttributeName value:[Font regular11] range:NSMakeRange(0, [backOtherPhone length])];
    [backOtherPhone addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [backOtherPhone length])];
    [self.backButton setAttributedTitle:backOtherPhone forState:UIControlStateNormal];
    
    //privacy button
    [self.privacyBtn setTintColor:[UIColor lightGrayColor]];
    NSMutableAttributedString *privacyText = [[NSMutableAttributedString alloc] initWithString:localizeString(@"menuitem_privacy")];
    [privacyText addAttribute:NSFontAttributeName value:[Font light9] range:NSMakeRange(0, [privacyText length])];
    [privacyText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [privacyText length])];
    [self.privacyBtn setAttributedTitle:privacyText forState:UIControlStateNormal];
    
    //terms button
    [self.termsBtn setTintColor:[UIColor lightGrayColor]];
    NSMutableAttributedString *termsText = [[NSMutableAttributedString alloc] initWithString:localizeString(@"menuitem_terms")];
    [termsText addAttribute:NSFontAttributeName value:[Font light9] range:NSMakeRange(0, [termsText length])];
    [termsText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [termsText length])];
    [self.termsBtn setAttributedTitle:termsText forState:UIControlStateNormal];
    
    [self.userDesc setText:[NSString stringWithFormat:localizeString(@"Message with a password was sent to %@\nEnter it in the field below"), self.enteredPhone]];
    
    [self setRepeatPasswordLabel];
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

- (IBAction)enterUserInApp:(id)sender {
    
    if (self.passField.text.length <= 2) {
        [self errorFunction];
        return;
    }
    
    NSString *delPhoneChar = [[self.enteredPhone componentsSeparatedByCharactersInSet:
                               [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                              componentsJoinedByString:@""];
    NSString *plusPhone = [NSString stringWithFormat:@"+%@", delPhoneChar];
    
}

- (void)errorFunction {
    if (IS_IPHONE_5 || IS_IPHONE_4)
        self.userDesc.font = [Font medium10];
    
    self.userDesc.text = localizeString(@"validation_invalid_password");
    self.userDesc.textColor = [Color officialRedColor];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (IS_IPHONE_5 || IS_IPHONE_4)
            self.userDesc.font = [Font regular12];
        
        [self.userDesc setText:[NSString stringWithFormat:localizeString(@"Message with a password was sent to %@\nEnter it in the field below"), self.enteredPhone]];
        self.userDesc.textColor = [Color darkGrayColor];
    });
}

- (void)resendPassword {
    if (!self.passwordAlertTimer.isValid) {
        currSeconds = 30;
        self.passwordAlertTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(runPasswordAlert) userInfo:nil repeats:YES];
    } else {
        [self.passwordAlertTimer invalidate];
        self.passwordAlertTimer = nil;
    }
    
    NSString *delPhoneChar = [[self.enteredPhone componentsSeparatedByCharactersInSet:
                               [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                              componentsJoinedByString:@""];
    
    
}

- (void)runPasswordAlert {
    if (currSeconds >= 1) {
        if (currSeconds == 1) {
            [self.passwordAlertTimer invalidate];
            [self setRepeatPasswordLabel];
            currSeconds = 30;
        } else if (currSeconds > 0) {
            currSeconds -= 1;
            
            self.repeatPasswordBtn.hidden = YES;
            
            NSString *seconds = [NSString stringWithFormat:NSLocalizedString(@"Resend password after %d sec", nil), currSeconds];
            self.repeatPasswordLbl.hidden = NO;
            self.repeatPasswordLbl.text = seconds;
        }
    } else {
        [self.passwordAlertTimer invalidate];
        [self setRepeatPasswordLabel];
    }
}

- (void)setRepeatPasswordLabel {
    self.repeatPasswordLbl.hidden = YES;
    self.repeatPasswordBtn.hidden = NO;
}

- (IBAction)privacyClick:(id)sender {
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [Configurator sharedInstance].linkPrivacyPolicy]];
    SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:URL];
    svc.delegate = self;
    svc.preferredControlTintColor = [UIColor redColor];
    [self presentViewController:svc animated:YES completion:nil];
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [self dismissViewControllerAnimated:true completion:nil];
}


#pragma mark UITextFieldDelegate

- (void)showKeyboard {
    [self.passField becomeFirstResponder];
}

- (void)dismissKeyboard {
    [self.passField resignFirstResponder];
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
    if (textField == self.passField) {
        [self.view endEditing:YES];
        [self enterUserInApp:self.enterBtn];
        return YES;
    }
    return YES;
}

- (IBAction)toMainPageAllBackAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
