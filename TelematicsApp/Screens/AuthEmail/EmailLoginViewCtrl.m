//
//  EmailLoginViewCtrl.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 14.06.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "EmailLoginViewCtrl.h"
#import "UIViewController+Preloader.h"
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
    
    [GeneralService sharedService].realtimeDatabase = [[FIRDatabase database] reference]; //GET FIREBASE DATABASE IN CACHE
    
    self.loggedNameLbl.textColor = [Color officialMainAppColor];
    
    [self.passField makeFormFieldZero];
    [self.passField setBackgroundColor:[Color lightSeparatorColor]];
    [self.passField.layer setMasksToBounds:YES];
    [self.passField.layer setCornerRadius:20.0f];
    self.passField.secureTextEntry = YES;
    [self.passField.layer setBorderColor:[[Color officialMainAppColor] CGColor]];
    [self.passField.layer setBorderWidth:1.5];
    self.passField.secureTextEntry = YES;
    self.passField.placeholder = localizeString(@"enter password");
    
    [self.loginBtn setBackgroundColor:[Color officialMainAppColor]];
    [self.loginBtn.layer setMasksToBounds:YES];
    [self.loginBtn.layer setCornerRadius:20.0f];
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
            
                                    [GeneralService sharedService].user_FIR = existUser.user;
            
                                    FIRDatabaseQuery *allUserData = [[[GeneralService sharedService].realtimeDatabase child:@"users"] child:existUser.user.uid];
                                    [allUserData observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
              
                                        if (snapshot.value == [NSNull null]) {
                                            NSLog(@"No user data!");
                                            [self createUserIfFirebaseDatabaseError:existUser];
                                            [self hidePreloader];
                                        } else {
                                            
                                            //GET SNAPSHOT USER DATA FROM FIREBASE DATABASE
                                            NSDictionary *allUsersData = (NSDictionary*)snapshot.value;
                                            NSLog(@"All Users Data From Firebase Database%@", allUsersData);
                                            
                                            [GeneralService sharedService].device_token_number = allUsersData[@"deviceToken"];
                                            [GeneralService sharedService].firebase_user_id = allUsersData[@"userId"];
                                            if (!allUsersData[@"userId"]) {
                                                [GeneralService sharedService].firebase_user_id = existUser.user.uid;
                                            }
                                            
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
                                                
                                                //DATABASE ERROR - GET NEW DEVICETOKEN FOR USER - CREATING USER AGAIN IF LOST
                                                [self createUserIfFirebaseDatabaseError:existUser];
                                                    
                                            } else {
                                                
                                                //LOGINAUTH FRAMEWORK
                                                //ELSE GET JWTOKEN & REFRESHTOKEN FOR EXIST USER BY DEVICETOKEN SAVED FROM FIREBASE DATABASE
                                                //LOGIN EXIST USER IN YOUR APP IF NO ERRORS
                                                
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
        
    } else {
        
        //CREATE NEW USER IN APP WITH FIREBASE SERVICE
        [[FIRAuth auth] createUserWithEmail:self.enteredEmail password:self.passField.text completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
            if (error) {
                [GeneralService alert:error.localizedDescription title:@"Message"];
                [self hidePreloader];
                return;
            } else {

                //LOGINAUTH FRAMEWORK
                //REGISTRATION - CREATE NEW DEVICETOKEN, JWTOKEN, REFRESHTOKEN FOR USER FOR CALLING INDICATORS SERVICE & OTHER API
                
                [[LoginAuthCore sharedManager] createDeviceTokenForUserWithParametersAndInstanceId:[Configurator sharedInstance].instanceId
                                                                instanceKey:[Configurator sharedInstance].instanceKey
                                                                      email:self.enteredEmail
                                                                      phone:@""
                                                                  firstName:@""
                                                                   lastName:@""
                                                                    address:@""
                                                                   birthday:@""
                                                                     gender:@""                 //   String Male/Female
                                                              maritalStatus:@""                 //   String 1/2/3/4 = "Married"/"Widowed"/"Divorced"/"Single"
                                                              childrenCount:@0                  //   count 1-10
                                                                   clientId:@""
                                                                     result:^(NSString* deviceToken, NSString* jwToken, NSString* refreshToken) {
                    
                //LOGINAUTH FRAMEWORK - SIMPLE WAY IF NEEDED
                //[[LoginAuthCore sharedManager] createDeviceTokenForUserWithInstanceId:[Configurator sharedInstance].instanceId
                //                                                          instanceKey:[Configurator sharedInstance].instanceKey
                //                                                               result:^(NSString *deviceToken, NSString *jwToken, NSString *refreshToken) {
                    
                    //STORE IN SHAREDSERVICE
                    [GeneralService sharedService].device_token_number = deviceToken;
                    [GeneralService sharedService].jwt_token_number = jwToken;
                    [GeneralService sharedService].refresh_token_number = refreshToken;
                    
                    FIRUserProfileChangeRequest *changeRequest = [[FIRAuth auth].currentUser profileChangeRequest];
                    changeRequest.displayName = self.enteredEmail;
                    [changeRequest commitChangesWithCompletion:^(NSError *_Nullable error) {

                        if (error) {
                            [self hidePreloader];
                            return;
                        }
                        
                        // DO NOT STORE JWTOKEN & REFRESHTOKEN IN FIREBASE DATABASE! IT IS NOT SAFE!
                        // STORE OTHER USER INFO IN FIREBASE DATABASE
                        [[[[GeneralService sharedService].realtimeDatabase child:@"users"]
                                                   child:authResult.user.uid] setValue:@{@"deviceToken": [GeneralService sharedService].device_token_number,
                                                                                         @"userId": authResult.user.uid,
                                                                                         @"email": self.enteredEmail,
                                                                                         @"phone": @"",
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
                    
                        [GeneralService sharedService].stored_userEmail = self.enteredEmail;
                        [GeneralService sharedService].stored_userPhone = @"";
                        [GeneralService sharedService].stored_firstName = @"";
                        [GeneralService sharedService].stored_lastName = @"";
                        [GeneralService sharedService].stored_birthday = @"";
                        [GeneralService sharedService].stored_address = @"";
                        [GeneralService sharedService].stored_gender = @"";
                        [GeneralService sharedService].stored_maritalStatus = @"";
                        [GeneralService sharedService].stored_childrenCount = @0;
                        [GeneralService sharedService].stored_clientId = @"";
                        
                        //LOGIN USER IN APP
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_IMMEDIATELY_2_SEC * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [[GeneralService sharedService] enterUserInAppWith:[GeneralService sharedService].device_token_number
                                                                       jwToken:[GeneralService sharedService].jwt_token_number
                                                                  refreshToken:[GeneralService sharedService].refresh_token_number];

                            [self hidePreloader];
                        });
                }];
                
            }
        }];
        
    }
}

- (void)createUserIfFirebaseDatabaseError:(FIRAuthDataResult *)existUser {
    
    //LOGINAUTH FRAMEWORK
    //REGISTRATION - CREATE NEW DEVICETOKEN, JWTOKEN, REFRESHTOKEN FOR USER FOR CALLING INDICATORS SERVICE & OTHER API
    [[LoginAuthCore sharedManager] createDeviceTokenForUserWithInstanceId:[Configurator sharedInstance].instanceId
                                                              instanceKey:[Configurator sharedInstance].instanceKey
                                                                   result:^(NSString *deviceToken, NSString *jwToken, NSString *refreshToken) {

        //STORE IN OUR SHAREDSERVICE MAIN USER TOKENS
        [GeneralService sharedService].device_token_number = deviceToken;
        [GeneralService sharedService].jwt_token_number = jwToken;
        [GeneralService sharedService].refresh_token_number = refreshToken;
        [GeneralService sharedService].firebase_user_id = existUser.user.uid;

        //CHECK ALL AT NIL
        //FIREBASE DATABASE DID'T WORK WITH NIL
        NSString *email = self.enteredEmail ? self.enteredEmail : @"";
        [GeneralService sharedService].stored_userEmail = email;

        NSString *phone = [GeneralService sharedService].stored_userPhone ? [GeneralService sharedService].stored_userPhone : @"";
        NSString *firstName = [GeneralService sharedService].stored_firstName ? [GeneralService sharedService].stored_firstName : @"";
        NSString *lastName = [GeneralService sharedService].stored_lastName ? [GeneralService sharedService].stored_lastName : @"";
        NSString *birthday = [GeneralService sharedService].stored_birthday ? [GeneralService sharedService].stored_birthday : @"";
        NSString *address = [GeneralService sharedService].stored_address ? [GeneralService sharedService].stored_address : @"";
        NSString *gender = [GeneralService sharedService].stored_gender ? [GeneralService sharedService].stored_gender : @"";
        NSString *marital = [GeneralService sharedService].stored_maritalStatus ? [GeneralService sharedService].stored_maritalStatus : @"";
        NSNumber *children = [GeneralService sharedService].stored_childrenCount ? [GeneralService sharedService].stored_childrenCount : @0;
        NSString *clientId = [GeneralService sharedService].stored_clientId ? [GeneralService sharedService].stored_clientId : @"";
        NSString *profileImg = [GeneralService sharedService].stored_profilePictureLink ? [GeneralService sharedService].stored_profilePictureLink : @"";

        //STORE IN FIREBASE DATANASE
        [[[[GeneralService sharedService].realtimeDatabase child:@"users"]
                                   child:existUser.user.uid] setValue:@{@"deviceToken": deviceToken,
                                                                        @"userId": existUser.user.uid,
                                                                        @"email": email,
                                                                        @"phone": phone,
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
    
    //UPDATE ERROR LABEL AFTER 4 SECONDS
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_IMMEDIATELY_4_SEC * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_IMMEDIATELY_04_SEC * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        double coefPhoto = 0.38;
        float coefLbl = 160.0f;
        if (IS_IPHONE_11 || IS_IPHONE_13_PRO) {
            coefPhoto = 0.55;
            coefLbl = 70.0f;
        } else if (IS_IPHONE_11_PROMAX || IS_IPHONE_13_PROMAX) {
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

        [UIView animateWithDuration:DELAY_IMMEDIATELY_04_SEC delay:0 options:UIViewAnimationOptionCurveEaseOut  animations:^{

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
    if (IS_IPHONE_11 || IS_IPHONE_13_PRO) {
        coefLbl = 463.0f;
    } else if (IS_IPHONE_11_PROMAX || IS_IPHONE_13_PROMAX) {
        coefLbl = 483.0f;
    } else if (IS_IPHONE_5 || IS_IPHONE_4)
        coefLbl = 274.0f;
    
    [UIView animateWithDuration:DELAY_IMMEDIATELY_03_SEC delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
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
