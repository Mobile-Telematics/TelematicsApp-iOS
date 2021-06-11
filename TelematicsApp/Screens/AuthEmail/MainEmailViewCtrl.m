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
@property (weak, nonatomic) IBOutlet UIButton           *facebookBtn;
@property (weak, nonatomic) IBOutlet UIButton           *googleBtn;
@property (weak, nonatomic) IBOutlet UIButton           *loginBtn;
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
    
    self.mainLogoImg.image = [UIImage imageNamed:[Configurator sharedInstance].mainLogoColor];
    self.useEmailLbl.text = localizeString(@"Use your email address\n\n");
    
    [self.emailField makeFormFieldZero];
    [self.emailField setBackgroundColor:[Color lightSeparatorColor]];
    [self.emailField.layer setMasksToBounds:YES];
    [self.emailField.layer setCornerRadius:15.0f];
    [self.emailField.layer setBorderColor:[[Color officialMainAppColor] CGColor]];
    [self.emailField.layer setBorderWidth:0.5];
    
    [self.loginBtn setTintColor:[Color officialWhiteColor]];
    [self.loginBtn setTitleColor:[Color officialWhiteColor] forState:UIControlStateNormal];
    [self.loginBtn setBackgroundColor:[Color officialMainAppColor]];
    [self.loginBtn.layer setMasksToBounds:YES];
    [self.loginBtn.layer setCornerRadius:16.0f];
    NSMutableAttributedString *loginText = [[NSMutableAttributedString alloc] initWithString:localizeString(@"JOIN")];
    [loginText addAttribute:NSFontAttributeName value:[Font medium13] range:NSMakeRange(0, [loginText length])];
    [loginText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleNone] range:NSMakeRange(0, [loginText length])];
    [loginText addAttribute:NSForegroundColorAttributeName value:[Color officialWhiteColor] range:NSMakeRange(0, [loginText length])];
    [self.loginBtn setAttributedTitle:loginText forState:UIControlStateNormal];
    
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

- (IBAction)logBtnClick:(id)sender {
    
    CheckUserRequestData* checkData = [[CheckUserRequestData alloc] init];
    checkData.Email = self.emailField.text;
    
    NSArray<NSString *> *errors = [checkData validateCheckEmail];
    if (errors) {
        self.useEmailLbl.text = localizeString(@"validation_invalid_email");
        self.useEmailLbl.textColor = [Color officialRedColor];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.useEmailLbl.text = localizeString(@"Use your email address\n\n");
            self.useEmailLbl.textColor = [Color darkGrayColor];
        });
        return;
    }
    
    [self.view endEditing:YES];
    
    //GENERATE SAMPLE PASSWORD
    NSString *checkUserExistSamplePassword = [self randomPasswordWithLength:6];
    
    //CHECK IF USER EXIST IN DATABASE FOR USER-FRIENDLY INTERFACE
    [[FIRAuth auth] signInWithEmail:self.emailField.text password:checkUserExistSamplePassword completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
        if (error.code == 17009) {
            
            //17009 USER EXIST LOGIN IN APP WELCOME TEXT
            EmailLoginViewCtrl* logIn = [self.storyboard instantiateViewControllerWithIdentifier:@"EmailLoginViewCtrl"];
            logIn.enteredEmail = self.emailField.text;
            logIn.userName = self.checkData.Result.FirstName ? self.checkData.Result.FirstName : @"";
            logIn.userPhotoUrl = self.checkData.Result.ImageUrl;
            logIn.welcomeText = [NSString stringWithFormat:@"Enter your password for %@", self.emailField.text];
            logIn.signInBtnText = @"LOG IN";
            logIn.isUserExist = YES;
            [self.navigationController pushViewController:logIn animated:YES];
            
        } else {
            [self showAlertForNewUser];
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
    double coef = 0.18;
    if (IS_IPHONE_11 || IS_IPHONE_12_PRO)
        coef = 0.35;
    else if (IS_IPHONE_11_PROMAX || IS_IPHONE_12_PROMAX)
        coef = 0.35;
    else if (IS_IPHONE_5 || IS_IPHONE_4)
        coef = 0.30;
    
    CGAffineTransform translate = CGAffineTransformMakeTranslation(0, self.mainLogoImg.frame.origin.y + self.view.bounds.size.height * coef);
    CGAffineTransform scale = CGAffineTransformMakeScale(0.5, 0.5);
    if (IS_IPHONE_11 || IS_IPHONE_12_PRO)
        scale = CGAffineTransformMakeScale(0.65, 0.65);
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
        [self dismissKeyboard];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailField) {
        [self logBtnClick:self.loginBtn];
        return YES;
    }
    return YES;
}


#pragma mark Helpers

- (NSString*)randomPasswordWithLength:(NSUInteger)length {
    NSMutableString* random = [NSMutableString stringWithCapacity:length];

    for (NSUInteger i=0; i<length; i++) {
        char c = '0' + (unichar)arc4random()%36;
        if(c > '9') c += ('a'-'9'-1);
        [random appendFormat:@"%c", c];
    }
    return random;
}

@end
