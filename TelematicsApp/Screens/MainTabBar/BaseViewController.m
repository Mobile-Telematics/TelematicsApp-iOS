//
//  BaseViewController.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 12.01.18.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "BaseViewController.h"
#import "UIActionSheet+Blocks.h"
#import "SystemServices.h"
#import <CoreLocation/CoreLocation.h>
#import "WiFiGPSChecker.h"
#import "Helpers.h"

@interface BaseViewController ()

@property (nonatomic, strong) UIImagePickerController* imagePickerController;

@property (nonatomic, strong) UIView                                            *networkAlert;
@property (nonatomic, strong) UIView                                            *gpsAlert;
@property (nonatomic, strong) UIView                                            *expAlertNET;
@property (nonatomic, strong) UIView                                            *expAlertGPS;
@property (nonatomic, strong) NSTimer                                           *alertTimer;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint)NSArray     *constraintsToPop;
@property (strong, nonatomic) NSMutableArray<NSNumber *>                        *originalConstraintHeight;

@end

@implementation BaseViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.errorHandler = [[APIErrorHandler alloc] init];
    self.errorHandler.viewController = self;
    [self subscribeToKeyboardNotifications];
    
    self.originalConstraintHeight = [NSMutableArray array];
    for (NSLayoutConstraint *pop in self.constraintsToPop) {
        [self.originalConstraintHeight addObject:[NSNumber numberWithFloat:pop.constant]];
    }
    
    self.view.backgroundColor = [Color officialWhiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
    
    [self.gpsAlert removeFromSuperview];
    self.gpsAlert = nil;
    [self.networkAlert removeFromSuperview];
    self.networkAlert = nil;
    [self.expAlertNET removeFromSuperview];
    self.expAlertNET = nil;
    [self.expAlertGPS removeFromSuperview];
    self.expAlertGPS = nil;
}

+ (NSString* __nonnull)storyboardIdentifier {
    return NSStringFromClass([self class]);
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)subscribeToKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChange:) name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (void)setViewsHidden:(BOOL)hidden {
    for (UIView *view in self.view.subviews) {
        view.hidden = hidden;
    }
}

- (void)keyboardDidChange:(NSNotification*)notification {
    NSDictionary* info = [notification userInfo];
    CGRect kbFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat h = self.view.frame.size.height - kbFrame.origin.y - self.keyboardAvoidingScrollView.frame.origin.y;
    if (!self.navigationController.navigationBarHidden) {
        h += CGRectGetMaxY(self.navigationController.navigationBar.frame);
    }
    [self keyboardChangedHeight:h];
}

- (void)keyboardChangedHeight:(CGFloat)height {
    if (self.keyboardAvoidingScrollView) {
        UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, height, 0);
        self.keyboardAvoidingScrollView.contentInset = insets;
        self.keyboardAvoidingScrollView.scrollIndicatorInsets = insets;
    }
}

- (void)showMessageWithTitle:(NSString* __nullable)title subTitle:(NSString* __nullable)subTitle type:(RMessageType)type {
    
    [RMessage showNotificationInViewController:self.navigationController
                                         title:title
                                      subtitle:subTitle
                                     iconImage:nil
                                          type:type
                                customTypeName:nil
                                      duration:RMessageDurationAutomatic
                                      callback:nil
                                   buttonTitle:nil
                                buttonCallback:nil
                                    atPosition:RMessagePositionNavBarOverlay
                          canBeDismissedByUser:YES];
}

- (void)showImagePicker {
    [self.view endEditing:YES];
    self.imagePicker = [[GKImagePicker alloc] init];
    self.imagePicker.delegate = self;
    [self.imagePicker showActionSheetOnViewController:self onPopoverFromView:self.view];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}


#pragma mark Actions

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        //[self showDebugTrackingController];
    }
}


#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark GKImagePickerDelegate

- (void)imagePickerDidCancel:(GKImagePicker *)imagePicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Additional Alerts

- (void)setNeedDisplayGPSAlert:(BOOL)needDisplayGPSAlert {
    _needDisplayGPSAlert = needDisplayGPSAlert;
    
    if (self.needDisplayGPSAlert) {
        if (!self.alertTimer.isValid) {
            self.alertTimer = [NSTimer
                               scheduledTimerWithTimeInterval:5
                               target:self
                               selector:@selector(checkAlert)
                               userInfo:nil
                               repeats:YES];
        }
    }
    else {
        [self.alertTimer invalidate];
        self.alertTimer = nil;
    }
}

- (void)checkAlert {
    //CHECK APP PERMISSIONS
}


@end
