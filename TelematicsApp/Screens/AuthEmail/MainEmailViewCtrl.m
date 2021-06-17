//
//  MainEmailViewCtrl.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 14.06.18.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "MainEmailViewCtrl.h"
#import "CoreTabBarController.h"
#import "EmailLoginViewCtrl.h"
#import "MainPhoneViewCtrl.h"
#import "UIViewController+Preloader.h"
#import "UITextField+Form.h"
#import "CheckUserRequestData.h"
#import "CheckResponse.h"
#import "RegResponse.h"
#import "UIAlertView+Blocks.h"
#import "TelematicsAppRegPopup.h"
#import "NSDate+UI.h"
#import "NSDate+ISO8601.h"
#import "LogSetup.h"

@interface MainEmailViewCtrl () <UITextFieldDelegate, SFSafariViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView        *mainLogoImg;

@property (weak, nonatomic) IBOutlet UITextField        *emailField;
@property (weak, nonatomic) IBOutlet UITextField        *passwordField;

@property (weak, nonatomic) IBOutlet UIButton           *joinBtn;
@property (weak, nonatomic) IBOutlet UIButton           *signInBtn;

@property (weak, nonatomic) IBOutlet UIButton           *justUsingBtn;
@property (weak, nonatomic) IBOutlet UILabel            *justUsingLbl;
@property (weak, nonatomic) IBOutlet UIButton           *privacyBtn;
@property (weak, nonatomic) IBOutlet UILabel            *useEmailLbl;
@property (weak, nonatomic) IBOutlet UIImageView        *backgroundMask;

@property (nonatomic, strong) CheckResponse             *checkData;
@property (nonatomic, strong) RegResponse               *userData;

@end

