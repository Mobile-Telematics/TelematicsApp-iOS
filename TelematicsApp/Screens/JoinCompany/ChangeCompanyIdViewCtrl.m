//
//  ChangeCompanyIdViewCtrl.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 10.06.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ChangeCompanyIdViewCtrl.h"
#import "JoinCompanyResponse.h"
#import "Color.h"
#import "Helpers.h"
#import "UIViewController+Preloader.h"
#import "GeneralService.h"
#import "NSDate+UI.h"
#import "NSDate+ISO8601.h"
#import "RefreshTokenRequestData.h"


@interface ChangeCompanyIdViewCtrl () <UIScrollViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView       *scrollView;

@property (weak, nonatomic) IBOutlet UILabel            *mainCompanyIdLbl;
@property (weak, nonatomic) IBOutlet UILabel            *mainTxtLbl;

@property (nonatomic, assign) UITextField               *activeTextField;
@property (weak, nonatomic) IBOutlet UITextField        *companyIdField;
@property (weak, nonatomic) IBOutlet UIButton           *backBtn;
@property (weak, nonatomic) IBOutlet UIButton           *saveBtn;
@property (weak, nonatomic) IBOutlet UIImageView        *avatar;

@property (strong, nonatomic) TelematicsAppModel        *appModel;
@property (nonatomic, strong) JoinCompanyResponse       *instanceData;

@end

@implementation ChangeCompanyIdViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];

    self.appModel = [TelematicsAppModel MR_findFirstByAttribute:@"current_user" withValue:@1];

    [self setupView];
    [self displayUserInfo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:true];
}

- (void)setupView {
    self.mainCompanyIdLbl.text = localizeString(@"Join a Company");
    self.mainTxtLbl.text = localizeString(@"If you have a Company invitation code, enter it in the field below");

    self.companyIdField.delegate = self;
    self.companyIdField.textColor = [UIColor darkGrayColor];
    [self.companyIdField setBackgroundColor:[Color lightSeparatorColor]];
    [self.companyIdField.layer setMasksToBounds:YES];
    [self.companyIdField.layer setCornerRadius:20.0f];
    [self.companyIdField.layer setBorderColor:[[Color officialMainAppColor] CGColor]];
    [self.companyIdField.layer setBorderWidth:1.5];
    self.companyIdField.placeholder = localizeString(@"Invite code");

    [self.backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];

    [self.saveBtn addTarget:self action:@selector(saveBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.saveBtn setTitle:localizeString(@"JOIN") forState:UIControlStateNormal];
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

    if (textField == _companyIdField) {
        [_companyIdField becomeFirstResponder];
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


#pragma mark - CompanyID Request

- (void)changeCompanyIdNow {

    [self.view endEditing:YES];
    [self showPreloader];

    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {

        self.instanceData = ((JoinCompanyResponse*)response);
        if ([response isSuccesful] && self.instanceData.Status.intValue != 404) {

            NSString *finAlertStr = [NSString stringWithFormat:@"You have successfully joined\n\n%@\n", self.instanceData.Result.InstanceName];

            UIAlertController *alert = [UIAlertController alertControllerWithTitle:localizeString(@"Completed") message:finAlertStr preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionCopy = [UIAlertAction actionWithTitle:localizeString(@"Copy Name to Clipboard") style:UIAlertActionStyleDefault handler:^(UIAlertAction *actionCopy) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = self.instanceData.Result.InstanceName;

                UIAlertController *alert = [UIAlertController alertControllerWithTitle:localizeString(@"Company Name copied to clipboard") message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:localizeString(@"Ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }];
            [alert addAction:actionCopy];
            UIAlertAction *action = [UIAlertAction actionWithTitle:localizeString(@"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];

            [self refreshJWTafterCompanyIdChanged];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self hidePreloader];
                [[GeneralService sharedService] loadProfile];
            });

        } else {
            [self hidePreloader];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:localizeString(@"Not found") message:@"Try again please" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:localizeString(@"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                self->_companyIdField.text = nil;
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }] joinCompanyIdRefresh:_companyIdField.text];
}


#pragma mark - Navigation

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveBtnAction {
    [self changeCompanyIdNow];
}

- (void)refreshJWTafterCompanyIdChanged {

    RefreshTokenRequestData* refreshData = [[RefreshTokenRequestData alloc] init];

    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *fileTokenKey = [NSString stringWithFormat:@"%@/authBearerTokenKey.txt", documentsDirectory];
    NSString *contentTK = [[NSString alloc] initWithContentsOfFile:fileTokenKey usedEncoding:nil error:nil];
    refreshData.accessToken = contentTK;

    NSString *fileRefreshKey = [NSString stringWithFormat:@"%@/authBearerRefreshTokenKey.txt", documentsDirectory];
    NSString *contentRT = [[NSString alloc] initWithContentsOfFile:fileRefreshKey usedEncoding:nil error:nil];
    refreshData.refreshToken = contentRT;

    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        NSLog(@"%s %@ %@", __func__, response, error);
        if ([response isSuccesful] && ((RootResponse*)response).Status.intValue != 400) {
            [[GeneralService sharedService] refreshJWToken:response];
        } else {
            NSLog(@"!!!!!REFRESH TOKEN ERROR!!!!!");
        }
    }] refreshJWToken:refreshData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
