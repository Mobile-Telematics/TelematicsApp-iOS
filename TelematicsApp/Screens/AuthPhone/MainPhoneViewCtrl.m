//
//  MainPhoneViewCtrl.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 14.11.18.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "MainPhoneViewCtrl.h"
#import "CoreTabBarController.h"
#import "PhoneLoginViewCtrl.h"
#import "UIViewController+Preloader.h"
#import "UITextField+Form.h"
#import "CheckResponse.h"
#import "RegResponse.h"
#import "CheckUserRequestData.h"
#import "SHSPhoneLibrary.h"
#import "TelematicsAppRegPopup.h"
#import "NSDate+UI.h"
#import "NSDate+ISO8601.h"
#import "LogSetup.h"
#import <KVNProgress/KVNProgress.h>
#import "libPhoneNumber_iOS/NBPhoneNumberUtil.h"
#import "libPhoneNumber_iOS/NBPhoneNumber.h"
#import "Helpers.h"

@interface MainPhoneViewCtrl () <UITextFieldDelegate, CountriesViewControllerDelegate>

@property (weak, nonatomic) IBOutlet SHSPhoneTextField  *phoneField;
@property (weak, nonatomic) IBOutlet UIImageView        *mainLogoImg;
@property (weak, nonatomic) IBOutlet UIButton           *facebookBtn;
@property (weak, nonatomic) IBOutlet UIButton           *googleBtn;
@property (weak, nonatomic) IBOutlet UIButton           *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton           *justUsingBtn;
@property (weak, nonatomic) IBOutlet UILabel            *justUsingLbl;
@property (weak, nonatomic) IBOutlet UIButton           *privacyBtn;
@property (weak, nonatomic) IBOutlet UIButton           *termsBtn;
@property (weak, nonatomic) IBOutlet UIButton           *countryButton;
@property (weak, nonatomic) IBOutlet UILabel            *usePhoneLbl;
@property (weak, nonatomic) IBOutlet UIImageView        *backgroundMask;

@property (nonatomic, strong) CheckResponse             *checkData;
@property (nonatomic, strong) RegResponse               *userData;
@property (nonatomic, strong) Country                   *country;
@property (nonatomic, strong) NSString                  *selectedCode;

@end

@implementation MainPhoneViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mainLogoImg.image = [UIImage imageNamed:[Configurator sharedInstance].mainLogoColor];
    
    [self.phoneField makeFormFieldShift40];
    [self.phoneField setBackgroundColor:[Color lightSeparatorColor]];
    [self.phoneField.layer setMasksToBounds:YES];
    [self.phoneField.layer setCornerRadius:15.0f];
    [self.phoneField.layer setBorderColor:[[Color officialMainAppColor] CGColor]];
    [self.phoneField.layer setBorderWidth:0.5];
    self.phoneField.placeholder = localizeString(@"enter phone");
    
    self.usePhoneLbl.text = localizeString(@"Use your phone number");
    
    [self.countryButton.layer setMasksToBounds:YES];
    [self.countryButton.layer setBorderColor:[[Color officialMainAppColor] CGColor]];
    [self.countryButton setBackgroundColor:[Color lightSeparatorColor]];
    [self.countryButton.layer setBorderWidth:0.5];
    [self.countryButton.layer setCornerRadius:15.0f];
    
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
    
    self.justUsingLbl.attributedText = [self createJoinLabelImgCentered:localizeString(@"Join via   ") phoneText:localizeString(@"Email Address")];
    
    [self.privacyBtn setTintColor:[UIColor lightGrayColor]];
    NSMutableAttributedString *privacyText = [[NSMutableAttributedString alloc] initWithString:localizeString(@"menuitem_privacy")];
    [privacyText addAttribute:NSFontAttributeName value:[Font light9] range:NSMakeRange(0, [privacyText length])];
    [privacyText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [privacyText length])];
    [self.privacyBtn setAttributedTitle:privacyText forState:UIControlStateNormal];
    
    [self.termsBtn setTintColor:[UIColor lightGrayColor]];
    NSMutableAttributedString *termsText = [[NSMutableAttributedString alloc] initWithString:localizeString(@"menuitem_terms")];
    [termsText addAttribute:NSFontAttributeName value:[Font light9] range:NSMakeRange(0, [termsText length])];
    [termsText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [termsText length])];
    [self.termsBtn setAttributedTitle:termsText forState:UIControlStateNormal];
    
    NSString *defCountry = [NSString stringWithFormat:@"+%@", Country.currentCountry.phoneExtension];
    if ([defCountry isEqualToString:@"+"]) {
        defCountry = @"+1";
    }
    [self.countryButton setTitle:defCountry forState:UIControlStateNormal];
    self.selectedCode = defCountry;
    
    self.shiftHeight = -1;
    [self registerForKeyboardNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.phoneField becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.phoneField.text = nil;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}


