//
//  Step1ViewController.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.04.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "Step1ViewController.h"
#import "Step2ViewController.h"
#import "CustomLocationPickerVC.h"
#import "Color.h"
#import "Helpers.h"
#import "UIViewController+Preloader.h"
#import "UITextField+Form.h"
#import "NSDate+UI.h"
#import "NSDate+ISO8601.h"
#import <NMAKit/NMAKit.h>
#import "ConfigGMaps.h"
#import "CommonFunctions.h"
#import "WiFiGPSChecker.h"
@import GoogleMaps;
@import GooglePlaces;


@interface Step1ViewController () <UIScrollViewDelegate, UITextFieldDelegate, UITextViewDelegate, RPLocationDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView       *scrollView;
@property (weak, nonatomic) IBOutlet UILabel            *mainLbl;

@property (nonatomic, assign) UITextField               *activeTextField;
@property (weak, nonatomic) IBOutlet UITextField        *dateField;
@property (weak, nonatomic) IBOutlet UITextField        *onlyTimeField;
@property (weak, nonatomic) IBOutlet UITextField        *locationField;
@property (weak, nonatomic) IBOutlet UITextView         *detailsField;
@property (weak, nonatomic) IBOutlet UIButton           *backBtn;
@property (weak, nonatomic) IBOutlet UIButton           *nextBtn;

@property (strong, nonatomic) TelematicsAppModel        *appModel;
@property int                                           counterLocationPicker;

@property (nonatomic, strong) NSString                  *dateSelectedByUser;
@property (nonatomic, strong) NSString                  *timeSelectedByUser;

@property (strong, nonatomic) NMAGeoCoordinates         *lastKnownCoordinate;
@property (assign, nonatomic) BOOL                      refreshGeoAddress;

@property (weak, nonatomic) NSString                    *gMapsLat;
@property (weak, nonatomic) NSString                    *gMapsLng;
@property (weak, nonatomic) NSString                    *gMapsAddressName;
@property (weak, nonatomic) NSString                    *gMapsFormattedAddress;

@end

@implementation Step1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //INITIALIZE USER APP MODEL
    self.appModel = [TelematicsAppModel MR_findFirstByAttribute:@"current_user" withValue:@1];
    self.counterLocationPicker = 0;
    
    [self setupView];
    [self setTextViewPlaceholder];
    [self setupCachedData];
    [self lowFontsForOldDevices];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.locationField.text = [ClaimsService sharedService].LocationStr;
    [self initGeoLocation];
    
    if (self.counterLocationPicker != 0) {
        [_detailsField becomeFirstResponder];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:true];
    
    if (self.counterLocationPicker == 0) {
        [_dateField becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [_dateField resignFirstResponder];
    [_onlyTimeField resignFirstResponder];
    [_detailsField resignFirstResponder];
    [_locationField resignFirstResponder];
    
    //[RPEntry instance].locationDelegate =  nil;
    [super viewWillDisappear:animated];
}

- (void)setupView {
    self.dateField.delegate = self;
    [self.dateField makeFormFieldShift20];
    self.dateField.textColor = [UIColor darkGrayColor];
    [self.dateField setBackgroundColor:[Color lightSeparatorColor]];
    [self.dateField.layer setMasksToBounds:YES];
    [self.dateField.layer setCornerRadius:15.0f];
    [self.dateField.layer setBorderColor:[[Color grayColor] CGColor]];
    [self.dateField.layer setBorderWidth:1.5];
    
    self.onlyTimeField.delegate = self;
    [self.onlyTimeField makeFormFieldShift20];
    self.onlyTimeField.textColor = [UIColor darkGrayColor];
    [self.onlyTimeField setBackgroundColor:[Color lightSeparatorColor]];
    [self.onlyTimeField.layer setMasksToBounds:YES];
    [self.onlyTimeField.layer setCornerRadius:15.0f];
    [self.onlyTimeField.layer setBorderColor:[[Color grayColor] CGColor]];
    [self.onlyTimeField.layer setBorderWidth:1.5];
    
    self.locationField.delegate = self;
    [self.locationField makeFormFieldShift20];
    self.locationField.textColor = [UIColor darkGrayColor];
    [self.locationField setBackgroundColor:[Color lightSeparatorColor]];
    [self.locationField.layer setMasksToBounds:YES];
    [self.locationField.layer setCornerRadius:15.0f];
    [self.locationField.layer setBorderColor:[[Color grayColor] CGColor]];
    [self.locationField.layer setBorderWidth:1.5];
    
    [self.nextBtn addTarget:self action:@selector(nextBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.nextBtn setTintColor:[Color officialWhiteColor]];
    [self.nextBtn setBackgroundColor:[Color officialMainAppColor]];
    [self.nextBtn.layer setMasksToBounds:YES];
    [self.nextBtn.layer setCornerRadius:15.0f];
    
    [self registerForKeyboardNotifications];
    
    UITapGestureRecognizer *scrollEndTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endStepEditing)];
    scrollEndTap.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:scrollEndTap];
}

