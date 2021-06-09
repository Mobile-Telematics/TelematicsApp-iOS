////
////  RestorePhoneViewCtrl.m
////  TelematicsApp
////
////  Created by DATA MOTION PTE. LTD. on 15.06.20.
////  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
////
//
//#import "RestorePhoneViewCtrl.h"
//#import "NewPassPhoneViewCtrl.h"
//#import "CoreTabBarController.h"
//#import "UIViewController+Preloader.h"
//#import "UITextField+Form.h"
//#import "LoginPhoneRequestData.h"
//#import "RegPhoneRequestData.h"
//#import "TelematicsAppRegPopup.h"
//#import "NSDate+UI.h"
//#import "NSDate+ISO8601.h"
//#import "LogSetup.h"
//#import "Helpers.h"
//
//@interface RestorePhoneViewCtrl () <UITextFieldDelegate> {
//    int currSeconds;
//}
//
//@property (nonatomic, strong) LoginResponse *loginData;
//
//@property (weak, nonatomic) IBOutlet UIImageView    *zrLogo;
//@property (weak, nonatomic) IBOutlet UITextField    *codeField;
//@property (weak, nonatomic) IBOutlet UIButton       *nextBtn;
//@property (weak, nonatomic) IBOutlet UIButton       *repeatPasswordBtn;
//@property (weak, nonatomic) IBOutlet UIButton       *backButton;
//@property (weak, nonatomic) IBOutlet UILabel        *userDesc;
//@property (weak, nonatomic) IBOutlet UILabel        *repeatPasswordLbl;
//@property (strong, nonatomic) NSTimer               *passwordAlertTimer;
//
//@end
//
//@implementation RestorePhoneViewCtrl
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    self.zrLogo.image = [UIImage imageNamed:[Configurator sharedInstance].mainLogoColor];
//    
//    self.codeField.delegate = self;
//    [self.codeField makeFormFieldZero];
//    [self.codeField setBackgroundColor:[Color lightSeparatorColor]];
//    self.codeField.textColor = [UIColor darkGrayColor];
//    [self.codeField.layer setMasksToBounds:YES];
//    [self.codeField.layer setCornerRadius:15.0f];
//    [self.codeField.layer setBorderColor:[[Color officialMainAppColor] CGColor]];
//    [self.codeField.layer setBorderWidth:0.5];
//    self.codeField.placeholder = localizeString(@"enter code");
//    if (@available(iOS 12.0, *)) {
//        self.codeField.textContentType = UITextContentTypeOneTimeCode;
//    }
//    
//    [self.nextBtn setTintColor:[Color officialWhiteColor]];
//    [self.nextBtn setBackgroundColor:[Color officialMainAppColor]];
//    [self.nextBtn.layer setMasksToBounds:YES];
//    [self.nextBtn.layer setCornerRadius:15.0f];
//    NSMutableAttributedString *nextText = [[NSMutableAttributedString alloc] initWithString:localizeString(@"NEXT")];
//    [nextText addAttribute:NSFontAttributeName value:[Font medium13] range:NSMakeRange(0, [nextText length])];
//    [nextText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleNone] range:NSMakeRange(0, [nextText length])];
//    [nextText addAttribute:NSForegroundColorAttributeName value:[Color officialWhiteColor] range:NSMakeRange(0, [nextText length])];
//    [self.nextBtn setAttributedTitle:nextText forState:UIControlStateNormal];
//    
//    //repeat pass button
//    [self.repeatPasswordBtn setTintColor:[UIColor lightGrayColor]];
//    NSMutableAttributedString *newPass = [[NSMutableAttributedString alloc] initWithString:localizeString(@"Get a new code")];
//    [newPass addAttribute:NSFontAttributeName value:[Font regular11] range:NSMakeRange(0, [newPass length])];
//    [newPass addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [newPass length])];
//    [self.repeatPasswordBtn setAttributedTitle:newPass forState:UIControlStateNormal];
//    [self.repeatPasswordBtn addTarget:self action:@selector(getVerifyCodeAgain) forControlEvents:UIControlEventTouchUpInside];
//    
//    //back button
//    [self.backButton setTintColor:[UIColor lightGrayColor]];
//    NSMutableAttributedString *backOtherPhone = [[NSMutableAttributedString alloc] initWithString:localizeString(@"Sign in with another phone")];
//    [backOtherPhone addAttribute:NSFontAttributeName value:[Font regular11] range:NSMakeRange(0, [backOtherPhone length])];
//    [backOtherPhone addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [backOtherPhone length])];
//    [self.backButton setAttributedTitle:backOtherPhone forState:UIControlStateNormal];
//    
//    [self.userDesc setText:[NSString stringWithFormat:localizeString(@"Message with a code was sent to %@\nEnter it in the field below"), self.enteredPhone]];
//    
//    [self setRepeatPasswordLabel];
//    self.shiftHeight = -1;
//    [self registerForKeyboardNotifications];
//}
//
//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self showKeyboard];
//    });
//}
//
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [super touchesBegan:touches withEvent:event];
//    [self.view endEditing:YES];
//}
//
//
//#pragma mark Actions
//
//- (IBAction)nextBtnAction:(id)sender {
//    
//    if (self.codeField.text.length <= 3) {
//        [self errorRestorePhoneFunction];
//        return;
//    }
//    
//    NewPassPhoneViewCtrl* newPassEmail = [self.storyboard instantiateViewControllerWithIdentifier:@"NewPassPhoneViewCtrl"];
//    newPassEmail.enteredPhone = self.enteredPhone;
//    newPassEmail.enteredCode = self.codeField.text;
//    [self.navigationController pushViewController:newPassEmail animated:YES];
//}
//
//- (void)errorRestorePhoneFunction {
//    if (IS_IPHONE_5 || IS_IPHONE_4)
//        self.userDesc.font = [Font medium10];
//    
//    self.userDesc.text = localizeString(@"validation_invalid_code_phone");
//    self.userDesc.textColor = [Color officialRedColor];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        if (IS_IPHONE_5 || IS_IPHONE_4)
//            self.userDesc.font = [Font regular12];
//        
//        [self.userDesc setText:[NSString stringWithFormat:localizeString(@"Message with a code was sent to %@\nEnter it in the field below"), self.enteredPhone]];
//        self.userDesc.textColor = [Color darkGrayColor];
//    });
//}
//
//- (void)getVerifyCodeAgain {
//    if (!self.passwordAlertTimer.isValid) {
//        currSeconds = 30;
//        self.passwordAlertTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(runPasswordAlert) userInfo:nil repeats:YES];
//    } else {
//        [self.passwordAlertTimer invalidate];
//        self.passwordAlertTimer = nil;
//    }
//    
//    NSString *delPhoneChar = [[self.enteredPhone componentsSeparatedByCharactersInSet:
//                               [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
//                              componentsJoinedByString:@""];
//    
//    RegPhoneRequestData* regData = [[RegPhoneRequestData alloc] init];
//    regData.value = [NSString stringWithFormat:@"+%@", delPhoneChar];
//    regData.resetTypeDataContract = @"Phone";
//    
//    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
//        [self hidePreloader];
//        if ([response isSuccesful]) {
//            //
//        } else {
//            if ([error.localizedDescription isEqualToString:@"Request failed: bad request (400)"]) {
//                [self.errorHandler showErrorMessages:@[localizeString(@"Phone number isn't correct.")]];
//            } else {
//                [self.errorHandler handleError:error response:response];
//            }
//        }
//    }] resendPasswordWithPhone:regData];
//}
//
//- (void)runPasswordAlert {
//    if (currSeconds >= 1) {
//        if (currSeconds == 1) {
//            [self.passwordAlertTimer invalidate];
//            [self setRepeatPasswordLabel];
//            currSeconds = 30;
//        } else if (currSeconds > 0) {
//            currSeconds -= 1;
//            
//            self.repeatPasswordBtn.hidden = YES;
//            
//            NSString *seconds = [NSString stringWithFormat:NSLocalizedString(@"Resend password after %d sec", nil), currSeconds];
//            self.repeatPasswordLbl.hidden = NO;
//            self.repeatPasswordLbl.text = seconds;
//        }
//    } else {
//        [self.passwordAlertTimer invalidate];
//        [self setRepeatPasswordLabel];
//    }
//}
//
//- (void)setRepeatPasswordLabel {
//    self.repeatPasswordLbl.hidden = YES;
//    self.repeatPasswordBtn.hidden = NO;
//}
//
//
//#pragma mark UITextFieldDelegate
//
//- (void)showKeyboard {
//    [self.codeField becomeFirstResponder];
//}
//
//- (void)dismissKeyboard {
//    [self.codeField resignFirstResponder];
//}
//
//- (void)textFieldDidBeginEditing:(UITextField *)textField {
//    
//    [self.errorHandler dismissActiveNotifNow];
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        
//        double coefPhoto = 0.2;
//        
//        CGAffineTransform translateAvatar = CGAffineTransformMakeTranslation(0, self.zrLogo.frame.origin.y + self.view.bounds.size.height * coefPhoto);
//        CGAffineTransform scaleAvatar = CGAffineTransformMakeScale(0.8, 0.8);
//        if (IS_IPHONE_5 || IS_IPHONE_4)
//            scaleAvatar = CGAffineTransformMakeScale(0.4, 0.4);
//        CGAffineTransform transformAvatar = CGAffineTransformConcat(translateAvatar, scaleAvatar);
//        
//        [UIView beginAnimations:@"TelematicsAppLogoMoveAnimation" context:nil];
//        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//        [UIView setAnimationDuration:0.4];
//        
//        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut  animations:^{
//            [self.view setFrame:CGRectMake(0.f, -160.0f, self.view.bounds.size.width, self.view.bounds.size.height)];
//            self.zrLogo.transform = transformAvatar;
//            [UIView commitAnimations];
//            
//        } completion:^(BOOL finished) {
//            if (finished) {
//                //
//            }
//        }];
//    });
//}
//
//- (void)textFieldDidEndEditing:(UITextField *)codeField {
//    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        [self.view setFrame:CGRectMake(0.f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height)];
//        self.zrLogo.transform = CGAffineTransformMakeScale(1.0, 1.0);
//        [UIView commitAnimations];
//    } completion:^(BOOL finished) {
//        [self dismissKeyboard];
//    }];
//}
//
//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    if (textField == self.codeField) {
//        [self.view endEditing:YES];
//        [self nextBtnAction:self.nextBtn];
//        return YES;
//    }
//    return YES;
//}
//
//- (IBAction)toMainPageAllBackAction:(id)sender {
//    [self.navigationController popToRootViewControllerAnimated:NO];
//}
//
//@end
