//
//  PhoneLoginViewCtrl.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 14.06.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "PhoneLoginViewCtrl.h"
#import "UIViewController+Preloader.h"
#import "UIImageView+WebCache.h"
#import "Helpers.h"

@interface PhoneLoginViewCtrl () <UITextFieldDelegate> {
    int currSeconds;
}

@property (nonatomic, strong) LoginResponse         *loginData;

@property (weak, nonatomic) IBOutlet UITextField    *passField;
@property (weak, nonatomic) IBOutlet UIButton       *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton       *getNewPassword;
@property (weak, nonatomic) IBOutlet UIButton       *backButton;
@property (weak, nonatomic) IBOutlet UIImageView    *logoImg;
@property (weak, nonatomic) IBOutlet UIImageView    *linesGreenBackground;
@property (weak, nonatomic) IBOutlet UILabel        *loggedNameLbl;
@property (weak, nonatomic) IBOutlet UILabel        *enterPassLbl;

@property (weak, nonatomic) IBOutlet UILabel        *repeatPasswordLbl;
@property (strong, nonatomic) NSTimer               *passwordAlertTimer;

@end

@implementation PhoneLoginViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [GeneralService sharedService].realtimeDatabase = [[FIRDatabase database] reference]; //GET FIREBASE DATABASE IN CACHE
    
    self.loggedNameLbl.textColor = [Color officialMainAppColor];
    
    self.passField.delegate = self;
    [self.passField makeFormFieldZero];
    self.passField.textColor = [UIColor blackColor];
    [self.passField setBackgroundColor:[Color lightSeparatorColor]];
    [self.passField.layer setMasksToBounds:YES];
    [self.passField.layer setCornerRadius:20.0f];
    [self.passField.layer setBorderColor:[[Color officialMainAppColor] CGColor]];
    [self.passField.layer setBorderWidth:1.5];
    self.passField.placeholder = localizeString(@"enter password");
    self.passField.secureTextEntry = YES;
    if (@available(iOS 12.0, *)) {
        self.passField.textContentType = UITextContentTypeOneTimeCode;
    }
    
    [self.loginBtn setBackgroundColor:[Color officialMainAppColor]];
    [self.loginBtn.layer setMasksToBounds:YES];
    [self.loginBtn.layer setCornerRadius:20.0f];
    [self.loginBtn.titleLabel setFont:[Font medium13]];
    //[self.loginBtn setTitle:localizeString(@"SIGN IN") forState:UIControlStateNormal];
    [self.loginBtn setTitle:localizeString(@"LOG IN") forState:UIControlStateNormal];
    
    self.enterPassLbl.text = localizeString(@"Enter your password from sms");
    
    [self.linesGreenBackground setImage:[UIImage imageNamed:@"zigzag"]];
    
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
    
    [self.loggedNameLbl setText:localizeString(@"Login to your account")];
    
    self.shiftHeight = -1;
    [self registerForKeyboardNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_IMMEDIATELY_08_SEC * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showKeyboard];
    });
}


#pragma mark Actions

