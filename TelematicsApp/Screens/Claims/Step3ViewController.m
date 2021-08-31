//
//  Step3ViewController.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.04.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "Step3ViewController.h"
#import "StepPhotoViewController.h"
#import "Color.h"
#import "Helpers.h"
#import "UIViewController+Preloader.h"
#import "UITextField+Form.h"


@interface Step3ViewController () <UIScrollViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView       *scrollView;
@property (weak, nonatomic) IBOutlet UILabel            *mainLbl;

@property (nonatomic, assign) UITextField               *activeTextField;
@property (weak, nonatomic) IBOutlet UITextField        *involvedFirstNameField;
@property (weak, nonatomic) IBOutlet UITextField        *involvedLastNameField;
@property (weak, nonatomic) IBOutlet UITextField        *involvedLicenseNumberField;
@property (weak, nonatomic) IBOutlet UITextField        *involvedCarPlateField;
@property (weak, nonatomic) IBOutlet UITextView         *involvedDetailsField;
@property (weak, nonatomic) IBOutlet UIButton           *photoBtn;
@property (weak, nonatomic) IBOutlet UIButton           *backBtn;
@property (weak, nonatomic) IBOutlet UIButton           *nextBtn;
@property (weak, nonatomic) IBOutlet UIButton           *photoLicenseBtn;
@property (weak, nonatomic) IBOutlet UIButton           *photoCarPlateBtn;

@end

@implementation Step3ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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

- (void)setupView
{
    self.involvedFirstNameField.delegate = self;
    [self.involvedFirstNameField makeFormFieldShift20];
    self.involvedFirstNameField.textColor = [UIColor darkGrayColor];
    [self.involvedFirstNameField setBackgroundColor:[Color lightSeparatorColor]];
    [self.involvedFirstNameField.layer setMasksToBounds:YES];
    [self.involvedFirstNameField.layer setCornerRadius:15.0f];
    [self.involvedFirstNameField.layer setBorderColor:[[Color grayColor] CGColor]];
    [self.involvedFirstNameField.layer setBorderWidth:1.5];
    
    self.involvedLastNameField.delegate = self;
    [self.involvedLastNameField makeFormFieldShift20];
    self.involvedLastNameField.textColor = [UIColor darkGrayColor];
    [self.involvedLastNameField setBackgroundColor:[Color lightSeparatorColor]];
    [self.involvedLastNameField.layer setMasksToBounds:YES];
    [self.involvedLastNameField.layer setCornerRadius:15.0f];
    [self.involvedLastNameField.layer setBorderColor:[[Color grayColor] CGColor]];
    [self.involvedLastNameField.layer setBorderWidth:1.5];
    
    self.involvedLicenseNumberField.delegate = self;
    [self.involvedLicenseNumberField makeFormFieldShift20];
    self.involvedLicenseNumberField.textColor = [UIColor darkGrayColor];
    [self.involvedLicenseNumberField setBackgroundColor:[Color lightSeparatorColor]];
    [self.involvedLicenseNumberField.layer setMasksToBounds:YES];
    [self.involvedLicenseNumberField.layer setCornerRadius:15.0f];
    [self.involvedLicenseNumberField.layer setBorderColor:[[Color grayColor] CGColor]];
    [self.involvedLicenseNumberField.layer setBorderWidth:1.5];
    
    self.involvedCarPlateField.delegate = self;
    [self.involvedCarPlateField makeFormFieldShift20];
    self.involvedCarPlateField.textColor = [UIColor darkGrayColor];
    [self.involvedCarPlateField setBackgroundColor:[Color lightSeparatorColor]];
    [self.involvedCarPlateField.layer setMasksToBounds:YES];
    [self.involvedCarPlateField.layer setCornerRadius:15.0f];
    [self.involvedCarPlateField.layer setBorderColor:[[Color grayColor] CGColor]];
    [self.involvedCarPlateField.layer setBorderWidth:1.5];
    
    self.involvedDetailsField.delegate = self;
    self.involvedDetailsField.textContainerInset = UIEdgeInsetsMake(7, 14, 0, 0);
    [self.involvedDetailsField setBackgroundColor:[Color lightSeparatorColor]];
    [self.involvedDetailsField.layer setMasksToBounds:YES];
    [self.involvedDetailsField.layer setCornerRadius:15.0f];
    [self.involvedDetailsField.layer setBorderColor:[[Color grayColor] CGColor]];
    [self.involvedDetailsField.layer setBorderWidth:1.5];
    if ([ClaimsService sharedService].InvolvedComments != nil && ![[ClaimsService sharedService].InvolvedComments isEqualToString:@"(null)"]) {
        self.involvedDetailsField.textColor = [UIColor darkGrayColor];
    } else {
        self.involvedDetailsField.text = localizeString(@"Comments...");
        self.involvedDetailsField.textColor = [Color softGrayColor];
    }
    self.involvedDetailsField.font = [Font regular14];
    
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
    if ([ClaimsService sharedService].InvolvedFirstName != nil && ![[ClaimsService sharedService].InvolvedFirstName isEqualToString:@"(null)"]) {
        _involvedFirstNameField.text = [ClaimsService sharedService].InvolvedFirstName;
    }
    if ([ClaimsService sharedService].InvolvedLastName != nil && ![[ClaimsService sharedService].InvolvedLastName isEqualToString:@"(null)"]) {
        _involvedLastNameField.text = [ClaimsService sharedService].InvolvedLastName;
    }
    if ([ClaimsService sharedService].InvolvedLicenseNo != nil && ![[ClaimsService sharedService].InvolvedLicenseNo isEqualToString:@"(null)"]) {
        _involvedLicenseNumberField.text = [ClaimsService sharedService].InvolvedLicenseNo;
    }
    if ([ClaimsService sharedService].InvolvedVehicleLicenseplateno != nil && ![[ClaimsService sharedService].InvolvedVehicleLicenseplateno isEqualToString:@"(null)"]) {
        _involvedCarPlateField.text = [ClaimsService sharedService].InvolvedVehicleLicenseplateno;
    }
    if ([ClaimsService sharedService].InvolvedComments != nil && ![[ClaimsService sharedService].InvolvedComments isEqualToString:@"(null)"] && ![[ClaimsService sharedService].InvolvedComments isEqualToString:@"Comments..."]) {
        _involvedDetailsField.text = [ClaimsService sharedService].InvolvedComments;
    }
}


