//
//  EmailLoginViewCtrl.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 14.06.18.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "EmailLoginViewCtrl.h"
#import "UIViewController+Preloader.h"
#import "UITextField+Form.h"
#import "UIImageView+WebCache.h"

@interface EmailLoginViewCtrl () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField        *passField;
@property (weak, nonatomic) IBOutlet UIButton           *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton           *backButton;
@property (weak, nonatomic) IBOutlet UIImageView        *userAvatarImg;
@property (weak, nonatomic) IBOutlet UIImageView        *linesGreenBackground;
@property (weak, nonatomic) IBOutlet UILabel            *loggedNameLbl;
@property (weak, nonatomic) IBOutlet UILabel            *enterPassLbl;

@end

@implementation EmailLoginViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _realtimeDatabaseRef = [[FIRDatabase database] reference];
    
    self.loggedNameLbl.textColor = [Color officialMainAppColor];
    
    [self.passField makeFormFieldZero];
    [self.passField setBackgroundColor:[Color lightSeparatorColor]];
    [self.passField.layer setMasksToBounds:YES];
    [self.passField.layer setCornerRadius:15.0f];
    self.passField.secureTextEntry = YES;
    [self.passField.layer setBorderColor:[[Color officialMainAppColor] CGColor]];
    [self.passField.layer setBorderWidth:1.5];
    self.passField.secureTextEntry = YES;
    self.passField.placeholder = localizeString(@"enter password");
    
    [self.loginBtn setBackgroundColor:[Color officialMainAppColor]];
    [self.loginBtn.layer setMasksToBounds:YES];
    [self.loginBtn.layer setCornerRadius:15.0f];
    [self.loginBtn.titleLabel setFont:[Font medium13]];
    [self.loginBtn setTitle:self.signInBtnText forState:UIControlStateNormal];
    
    self.enterPassLbl.text = self.welcomeText;
    
    [self.linesGreenBackground setImage:[UIImage imageNamed:@"zigzag"]];
    
    [self.userAvatarImg sd_setImageWithURL:[NSURL URLWithString:_userPhotoUrl] placeholderImage:[UIImage imageNamed:@"no_avatar"]];
    self.userAvatarImg.layer.cornerRadius = self.userAvatarImg.layer.frame.size.width/2;
    self.userAvatarImg.layer.masksToBounds = YES;
    self.userAvatarImg.contentMode = UIViewContentModeScaleAspectFill;
    
    //Other Login
    UIFont *fontSpecial = [Font regular11];
    [self.backButton setTintColor:[UIColor lightGrayColor]];
    NSMutableAttributedString *backOtherEmail = [[NSMutableAttributedString alloc] initWithString:localizeString(@"Sign in with another email")];
    [backOtherEmail addAttribute:NSFontAttributeName value:fontSpecial range:NSMakeRange(0, [backOtherEmail length])];
    [backOtherEmail addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [backOtherEmail length])];
    [self.backButton setAttributedTitle:backOtherEmail forState:UIControlStateNormal];
    
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
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

#pragma mark Actions

