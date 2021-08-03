//
//  EditProfileCtrl.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 07.02.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "EditProfileCtrl.h"
#import "TelematicsAppTextField.h"
#import "UIViewController+Preloader.h"
#import "ProfileResponse.h"
#import "NSDate+UI.h"
#import "NSDate+ISO8601.h"
#import "WiFiGPSChecker.h"
#import "Helpers.h"
#import "TelematicsAppPrivacyRequestManager.h"


@interface EditProfileCtrl () <UIScrollViewDelegate, UITextFieldDelegate, UIPickerViewDelegate>

@property (strong, nonatomic) TelematicsAppModel                                       *appModel;

//@property(strong, nonatomic) FIRDatabaseReference *realtimeDatabase;

@property (weak, nonatomic) IBOutlet UIScrollView                               *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView                                *mainHeaderImg;

@property (weak, nonatomic) IBOutlet UILabel                                    *userNameLbl;
@property (weak, nonatomic) IBOutlet UIImageView                                *avatarImg;
@property (weak, nonatomic) IBOutlet UIView                                     *bottomView;
@property (weak, nonatomic) IBOutlet UIButton                                   *saveBtn;

@property (nonatomic, assign) UITextField                                       *activeTextField;
@property (strong, nonatomic) IBOutlet TelematicsAppTextField                   *firstNameField;
@property (strong, nonatomic) IBOutlet TelematicsAppTextField                   *lastNameField;
@property (strong, nonatomic) IBOutlet TelematicsAppTextField                   *emailField;
@property (strong, nonatomic) IBOutlet TelematicsAppTextField                   *phoneField;
@property (strong, nonatomic) IBOutlet TelematicsAppTextField                   *birthField;
@property (strong, nonatomic) IBOutlet TelematicsAppTextField                   *addressField;
@property (strong, nonatomic) IBOutlet TelematicsAppTextField                   *clientIdField;

@property (nonatomic, strong) NSString                                          *birthdaySelect;
@property (assign, nonatomic) BOOL                                              refreshGeoAddress;

@end

