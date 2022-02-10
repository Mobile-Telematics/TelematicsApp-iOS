//
//  MainEmailViewCtrl.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 14.06.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "MainEmailViewCtrl.h"
#import "CoreTabBarController.h"
#import "EmailLoginViewCtrl.h"
#import "MainPhoneViewCtrl.h"
#import "UIViewController+Preloader.h"
#import "CheckUserRequestData.h"
#import "CheckResponse.h"
#import "RegResponse.h"
#import "UIAlertView+Blocks.h"
#import "TelematicsAppRegPopup.h"
#import "NSDate+UI.h"
#import "NSDate+ISO8601.h"

@interface MainEmailViewCtrl () <UITextFieldDelegate, SFSafariViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView        *mainLogoImg;
@property (weak, nonatomic) IBOutlet UILabel            *welcomeLbl;

@property (weak, nonatomic) IBOutlet UITextField        *emailField;
@property (weak, nonatomic) IBOutlet UITextField        *passwordField;

@property (weak, nonatomic) IBOutlet UIButton           *joinBtn;
@property (weak, nonatomic) IBOutlet UIButton           *signInBtn;

@property (weak, nonatomic) IBOutlet UIButton           *justUsingBtn;
@property (weak, nonatomic) IBOutlet UILabel            *justUsingLbl;
@property (weak, nonatomic) IBOutlet UIButton           *privacyBtn;
@property (weak, nonatomic) IBOutlet UIImageView        *backgroundMask;

@property (nonatomic, strong) CheckResponse             *checkData;
@property (nonatomic, strong) RegResponse               *userData;

@end

@implementation MainEmailViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [GeneralService sharedService].realtimeDatabase = [[FIRDatabase database] reference]; //GET FIREBASE DATABASE IN CACHE
    
    self.mainLogoImg.image = [UIImage imageNamed:[Configurator sharedInstance].mainLogoColor];
    
    self.welcomeLbl.text = localizeString(@"Sign In\n");
    self.welcomeLbl.textColor = [Color officialGreenColor];
    self.welcomeLbl.font = [Font semibold22];
    
    [self.emailField makeFormFieldZero];
    [self.emailField setBackgroundColor:[Color lightSeparatorColor]];
    [self.emailField.layer setMasksToBounds:YES];
    [self.emailField.layer setCornerRadius:20.0f];
    [self.emailField.layer setBorderColor:[[Color officialMainAppColor] CGColor]];
    [self.emailField.layer setBorderWidth:0.5];
    
    [self.passwordField makeFormFieldZero];
    [self.passwordField setBackgroundColor:[Color lightSeparatorColor]];
    [self.passwordField.layer setMasksToBounds:YES];
    [self.passwordField.layer setCornerRadius:20.0f];
    [self.passwordField.layer setBorderColor:[[Color officialMainAppColor] CGColor]];
    [self.passwordField.layer setBorderWidth:0.5];
    
#if TARGET_IPHONE_SIMULATOR
    //
#else
    self.passwordField.secureTextEntry = YES;