- (void)setupCachedData {
    
    if ([ClaimsService sharedService].ClaimDateTime != nil && ![[ClaimsService sharedService].ClaimDateTime isEqualToString:@"(null)"]) {
        NSDate *date = [NSDate dateWithISO8601String:[ClaimsService sharedService].ClaimDateTime];
        _dateField.text = [date dateTimeStringShortSimple];
    }
    if ([ClaimsService sharedService].ClaimTime != nil && ![[ClaimsService sharedService].ClaimTime isEqualToString:@"(null)"]) {
        _onlyTimeField.text = [ClaimsService sharedService].ClaimTime;
    }
    if ([ClaimsService sharedService].DriverComments != nil && ![[ClaimsService sharedService].DriverComments isEqualToString:@"(null)"]) {
        _detailsField.text = [ClaimsService sharedService].DriverComments;
    }
    if ([ClaimsService sharedService].LocationStr != nil && ![[ClaimsService sharedService].LocationStr isEqualToString:@"(null)"]) {
        _locationField.text = [ClaimsService sharedService].LocationStr;
    } else {
        if (self.appModel.userAddress != nil) {
            _locationField.text = self.appModel.userAddress;
        }
    }
}

- (void)setTextViewPlaceholder {
    self.detailsField.delegate = self;
    self.detailsField.textContainerInset = UIEdgeInsetsMake(7, 14, 0, 0);
    [self.detailsField setBackgroundColor:[Color lightSeparatorColor]];
    [self.detailsField.layer setMasksToBounds:YES];
    [self.detailsField.layer setCornerRadius:15.0f];
    
    if ([ClaimsService sharedService].DriverComments != nil && ![[ClaimsService sharedService].DriverComments isEqualToString:@"(null)"]) {
        self.detailsField.textColor = [UIColor darkGrayColor];
    } else {
        self.detailsField.text = localizeString(@"Specify accident details including exact location and what happened");
        self.detailsField.textColor = [Color softGrayColor];
    }
    [self.detailsField.layer setBorderColor:[[Color grayColor] CGColor]];
    [self.detailsField.layer setBorderWidth:1.5];
    self.detailsField.font = [Font regular14];
}


#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == _dateField) {
        [_onlyTimeField becomeFirstResponder];
    } else if (textField == _onlyTimeField) {
        //[_locationField becomeFirstResponder];
    } else if (textField == _locationField) {
        [_detailsField becomeFirstResponder];
    } else {
        [self endStepEditing];
    }
    return YES;
}