- (IBAction)loginBtnClick:(id)sender {
    
    FIRAuthCredential *credential = [[FIRPhoneAuthProvider provider] credentialWithVerificationID:_savedVerificationId verificationCode:self.passField.text];
    
    [[FIRAuth auth] signInWithCredential:credential
                              completion:^(FIRAuthDataResult * _Nullable authResult,
                                           NSError * _Nullable error) {
        
        if (error.code == FIRAuthErrorCodeSecondFactorRequired) {
            //TODO IF NEEDED
        } else if (error) {
            [self.errorHandler handleError:error response:nil];
            return;
        }
        
        // User successfully signed in. Get user data from the FIRUser object
        if (authResult == nil) { return; }
        
        [GeneralService sharedService].user_FIR = authResult.user;

        FIRDatabaseQuery *allUserData = [[[GeneralService sharedService].realtimeDatabase child:@"users"] child:authResult.user.uid];
        [allUserData observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull userProfileSnapshot) {

            [self dismissKeyboard];
            [self showPreloader];
            
            if (userProfileSnapshot.value == [NSNull null]) {
                
                NSLog(@"No user data in Firebase Database! Create this if deleted NEW USER!");
                
                //LOGINAUTH FRAMEWORK
                //DATABASE ERROR - GET NEW DEVICETOKEN FOR USER - CREATING USER AGAIN IF LOST
                
                NSString *finishedPhoneNumber = self.enteredPhone ? self.enteredPhone : @"";
                
                [[LoginAuthCore sharedManager] createDeviceTokenForUserWithParametersAndInstanceId:[Configurator sharedInstance].instanceId
                                                                instanceKey:[Configurator sharedInstance].instanceKey
                                                                      email:@""
                                                                      phone:finishedPhoneNumber
                                                                  firstName:@""
                                                                   lastName:@""
                                                                    address:@""
                                                                   birthday:@""
                                                                     gender:@""                 //   String Male/Female
                                                              maritalStatus:@""                 //   String 1/2/3/4 = "Married"/"Widowed"/"Divorced"/"Single"
                                                              childrenCount:@0                  //   count 1-10
                                                                   clientId:@""
                                                                     result:^(NSString* deviceToken, NSString* jwToken, NSString* refreshToken) {

                    //STORE IN SHAREDSERVICE
                    [GeneralService sharedService].device_token_number = deviceToken;
                    [GeneralService sharedService].jwt_token_number = jwToken;
                    [GeneralService sharedService].refresh_token_number = refreshToken;
                    [GeneralService sharedService].firebase_user_id = authResult.user.uid;
                    
                    if (deviceToken == nil || jwToken == nil || refreshToken == nil) {
                        NSLog(@"BACKEND ERROR NO TOKENS NEED UPDATE COMPANY %@", deviceToken);
                        [self hidePreloader];
                        return;
                    }

                    //CHECK ALL AT NIL
                    //FIREBASE DATABASE DID'T WORK WITH NIL
                    //NSString *finishedPhoneNumber = self.enteredPhone ? self.enteredPhone : @"";
                    [GeneralService sharedService].stored_userPhone = finishedPhoneNumber;

                    // DO NOT STORE JWTOKEN & REFRESHTOKEN IN FIREBASE DATABASE! IT IS NOT SAFE!
                    // STORE OTHER USER INFO IN DATABASE
                    [[[[GeneralService sharedService].realtimeDatabase child:@"users"] child:authResult.user.uid] setValue:@{
                                                                                     @"deviceToken": [GeneralService sharedService].device_token_number,
                                                                                     @"userId": authResult.user.uid,
                                                                                     @"email": @"",
                                                                                     @"phone": finishedPhoneNumber,
                                                                                     @"firstName": @"",
                                                                                     @"lastName": @"",
                                                                                     @"birthday": @"",
                                                                                     @"address": @"",
                                                                                     @"gender": @"",
                                                                                     @"maritalStatus": @"",
                                                                                     @"childrenCount": @"",
                                                                                     @"clientId": @"",
                                                                                     @"profilePictureLink": @""
                                               }];
                    }];

                    [GeneralService sharedService].user_FIR = authResult.user;
                    [GeneralService sharedService].firebase_user_id = authResult.user.uid;

                    [GeneralService sharedService].stored_userEmail = @"";
                    [GeneralService sharedService].stored_firstName = @"";
                    [GeneralService sharedService].stored_lastName = @"";
                    [GeneralService sharedService].stored_birthday = @"";
                    [GeneralService sharedService].stored_address = @"";
                    [GeneralService sharedService].stored_gender = @"";
                    [GeneralService sharedService].stored_maritalStatus = @"";
                    [GeneralService sharedService].stored_childrenCount = @0;
                    [GeneralService sharedService].stored_clientId = @"";

                    //LOGIN USER IN APP WITH NEW DEVICETOKEN IF IT'S LOST AFTER STORE SNAPSHOT IN FIREBASE
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_IMMEDIATELY_2_SEC * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[GeneralService sharedService] enterUserInAppWith:[GeneralService sharedService].device_token_number
                                                                   jwToken:[GeneralService sharedService].jwt_token_number
                                                              refreshToken:[GeneralService sharedService].refresh_token_number];

                        [self hidePreloader];
                    });
                
            } else {
                
                //GET SNAPSHOT USER DATA FROM FIREBASE DATABASE
                NSDictionary *allUsersData = (NSDictionary*)userProfileSnapshot.value;
                NSLog(@"Success Fetch Users Data From Firebase Database %@", allUsersData);
                
                [GeneralService sharedService].device_token_number = allUsersData[@"deviceToken"];
                [GeneralService sharedService].firebase_user_id = allUsersData[@"userId"];
                
                [GeneralService sharedService].stored_userEmail = allUsersData[@"email"];
                [GeneralService sharedService].stored_userPhone = allUsersData[@"phone"];
                [GeneralService sharedService].stored_firstName = allUsersData[@"firstName"];
                [GeneralService sharedService].stored_lastName = allUsersData[@"lastName"];
                [GeneralService sharedService].stored_birthday = allUsersData[@"birthday"];
                [GeneralService sharedService].stored_address = allUsersData[@"address"];
                [GeneralService sharedService].stored_gender = allUsersData[@"gender"];
                [GeneralService sharedService].stored_maritalStatus = allUsersData[@"maritalStatus"];
                [GeneralService sharedService].stored_childrenCount = allUsersData[@"childrenCount"];
                [GeneralService sharedService].stored_clientId = allUsersData[@"clientId"];
                [GeneralService sharedService].stored_profilePictureLink = allUsersData[@"profilePictureLink"];
                
                //
                //IF DEVICE TOKEN IS LOST IT CANNOT BE RESTORED!
                //THE USER WILL GET A NEW TOKEN AND LOSE ALL ITS DATA!
                //
                //IF WE DID NOT HAVE DEVICE TOKEN - GET HERE NOW, IT IS REQUIRED!
                //CHECK USER DEVICE TOKEN & SAFE IN FIREBASE DATABASE ALWAYS
                //
                if (allUsersData[@"deviceToken"] == nil || [allUsersData[@"deviceToken"] isEqual:@""]) {
                    
                    NSString *phoneSelected = self.enteredPhone ? self.enteredPhone : @"";
                    
                    //LOGINAUTH FRAMEWORK
                    //DATABASE ERROR - GET NEW DEVICETOKEN FOR USER - CREATING USER AGAIN IF LOST!
                    [[LoginAuthCore sharedManager] createDeviceTokenForUserWithParametersAndInstanceId:[Configurator sharedInstance].instanceId
                                                                    instanceKey:[Configurator sharedInstance].instanceKey
                                                                          email:@""
                                                                          phone:phoneSelected
                                                                      firstName:@""
                                                                       lastName:@""
                                                                        address:@""
                                                                       birthday:@""
                                                                         gender:@""                 //   String Male/Female
                                                                  maritalStatus:@""                 //   String 1/2/3/4 = "Married"/"Widowed"/"Divorced"/"Single"
                                                                  childrenCount:@0                  //   count 1-10
                                                                       clientId:@""
                                                                         result:^(NSString* deviceToken, NSString* jwToken, NSString* refreshToken) {

                        //STORE IN OUR SHAREDSERVICE MAIN USER TOKENS
                        [GeneralService sharedService].device_token_number = deviceToken;
                        [GeneralService sharedService].jwt_token_number = jwToken;
                        [GeneralService sharedService].refresh_token_number = refreshToken;
                        [GeneralService sharedService].firebase_user_id = authResult.user.uid;

                        //CHECK ALL AT NIL
                        //FIREBASE DATABASE DID'T WORK WITH NIL
                        [GeneralService sharedService].stored_userPhone = phoneSelected;

                        NSString *email = [GeneralService sharedService].stored_userEmail ? [GeneralService sharedService].stored_userEmail : @"";
                        NSString *firstName = [GeneralService sharedService].stored_firstName ? [GeneralService sharedService].stored_firstName : @"";
                        NSString *lastName = [GeneralService sharedService].stored_lastName ? [GeneralService sharedService].stored_lastName : @"";
                        NSString *birthday = [GeneralService sharedService].stored_birthday ? [GeneralService sharedService].stored_birthday : @"";
                        NSString *address = [GeneralService sharedService].stored_address ? [GeneralService sharedService].stored_address : @"";
                        NSString *gender = [GeneralService sharedService].stored_gender ? [GeneralService sharedService].stored_gender : @"";
                        NSString *marital = [GeneralService sharedService].stored_maritalStatus ? [GeneralService sharedService].stored_maritalStatus : @"";
                        NSNumber *children = [GeneralService sharedService].stored_childrenCount ? [GeneralService sharedService].stored_childrenCount : @0;
                        NSString *clientId = [GeneralService sharedService].stored_clientId ? [GeneralService sharedService].stored_clientId : @"";
                        NSString *profileImg = [GeneralService sharedService].stored_profilePictureLink ? [GeneralService sharedService].stored_profilePictureLink : @"";

                        [[[[GeneralService sharedService].realtimeDatabase child:@"users"]
                                                   child:authResult.user.uid] setValue:@{@"deviceToken": deviceToken,
                                                                                         @"userId": authResult.user.uid,
                                                                                         @"email": email,
                                                                                         @"phone": phoneSelected,
                                                                                         @"firstName": firstName,
                                                                                         @"lastName": lastName,
                                                                                         @"birthday": birthday,
                                                                                         @"address": address,
                                                                                         @"gender": gender,
                                                                                         @"maritalStatus": marital,
                                                                                         @"childrenCount": children,
                                                                                         @"clientId": clientId,
                                                                                         @"profilePictureLink": profileImg
                                                   }
                         ];

                        //LOGIN USER IN APP WITH NEW DEVICETOKEN IF IT'S LOST!
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_IMMEDIATELY_2_SEC * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [[GeneralService sharedService] enterUserInAppWith:[GeneralService sharedService].device_token_number
                                                                       jwToken:[GeneralService sharedService].jwt_token_number
                                                                  refreshToken:[GeneralService sharedService].refresh_token_number];

                            [self hidePreloader];
                        });
                    }];
                        
                } else {
                    
                    //LOGINAUTH FRAMEWORK
                    //ELSE GET JWTOKEN & REFRESHTOKEN FOR EXIST USER BY DEVICETOKEN SAVED FROM FIREBASE DATABASE
                    //LOGIN EXIST USER IN YOUR APP AGAIN
                    
                    [[LoginAuthCore sharedManager] getJWTokenForUserWithDeviceToken:[GeneralService sharedService].device_token_number
                                                                         instanceId:[Configurator sharedInstance].instanceId
                                                                        instanceKey:[Configurator sharedInstance].instanceKey
                                                                             result:^(NSString *newJWToken, NSString *newRefreshToken) {
                        NSLog(@"NEW RESTORED jwToken by DEVICETOKEN %@", newJWToken);
                        NSLog(@"NEW RESTORED refreshToken by DEVICETOKEN %@", newRefreshToken);
                        
                        //STORE IN SHAREDSERVICE
                        [GeneralService sharedService].jwt_token_number = newJWToken;
                        [GeneralService sharedService].refresh_token_number = newRefreshToken;
                        
                        //LOGIN EXIST USER IN APP
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_IMMEDIATELY_2_SEC * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [[GeneralService sharedService] enterUserInAppWith:[GeneralService sharedService].device_token_number
                                                                       jwToken:[GeneralService sharedService].jwt_token_number
                                                                  refreshToken:[GeneralService sharedService].refresh_token_number];

                            [self hidePreloader];
                        });
                    }];
                    
                }
            }
        }];
    }];
}

