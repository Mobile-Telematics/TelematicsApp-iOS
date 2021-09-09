//
//  SettingsViewController.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 20.09.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsMenuCell.h"
#import "SettingsNoIconCell.h"
#import "ProfileViewController.h"
#import "LeaderboardViewCtrl.h"
#import "MeasuresViewCtrl.h"
#import "ChangeCompanyIdViewCtrl.h"
#import <MessageUI/MessageUI.h>
#import "MainClaimViewController.h"
#import "ClaimsTokenRequestData.h"
#import "ClaimsTokenResponse.h"
#import "ClaimsUserResponse.h"
#import "ClaimsAccidentResponse.h"

@interface SettingsViewController () <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) TelematicsAppModel                       *appModel;

@property (weak, nonatomic) IBOutlet UITableView                *tableView;
@property (weak, nonatomic) IBOutlet UILabel                    *mainTitle;

@property (nonatomic, strong) ClaimsUserResultResponse          *claimsUserResponse;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //INITIALIZE USER APP MODEL
    self.appModel = [TelematicsAppModel MR_findFirstByAttribute:@"current_user" withValue:@1];
    self.mainTitle.text = localizeString(@"settings_title");
    
    [self getTokenForClaims];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 7;
    } if (section == 1) {
        return 2;
    } if (section == 2) {
        return 4;
    } if (section == 3) {
        return 1;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        SettingsMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsMenuCell"];
        if (!cell) {
            cell = [[SettingsMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingsMenuCell"];
        }
        
        cell.uberLogo.hidden = YES;
        
        if (indexPath.row == 0) {
            cell.titleLbl.text = localizeString(@"menuitem_profile");
            [cell.iconImg setImage:[UIImage imageNamed:@"ic_user"]];
        } else if (indexPath.row == 1) {
            cell.titleLbl.text = localizeString(@"menuitem_claims");
            [cell.iconImg setImage:[UIImage imageNamed:@"ic_claims"]];
        } else if (indexPath.row == 2) {
            cell.titleLbl.text = localizeString(@"menuitem_leaderboard");
            [cell.iconImg setImage:[UIImage imageNamed:@"ic_leader"]];
        } else if (indexPath.row == 3) {
            cell.titleLbl.text = localizeString(@"menuitem_tsettings");
            [cell.iconImg setImage:[UIImage imageNamed:@"ic_telematics"]];
        } else if (indexPath.row == 4) {
            cell.titleLbl.text = localizeString(@"menuitem_connectobd");
            [cell.iconImg setImage:[UIImage imageNamed:@"ic_ridehailing"]];
        } else if (indexPath.row == 5) {
            cell.titleLbl.text = localizeString(@"menuitem_measures");
            [cell.iconImg setImage:[UIImage imageNamed:@"ic_meas"]];
        } else if (indexPath.row == 6) {
            cell.titleLbl.text = localizeString(@"menuitem_companyId");
            [cell.iconImg setImage:[UIImage imageNamed:@"ic_add_dealer"]];
        }
        return cell;
        
    } else if (indexPath.section == 1 || indexPath.section == 3) {
        
        SettingsNoIconCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsNoIconCell"];
        if (!cell) {
            cell = [[SettingsNoIconCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingsNoIconCell"];
        }
        
        if (indexPath.row == 0) {
            cell.titleLbl.text = @"";
            cell.titleLbl.textColor = [Color officialRedColor];
            cell.arrow.hidden = YES;
            cell.userInteractionEnabled = NO;
        } else if (indexPath.row == 1) {
            cell.titleLbl.text = localizeString(@"menuitem_logout");
            cell.titleLbl.textColor = [Color officialRedColor];
            cell.arrow.hidden = YES;
        }
        return cell;
        
    } else if (indexPath.section == 2) {
        
        SettingsNoIconCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsNoIconCell"];
        if (!cell) {
            cell = [[SettingsNoIconCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingsNoIconCell"];
        }
        
        if (indexPath.row == 0) {
            cell.titleLbl.text = localizeString(@"menuitem_privacy");
        } else if (indexPath.row == 1) {
            cell.titleLbl.text = localizeString(@"menuitem_terms");
        } else if (indexPath.row == 2) {
            cell.titleLbl.text = localizeString(@"menuitem_rate");
        } else if (indexPath.row == 3) {
            cell.titleLbl.text = localizeString(@"menuitem_help");
        }
        return cell;
        
    } else {
        
        SettingsNoIconCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsNoIconCell"];
        if (!cell) {
            cell = [[SettingsNoIconCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingsNoIconCell"];
        }
        
        if (indexPath.row == 0) {
            cell.titleLbl.text = localizeString(@"menuitem_privacy");
        } else if (indexPath.row == 1) {
            cell.titleLbl.text = localizeString(@"menuitem_terms");
        } else if (indexPath.row == 2) {
            cell.titleLbl.text = localizeString(@"menuitem_rate");
        } else if (indexPath.row == 3) {
            cell.titleLbl.text = localizeString(@"menuitem_help");
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    CGFloat height = cell.frame.size.height;
    return height;
}


#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
            [self openUserProfile];
        } else if (indexPath.row == 1) {
            [self openClaims];
        } else if (indexPath.row == 2) {
			[self openLeaderboard];
        } else if (indexPath.row == 3) {
            [self settingsTelematicsClick];
        } else if (indexPath.row == 4) {
            [self openConnectOBDDevice];
        } else if (indexPath.row == 5) {
            [self openMeasuresSettings];
        } else if (indexPath.row == 6) {
            [self openJoinCompany];
        }
	} else if (indexPath.section == 1) {
		if (indexPath.row == 1) {
			[self logoutButtonPressed];
		}
	} else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [self settingsPrivacyClick];
        } else if (indexPath.row == 1) {
            [self settingsTermsClick];
        } else if (indexPath.row == 2) {
            [self settingsRateAppClick];
        } else if (indexPath.row == 3) {
            [self settingsHelpClick];
        }
	}
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)openUserProfile {
    ProfileViewController *profileVC = [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateInitialViewController];
    profileVC.hideBackButton = YES;
    [self.navigationController pushViewController:profileVC animated:YES];
}

- (void)openLeaderboard {
    LeaderboardViewCtrl *leadersVC = [[UIStoryboard storyboardWithName:@"Leaderboard" bundle:nil] instantiateInitialViewController];
    leadersVC.hideBackButton = NO;
    [self.navigationController pushViewController:leadersVC animated:YES];
}

- (void)openConnectOBDDevice {
    ConnectOBDViewCtrl *connectVC = [[UIStoryboard storyboardWithName:@"ConnectOBD" bundle:nil] instantiateInitialViewController];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:connectVC];
    navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    navController.navigationBar.hidden = YES;
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)openClaims {
    MainClaimViewController *claimVC = [[UIStoryboard storyboardWithName:@"Claims" bundle:nil] instantiateInitialViewController];
    CATransition *transition = [[CATransition alloc] init];
    transition.duration = 0.5;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [self.view.window.layer addAnimation:transition forKey:kCATransition];
    
    claimVC.modalPresentationStyle = UIModalPresentationCustom;
    claimVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    claimVC.userClaims = self.claimsUserResponse;
    [self presentViewController:claimVC animated:NO completion:nil];
}

- (void)openMeasuresSettings {
    MeasuresViewCtrl *meas = [self.storyboard instantiateViewControllerWithIdentifier:@"MeasuresViewCtrl"];
    [self.navigationController pushViewController:meas animated:YES];
}

- (void)openJoinCompany {
    ChangeCompanyIdViewCtrl *cEdit = [self.storyboard instantiateViewControllerWithIdentifier:@"ChangeCompanyIdViewCtrl"];
    [self.navigationController pushViewController:cEdit animated:YES];
}

- (void)openChat {
    //TODO CHAT CONNECTION
}
    
- (void)settingsHowItWorksClick {
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [Configurator sharedInstance].linkHowItWorks]];
    SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:URL];
    svc.delegate = self;
    svc.preferredControlTintColor = [Color officialMainAppColor];
    [self presentViewController:svc animated:YES completion:nil];
}

