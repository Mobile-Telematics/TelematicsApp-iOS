//
//  ChangePasswordViewCtrl.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 26.04.19.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ChangePasswordViewCtrl.h"
#import "Color.h"
#import "Helpers.h"
#import "UIViewController+Preloader.h"
#import "GeneralService.h"
#import "UITextField+Form.h"
#import "NSDate+UI.h"
#import "NSDate+ISO8601.h"


@interface ChangePasswordViewCtrl () <UIScrollViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *mainPassLbl;
@property (weak, nonatomic) IBOutlet UILabel *passOldLbl;
@property (weak, nonatomic) IBOutlet UILabel *passNewLbl;

@property (nonatomic, assign) UITextField *activeTextField;
@property (weak, nonatomic) IBOutlet UITextField *passOldField;
@property (weak, nonatomic) IBOutlet UITextField *passNewField;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;

@property (strong, nonatomic) ZenAppModel *appModel;

@end

@implementation ChangePasswordViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //INITIALIZE USER APP MODEL
    self.appModel = [ZenAppModel MR_findFirstByAttribute:@"current_user" withValue:@1];
    
    [self setupView];
    [self displayUserInfo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:true];
}

- (void)setupView
{
    self.mainPassLbl.text = localizeString(@"Change Password");
    self.passOldLbl.text = localizeString(@"Old Password");
    self.passNewLbl.text = localizeString(@"New Password");
    
    self.passOldField.delegate = self;
    [self.passOldField makeFormFieldShift20];
    self.passOldField.textColor = [UIColor darkGrayColor];
    [self.passOldField setBackgroundColor:[Color lightSeparatorColor]];
    [self.passOldField.layer setMasksToBounds:YES];
    [self.passOldField.layer setCornerRadius:15.0f];
    [self.passOldField.layer setBorderColor:[[Color officialMainAppColor] CGColor]];
    [self.passOldField.layer setBorderWidth:1.5];
    self.passOldField.placeholder = localizeString(@"Enter old password");
    
    self.passNewField.delegate = self;
    [self.passNewField makeFormFieldShift20];
    self.passNewField.textColor = [UIColor darkGrayColor];
    [self.passNewField setBackgroundColor:[Color lightSeparatorColor]];
    [self.passNewField.layer setMasksToBounds:YES];
    [self.passNewField.layer setCornerRadius:15.0f];
    [self.passNewField.layer setBorderColor:[[Color officialMainAppColor] CGColor]];
    [self.passNewField.layer setBorderWidth:1.5];
    self.passNewField.placeholder = localizeString(@"Enter new password");
    
    [self.backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.saveBtn addTarget:self action:@selector(saveBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.saveBtn setTitle:localizeString(@"SAVE") forState:UIControlStateNormal];
    [self.saveBtn setBackgroundColor:[Color officialMainAppColor]];
    
    [self registerForKeyboardNotifications];
    
    UITapGestureRecognizer *scrollEndTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    scrollEndTap.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:scrollEndTap];
}

    
#pragma mark - UserInfo
    
- (void)displayUserInfo {
    self.avatar.layer.cornerRadius = self.avatar.frame.size.width / 2.0;
    self.avatar.layer.masksToBounds = YES;
    self.avatar.contentMode = UIViewContentModeScaleAspectFill;
    if (self.appModel.userPhotoData != nil) {
        self.avatar.image = [UIImage imageWithData:self.appModel.userPhotoData];
    }
}


#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == _passOldField) {
        [_passNewField becomeFirstResponder];
    } else {
        [self endEditing];
    }
    return YES;
}

- (void)endEditing {
    [self.view endEditing:YES];
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
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
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height + 15, 0.0);
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


#pragma mark - Request

- (void)changePassNow {
    
    //TODO FIREBASE CHANGE PASSWORD
}


#pragma mark - Navigation

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveBtnAction {
    [self changePassNow];
}

- (void)showSuccessAlert {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:localizeString(@"Successfully") message:localizeString(@"You have changed password for your account") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:localizeString(@"Ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alert addAction:action];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