#endif
    
    self.isSignUpButtonPressed = NO;
    
    [self.joinBtn setTintColor:[Color officialWhiteColor]];
    [self.joinBtn setTitleColor:[Color officialWhiteColor] forState:UIControlStateNormal];
    [self.joinBtn setBackgroundColor:[Color officialGreenColor]];
    [self.joinBtn.layer setMasksToBounds:YES];
    [self.joinBtn.layer setCornerRadius:20.0f];
    NSMutableAttributedString *loginText = [[NSMutableAttributedString alloc] initWithString:localizeString(@"SIGN IN")];
    [loginText addAttribute:NSFontAttributeName value:[Font medium13] range:NSMakeRange(0, [loginText length])];
    [loginText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleNone] range:NSMakeRange(0, [loginText length])];
    [loginText addAttribute:NSForegroundColorAttributeName value:[Color officialWhiteColor] range:NSMakeRange(0, [loginText length])];
    [self.joinBtn setAttributedTitle:loginText forState:UIControlStateNormal];

    [self.signInBtn setTintColor:[Color darkGrayColor83]];
    [self.signInBtn setTitleColor:[Color darkGrayColor83] forState:UIControlStateNormal];
    [self.signInBtn setBackgroundColor:[Color officialWhiteColor]];
    [self.signInBtn.layer setMasksToBounds:YES];
    [self.signInBtn.layer setCornerRadius:20.0f];
    [self.signInBtn.layer setBorderColor:[[Color officialWhiteColor] CGColor]];
    [self.signInBtn.layer setBorderWidth:0.4];
    NSMutableAttributedString *signUpText = [[NSMutableAttributedString alloc] initWithString:localizeString(@"Don’t have an account? Sign Up")];
    [signUpText addAttribute:NSFontAttributeName value:[Font medium15] range:NSMakeRange(0, [signUpText length])];
    [signUpText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleNone] range:NSMakeRange(0, [signUpText length])];
    [signUpText addAttribute:NSForegroundColorAttributeName value:[Color darkGrayColor83] range:NSMakeRange(0, [signUpText length])];
    [self.signInBtn setAttributedTitle:signUpText forState:UIControlStateNormal];
    
    self.justUsingLbl.attributedText = [self createJoinLabelImgCentered:localizeString(@"Login via   ") phoneText:localizeString(@"Phone Number")];
    
    [self.privacyBtn setTintColor:[UIColor lightGrayColor]];
    NSMutableAttributedString *privacyText = [[NSMutableAttributedString alloc] initWithString:localizeString(@"menuitem_privacy")];
    [privacyText addAttribute:NSFontAttributeName value:[Font light9] range:NSMakeRange(0, [privacyText length])];
    [privacyText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [privacyText length])];
    [self.privacyBtn setAttributedTitle:privacyText forState:UIControlStateNormal];
    
    self.shiftHeight = -1;
    [self registerForKeyboardNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.emailField.text = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}


#pragma mark Login Actions