#pragma mark Main Actions

- (IBAction)getCountriesList:(id)sender {
    CountriesViewController *countriesViewController = [[CountriesViewController alloc] init];
    countriesViewController.majorCountryLocaleIdentifiers = @[@"US", @"GB", @"IT", @"DE", @"RU", @"SG", @"IN"];
    countriesViewController.allowMultipleSelection = NO;
    countriesViewController.delegate = self;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:countriesViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)logBtnClick:(id)sender {
    
    NSString *phone = [NSString stringWithFormat:@"%@%@", self.selectedCode, self.phoneField.text];
    
    NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
    NSError *anError = nil;
    NSString *detectCountry = [phoneUtil getRegionCodeForCountryCode:@([self.selectedCode intValue])];
                                                          
    NBPhoneNumber *checkNumber = [phoneUtil parse:phone defaultRegion:detectCountry error:&anError];
    if (anError == nil) {
        NSLog(@"isValidPhoneNumber ? [%@]", [phoneUtil isValidNumber:checkNumber] ? @"YES":@"NO");

        // E164          : +436766077303
        NSLog(@"E164          : %@", [phoneUtil format:checkNumber
                                          numberFormat:NBEPhoneNumberFormatE164
                                                 error:&anError]);
        // INTERNATIONAL : +43 676 6077303
        NSLog(@"INTERNATIONAL : %@", [phoneUtil format:checkNumber
                                          numberFormat:NBEPhoneNumberFormatINTERNATIONAL
                                                 error:&anError]);
        // NATIONAL      : 0676 6077303
        NSLog(@"NATIONAL      : %@", [phoneUtil format:checkNumber
                                          numberFormat:NBEPhoneNumberFormatNATIONAL
                                                 error:&anError]);
        // RFC3966       : tel:+43-676-6077303
        NSLog(@"RFC3966       : %@", [phoneUtil format:checkNumber
                                          numberFormat:NBEPhoneNumberFormatRFC3966
                                                 error:&anError]);
    } else {
        NSLog(@"Error : %@", [anError localizedDescription]);
    }

    NSString *nationalNumber = nil;
    NSNumber *countryCode = [phoneUtil extractCountryCode:phone nationalNumber:&nationalNumber];
    NSLog(@"extractCountryCode [%@] [%@]", countryCode, nationalNumber);
    
    if (![phoneUtil isValidNumber:checkNumber]) {
        self.usePhoneLbl.text = localizeString(@"validation_invalid_phone");
        self.usePhoneLbl.textColor = [Color officialRedColor];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.usePhoneLbl.text = localizeString(@"Use your phone number");
            self.usePhoneLbl.textColor = [Color darkGrayColor];
        });
        return;
    }
    
    CheckUserRequestData* checkData = [[CheckUserRequestData alloc] init];
    NSString *delPhoneChar = [[phone componentsSeparatedByCharactersInSet:
                            [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                           componentsJoinedByString:@""];
    checkData.Phone = delPhoneChar;
    
    [self.view endEditing:YES];
    
    NSArray<NSString *> *errors = [checkData validateCheckPhone];
    if (errors) {
        [self.errorHandler showErrorMessages:errors];
        return;
    }
    
    checkData.Phone = [NSString stringWithFormat:@"+%@", delPhoneChar];
    
    [FIRAuth auth].languageCode = @"en";
    [[FIRPhoneAuthProvider provider] verifyPhoneNumber:[NSString stringWithFormat:@"+%@", delPhoneChar]
                                            UIDelegate:nil
                                            completion:^(NSString * _Nullable verificationID, NSError * _Nullable error) {
     
        if (error) {
            [self dismissKeyboard];
            self.usePhoneLbl.text = localizeString(@"Temporarily unavailable. Try again in a few minutes");
            self.usePhoneLbl.textColor = [Color officialRedColor];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.usePhoneLbl.text = localizeString(@"Use your email address");
                self.usePhoneLbl.textColor = [Color darkGrayColor];
            });
            return;
        }
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:verificationID forKey:@"authVerificationID"];
        //'NSString *verificationIDrestore = [defaults stringForKey:@"authVerificationID"]; //IF NEEDED FOR NEXT FIREBASE AUTH ALL AROUND
        
        PhoneLoginViewCtrl* logIn = [self.storyboard instantiateViewControllerWithIdentifier:@"PhoneLoginViewCtrl"];
        logIn.enteredPhone = checkData.Phone;
        logIn.savedVerificationId = verificationID;
        [self.navigationController pushViewController:logIn animated:NO];
    }];
}

