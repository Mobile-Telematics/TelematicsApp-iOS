//
//  Step2ViewController.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.04.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "Step2ViewController.h"
#import "Step3ViewController.h"
#import "Color.h"
#import "Helpers.h"
#import "UIViewController+Preloader.h"
#import "UITextField+Form.h"


@interface Step2ViewController () <UIScrollViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView       *scrollView;
@property (weak, nonatomic) IBOutlet UILabel            *mainLbl;

@property (nonatomic, assign) UITextField               *activeTextField;
@property (weak, nonatomic) IBOutlet UITextField        *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField        *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField        *driverLicenseField;
@property (weak, nonatomic) IBOutlet UIButton           *photoBtn;
@property (weak, nonatomic) IBOutlet UIButton           *backBtn;
@property (weak, nonatomic) IBOutlet UIButton           *nextBtn;

@property (strong, nonatomic) TelematicsAppModel               *appModel;

@end

@implementation Step2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appModel = [TelematicsAppModel MR_findFirstByAttribute:@"current_user" withValue:@1];
    
    [self setupView];
    [self setupCachedData];
    [self lowFontsForOldDevices];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:true];
}

- (void)setupView {
    self.firstNameField.delegate = self;
    [self.firstNameField makeFormFieldShift20];
    self.firstNameField.textColor = [UIColor darkGrayColor];
    [self.firstNameField setBackgroundColor:[Color lightSeparatorColor]];
    [self.firstNameField.layer setMasksToBounds:YES];
    [self.firstNameField.layer setCornerRadius:15.0f];
    [self.firstNameField.layer setBorderColor:[[Color grayColor] CGColor]];
    [self.firstNameField.layer setBorderWidth:1.5];
    
    self.lastNameField.delegate = self;
    [self.lastNameField makeFormFieldShift20];
    self.lastNameField.textColor = [UIColor darkGrayColor];
    [self.lastNameField setBackgroundColor:[Color lightSeparatorColor]];
    [self.lastNameField.layer setMasksToBounds:YES];
    [self.lastNameField.layer setCornerRadius:15.0f];
    [self.lastNameField.layer setBorderColor:[[Color grayColor] CGColor]];
    [self.lastNameField.layer setBorderWidth:1.5];
    
    self.driverLicenseField.delegate = self;
    [self.driverLicenseField makeFormFieldShift20];
    self.driverLicenseField.textColor = [UIColor darkGrayColor];
    [self.driverLicenseField setBackgroundColor:[Color lightSeparatorColor]];
    [self.driverLicenseField.layer setMasksToBounds:YES];
    [self.driverLicenseField.layer setCornerRadius:15.0f];
    [self.driverLicenseField.layer setBorderColor:[[Color grayColor] CGColor]];
    [self.driverLicenseField.layer setBorderWidth:1.5];
    
    [self.nextBtn addTarget:self action:@selector(nextBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.nextBtn setTintColor:[Color officialWhiteColor]];
    [self.nextBtn setBackgroundColor:[Color officialMainAppColor]];
    [self.nextBtn.layer setMasksToBounds:YES];
    [self.nextBtn.layer setCornerRadius:15.0f];
    
    [self registerForKeyboardNotifications];
    
    UITapGestureRecognizer *scrollEndTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    scrollEndTap.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:scrollEndTap];
}

- (void)setupCachedData {
    if (self.appModel.userFirstName != nil && ![self.appModel.userFirstName isEqual:@""]) {
        _firstNameField.text = self.appModel.userFirstName;
    }
    if (self.appModel.userLastName != nil) {
        _lastNameField.text = self.appModel.userLastName;
    }
    if ([ClaimsService sharedService].CarLicensePlate != nil) {
        _driverLicenseField.text = [ClaimsService sharedService].CarLicensePlate;
    }
}


#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == _firstNameField) {
        [_lastNameField becomeFirstResponder];
    } else if (textField == _lastNameField) {
        [_driverLicenseField becomeFirstResponder];
    } else {
        [self endEditing];
    }
    return YES;
}

- (void)endEditing {
    [self.view endEditing:YES];
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.view.frame.size.height/2, 0.0);
    if (IS_IPHONE_5 || IS_IPHONE_4) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.view.frame.size.height/2.8, 0.0);
    } else if (IS_IPHONE_11_PROMAX || IS_IPHONE_12_PROMAX) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.view.frame.size.height/6, 0.0);
    } else if (IS_IPHONE_11 || IS_IPHONE_12_PRO) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.view.frame.size.height/3.5, 0.0);
    } else if (IS_IPHONE_8P) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.view.frame.size.height/3, 0.0);
    } else if (IS_IPHONE_8P) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.view.frame.size.height/5, 0.0);
    }
    self.scrollView.contentInset = contentInsets;
    [self syncEnteredInfo];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeTextField = nil;
}