@implementation MainEmailViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _realtimeDatabase = [[FIRDatabase database] reference];
    
    self.mainLogoImg.image = [UIImage imageNamed:[Configurator sharedInstance].mainLogoColor];
    self.useEmailLbl.text = localizeString(@"Sign Up\n");
    
    [self.emailField makeFormFieldZero];
    [self.emailField setBackgroundColor:[Color lightSeparatorColor]];
    [self.emailField.layer setMasksToBounds:YES];
    [self.emailField.layer setCornerRadius:15.0f];
    [self.emailField.layer setBorderColor:[[Color officialMainAppColor] CGColor]];
    [self.emailField.layer setBorderWidth:0.5];
    
    [self.passwordField makeFormFieldZero];
    [self.passwordField setBackgroundColor:[Color lightSeparatorColor]];
    [self.passwordField.layer setMasksToBounds:YES];
    [self.passwordField.layer setCornerRadius:15.0f];
    [self.passwordField.layer setBorderColor:[[Color officialMainAppColor] CGColor]];
    [self.passwordField.layer setBorderWidth:0.5];
    self.passwordField.secureTextEntry = YES;
    
    self.isSignUpPressed = NO;
    
    [self.joinBtn setTintColor:[Color officialWhiteColor]];
    [self.joinBtn setTitleColor:[Color officialWhiteColor] forState:UIControlStateNormal];
    [self.joinBtn setBackgroundColor:[Color officialMainAppColor]];
    [self.joinBtn.layer setMasksToBounds:YES];
    [self.joinBtn.layer setCornerRadius:16.0f];
    NSMutableAttributedString *loginText = [[NSMutableAttributedString alloc] initWithString:localizeString(@"JOIN")];
    [loginText addAttribute:NSFontAttributeName value:[Font medium13] range:NSMakeRange(0, [loginText length])];
    [loginText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleNone] range:NSMakeRange(0, [loginText length])];
    [loginText addAttribute:NSForegroundColorAttributeName value:[Color officialWhiteColor] range:NSMakeRange(0, [loginText length])];
    [self.joinBtn setAttributedTitle:loginText forState:UIControlStateNormal];

    [self.signInBtn setTintColor:[Color officialWhiteColor]];
    [self.signInBtn setTitleColor:[Color officialMainAppColor] forState:UIControlStateNormal];
    [self.signInBtn setBackgroundColor:[Color officialWhiteColor]];
    [self.signInBtn.layer setMasksToBounds:YES];
    [self.signInBtn.layer setCornerRadius:16.0f];
    [self.signInBtn.layer setBorderColor:[[Color officialMainAppColor] CGColor]];
    [self.signInBtn.layer setBorderWidth:0.4];
    NSMutableAttributedString *signInText = [[NSMutableAttributedString alloc] initWithString:localizeString(@"SIGN IN")];
    [signInText addAttribute:NSFontAttributeName value:[Font medium13] range:NSMakeRange(0, [signInText length])];
    [signInText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleNone] range:NSMakeRange(0, [signInText length])];
    [signInText addAttribute:NSForegroundColorAttributeName value:[Color officialMainAppColor] range:NSMakeRange(0, [signInText length])];
    [self.signInBtn setAttributedTitle:signInText forState:UIControlStateNormal];
    
    self.justUsingLbl.attributedText = [self createJoinLabelImgCentered:localizeString(@"Join via   ") phoneText:localizeString(@"Phone Number")];
    
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
    
    NSArray<NSString *> *errors = [checkData validateCheckEmail];
    if (errors) {
        self.useEmailLbl.text = localizeString(@"validation_invalid_email");
        self.useEmailLbl.textColor = [Color officialRedColor];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.useEmailLbl.text = localizeString(@"Sign Up\n");
            self.useEmailLbl.textColor = [Color darkGrayColor];
        });
        return;
    }
    
    if(![self isValidPassword:self.passwordField.text]) {
        self.useEmailLbl.text = localizeString(@"validation_enter_symbols_six");
        self.useEmailLbl.textColor = [Color officialRedColor];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.useEmailLbl.text = localizeString(@"Sign Up\n");
            self.useEmailLbl.textColor = [Color darkGrayColor];
        });
        return;
    }
    
    [self.view endEditing:YES];
    
    [[FIRAuth auth] createUserWithEmail:self.emailField.text password:self.passwordField.text completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
        if (error) {
            if (error.code == 17007) {
                
                //LOGIN USER IN APP
                [[FIRAuth auth] signInWithEmail:self.emailField.text
                                       password:self.passwordField.text
                                     completion:^(FIRAuthDataResult *existUser, NSError *error) {
                                        
                                            if (error) {
                                                [GeneralService alert:error.localizedDescription title:@"Message"];
                                                [self hidePreloader];
                                                return;
                                            }
                    
                                            [GeneralService sharedInstance].user_FIR = existUser.user;
                    
                                            FIRDatabaseQuery *allUserData = [[self.realtimeDatabase child:@"users"] child:existUser.user.uid];
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
                                                            NSString *email = self.emailField.text ? self.emailField.text : @"";
                                                            [GeneralService sharedInstance].stored_userEmail = email;
                                                            
                                                            NSString *phone = [GeneralService sharedInstance].stored_userPhone ? [GeneralService sharedInstance].stored_userPhone : @"";
                                                            NSString *firstName = [GeneralService sharedInstance].stored_firstName ? [GeneralService sharedInstance].stored_firstName : @"";
                                                            NSString *lastName = [GeneralService sharedInstance].stored_lastName ? [GeneralService sharedInstance].stored_lastName : @"";
                                                            NSString *birthday = [GeneralService sharedInstance].stored_birthday ? [GeneralService sharedInstance].stored_birthday : @"";
                                                            NSString *address = [GeneralService sharedInstance].stored_address ? [GeneralService sharedInstance].stored_address : @"";
                                                            NSString *clientId = [GeneralService sharedInstance].stored_clientId ? [GeneralService sharedInstance].stored_clientId : @"";
                                                            
                                                            [[[self->_realtimeDatabase child:@"users"]
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

            }
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
                changeRequest.displayName = self.emailField.text;
                [changeRequest commitChangesWithCompletion:^(NSError *_Nullable error) {

                    if (error) {
                        [self hidePreloader];
                        return;
                    }
                    
                    // DO NOT STORE JWTOKEN & REFRESHTOKEN IN FIREBASE DATABASE! IT IS NOT SAFE!
                    // STORE OTHER USER INFO IN DATABASE
                    [[[self->_realtimeDatabase child:@"users"]
                                               child:authResult.user.uid] setValue:@{@"deviceToken": [GeneralService sharedInstance].device_token_number,
                                                                                     @"userId": authResult.user.uid,
                                                                                     @"email": self.emailField.text,
                                                                                     @"phone": @"",
                                                                                     @"firstName": @"",
                                                                                     @"lastName": @"",
                                                                                     @"birthday": @"",
                                                                                     @"address": @"",
                                                                                     @"clientId": @""}];
                    }];
                    
                    [GeneralService sharedInstance].user_FIR = authResult.user;
                    [GeneralService sharedInstance].firebase_user_id = authResult.user.uid;
                
                    [GeneralService sharedInstance].stored_userEmail = self.emailField.text;
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
    
    if (!self.isSignUpPressed) {
        
        [self.joinBtn setTintColor:[Color officialMainAppColor]];
        [self.joinBtn setTitleColor:[Color officialMainAppColor] forState:UIControlStateNormal];
        [self.joinBtn setBackgroundColor:[Color officialWhiteColor]];
        [self.joinBtn.layer setMasksToBounds:YES];
        [self.joinBtn.layer setCornerRadius:16.0f];
        [self.joinBtn.layer setBorderColor:[[Color officialMainAppColor] CGColor]];
        [self.joinBtn.layer setBorderWidth:0.4];
        NSMutableAttributedString *loginText = [[NSMutableAttributedString alloc] initWithString:localizeString(@"SIGN IN")];
        [loginText addAttribute:NSFontAttributeName value:[Font medium13] range:NSMakeRange(0, [loginText length])];
        [loginText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleNone] range:NSMakeRange(0, [loginText length])];
        [loginText addAttribute:NSForegroundColorAttributeName value:[Color officialMainAppColor] range:NSMakeRange(0, [loginText length])];
        [self.joinBtn setAttributedTitle:loginText forState:UIControlStateNormal];
        
        [self.signInBtn setTintColor:[Color officialMainAppColor]];
        [self.signInBtn setTitleColor:[Color curveRedColor] forState:UIControlStateNormal];
        [self.signInBtn setBackgroundColor:[Color officialMainAppColor]];
        [self.signInBtn.layer setMasksToBounds:YES];
        [self.signInBtn.layer setCornerRadius:16.0f];
        [self.signInBtn.layer setBorderColor:[[Color officialMainAppColor] CGColor]];
        [self.signInBtn.layer setBorderWidth:0.4];
        NSMutableAttributedString *signInText = [[NSMutableAttributedString alloc] initWithString:localizeString(@"SIGN UP")];
        [signInText addAttribute:NSFontAttributeName value:[Font medium13] range:NSMakeRange(0, [signInText length])];
        [signInText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleNone] range:NSMakeRange(0, [signInText length])];
        [signInText addAttribute:NSForegroundColorAttributeName value:[Color officialWhiteColor] range:NSMakeRange(0, [signInText length])];
        [self.signInBtn setAttributedTitle:signInText forState:UIControlStateNormal];
        
        self.passwordField.placeholder = localizeString(@"enter password");
        
        self.isSignUpPressed = YES;
        
    } else {
        
        [self.joinBtn setTintColor:[Color officialWhiteColor]];
        [self.joinBtn setTitleColor:[Color officialWhiteColor] forState:UIControlStateNormal];
        [self.joinBtn setBackgroundColor:[Color officialMainAppColor]];
        [self.joinBtn.layer setMasksToBounds:YES];
        [self.joinBtn.layer setCornerRadius:16.0f];
        NSMutableAttributedString *loginText = [[NSMutableAttributedString alloc] initWithString:localizeString(@"JOIN")];
        [loginText addAttribute:NSFontAttributeName value:[Font medium13] range:NSMakeRange(0, [loginText length])];
        [loginText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleNone] range:NSMakeRange(0, [loginText length])];
        [loginText addAttribute:NSForegroundColorAttributeName value:[Color officialWhiteColor] range:NSMakeRange(0, [loginText length])];
        [self.joinBtn setAttributedTitle:loginText forState:UIControlStateNormal];
        
        [self.signInBtn setTintColor:[Color officialWhiteColor]];
        [self.signInBtn setTitleColor:[Color officialMainAppColor] forState:UIControlStateNormal];
        [self.signInBtn setBackgroundColor:[Color officialWhiteColor]];
        [self.signInBtn.layer setMasksToBounds:YES];
        [self.signInBtn.layer setCornerRadius:16.0f];
        [self.signInBtn.layer setBorderColor:[[Color officialMainAppColor] CGColor]];
        [self.signInBtn.layer setBorderWidth:0.4];
        NSMutableAttributedString *signInText = [[NSMutableAttributedString alloc] initWithString:localizeString(@"SIGN IN")];
        [signInText addAttribute:NSFontAttributeName value:[Font medium13] range:NSMakeRange(0, [signInText length])];
        [signInText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleNone] range:NSMakeRange(0, [signInText length])];
        [signInText addAttribute:NSForegroundColorAttributeName value:[Color officialMainAppColor] range:NSMakeRange(0, [signInText length])];
        [self.signInBtn setAttributedTitle:signInText forState:UIControlStateNormal];
        
        self.passwordField.placeholder = localizeString(@"create password");
        
        self.isSignUpPressed = NO;
        
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
    if (IS_IPHONE_11 || IS_IPHONE_12_PRO)
        deltaCoef = 0.30;
    else if (IS_IPHONE_11_PROMAX || IS_IPHONE_12_PROMAX)
        deltaCoef = 0.25;
    else if (IS_IPHONE_5 || IS_IPHONE_4)
        deltaCoef = 0.30;
    
    CGAffineTransform translate = CGAffineTransformMakeTranslation(0, self.mainLogoImg.frame.origin.y + self.view.bounds.size.height * deltaCoef);
    CGAffineTransform scale = CGAffineTransformMakeScale(0.5, 0.5);
    if (IS_IPHONE_11 || IS_IPHONE_12_PRO)
        scale = CGAffineTransformMakeScale(0.45, 0.45);
    else if (IS_IPHONE_11_PROMAX || IS_IPHONE_12_PROMAX)
        scale = CGAffineTransformMakeScale(0.7, 0.7);
    else if (IS_IPHONE_5 || IS_IPHONE_4)
        scale = CGAffineTransformMakeScale(0.3, 0.3);
    CGAffineTransform transform =  CGAffineTransformConcat(translate, scale);
    
    [UIView beginAnimations:@"LogoMoveAnimation" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut  animations:^{
        
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
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut  animations:^{
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