- (IBAction)joinBtnClick:(id)sender {
    
    CheckUserRequestData* checkData = [[CheckUserRequestData alloc] init];
    checkData.Email = self.emailField.text;
    checkData.Password = self.passwordField.text;
    
    //CHECK USER EMAIL
    NSArray<NSString *> *errors = [checkData validateCheckEmail];
    if (errors) {
        self.welcomeLbl.text = localizeString(@"validation_invalid_email"); //BAD EMAIL
        self.welcomeLbl.textColor = [Color officialDarkRedColor];
        self.welcomeLbl.font = [Font regular19];
        
        //UPDATE ERROR LABEL AFTER 4 SECONDS
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_IMMEDIATELY_4_SEC * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.welcomeLbl.text = localizeString(@"Sign In\n");
            self.welcomeLbl.textColor = [Color officialGreenColor];
            self.welcomeLbl.font = [Font semibold22];
        });
        return;
    }
    
    //CHECK PASSWORD 6 SYMBOLS
    if (![self isValidPassword:self.passwordField.text]) {
        self.welcomeLbl.text = localizeString(@"validation_enter_symbols_six"); //6 SYMBOLS
        self.welcomeLbl.textColor = [Color officialDarkRedColor];
        self.welcomeLbl.font = [Font regular19];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_IMMEDIATELY_4_SEC * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.welcomeLbl.text = localizeString(@"Sign In\n");
            self.welcomeLbl.textColor = [Color officialGreenColor];
            self.welcomeLbl.font = [Font semibold22];
        });
        return;
    }
    
    [self.view endEditing:YES];
    
    [self showPreloader];
    
    //FIREBASE AUTH
    [[FIRAuth auth] createUserWithEmail:self.emailField.text password:self.passwordField.text completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
        if (error) {
            if (error.code == 17007) { //USER IS EXIST
                
                //LOGIN USER IN APP
                [[FIRAuth auth] signInWithEmail:self.emailField.text
                                       password:self.passwordField.text
                                     completion:^(FIRAuthDataResult *existUser, NSError *error) {
                                        
                                            if (error) {
                                                [GeneralService alert:error.localizedDescription title:@"Message"];
                                                [self hidePreloader];
                                                return;
                                            }
                    
                                            [GeneralService sharedService].user_FIR = existUser.user;
                    
                                            FIRDatabaseQuery *allUserData = [[[GeneralService sharedService].realtimeDatabase child:@"users"] child:existUser.user.uid];
                                            [allUserData observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull userProfileSnapshot) {
                      
                                                if (userProfileSnapshot.value == [NSNull null]) {
                                                    NSLog(@"No user data!");
                                                    [self createEmailUserIfFirebaseDatabaseError:existUser];
                                                    [self hidePreloader];
                                                } else {
                                                    
                                                    //GET SNAPSHOT USER DATA FROM FIREBASE DATABASE
                                                    NSDictionary *allUsersData = (NSDictionary*)userProfileSnapshot.value;
                                                    NSLog(@"Success Fetch Users Data From Firebase Database %@", allUsersData);
                                                    
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
                                                    [GeneralService sharedService].stored_address = allUsersData [@"address"];
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
                                                        [self createEmailUserIfFirebaseDatabaseError:existUser];
                                                            
                                                    } else {
                                                        
                                                        //LOGINAUTH FRAMEWORK
                                                        //ELSE GET JWTOKEN & REFRESHTOKEN FOR EXIST USER BY DEVICETOKEN SAVED FROM FIREBASE DATABASE
                                                        //LOGIN EXIST USER IN YOUR APP
                                                        
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
            
        } else {

            //LOGINAUTH FRAMEWORK
            //REGISTRATION - CREATE NEW DEVICETOKEN, JWTOKEN, REFRESHTOKEN FOR USER IN OUR USER SERVICE
            //CALL INDICATORS SERVICE, DRIVECOINS SERVICE & OTHER API WITH THIS TOKENS FROM RESPONSE
            
            [[LoginAuthCore sharedManager] createDeviceTokenForUserWithParametersAndInstanceId:[Configurator sharedInstance].instanceId
                                                            instanceKey:[Configurator sharedInstance].instanceKey
                                                                  email:self.emailField.text
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
            
                
            //YOU CAN USE THE SIMPLIFIED VERSION OF REGISTRATION WITHOUT PARAMETERS.
            //BUT WE RECOMMEND FOR EASY TO USE IN DATAHUB TO INDICATE FULL INFORMATION ABOUT USERS IMMEDIATELY.
            //USER PARAMETERS CAN BE UPDATED IN THE APP PROFILE SECTION
            
            //[[LoginAuthCore sharedManager] createDeviceTokenForUserWithInstanceId:[Configurator sharedInstance].instanceId
            //                                                          instanceKey:[Configurator sharedInstance].instanceKey
            //                                                               result:^(NSString *deviceToken, NSString *jwToken, NSString *refreshToken) {
                
                //STORE IN SHAREDSERVICE
                [GeneralService sharedService].device_token_number = deviceToken;
                [GeneralService sharedService].jwt_token_number = jwToken;
                [GeneralService sharedService].refresh_token_number = refreshToken;
                
                if (deviceToken == nil || jwToken == nil || refreshToken == nil) {
                    NSLog(@"BACKEND ERROR NO TOKENS NEED UPDATE COMPANY ID CONTACT WITH US %@", deviceToken);
                    [self hidePreloader];
                    return;
                }
                
                FIRUserProfileChangeRequest *changeRequest = [[FIRAuth auth].currentUser profileChangeRequest];
                changeRequest.displayName = self.emailField.text;
                [changeRequest commitChangesWithCompletion:^(NSError *_Nullable error) {

                    if (error) {
                        [self hidePreloader];
                        return;
                    }
                    
                    // DO NOT STORE JWTOKEN & REFRESHTOKEN IN FIREBASE DATABASE! IT IS NOT SAFE!
                    // STORE OTHER USER INFO IN DATABASE
                    [[[[GeneralService sharedService].realtimeDatabase child:@"users"]
                                               child:authResult.user.uid] setValue:@{@"deviceToken": [GeneralService sharedService].device_token_number,
                                                                                     @"userId": authResult.user.uid,
                                                                                     @"email": self.emailField.text,
                                                                                     @"phone": @"",
                                                                                     @"firstName": @"",
                                                                                     @"lastName": @"",
                                                                                     @"birthday": @"",
                                                                                     @"address": @"",
                                                                                     @"clientId": @"",
                                                                                     @"profilePictureLink": @""
                                               }];
                    }];
                    
                    [GeneralService sharedService].user_FIR = authResult.user;
                    [GeneralService sharedService].firebase_user_id = authResult.user.uid;
                
                    [GeneralService sharedService].stored_userEmail = self.emailField.text;
                    [GeneralService sharedService].stored_userPhone = @"";
                    [GeneralService sharedService].stored_firstName = @"";
                    [GeneralService sharedService].stored_lastName = @"";
                    [GeneralService sharedService].stored_birthday = @"";
                    [GeneralService sharedService].stored_address = @"";
                    [GeneralService sharedService].stored_clientId = @"";
                
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

- (void)createEmailUserIfFirebaseDatabaseError:(FIRAuthDataResult *)existUser {
    
    //LOGINAUTH FRAMEWORK
    //CREATING DEVICETOKEN, JWTOKEN, REFRESHTOKEN FOR CALLING INDICATORS SERVICE & OTHER API
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
        NSString *email = self.emailField.text ? self.emailField.text : @"";
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

        //STORE USER PROFILE IN UR APP
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
                                                                        @"profilePictureLink": profileImg}
         ];

        //LOGIN USER IN APP WITH NEW DEVICETOKEN IF IT'S LOST AFTER STORE SNAPSHOT IN FIREBASE
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_IMMEDIATELY_2_SEC * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[GeneralService sharedService] enterUserInAppWith:[GeneralService sharedService].device_token_number
                                                       jwToken:[GeneralService sharedService].jwt_token_number
                                                  refreshToken:[GeneralService sharedService].refresh_token_number];

            [self hidePreloader];
        });
    }];
}

- (void)showAlertForNewUser {
    [[TelematicsAppRegPopup showMessage:localizeString(@"This Email is not registered.\nDo you want to proceed registration\nwith this Email?") withTitle:localizeString(@"Welcome!")]
     withConfirm:localizeString(@"CONFIRM") onConfirm:^{
        
        EmailLoginViewCtrl* signIn = [self.storyboard instantiateViewControllerWithIdentifier:@"EmailLoginViewCtrl"];
        signIn.enteredEmail = self.emailField.text;
        signIn.userName = self.checkData.Result.FirstName ? self.checkData.Result.FirstName : @"";
        signIn.userPhotoUrl = self.checkData.Result.ImageUrl;
        signIn.welcomeText = [NSString stringWithFormat:@"Create your password for %@", self.emailField.text];
        signIn.signInBtnText = @"SIGN IN";
        signIn.isUserExist = NO;
        [self.navigationController pushViewController:signIn animated:YES];
        
    } withCancel:localizeString(@"CANCEL") onCancel:^{
        //DO NOTHING
    }];
}

- (IBAction)signInBtnAction:(id)sender {
    
    if (!self.isSignUpButtonPressed) {
        
        [self.joinBtn setTintColor:[Color officialWhiteColor]];
        [self.joinBtn setTitleColor:[Color officialWhiteColor] forState:UIControlStateNormal];
        [self.joinBtn setBackgroundColor:[Color officialOrangeColor]];
        [self.joinBtn.layer setMasksToBounds:YES];
        [self.joinBtn.layer setCornerRadius:20.0f];
        [self.joinBtn.layer setBorderColor:[[Color officialOrangeColor] CGColor]];
        [self.joinBtn.layer setBorderWidth:0.4];
        NSMutableAttributedString *loginText = [[NSMutableAttributedString alloc] initWithString:localizeString(@"JOIN")];
        [loginText addAttribute:NSFontAttributeName value:[Font medium13] range:NSMakeRange(0, [loginText length])];
        [loginText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleNone] range:NSMakeRange(0, [loginText length])];
        [loginText addAttribute:NSForegroundColorAttributeName value:[Color officialWhiteColor] range:NSMakeRange(0, [loginText length])];
        [self.joinBtn setAttributedTitle:loginText forState:UIControlStateNormal];
        
        [self.signInBtn setTintColor:[Color darkGrayColor83]];
        [self.signInBtn setTitleColor:[Color darkGrayColor83] forState:UIControlStateNormal];
        [self.signInBtn setBackgroundColor:[Color officialWhiteColor]];
        [self.signInBtn.layer setMasksToBounds:YES];
        [self.signInBtn.layer setCornerRadius:20.0f];
        [self.signInBtn.layer setBorderColor:[[Color officialWhiteColor] CGColor]];
        [self.signInBtn.layer setBorderWidth:0.4];
        NSMutableAttributedString *signInText = [[NSMutableAttributedString alloc] initWithString:localizeString(@"Already have an account? Sign In")];
        [signInText addAttribute:NSFontAttributeName value:[Font medium15] range:NSMakeRange(0, [signInText length])];
        [signInText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleNone] range:NSMakeRange(0, [signInText length])];
        [signInText addAttribute:NSForegroundColorAttributeName value:[Color darkGrayColor83] range:NSMakeRange(0, [signInText length])];
        [self.signInBtn setAttributedTitle:signInText forState:UIControlStateNormal];
        
        self.welcomeLbl.text = localizeString(@"Sign Up\n");
        self.welcomeLbl.textColor = [Color officialGreenColor];
        self.welcomeLbl.font = [Font semibold22];
        
        self.passwordField.placeholder = localizeString(@"create password");
        
        self.justUsingLbl.attributedText = [self createJoinLabelImgCentered:localizeString(@"Sign Up via   ") phoneText:localizeString(@"Phone Number")];
        
        self.isSignUpButtonPressed = YES;
        
    } else {
        
        [self.joinBtn setTintColor:[Color officialWhiteColor]];
        [self.joinBtn setTitleColor:[Color officialWhiteColor] forState:UIControlStateNormal];
        [self.joinBtn setBackgroundColor:[Color officialGreenColor]];
        [self.joinBtn.layer setMasksToBounds:YES];
        [self.joinBtn.layer setCornerRadius:20.0f];
        [self.joinBtn.layer setBorderColor:[[Color officialGreenColor] CGColor]];
        [self.joinBtn.layer setBorderWidth:0.4];
        NSMutableAttributedString *loginText = [[NSMutableAttributedString alloc] initWithString:localizeString(@"SIGN IN")];
        [loginText addAttribute:NSFontAttributeName value:[Font medium13] range:NSMakeRange(0, [loginText length])];
        [loginText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleNone] range:NSMakeRange(0, [loginText length])];
        [loginText addAttribute:NSForegroundColorAttributeName value:[Color officialWhiteColor] range:NSMakeRange(0, [loginText length])];
        [self.joinBtn setAttributedTitle:loginText forState:UIControlStateNormal];
        
        [self.signInBtn setTintColor:[Color darkGrayColor83]];
        [self.signInBtn setTitleColor:[Color darkGrayColor83] forState:UIControlStateNormal];
        [self.signInBtn setBackgroundColor:[Color officialWhiteColor]];
        [self.signInBtn.layer setMasksToBounds:YES];
        [self.signInBtn.layer setCornerRadius:20.0f];
        [self.signInBtn.layer setBorderColor:[[Color officialWhiteColor] CGColor]];
        [self.signInBtn.layer setBorderWidth:0.4];
        NSMutableAttributedString *signInText = [[NSMutableAttributedString alloc] initWithString:localizeString(@"Don’t have an account? Sign Up")];
        [signInText addAttribute:NSFontAttributeName value:[Font medium15] range:NSMakeRange(0, [signInText length])];
        [signInText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleNone] range:NSMakeRange(0, [signInText length])];
        [signInText addAttribute:NSForegroundColorAttributeName value:[Color darkGrayColor83] range:NSMakeRange(0, [signInText length])];
        [self.signInBtn setAttributedTitle:signInText forState:UIControlStateNormal];
        
        self.welcomeLbl.text = localizeString(@"Sign In\n");
        self.welcomeLbl.textColor = [Color officialGreenColor];
        self.welcomeLbl.font = [Font semibold22];
        
        self.passwordField.placeholder = localizeString(@"enter password");
        
        self.justUsingLbl.attributedText = [self createJoinLabelImgCentered:localizeString(@"Login via   ") phoneText:localizeString(@"Phone Number")];
        
        self.isSignUpButtonPressed = NO;
        
    }
}