@implementation EditProfileCtrl


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //INITIALIZE USER APP MODEL
    self.appModel = [TelematicsAppModel MR_findFirstByAttribute:@"current_user" withValue:@1];
    
    //INITIALIZE FIREBASE REALTIMEDATABASE FOR WRITING
    [GeneralService sharedService].realtimeDatabase = [[FIRDatabase database] reference];
    
    [self.saveBtn setTitle:localizeString(@"Save") forState:UIControlStateNormal];
    
    [self displayUserInfo];
    
    _firstNameField.delegate = self;
    _lastNameField.delegate = self;
    _emailField.delegate = self;
    _phoneField.delegate = self;
    _birthField.delegate = self;
    _addressField.delegate = self;
    
    _firstNameField.colorNormal = [UIColor groupTableViewBackgroundColor];
    _firstNameField.colorHighlight = [Color lightSeparatorColor];
    _firstNameField.leftIconNormal = [UIImage imageNamed:@"wizard_useravatar"];
    _firstNameField.leftIconHighlight = [UIImage imageNamed:@"wizard_useravatar"];
    _firstNameField.showHighlightedEditing = YES;
    _firstNameField.showBottomLine = YES;
    [_firstNameField setTintColor:[UIColor darkGrayColor]];
    _firstNameField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    [_firstNameField setReturnKeyType:UIReturnKeyNext];
    _firstNameField.placeholder = localizeString(@"FIRST NAME");
    
    _lastNameField.colorNormal = [UIColor groupTableViewBackgroundColor];
    _lastNameField.colorHighlight = [Color lightSeparatorColor];
    _lastNameField.leftIconNormal = [UIImage imageNamed:@"wizard_useravatar"];
    _lastNameField.leftIconHighlight = [UIImage imageNamed:@"wizard_useravatar"];
    _lastNameField.showHighlightedEditing = YES;
    _lastNameField.showBottomLine = YES;
    [_lastNameField setTintColor:[UIColor darkGrayColor]];
    _lastNameField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    [_lastNameField setReturnKeyType:UIReturnKeyNext];
    _lastNameField.placeholder = localizeString(@"LAST NAME");
    
    _emailField.colorNormal = [UIColor groupTableViewBackgroundColor];
    _emailField.colorHighlight = [Color lightSeparatorColor];
    _emailField.leftIconNormal = [UIImage imageNamed:@"wizard_email"];
    _emailField.leftIconHighlight = [UIImage imageNamed:@"wizard_email"];
    _emailField.showHighlightedEditing = YES;
    _emailField.showBottomLine = YES;
    [_emailField setTintColor:[UIColor darkGrayColor]];
    _emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [_emailField setReturnKeyType:UIReturnKeyNext];
    _emailField.placeholder = localizeString(@"EMAIL");
    
    _phoneField.colorNormal = [UIColor groupTableViewBackgroundColor];
    _phoneField.colorHighlight = [Color lightSeparatorColor];
    _phoneField.leftIconNormal = [UIImage imageNamed:@"wizard_phone"];
    _phoneField.leftIconHighlight = [UIImage imageNamed:@"wizard_phone"];
    _phoneField.showHighlightedEditing = YES;
    _phoneField.showBottomLine = YES;
    [_phoneField setTintColor:[UIColor darkGrayColor]];
    [_phoneField setReturnKeyType:UIReturnKeyNext];
    _phoneField.placeholder = localizeString(@"PHONE NUMBER");
    if (self.appModel.userPhone != nil) {
        _phoneField.text = self.appModel.userPhone;
    }
    
    UIToolbar *keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(nextBtnPhoneClicked)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:flexible, doneButton, nil]];
    [keyboardDoneButtonView setTintColor:[Color officialMainAppColor]];
    _phoneField.inputAccessoryView = keyboardDoneButtonView;
    
    _birthField.colorNormal = [UIColor groupTableViewBackgroundColor];
    _birthField.colorHighlight = [Color lightSeparatorColor];
    _birthField.leftIconNormal = [UIImage imageNamed:@"wizard_calendar"];
    _birthField.leftIconHighlight = [UIImage imageNamed:@"wizard_calendar"];
    _birthField.showHighlightedEditing = YES;
    _birthField.showBottomLine = YES;
    [_birthField setReturnKeyType:UIReturnKeyNext];
    _birthField.placeholder = localizeString(@"BIRTH DATE");
    
    _addressField.colorNormal = [UIColor groupTableViewBackgroundColor];
    _addressField.colorHighlight = [Color lightSeparatorColor];
    _addressField.leftIconNormal = [UIImage imageNamed:@"wizard_address"];
    _addressField.leftIconHighlight = [UIImage imageNamed:@"wizard_address"];
    _addressField.showHighlightedEditing = YES;
    _addressField.showBottomLine = YES;
    [_addressField setTintColor:[UIColor darkGrayColor]];
    _addressField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    [_addressField setReturnKeyType:UIReturnKeyNext];
    _addressField.placeholder = localizeString(@" ADDRESS");
    
    _clientIdField.colorNormal = [UIColor groupTableViewBackgroundColor];
    _clientIdField.colorHighlight = [Color lightSeparatorColor];
    _clientIdField.leftIconNormal = [UIImage imageNamed:@"wizard_number"];
    _clientIdField.leftIconHighlight = [UIImage imageNamed:@"wizard_number"];
    _clientIdField.showHighlightedEditing = YES;
    _clientIdField.showBottomLine = YES;
    [_clientIdField setTintColor:[UIColor darkGrayColor]];
    [_clientIdField setReturnKeyType:UIReturnKeyDone];
    _clientIdField.placeholder = localizeString(@"ID (Optional)");
    
    //[self.scrollView setContentSize:(CGSizeMake(self.view.frame.size.width, self.view.frame.size.height))];
    
    [self registerForKeyboardNotifications];
    self.shiftHeight = -1;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self setUserCacheDataEditProfile];
    
    UITapGestureRecognizer *scrollEndTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    scrollEndTap.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:scrollEndTap];
    
    [_firstNameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_lastNameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_emailField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    defaults_set_object(@"updatePopupLayoutForWizard", @(NO));
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUserCacheDataEditProfile) name:@"setUserCacheDataEditProfile" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
    
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)displayUserInfo {
    self.userNameLbl.text = self.appModel.userFullName ? self.appModel.userFullName : @"";
    self.avatarImg.layer.cornerRadius = self.avatarImg.frame.size.width / 2.0;
    self.avatarImg.layer.masksToBounds = YES;
    self.avatarImg.contentMode = UIViewContentModeScaleAspectFill;
    if (self.appModel.userPhotoData != nil) {
        self.avatarImg.image = [UIImage imageWithData:self.appModel.userPhotoData];
    }
}