- (IBAction)loginBtnClick:(id)sender {
    
    [self dismissKeyboard];
    [self showPreloader];
    
    if (self.isUserExist) {
        
        //LOGIN USER IN APP
        [[FIRAuth auth] signInWithEmail:self.enteredEmail
                               password:self.passField.text
                             completion:^(FIRAuthDataResult *existUser, NSError *error) {
                                
                                    if (error) {
                                        [GeneralService alert:error.localizedDescription title:@"Message"];
                                        [self hidePreloader];
                                        return;
                                    }
            
                                    [GeneralService sharedInstance].user_FIR = existUser.user;
            
                                    FIRDatabaseQuery *allUserData = [[self.realtimeDatabaseRef child:@"users"] child:existUser.user.uid];
                                    [allUserData observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
              
                                        if (snapshot.value == [NSNull null]) {
                                            NSLog(@"No user data!");
                                        } else {
                                            
                                            //GET SNAPSHOT USER DATA FROM FIREBASE DATABASE
                                            NSDictionary *allUsersData = (NSDictionary*)snapshot.value;
                                            NSLog(@"All Users Data From Firebase Database%@", allUsersData);
                                            
                                            [GeneralService sharedInstance].device_token_number = allUsersData[@"deviceToken"];
                                            [GeneralService sharedInstance].firebase_user_id = allUsersData[@"userId"];
                                            
                                            [GeneralService sharedInstance].stored_userEmail = allUsersData[@"email"];
                                            [GeneralService sharedInstance].stored_userPhone = allUsersData[@"phone"];
                                            [GeneralService sharedInstance].stored_firstName = allUsersData[@"firstName"];
                                            [GeneralService sharedInstance].stored_lastName = allUsersData[@"lastName"];
                                            [GeneralService sharedInstance].stored_birthday = allUsersData[@"birthday"];
                                            [GeneralService sharedInstance].stored_address = allUsersData[@"address"];
                                            [GeneralService sharedInstance].stored_clientId = allUsersData[@"clientId"];
                                            [GeneralService sharedInstance].stored_avatarLink = allUsersData[@"avatarLink"];
                                            
                                            
                                            //
                                            //IF DEVICE TOKEN IS LOST IT CANNOT BE RESTORED!
                                            //THE USER WILL GET A NEW TOKEN AND LOSE ALL ITS DATA!
                                            //
                                            //IF WE DID NOT HAVE DEVICE TOKEN - GET HERE NOW, IT IS REQUIRED!
                                            //CHECK USER DEVICE TOKEN & SAFE IN FIREBASE DATABASE ALWAYS
                                            //
                                            if (allUsersData[@"deviceToken"] == nil || [allUsersData[@"deviceToken"] isEqual:@""]) {
                                                
                                                //GET NEW DEVICETOKEN FOR USER
                                                [[LoginAuthCore sharedManager] createDeviceTokenForUserWithInstanceId:[Configurator sharedInstance].instanceId
                                                                                                          instanceKey:[Configurator sharedInstance].instanceKey
                                                                                                               result:^(NSString *deviceToken, NSString *jwToken, NSString *refreshToken) {
                                                    
                                                    //STORE IN SHAREDSERVICE
                                                    [GeneralService sharedInstance].device_token_number = deviceToken;
                                                    [GeneralService sharedInstance].jwt_token_number = jwToken;
                                                    [GeneralService sharedInstance].refresh_token_number = refreshToken;
                                                    [GeneralService sharedInstance].firebase_user_id = existUser.user.uid;
                                                    
                                                    //CHECK ALL AT NIL
                                                    //FIREBASE DATABASE DID'T WORK WITH NIL
                                                    NSString *email = self.enteredEmail ? self.enteredEmail : @"";
                                                    [GeneralService sharedInstance].stored_userEmail = email;
                                                    
                                                    NSString *phone = [GeneralService sharedInstance].stored_userPhone ? [GeneralService sharedInstance].stored_userPhone : @"";
                                                    NSString *firstName = [GeneralService sharedInstance].stored_firstName ? [GeneralService sharedInstance].stored_firstName : @"";
                                                    NSString *lastName = [GeneralService sharedInstance].stored_lastName ? [GeneralService sharedInstance].stored_lastName : @"";
                                                    NSString *birthday = [GeneralService sharedInstance].stored_birthday ? [GeneralService sharedInstance].stored_birthday : @"";
                                                    NSString *address = [GeneralService sharedInstance].stored_address ? [GeneralService sharedInstance].stored_address : @"";
                                                    NSString *clientId = [GeneralService sharedInstance].stored_clientId ? [GeneralService sharedInstance].stored_clientId : @"";
                                                    
                                                    [[[self->_realtimeDatabaseRef child:@"users"]
                                                                               child:existUser.user.uid] setValue:@{@"deviceToken": deviceToken,
                                                                                                                    @"userId": existUser.user.uid,
                                                                                                                    @"email": email,
                                                                                                                    @"phone": phone,
                                                                                                                    @"firstName": firstName,
                                                                                                                    @"lastName": lastName,
                                                                                                                    @"birthday": birthday,
                                                                                                                    @"address": address,
                                                                                                                    @"clientId": clientId}
                                                     ];
                                                    
                                                    //LOGIN USER IN APP WITH NEW DEVICETOKEN IF IT'S LOST!
                                                    [[GeneralService sharedInstance] enterUserInAppWith:[GeneralService sharedInstance].device_token_number
                                                                                                jwToken:[GeneralService sharedInstance].jwt_token_number
                                                                                           refreshToken:[GeneralService sharedInstance].refresh_token_number];
                                                    
                                                    [self hidePreloader];
                                                }];
                                                    
                                            } else {
                                                
                                                //ELSE GET JWTOKEN & REFRESHTOKEN FOR EXIST USER BY DEVICETOKEN SAVED FROM FIREBASE DATABASE
                                                //LOGIN EXIST USER IN YOUR APP
                                                
                                                [[LoginAuthCore sharedManager] getJWTokenForUserWithDeviceToken:[GeneralService sharedInstance].device_token_number
                                                                                                     instanceId:[Configurator sharedInstance].instanceId
                                                                                                    instanceKey:[Configurator sharedInstance].instanceKey
                                                                                                         result:^(NSString *newJWToken, NSString *newRefreshToken) {
                                                    NSLog(@"NEW RESTORED jwToken by DEVICETOKEN %@", newJWToken);
                                                    NSLog(@"NEW RESTORED refreshToken by DEVICETOKEN %@", newRefreshToken);
                                                    
                                                    //STORE IN SHAREDSERVICE
                                                    [GeneralService sharedInstance].jwt_token_number = newJWToken;
                                                    [GeneralService sharedInstance].refresh_token_number = newRefreshToken;
                                                    
                                                    //LOGIN EXIST USER IN APP
                                                    [[GeneralService sharedInstance] enterUserInAppWith:[GeneralService sharedInstance].device_token_number
                                                                                                jwToken:[GeneralService sharedInstance].jwt_token_number
                                                                                           refreshToken:[GeneralService sharedInstance].refresh_token_number];
                                                    
                                                    [self hidePreloader];
                                                }];
                                                
                                            }
                                        }
                                    }];
        }];
        
    } else {
        
        [[FIRAuth auth] createUserWithEmail:self.enteredEmail password:self.passField.text completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
            if (error) {
                [GeneralService alert:error.localizedDescription title:@"Message"];
                [self hidePreloader];
                return;
            } else {

                //REGISTRATION - CREATE NEW DEVICETOKEN FOR USER
                [[LoginAuthCore sharedManager] createDeviceTokenForUserWithInstanceId:[Configurator sharedInstance].instanceId
                                                                          instanceKey:[Configurator sharedInstance].instanceKey
                                                                               result:^(NSString *deviceToken, NSString *jwToken, NSString *refreshToken) {
                    
                    //STORE IN SHAREDSERVICE
                    [GeneralService sharedInstance].device_token_number = deviceToken;
                    [GeneralService sharedInstance].jwt_token_number = jwToken;
                    [GeneralService sharedInstance].refresh_token_number = refreshToken;
                    
                    FIRUserProfileChangeRequest *changeRequest = [[FIRAuth auth].currentUser profileChangeRequest];
                    changeRequest.displayName = self.enteredEmail;
                    [changeRequest commitChangesWithCompletion:^(NSError *_Nullable error) {

                        if (error) {
                            [self hidePreloader];
                            return;
                        }
                        
                        // DO NOT STORE JWTOKEN & REFRESHTOKEN IN FIREBASE DATABASE! IT IS NOT SAFE!
                        // STORE OTHER USER INFO IN DATABASE
                        [[[self->_realtimeDatabaseRef child:@"users"]
                                                   child:authResult.user.uid] setValue:@{@"deviceToken": [GeneralService sharedInstance].device_token_number,
                                                                                         @"userId": authResult.user.uid,
                                                                                         @"email": self.enteredEmail,
                                                                                         @"phone": @"",
                                                                                         @"firstName": @"",
                                                                                         @"lastName": @"",
                                                                                         @"birthday": @"",
                                                                                         @"address": @"",
                                                                                         @"clientId": @""}];
                        }];
                        
                        [GeneralService sharedInstance].user_FIR = authResult.user;
                        [GeneralService sharedInstance].firebase_user_id = authResult.user.uid;
                    
                        [GeneralService sharedInstance].stored_userEmail = self.enteredEmail;
                        [GeneralService sharedInstance].stored_userPhone = @"";
                        [GeneralService sharedInstance].stored_firstName = @"";
                        [GeneralService sharedInstance].stored_lastName = @"";
                        [GeneralService sharedInstance].stored_birthday = @"";
                        [GeneralService sharedInstance].stored_address = @"";
                        [GeneralService sharedInstance].stored_clientId = @"";
                        
                        //LOGIN USER IN APP
                        [[GeneralService sharedInstance] enterUserInAppWith:[GeneralService sharedInstance].device_token_number
                                                                    jwToken:[GeneralService sharedInstance].jwt_token_number
                                                               refreshToken:[GeneralService sharedInstance].refresh_token_number];
                    
                        [self hidePreloader];
                }];
                
            }
        }];
        
    }
}

- (IBAction)getNewVerifyCodeOnEmail:(id)sender {
    // GET NEW PASSWORD ON EMAIL
    [[FIRAuth auth] sendPasswordResetWithEmail:self.enteredEmail completion:^(NSError * _Nullable error) {
        NSLog(@"ff");
    }];
}

- (void)errorEmailFunction {
    if (IS_IPHONE_5 || IS_IPHONE_4)
        self.enterPassLbl.font = [Font medium10];
    
    self.enterPassLbl.text = localizeString(@"validation_invalid_email_password");
    self.enterPassLbl.textColor = [Color officialRedColor];
    [self.loginBtn setTitle:localizeString(@"TRY AGAIN") forState:UIControlStateNormal];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (IS_IPHONE_5 || IS_IPHONE_4)
            self.enterPassLbl.font = [Font regular12];
        
        self.enterPassLbl.text = localizeString(@"Enter your password");
        self.enterPassLbl.textColor = [Color darkGrayColor];
    });
}

- (IBAction)backBtnClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.errorHandler dismissActiveNotifNow];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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