- (void)endStepEditing {
    [self.view endEditing:YES];
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.view.frame.size.height/4, 0.0);
    if (IS_IPHONE_5 || IS_IPHONE_4_OR_LESS) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.view.frame.size.height/2.7, 0.0);
    } else if (IS_IPHONE_11_PROMAX || IS_IPHONE_13_PROMAX) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.view.frame.size.height/6, 0.0);
    } else if (IS_IPHONE_11 || IS_IPHONE_13_PRO) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.view.frame.size.height/7, 0.0);
    }
    self.scrollView.contentInset = contentInsets;
    [self syncEnteredInfo];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == _dateField) {
        
        UIDatePicker *datePicker = [[UIDatePicker alloc] init];
        datePicker.datePickerMode = UIDatePickerModeDate;
        datePicker.maximumDate = [NSDate date];
        [datePicker setBackgroundColor:[Color officialWhiteColor]];
        [datePicker addTarget:self action:@selector(updateDateField:) forControlEvents:UIControlEventValueChanged];
        if (@available(iOS 13.4, *)) {
            datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
            datePicker.inputView.backgroundColor = [Color officialWhiteColor];
        }
        _dateField.inputView = datePicker;

        if ([ClaimsService sharedService].ClaimDateTime != nil && ![[ClaimsService sharedService].ClaimDateTime isEqualToString:@"(null)"]) {
            NSDate *selectedDate = [NSDate dateWithISO8601String:[ClaimsService sharedService].ClaimDateTime];
            [datePicker setDate:selectedDate];
        } else {
            [datePicker setDate:[NSDate date]];
        }
        
        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        [toolBar setTintColor:[Color officialMainAppColor]];
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(donePickerSelectedDate)];
        UIBarButtonItem *space = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [toolBar setItems:[NSArray arrayWithObjects:space, doneBtn, nil]];
        [_dateField setInputAccessoryView:toolBar];
        
        _dateSelectedByUser = [NSDate dateFromISO8601:datePicker.date];
        [ClaimsService sharedService].ClaimDateTime = _dateSelectedByUser;
        
    } else if (textField == _onlyTimeField) {
        
        UIDatePicker *timePicker = [[UIDatePicker alloc] init];
        timePicker.datePickerMode = UIDatePickerModeTime;
        [timePicker setBackgroundColor:[Color officialWhiteColor]];
        [timePicker addTarget:self action:@selector(updateTimeField:) forControlEvents:UIControlEventValueChanged];
        if (@available(iOS 13.4, *)) {
            timePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
            timePicker.inputView.backgroundColor = [Color officialWhiteColor];
        }
        _onlyTimeField.inputView = timePicker;
        
        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        [toolBar setTintColor:[Color officialMainAppColor]];
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(donePickerSelectedTime)];
        UIBarButtonItem *space = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [toolBar setItems:[NSArray arrayWithObjects:space, doneBtn, nil]];
        [_onlyTimeField setInputAccessoryView:toolBar];
        
        _timeSelectedByUser = [NSDate dateFromISO8601:timePicker.date];
        [ClaimsService sharedService].ClaimTime = _timeSelectedByUser;
        
    } else if (textField == _locationField) {
        
        [self performSegueWithIdentifier:@"VIEW_TO_ADDRESS_PICKER" sender:nil];
        self.counterLocationPicker += 1;
    }
    
    self.activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeTextField = nil;
}


#pragma mark - UITextView Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([self.detailsField.text isEqualToString:@"Specify accident details including exact location and what happened"]) {
        self.detailsField.text = @"";
        self.detailsField.textColor = [UIColor darkGrayColor];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView == _detailsField) {
        if (IS_IPHONE_5 || IS_IPHONE_4_OR_LESS) {
            [self.scrollView setContentOffset:CGPointMake(0, (textView.superview.frame.origin.y + (textView.frame.origin.y) - 100)) animated:NO];
        } else if (IS_IPHONE_8) {
            [self.scrollView setContentOffset:CGPointMake(0, (textView.superview.frame.origin.y + (textView.frame.origin.y) - 170)) animated:NO];
        } else if (IS_IPHONE_8P) {
            [self.scrollView setContentOffset:CGPointMake(0, (textView.superview.frame.origin.y + (textView.frame.origin.y) - 250)) animated:NO];
        } else if (IS_IPHONE_11 || IS_IPHONE_13_PRO) {
            [self.scrollView setContentOffset:CGPointMake(0, (textView.superview.frame.origin.y + (textView.frame.origin.y) - 200)) animated:NO];
        } else if (IS_IPHONE_11_PROMAX || IS_IPHONE_13_PROMAX) {
            [self.scrollView setContentOffset:CGPointMake(0, (textView.superview.frame.origin.y + (textView.frame.origin.y) - 250)) animated:NO];
        }
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([self.detailsField.text isEqualToString:@""] || [self.detailsField.text isEqualToString:@"Specify accident details including exact location and what happened"]) {
        self.detailsField.text = @"Specify accident details including exact location and what happened";
        self.detailsField.textColor = [UIColor lightGrayColor];
    } else if (![self.detailsField.text isEqualToString:@""] || ![self.detailsField.text isEqualToString:@"Specify accident details including exact location and what happened"]) {
        [ClaimsService sharedService].DriverComments = self.detailsField.text;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}


#pragma mark - PickerView Date Delegate

- (void)updateDateField:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)_dateField.inputView;
    _dateField.text = [picker.date dateTimeStringShortSimple];
    _dateSelectedByUser = [NSDate dateFromISO8601:picker.date];
    [ClaimsService sharedService].ClaimDateTime = self->_dateSelectedByUser;
}

- (void)donePickerSelectedDate
{
    UIDatePicker *picker = (UIDatePicker*)_dateField.inputView;
    _dateField.text = [picker.date dateTimeStringShortSimple];
    _dateSelectedByUser = [NSDate dateFromISO8601:picker.date];
    [_dateField resignFirstResponder];
    [_onlyTimeField becomeFirstResponder];
    [ClaimsService sharedService].ClaimDateTime = self->_dateSelectedByUser;
}