- (void)settingsTelematicsClick {
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [Configurator sharedInstance].telematicsSettingsOS13]];
    if IS_OS_13_OR_OLD
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [Configurator sharedInstance].telematicsSettingsOS12]];
    SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:URL];
    svc.delegate = self;
    svc.preferredControlTintColor = [Color officialGreenColor];
    [self presentViewController:svc animated:YES completion:nil];
}

- (void)settingsPrivacyClick {
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [Configurator sharedInstance].linkPrivacyPolicy]];
    SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:URL];
    svc.delegate = self;
    svc.preferredControlTintColor = [Color officialMainAppColor];
    [self presentViewController:svc animated:YES completion:nil];
}

- (void)settingsTermsClick {
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [Configurator sharedInstance].linkTermsOfUse]];
    SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:URL];
    svc.delegate = self;
    svc.preferredControlTintColor = [Color officialMainAppColor];
    [self presentViewController:svc animated:YES completion:nil];
}

- (void)settingsRateAppClick {
    NSString *link = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/us/app/id%@?action=write-review", [Configurator sharedInstance].appStoreAppId];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link] options:@{} completionHandler:nil];
}
    
- (void)logoutButtonPressed {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:localizeString(@"Logout")
                                message:localizeString(@"Are you sure you want to quit?")
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *noButton = [UIAlertAction
                               actionWithTitle:localizeString(@"Cancel")
                               style:UIAlertActionStyleDestructive
                               handler:^(UIAlertAction *action) {
                               }];
    
    UIAlertAction *yesButton = [UIAlertAction
                                actionWithTitle:localizeString(@"Yes")
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction *action) {
                                    [[GeneralService sharedService] logout];
                                }];
    
    [alert addAction:noButton];
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)settingsHelpClick {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
        [composeViewController setMailComposeDelegate:self];
        [composeViewController setToRecipients:@[[Configurator sharedInstance].linkSupportEmail]];
        NSString *support = [NSString stringWithFormat:@"%@ %@", localizeString(@"TelematicsApp"), localizeString(@"support_name")];
        [composeViewController setSubject:support];
        [composeViewController setMessageBody:localizeString(@"support_comment") isHTML:NO];
        [self presentViewController:composeViewController animated:YES completion:nil];
    } else {
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:localizeString(@"error_title")
                                    message:localizeString(@"support_nomail")
                                    preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *okButton = [UIAlertAction
                                   actionWithTitle:localizeString(@"Ok")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                                   }];

        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    //[self dismissViewControllerAnimated:true completion:nil];
}