#pragma mark - Save

- (IBAction)saveBtnClick:(id)sender {
    
    NSString *email = _emailField.text ? _emailField.text : @"";
    NSString *phone = _phoneField.text ? _phoneField.text : @"";
    NSString *firstName = _firstNameField.text ? _firstNameField.text : @"";
    NSString *lastName = _lastNameField.text ? _lastNameField.text : @"";
    NSString *birthday = _birthdaySelect ? _birthdaySelect : @"";
    NSString *address = _addressField.text ? _addressField.text : @"";
    NSString *gender = [GeneralService sharedService].stored_gender ? [GeneralService sharedService].stored_gender : @"";
    NSString *marital = [GeneralService sharedService].stored_maritalStatus ? [GeneralService sharedService].stored_maritalStatus : @"";
    NSString *children = [GeneralService sharedService].stored_childrenCount ? [GeneralService sharedService].stored_childrenCount : @"";
    NSString *clientId = _clientIdField.text ? _clientIdField.text : @"";
    NSString *profilePictureLink = [GeneralService sharedService].stored_profilePictureLink ? [GeneralService sharedService].stored_profilePictureLink : @"";
    
    [[[[GeneralService sharedService].realtimeDatabase child:@"users"]
                               child:[GeneralService sharedService].firebase_user_id] setValue:@{@"deviceToken": [GeneralService sharedService].device_token_number,
                                                                                                  @"userId": [GeneralService sharedService].firebase_user_id,
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
                                                                                                  @"profilePictureLink": profilePictureLink
                               }
     ];
    
    [GeneralService sharedService].stored_userEmail = email;
    [GeneralService sharedService].stored_userPhone = phone;
    [GeneralService sharedService].stored_firstName = firstName;
    [GeneralService sharedService].stored_lastName = lastName;
    [GeneralService sharedService].stored_birthday = birthday;
    [GeneralService sharedService].stored_address = address;
    [GeneralService sharedService].stored_gender = gender;
    [GeneralService sharedService].stored_maritalStatus = marital;
    [GeneralService sharedService].stored_childrenCount = children;
    [GeneralService sharedService].stored_clientId = clientId;
    [GeneralService sharedService].stored_profilePictureLink = profilePictureLink;
    
    NSLog(@"deviceToken %@", [GeneralService sharedService].device_token_number);
    NSLog(@"firebaseUserId %@", [GeneralService sharedService].firebase_user_id);
    NSLog(@"email %@", email);
    NSLog(@"phone %@", phone);
    NSLog(@"firstName %@", firstName);
    NSLog(@"lastName %@", lastName);
    NSLog(@"birthday %@", birthday);
    NSLog(@"address %@", address);
    NSLog(@"gender %@", gender);
    NSLog(@"marital %@", marital);
    NSLog(@"children %@", children);
    NSLog(@"clientId %@", clientId);
    NSLog(@"profilePicture %@", profilePictureLink);
    
    //UPDATE PROFILE
    [[GeneralService sharedService] loadProfile];
    
    [self quitAndUpdate];
    
}


#pragma mark - Cached & Text's

- (void)setUserCacheDataEditProfile {
    if (self.appModel.userFirstName != nil && ![self.appModel.userFirstName isEqual:@""]) {
        _firstNameField.text = self.appModel.userFirstName;
    }
    if (self.appModel.userLastName != nil) {
        _lastNameField.text = self.appModel.userLastName;
    }
    if (self.appModel.userEmail != nil) {
        _emailField.text = self.appModel.userEmail;
    }
    if (self.appModel.userPhone != nil) {
        _phoneField.text = self.appModel.userPhone;
    }
    if (self.appModel.userBirthday != nil) {
        NSDate *date = [NSDate dateWithISO8601String:self.appModel.userBirthday];
        _birthField.text = [date dateTimeStringShortSimple];
        _birthdaySelect = [NSDate dateFromISO8601:date];
    }
    if (self.appModel.userAddress != nil) {
        _addressField.text = self.appModel.userAddress;
    }
    if (self.appModel.userClientId != nil) {
        _clientIdField.text = self.appModel.userClientId;
    }
}