#pragma mark - PickerView Time Delegate

- (void)updateTimeField:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)_onlyTimeField.inputView;
    _onlyTimeField.text = [picker.date timeString];
    _timeSelectedByUser = [NSDate dateFromISO8601:picker.date];
    [ClaimsService sharedService].ClaimDateTime = self->_timeSelectedByUser;
}

- (void)donePickerSelectedTime
{
    UIDatePicker *picker = (UIDatePicker*)_onlyTimeField.inputView;
    _onlyTimeField.text = [picker.date timeString];
    _timeSelectedByUser = [NSDate dateFromISO8601:picker.date];
    [_onlyTimeField resignFirstResponder];
    //[_locationField becomeFirstResponder];
    [ClaimsService sharedService].ClaimDateTime = self->_timeSelectedByUser;
    
    [self performSegueWithIdentifier:@"VIEW_TO_ADDRESS_PICKER" sender:nil];
    self.counterLocationPicker += 1;
}


#pragma mark - Keyboard Delegate

- (void)keyboardWasShown:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height + 110, 0.0);
    if (IS_IPHONE_11_PROMAX || IS_IPHONE_13_PROMAX) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height - 200, 0.0);
    } else if (IS_IPHONE_11 || IS_IPHONE_13_PRO) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height - 100, 0.0);
    } else if (IS_IPHONE_8P) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height + 70, 0.0);
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


#pragma mark - Coordinates

- (void)onLocationChanged:(CLLocation *)location {
//    NSString *latString = [NSString stringWithFormat:@"%.14f", location.coordinate.latitude];
//    NSString *lngString = [NSString stringWithFormat:@"%.14f", location.coordinate.longitude];
//    [ClaimsService sharedService].PlaceCreateLat = latString;
//    [ClaimsService sharedService].PlaceCreateLng = lngString;
}

- (void)onNewEvents:(NSMutableArray *)events {
    //TELEMATICS SDK EVENTS LISTENER IF NEEDED FOR GOOGLEMAPS
}


- (void)initGeoLocation {
    
    BOOL isMotionEnabled = [[WiFiGPSChecker sharedChecker] motionAvailable];
    BOOL isGPSAuthorized = ([CLLocationManager locationServicesEnabled]
                            && (([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) ||
                                ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)));
    
    if (!isGPSAuthorized) {
        //        self->permissionWizardPopup.disabledGPS = YES;
        //        if (!isMotionEnabled){
        //            permissionWizardPopup.disabledMotion = YES;
        //        }
        //        [permissionWizardPopup showPopup];
    } else {
        if ([[NMAPositioningManager sharedPositioningManager] startPositioning]) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(didUpdatePositionForClaims) name:NMAPositioningManagerDidUpdatePositionNotification
                                                       object:[NMAPositioningManager sharedPositioningManager]];
        }
    }
}

- (void)didUpdatePositionForClaims {
    NMAGeoPosition *position = [[NMAPositioningManager sharedPositioningManager] currentPosition];
    _lastKnownCoordinate = position.coordinates;
    
    NSString *latString = [NSString stringWithFormat:@"%f", _lastKnownCoordinate.latitude];
    NSString *lngString = [NSString stringWithFormat:@"%f", _lastKnownCoordinate.longitude];
    [ClaimsService sharedService].PlaceCreateLat = latString;
    [ClaimsService sharedService].PlaceCreateLng = lngString;
}

- (IBAction)selectAddressAction:(id)sender {
    [self performSegueWithIdentifier:@"VIEW_TO_ADDRESS_PICKER" sender:nil];
}


#pragma mark - Google Maps Delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[CustomLocationPickerVC class]]) {
        CustomLocationPickerVC *vc = (CustomLocationPickerVC *)[segue destinationViewController];
        vc.lat = [NSString stringWithFormat:@"%f", CURRENT_LATITUDE] ? [NSString stringWithFormat:@"%f", CURRENT_LATITUDE] : @"";
        vc.lng = [NSString stringWithFormat:@"%f", CURRENT_LONGITUDE] ? [NSString stringWithFormat:@"%f", CURRENT_LONGITUDE] : @"";
        vc.address = CURRENT_ADDRESS ? CURRENT_ADDRESS : @"";
    }
}