- (void)createUserAccount {
    //
}

- (IBAction)loginWithEmail:(id)sender {
    MainEmailViewCtrl *enterEmail = [self.storyboard instantiateViewControllerWithIdentifier:@"MainEmailViewCtrl"];
    [self.navigationController pushViewController:enterEmail animated:YES];
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
    [self dismissViewControllerAnimated:NO completion:nil];
}


#pragma mark JustUsingLabel View

- (NSMutableAttributedString*)createJoinLabelImgCentered:(NSString*)joinText phoneText:(NSString*)phoneText {
    NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
    imageAttachment.image = [UIImage imageNamed:@"mail"];
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
    [self.phoneField resignFirstResponder];
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
    [UIView setAnimationDuration:0.3];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut  animations:^{
        
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
    if (textField == self.phoneField) {
        [self.view endEditing:YES];
        return YES;
    }
    return YES;
}


#pragma mark Countries Delegate

- (void)countriesViewController:(CountriesViewController * _Nonnull)countriesViewController didSelectCountry:(Country * _Nonnull)country {
    self.selectedCode = [NSString stringWithFormat:@"+%@", country.phoneExtension];
    [self.countryButton setTitle:self.selectedCode forState:UIControlStateNormal];
    NSLog(@"didSelectCountry");
}

- (void)countriesViewControllerDidCancel:(CountriesViewController * _Nonnull)countriesViewController {
    NSLog(@"countriesViewControllerDidCancel");
}

- (void)countriesViewController:(CountriesViewController * _Nonnull)countriesViewController didSelectCountries:(NSArray<Country *> * _Nonnull)countries {
    NSLog(@"didSelectCountries");
}

- (void)countriesViewController:(CountriesViewController * _Nonnull)countriesViewController didUnselectCountry:(Country * _Nonnull)country {
    NSLog(@"didUnselectCountry");
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    NSLog(@"encodeWithCoder");
}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
    NSLog(@"traitCollectionDidChange");
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
    NSLog(@"preferredContentSizeDidChangeForChildContentContainer");
}

- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
    NSLog(@"systemLayoutFittingSizeDidChangeForChildContentContainer");
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"viewWillTransitionToSize");
}

- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"willTransitionToTraitCollection");
}

- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
    return CGSizeZero;
}

- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {
    NSLog(@"didUpdateFocusInContext");
}

- (void)setNeedsFocusUpdate {
    NSLog(@"setNeedsFocusUpdate");
}

- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context {
    return YES;
}

- (void)updateFocusIfNeeded {
    NSLog(@"updateFocusIfNeeded");
}

@end