#pragma mark - Claims Service Get Token Preload

- (void)getTokenForClaims {
    
    ClaimsTokenRequestData* requestToken = [[ClaimsTokenRequestData alloc] init];
    requestToken.device_token = [GeneralService sharedService].device_token_number;
    
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        NSLog(@"%s %@ %@", __func__, response, error);
        if (!error && [response isSuccesful]) {
            [GeneralService sharedService].claimsToken = ((ClaimsTokenResponse*)response).Result.Token;
            NSLog(@"CLAIMS TOKEN SUCCESS: %@", [GeneralService sharedService].claimsToken);
            [self getUserClaims];
            [self getAccidentTypes];
        } else {
            NSLog(@"ErrorGetClaimsToken");
        }
    }] getTokenForClaims:requestToken];
}

- (void)getUserClaims {
    
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        NSLog(@"%s %@ %@", __func__, response, error);
        if (!error && [response isSuccesful]) {
            self.claimsUserResponse = ((ClaimsUserResponse*)response).Result;
        } else {
            self.claimsUserResponse = ((ClaimsUserResponse*)response).Result;
        }
    }] getUserClaims];
}

- (void)getAccidentTypes {
    
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        NSLog(@"%s %@ %@", __func__, response, error);
        if (!error && [response isSuccesful]) {
            [ClaimsService sharedService].AccidentTypes = ((ClaimsAccidentResponse*)response).Result.AccidentTypes;
        } else {
            [ClaimsService sharedService].AccidentTypes = ((ClaimsAccidentResponse*)response).Result.AccidentTypes;
        }
    }] getAccidentTypes];
}


#pragma mark - Back Navigation

- (IBAction)dismissSettings:(id)sender {
    if (@available(iOS 13.0, *)) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        CATransition *transition = [[CATransition alloc] init];
        transition.duration = 0.3;
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromLeft;
        [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
        [self.view.window.layer addAnimation:transition forKey:kCATransition];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}


#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView * headerView = (UITableViewHeaderFooterView *) view;
        headerView.backgroundColor  = [UIColor redColor];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1f;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