- (IBAction)unwindFromLocationPickerToCreateOrder:(UIStoryboardSegue *)segue {
    if ([[segue sourceViewController] isKindOfClass:[CustomLocationPickerVC class]]) {
        CustomLocationPickerVC *vc = (CustomLocationPickerVC *)[segue sourceViewController];
        
        self.gMapsLat = [NSString stringWithFormat:@"LAT - %@", vc.lat];
        self.gMapsLng = [NSString stringWithFormat:@"LNG - %@", vc.lng];
        self.gMapsFormattedAddress = [NSString stringWithFormat:@"ADDRESS - %@", vc.address];
        self.gMapsAddressName = [NSString stringWithFormat:@"CITY - %@, COUNTRY - %@", vc.city, vc.country];
        
        self.locationField.text = [NSString stringWithFormat:@"%@", vc.address];
    }
}


#pragma mark - Navigation

- (void)nextBtnAction {
    
    if ([_dateField.text isEqualToString:@""]) {
        [_dateField setBackgroundColor:[Color curveRedColorAlpha]];
        [_dateField.layer setBorderColor:[[Color officialRedColor] CGColor]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self->_dateField setBackgroundColor:[Color lightSeparatorColor]];
            [self->_dateField.layer setBorderColor:[[Color grayColor] CGColor]];
        });
        return;
        
    } else if ([_onlyTimeField.text isEqualToString:@""]) {
        [_onlyTimeField setBackgroundColor:[Color curveRedColorAlpha]];
        [_onlyTimeField.layer setBorderColor:[[Color officialRedColor] CGColor]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self->_onlyTimeField setBackgroundColor:[Color lightSeparatorColor]];
            [self->_onlyTimeField.layer setBorderColor:[[Color grayColor] CGColor]];
        });
        return;
        
    } else if ([_locationField.text isEqualToString:@""]) {
        //        //IF NEEDED LOCATION REQUIRED
        //        [_locationField setBackgroundColor:[Color curveRedColorAlpha]];
        //        [_locationField.layer setBorderColor:[[Color officialRedColor] CGColor]];
        //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //            [self->_locationField setBackgroundColor:[Color lightSeparatorColor]];
        //            [self->_locationField.layer setBorderColor:[[Color grayColor] CGColor]];
        //        });
        //        return;
        
    } else if ([_detailsField.text isEqualToString:@""] || [_detailsField.text isEqualToString:@"Specify accident details including exact location and what happened"]) {
        [_detailsField setBackgroundColor:[Color curveRedColorAlpha]];
        [_detailsField.layer setBorderColor:[[Color officialRedColor] CGColor]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self->_detailsField setBackgroundColor:[Color lightSeparatorColor]];
            [self->_detailsField.layer setBorderColor:[[Color grayColor] CGColor]];
        });
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [ClaimsService sharedService].ClaimDateTime = self->_dateSelectedByUser;
        [ClaimsService sharedService].ClaimTime = self->_onlyTimeField.text;
        [ClaimsService sharedService].LocationStr = self->_locationField.text;
        [ClaimsService sharedService].DriverComments = self->_detailsField.text;
    });
    
    Step2ViewController* step2 = [self.storyboard instantiateViewControllerWithIdentifier:@"Step2ViewController"];
    step2.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:step2 animated:NO completion:nil];
    
    [[NMAPositioningManager sharedPositioningManager] stopPositioning];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NMAPositioningManagerDidUpdatePositionNotification
                                                  object:[NMAPositioningManager sharedPositioningManager]];
}

- (IBAction)dismissAction:(id)sender {
    [self syncEnteredInfo];
    [[[[self presentingViewController] presentingViewController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)backAction:(id)sender {
    CATransition *transition = [[CATransition alloc] init];
    transition.duration = 0.3;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [self.view.window.layer addAnimation:transition forKey:kCATransition];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)syncEnteredInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        [ClaimsService sharedService].ClaimDateTime = self->_dateSelectedByUser;
        [ClaimsService sharedService].ClaimTime = self->_onlyTimeField.text;
        [ClaimsService sharedService].LocationStr = self->_locationField.text;
        [ClaimsService sharedService].DriverComments = self->_detailsField.text;
    });
}

//iPHONE 5S DEPRECATED EXCUSE US, LOW FONTS IF YOU NEEDED HELPERS FOR SOME ELEMENTS
- (void)lowFontsForOldDevices {
    if (IS_IPHONE_5 || IS_IPHONE_4_OR_LESS) {
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.view.frame.size.height/1.7, 0.0);
        self.scrollView.contentInset = contentInsets;
        self.scrollView.scrollIndicatorInsets = contentInsets;
        self.mainLbl.font = [Font semibold15];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