#pragma mark - Keyboard Delegate

- (void)keyboardWasShown:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height + 15, 0.0);
    if (IS_IPHONE_11_PROMAX || IS_IPHONE_12_PROMAX) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height - 300, 0.0);
    } else if (IS_IPHONE_11 || IS_IPHONE_12_PRO) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height - 100, 0.0);
    } else if (IS_IPHONE_8P) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height - 100, 0.0);
    } else if (IS_IPHONE_8) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height - 30, 0.0);
    }
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyboardSize.height;
    if (!CGRectContainsPoint(aRect, _activeTextField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, _activeTextField.frame.origin.y - (keyboardSize.height-15));
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.view.frame.size.height/2, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}


#pragma mark - Navigation

- (IBAction)dismissAction:(id)sender {
    [[[[[self presentingViewController] presentingViewController] presentingViewController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)nextBtnAction {
    
    if ([_firstNameField.text isEqualToString:@""]) {
        [_firstNameField setBackgroundColor:[Color curveRedColorAlpha]];
        [_firstNameField.layer setBorderColor:[[Color officialRedColor] CGColor]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self->_firstNameField setBackgroundColor:[Color lightSeparatorColor]];
            [self->_firstNameField.layer setBorderColor:[[Color grayColor] CGColor]];
        });
        return;
        
    } else if ([_lastNameField.text isEqualToString:@""]) {
        [_lastNameField setBackgroundColor:[Color curveRedColorAlpha]];
        [_lastNameField.layer setBorderColor:[[Color officialRedColor] CGColor]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self->_lastNameField setBackgroundColor:[Color lightSeparatorColor]];
            [self->_lastNameField.layer setBorderColor:[[Color grayColor] CGColor]];
        });
        return;
        
    } else if ([_driverLicenseField.text isEqualToString:@""]) {
        [_driverLicenseField setBackgroundColor:[Color curveRedColorAlpha]];
        [_driverLicenseField.layer setBorderColor:[[Color officialRedColor] CGColor]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self->_driverLicenseField setBackgroundColor:[Color lightSeparatorColor]];
            [self->_driverLicenseField.layer setBorderColor:[[Color grayColor] CGColor]];
        });
        return;
    }
    
    [ClaimsService sharedService].DriverFirstName = _firstNameField.text;
    [ClaimsService sharedService].DriverLastName = _lastNameField.text;
    [ClaimsService sharedService].DriverLicenseNo = _driverLicenseField.text;
    
    NSString *userPhone = self.appModel.userPhone ? self.appModel.userPhone : @"";
    NSString *deletedPlusUserPhone = [[userPhone componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    [ClaimsService sharedService].DriverPhone = deletedPlusUserPhone;
    
    Step3ViewController* step3 = [self.storyboard instantiateViewControllerWithIdentifier:@"Step3ViewController"];
    step3.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:step3 animated:NO completion:nil];
}

- (void)syncEnteredInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        [ClaimsService sharedService].DriverFirstName = self->_firstNameField.text;
        [ClaimsService sharedService].DriverLastName = self->_lastNameField.text;
        [ClaimsService sharedService].DriverLicenseNo = self->_driverLicenseField.text;
        
        NSString *userPhone = self.appModel.userPhone ? self.appModel.userPhone : @"";
        NSString *deletedPlusUserPhone = [[userPhone componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
        [ClaimsService sharedService].DriverPhone = deletedPlusUserPhone;
    });
}

- (IBAction)backAction:(id)sender {
    [self syncEnteredInfo];
    
    CATransition *transition = [[CATransition alloc] init];
    transition.duration = 0.3;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [self.view.window.layer addAnimation:transition forKey:kCATransition];
    [self dismissViewControllerAnimated:NO completion:nil];
}

//iPHONE 5S DEPRECATED EXCUSE US, LOW FONTS IF YOU NEEDEED HELPERS FOR SOME ELEMENTS
- (void)lowFontsForOldDevices {
    if (IS_IPHONE_5 || IS_IPHONE_4) {
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.view.frame.size.height/2.2, 0.0);
        self.scrollView.contentInset = contentInsets;
        self.scrollView.scrollIndicatorInsets = contentInsets;
        
        self.mainLbl.font = [Font semibold15];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