#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _emailField) {
        [_phoneField becomeFirstResponder];
    } else if (textField == _phoneField) {
        [_firstNameField becomeFirstResponder];
    } else if (textField == _firstNameField) {
        [_lastNameField becomeFirstResponder];
    } else if (textField == _lastNameField) {
        [_birthField becomeFirstResponder];
    } else if (textField == _birthField) {
        [_addressField becomeFirstResponder];
    } else if (textField == _addressField) {
        [_clientIdField becomeFirstResponder];
    } else {
        [self endEditing];
    }
    return YES;
}

- (void)endEditing {
    [self.view endEditing:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == _birthField) {
        
        UIDatePicker *datePicker = [[UIDatePicker alloc] init];
        datePicker.datePickerMode = UIDatePickerModeDate;
        datePicker.maximumDate = [NSDate date];
        [datePicker setBackgroundColor:[Color officialWhiteColor]];
        [datePicker addTarget:self action:@selector(updateDateField:) forControlEvents:UIControlEventValueChanged];
        
        if (@available(iOS 13.4, *)) {
            datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
            datePicker.inputView.backgroundColor = [Color officialWhiteColor];
        }
        _birthField.inputView = datePicker;
        
        if (self.appModel.userBirthday != nil && self.appModel.userBirthday.length != 0) {
            NSDate *selectedDate = [NSDate dateWithISO8601String:self.appModel.userBirthday];
            [datePicker setDate:selectedDate];
        } else {
            [datePicker setDate:[NSDate date]];
            _birthField.text = [datePicker.date dateTimeStringShortSimple];
            _birthdaySelect = [NSDate dateFromISO8601:datePicker.date];
        }

        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        [toolBar setTintColor:[Color officialMainAppColor]];
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:localizeString(@"Next") style:UIBarButtonItemStylePlain target:self action:@selector(donePickerSelectedDate)];
        UIBarButtonItem *space = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [toolBar setItems:[NSArray arrayWithObjects:space, doneBtn, nil]];
        [_birthField setInputAccessoryView:toolBar];

    }
    
    self.activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeTextField = nil;
}

- (void)textFieldDidChange:(UITextField *)sender {
    if (sender == _firstNameField || sender == _lastNameField) {
        self.userNameLbl.text = [NSString stringWithFormat:@"%@ %@", _firstNameField.text, _lastNameField.text];
    }
    if (sender == _emailField) {
        _emailField.textColor = [UIColor darkGrayColor];
    }
}


#pragma mark - Keyboard Delegate

- (void)keyboardWasShown:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
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
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}


#pragma mark - PickerView Date Delegate

- (void)updateDateField:(id)sender {
    UIDatePicker *picker = (UIDatePicker*)_birthField.inputView;
    _birthField.text = [picker.date dateTimeStringShortSimple];
    _birthdaySelect = [NSDate dateFromISO8601:picker.date];
}

- (void)donePickerSelectedDate {
    UIDatePicker *picker = (UIDatePicker*)_birthField.inputView;
    _birthField.text = [picker.date dateTimeStringShortSimple];
    _birthdaySelect = [NSDate dateFromISO8601:picker.date];
    [_birthField resignFirstResponder];
    [_addressField becomeFirstResponder];
}

- (void)nextBtnPhoneClicked {
    [_phoneField resignFirstResponder];
    [_firstNameField becomeFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    // VALIDATE IF NEEDED EMAIL/PHONE CHANGES BY USER
//    if (textField == _phoneField && ![self.appModel.userPhone isEqual:@""] && self.appModel.userPhone != nil) {
//        return NO;
//    } else if (textField == _emailField && ![self.appModel.userEmail isEqual:@""] && self.appModel.userEmail != nil) {
//        return NO;
//    }
    return YES;
}

- (IBAction)backBtnClick:(id)sender {
    if (self.navigationController.presentingViewController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        if (@available(iOS 13.0, *)) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }
}

- (void)quitAndUpdate {
    [self dismissViewControllerAnimated:YES completion:^{
        [self hidePreloader];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateProfileTableDataWait" object:self];
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