- (IBAction)loginWithPhone:(id)sender {
    MainPhoneViewCtrl *enterPhone = [self.storyboard instantiateViewControllerWithIdentifier:@"MainPhoneViewCtrl"];
    [self.navigationController pushViewController:enterPhone animated:YES];
}

- (IBAction)privacyClick:(id)sender {
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [Configurator sharedInstance].linkPrivacyPolicy]];
    SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:URL];
    svc.delegate = self;
    svc.preferredControlTintColor = [Color officialMainAppColor];
    [self presentViewController:svc animated:YES completion:nil];
}

- (IBAction)termsClick:(id)sender {
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [Configurator sharedInstance].linkTermsOfUse]];
    SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:URL];
    svc.delegate = self;
    svc.preferredControlTintColor = [Color officialMainAppColor];
    [self presentViewController:svc animated:YES completion:nil];
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [self dismissViewControllerAnimated:true completion:nil];
}


#pragma mark Password Validation Helper

- (BOOL)isValidPassword:(NSString *)passwordString {
    NSString *stricterFilterString = @"^(?=.{6,})([@#$%^&=a-zA-Z0-9_-]+)$";
    NSPredicate *passwordTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stricterFilterString];
    return [passwordTest evaluateWithObject:passwordString];
}


#pragma mark JustLabel View