- (IBAction)getNewPassword:(id)sender {
    //TODO FIREBASE RESTORE IF NEEDED
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

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_IMMEDIATELY_04_SEC * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //ANIMATION VALUE FOR LOGO
        double coefPhoto = 0.38;
        float coefLbl = 170.0f;
        if (IS_IPHONE_11 || IS_IPHONE_13_PRO) {
            coefPhoto = 0.55;
            coefLbl = 76.0f;
        } else if (IS_IPHONE_11_PROMAX || IS_IPHONE_13_PROMAX) {
            coefPhoto = 0.55;
            coefLbl = 50.0f;
        } else if (IS_IPHONE_5 || IS_IPHONE_4) {
            coefPhoto = 0.30;
            coefLbl = 218.0f;
        }

        CGAffineTransform translateAvatar = CGAffineTransformMakeTranslation(0, self.logoImg.frame.origin.y + self.view.bounds.size.height * coefPhoto);
        CGAffineTransform scaleAvatar = CGAffineTransformMakeScale(0.5, 0.5);
        CGAffineTransform transformAvatar = CGAffineTransformConcat(translateAvatar, scaleAvatar);

        CGAffineTransform translateLabel = CGAffineTransformMakeTranslation(0, self.loggedNameLbl.frame.origin.y - coefLbl);
        CGAffineTransform scaleLabel = CGAffineTransformMakeScale(1.0, 1.0);
        CGAffineTransform transformLabel = CGAffineTransformConcat(translateLabel, scaleLabel);

        [UIView beginAnimations:@"LogoMoveAnimation" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.4];

        [UIView animateWithDuration:DELAY_IMMEDIATELY_04_SEC delay:0 options:UIViewAnimationOptionCurveEaseOut  animations:^{

            [self.view setFrame:CGRectMake(0.f, -160.0f, self.view.bounds.size.width, self.view.bounds.size.height)];
            self.logoImg.transform = transformAvatar;
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
    
    //ANIMATION VALUE FOR END EDITING
    float coefLbl = 320.0f;
    if (IS_IPHONE_11 || IS_IPHONE_13_PRO) {
        coefLbl = 463.0f;
    } else if (IS_IPHONE_11_PROMAX || IS_IPHONE_13_PROMAX) {
        coefLbl = 483.0f;
    } else if (IS_IPHONE_5 || IS_IPHONE_4)
        coefLbl = 274.0f;
    
    [UIView animateWithDuration:DELAY_IMMEDIATELY_04_SEC delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.view setFrame:CGRectMake(0.f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height)];
        self.logoImg.transform = CGAffineTransformMakeScale(1.0, 1.0);
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
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