#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == _involvedFirstNameField) {
        [_involvedLastNameField becomeFirstResponder];
    } else if (textField == _involvedLastNameField) {
        [_involvedLicenseNumberField becomeFirstResponder];
    } else if (textField == _involvedLicenseNumberField) {
        [_involvedCarPlateField becomeFirstResponder];
    } else if (textField == _involvedCarPlateField) {
        [_involvedDetailsField becomeFirstResponder];
    } else {
        [self endEditing];
    }
    return YES;
}


#pragma mark - UITextView Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([self.involvedDetailsField.text isEqualToString:@"Comments..."] && self.involvedDetailsField.textColor != [UIColor darkGrayColor]) {
        self.involvedDetailsField.text = @"";
        self.involvedDetailsField.textColor = [UIColor darkGrayColor];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView == _involvedDetailsField) {
        if (IS_IPHONE_5 || IS_IPHONE_4) {
            [self.scrollView setContentOffset:CGPointMake(0, (textView.superview.frame.origin.y + (textView.frame.origin.y) - 90)) animated:NO];
        } else if (IS_IPHONE_8) {
            [self.scrollView setContentOffset:CGPointMake(0, (textView.superview.frame.origin.y + (textView.frame.origin.y) - 150)) animated:NO];
        } else if (IS_IPHONE_8P) {
            [self.scrollView setContentOffset:CGPointMake(0, (textView.superview.frame.origin.y + (textView.frame.origin.y) - 150)) animated:NO];
        } else if (IS_IPHONE_11 || IS_IPHONE_12_PRO) {
            [self.scrollView setContentOffset:CGPointMake(0, (textView.superview.frame.origin.y + (textView.frame.origin.y) - 150)) animated:NO];
        } else if (IS_IPHONE_11_PROMAX || IS_IPHONE_12_PROMAX) {
            [self.scrollView setContentOffset:CGPointMake(0, (textView.superview.frame.origin.y + (textView.frame.origin.y) - 250)) animated:NO];
        }
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([self.involvedDetailsField.text isEqualToString:@""]) {
        self.involvedDetailsField.text = @"Comments...";
        self.involvedDetailsField.textColor = [UIColor lightGrayColor];
    } else if (![self.involvedDetailsField.text isEqualToString:@""] || ![self.involvedDetailsField.text isEqualToString:@"Comments..."]) {
        [ClaimsService sharedService].InvolvedComments = self.involvedDetailsField.text;
    } else if ([self.involvedDetailsField.text isEqualToString:@"Comments..."]) {
        self.involvedDetailsField.textColor = [Color softGrayColor];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)endEditing {
    [self.view endEditing:YES];
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.view.frame.size.height/2, 0.0);
    if (IS_IPHONE_5 || IS_IPHONE_4) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.view.frame.size.height/2.6, 0.0);
    } else if (IS_IPHONE_11_PROMAX || IS_IPHONE_12_PROMAX) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.view.frame.size.height/8, 0.0);
    } else if (IS_IPHONE_11 || IS_IPHONE_12_PRO) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.view.frame.size.height/5, 0.0);
    } else if (IS_IPHONE_8P) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.view.frame.size.height/3.2, 0.0);
    }
    self.scrollView.contentInset = contentInsets;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeTextField = nil;
}