- (NSMutableAttributedString*)createJoinLabelImgCentered:(NSString*)joinText phoneText:(NSString*)phoneText {
    NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
    imageAttachment.image = [UIImage imageNamed:@"smartphone"];
    imageAttachment.bounds = CGRectMake(0, -3, imageAttachment.image.size.width, imageAttachment.image.size.height);
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
    NSMutableAttributedString *completeText = [[NSMutableAttributedString alloc] initWithString:joinText];
    [completeText addAttribute:NSFontAttributeName value:[Font light12] range:NSMakeRange(0, [completeText length])];
    [completeText appendAttributedString:attachmentString];
    NSString *phoneUsageText = [NSString stringWithFormat:@" %@", phoneText];
    NSMutableAttributedString *textAfterIcon = [[NSMutableAttributedString alloc] initWithString:phoneUsageText];
    [textAfterIcon addAttribute:NSFontAttributeName value:[Font medium13] range:NSMakeRange(0, [phoneUsageText length])];
    [textAfterIcon addAttribute:NSForegroundColorAttributeName value:[Color officialGreenColor] range:NSMakeRange(0, [phoneUsageText length])];
    [completeText appendAttributedString:textAfterIcon];
    return completeText;
}


#pragma mark UITextFieldDelegate

- (void)dismissKeyboard {
    [self.emailField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    //ANIMATION VALUE
    double deltaCoef = 0.12;
    if (IS_IPHONE_11 || IS_IPHONE_13_PRO)
        deltaCoef = 0.30;
    else if (IS_IPHONE_11_PROMAX || IS_IPHONE_13_PROMAX)
        deltaCoef = 0.25;
    else if (IS_IPHONE_5 || IS_IPHONE_4)
        deltaCoef = 0.30;
    
    CGAffineTransform translate = CGAffineTransformMakeTranslation(0, self.mainLogoImg.frame.origin.y + self.view.bounds.size.height * deltaCoef);
    CGAffineTransform scale = CGAffineTransformMakeScale(0.5, 0.5);
    if (IS_IPHONE_11 || IS_IPHONE_13_PRO)
        scale = CGAffineTransformMakeScale(0.45, 0.45);
    else if (IS_IPHONE_11_PROMAX || IS_IPHONE_13_PROMAX)
        scale = CGAffineTransformMakeScale(0.7, 0.7);
    else if (IS_IPHONE_5 || IS_IPHONE_4)
        scale = CGAffineTransformMakeScale(0.3, 0.3);
    CGAffineTransform transform =  CGAffineTransformConcat(translate, scale);
    
    [UIView beginAnimations:@"LogoMoveAnimation" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    
    [UIView animateWithDuration:DELAY_IMMEDIATELY_05_SEC delay:0 options:UIViewAnimationOptionCurveEaseOut  animations:^{
        
        [self.view setFrame:CGRectMake(0.f, -170.0f, self.view.bounds.size.width, self.view.bounds.size.height)];
        self.mainLogoImg.transform = transform;
        [UIView commitAnimations];
        
    } completion:^(BOOL finished) {
        if (finished) {
            //TO DO
        }
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)codeField {
    [UIView animateWithDuration:DELAY_IMMEDIATELY_03_SEC delay:0 options:UIViewAnimationOptionCurveEaseOut  animations:^{
        [self.view setFrame:CGRectMake(0.f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height)];
        self.mainLogoImg.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        //[self dismissKeyboard];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailField) {
        [self.passwordField becomeFirstResponder];
        return YES;
    } else if (textField == self.passwordField) {
        [self joinBtnClick:self.joinBtn];
        return YES;
    }
    return YES;
}

@end