#pragma mark - Keyboard Delegate

- (void)keyboardWasShown:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height - 100, 0.0);
    if (IS_IPHONE_5 || IS_IPHONE_4) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height + 170, 0.0);
    } else if (IS_IPHONE_11_PROMAX || IS_IPHONE_12_PROMAX) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    } else if (IS_IPHONE_11 || IS_IPHONE_12_PRO) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height - 50, 0.0);
    } else if (IS_IPHONE_8P) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
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
    [[[[[[self presentingViewController] presentingViewController] presentingViewController] presentingViewController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
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

- (void)nextBtnAction {
    
    [ClaimsService sharedService].InvolvedFirstName = self->_involvedFirstNameField.text;
    [ClaimsService sharedService].InvolvedLastName = self->_involvedLastNameField.text;
    [ClaimsService sharedService].InvolvedLicenseNo = self->_involvedLicenseNumberField.text;
    [ClaimsService sharedService].InvolvedVehicleLicenseplateno = self->_involvedCarPlateField.text;
    
    if ([_involvedDetailsField.text isEqualToString:@"Comments..."])
        [ClaimsService sharedService].InvolvedComments = @"";
    else {
        [ClaimsService sharedService].InvolvedComments = self->_involvedDetailsField.text;
    }
    
    StepPhotoViewController* step4 = [self.storyboard instantiateViewControllerWithIdentifier:@"StepPhotoViewController"];
    step4.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:step4 animated:NO completion:nil];
}

- (void)syncEnteredInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        [ClaimsService sharedService].InvolvedFirstName = self->_involvedFirstNameField.text;
        [ClaimsService sharedService].InvolvedLastName = self->_involvedLastNameField.text;
        [ClaimsService sharedService].InvolvedLicenseNo = self->_involvedLicenseNumberField.text;
        [ClaimsService sharedService].InvolvedVehicleLicenseplateno = self->_involvedCarPlateField.text;
        
        if ([self->_involvedDetailsField.text isEqualToString:@"Comments..."])
            [ClaimsService sharedService].InvolvedComments = @"";
        else {
            [ClaimsService sharedService].InvolvedComments = self->_involvedDetailsField.text;
        }
    });
}

//iPHONE 5S DEPRECATED EXCUSE US, LOW FONTS IF YOU NEEDED HELPERS FOR SOME ELEMENTS
- (void)lowFontsForOldDevices {
    if (IS_IPHONE_5 || IS_IPHONE_4) {
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.view.frame.size.height/2, 0.0);
        self.scrollView.contentInset = contentInsets;
        self.scrollView.scrollIndicatorInsets = contentInsets;
        
        self.mainLbl.font = [Font semibold15];
        
    } else if (IS_IPHONE_8) {
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.view.frame.size.height/2.5, 0.0);
        self.scrollView.contentInset = contentInsets;
        self.scrollView.scrollIndicatorInsets = contentInsets;
        
    } else if (IS_IPHONE_8P) {
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.view.frame.size.height/3.4, 0.0);
        self.scrollView.contentInset = contentInsets;
        self.scrollView.scrollIndicatorInsets = contentInsets;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
