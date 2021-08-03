//
//  MainClaimViewController.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.04.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "MainClaimViewController.h"
#import "CarClaimViewController.h"
#import "ClaimDetailsViewCtrl.h"
#import "ClaimQouteCell.h"
#import "ClaimsUserResponse.h"
#import "ClaimsTokenResponse.h"
#import "ClaimsTokenRequestData.h"
#import "ClaimsAccidentResponse.h"
#import "UIViewController+Preloader.h"
#import "HapticHelper.h"
#import "NSDate+UI.h"
#import "NSDate+ISO8601.h"


@interface MainClaimViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView        *tableView;

@property (weak, nonatomic) IBOutlet UIView             *verifiedProfileView;
@property (weak, nonatomic) IBOutlet UIButton           *completeProfileBtn;
@property (weak, nonatomic) IBOutlet UILabel            *userNameLbl;
@property (weak, nonatomic) IBOutlet UILabel            *userPhoneLbl;
@property (weak, nonatomic) IBOutlet UILabel            *userMaritalLbl;
@property (weak, nonatomic) IBOutlet UIImageView        *avatarImg;
@property (weak, nonatomic) IBOutlet UIButton           *backButton;
@property (weak, nonatomic) IBOutlet UILabel            *noClaimsLbl;
@property (weak, nonatomic) IBOutlet UIImageView        *claimPlusBtn;

@property (nonatomic, strong) UIRefreshControl          *refreshController;
@property (strong, nonatomic) TelematicsAppModel               *appModel;

@end


@implementation MainClaimViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.noClaimsLbl.hidden = YES;
    
    [[ClaimsService sharedService] destroyClaimsService];
    
    self.appModel = [TelematicsAppModel MR_findFirstByAttribute:@"current_user" withValue:@1];
    [self.tableView setContentSize:(CGSizeMake(self.tableView.frame.size.width, self.tableView.frame.size.height + 150))];
    [self initRefreshControlSpinnerForClaims];
    
    NSArray *sortedArray = [self.userClaims.Claims sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 valueForKey:@"Id"] compare:[obj2 valueForKey:@"Id"]];
    }];
    NSArray *reversedClaims = [[sortedArray reverseObjectEnumerator] allObjects];
    self.userClaims.Claims = [reversedClaims mutableCopy];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserClaims) name:@"claimsNeedUpdateNow" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.userClaims.Claims.count == 0) {
        [self showPreloader];
        [self refreshUserClaims];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hidePreloader];
        });
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.userClaims.Claims = nil;
    [self refreshUserClaims];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userClaims.Claims.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ClaimQouteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClaimQouteCell"];
    
    if (!cell) {
        cell = [[ClaimQouteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ClaimQouteCell"];
    }
    
    NSString *detectAccident = [[self.userClaims.Claims objectAtIndex:indexPath.row] valueForKey:@"AccidentType"];
    NSString *accName = @"Other";
    if (detectAccident != nil) {
        if ([detectAccident isEqualToString:@"road_accident"]) {
            accName = @"Road Accident";
        } else if ([detectAccident isEqualToString:@"fire_damage"]) {
            accName = @"Fire Damage";
        } else if ([detectAccident isEqualToString:@"cataclysm"]) {
            accName = @"Cataclysm";
        } else if ([detectAccident isEqualToString:@"hijacking"]) {
            accName = @"Hijacking";
        } else if ([detectAccident isEqualToString:@"vandalism"]) {
            accName = @"Vandalism";
        } else if ([detectAccident isEqualToString:@"vandalism"]) {
            accName = @"Vandalism";
        } else if ([detectAccident isEqualToString:@"glass_damage"]) {
            accName = @"Glass Damage";
        } else if ([detectAccident isEqualToString:@"animals"]) {
            accName = @"Animals";
        } else {
            accName = @"Other";
        }
    }
    
    NSString *dateClaimFormat = localizeString(@"Not specified");
    NSString *claimDateTime = [[self.userClaims.Claims objectAtIndex:indexPath.row] valueForKey:@"ClaimDateTime"] ? [[self.userClaims.Claims objectAtIndex:indexPath.row] valueForKey:@"ClaimDateTime"] :localizeString(@"Not specified");
    if (![claimDateTime isEqual:[NSNull null]]) {
        NSDate *date = [NSDate dateWithISO8601String:claimDateTime];
        dateClaimFormat = [date dateString];
    } else {
        dateClaimFormat = localizeString(@"Not specified");
    }
    cell.claimName.text = [NSString stringWithFormat:@"%@  |  %@", accName, dateClaimFormat];
    cell.claimId.text = [[self.userClaims.Claims objectAtIndex:indexPath.row] valueForKey:@"VehicleMake"];
    
    NSString *stateNow = [[self.userClaims.Claims objectAtIndex:indexPath.row] valueForKey:@"State"];
    if ([stateNow isEqualToString:@"draft"]) {
        cell.claimStatus.text =  @"Draft";
    } else if ([stateNow isEqualToString:@"processing"]) {
        cell.claimStatus.text =  @"Processing";
    } else if ([stateNow isEqualToString:@"pending"]) {
        cell.claimStatus.text =  @"Pending";
    } else if ([stateNow isEqualToString:@"hold"]) {
        cell.claimStatus.text =  @"Hold";
    } else if ([stateNow isEqualToString:@"rejected"]) {
        cell.claimStatus.text =  @"Rejected";
    } else if ([stateNow isEqualToString:@"approved"]) {
        cell.claimStatus.text =  @"Processing";
    } else if ([stateNow isEqualToString:@"quote"]) {
        cell.claimStatus.text =  @"Processing";
    } else if ([stateNow isEqualToString:@"executed"]) {
        cell.claimStatus.text =  @"Processing";
    } else {
        cell.claimStatus.text =  @"Draft";
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    CGFloat height = cell.frame.size.height;
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSArray *names = @[@"My Claims"];
    //NSArray *names = @[@"PROCESSING", @"RECEIVED", @"PENDING", @"APPROVAL", @"DECLINED"];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(35, 15, tableView.frame.size.width, 30)];
    [label setFont:[Font bold17]];
    label.textColor = [Color officialWhiteColor];
    NSString *string = [names objectAtIndex:section];
    [label setText:string];
    [view addSubview:label];
    [view setBackgroundColor:[Color officialWhiteColor]];
    
    if (self.userClaims.Claims.count != 0) {
        label.textColor = [Color tabBarDarkColor];
    }
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ClaimDetailsViewCtrl* detailClaim = [self.storyboard instantiateViewControllerWithIdentifier:@"ClaimDetailsViewCtrl"];
    detailClaim.selectedClaim = [self.userClaims.Claims objectAtIndex:indexPath.row];
    detailClaim.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:detailClaim animated:YES completion:nil];
}

- (IBAction)newClaimAction:(id)sender {
    [[ClaimsService sharedService] destroyPhotosForClaimsService];
    
    CarClaimViewController* newClaim = [self.storyboard instantiateViewControllerWithIdentifier:@"CarClaimViewController"];
    newClaim.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:newClaim animated:YES completion:nil];
}

- (IBAction)dismissAction:(id)sender {
    CATransition *transition = [[CATransition alloc] init];
    transition.duration = 0.3;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [self.view.window.layer addAnimation:transition forKey:kCATransition];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Claims Update Methods

- (void)refreshUserClaims {
    [[ClaimsService sharedService] destroyClaimsService];
    
    ClaimsTokenRequestData* requestToken = [[ClaimsTokenRequestData alloc] init];
    requestToken.device_token = [GeneralService sharedService].device_token_number;
    
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        if (!error && [response isSuccesful]) {
            [GeneralService sharedService].claimsToken = ((ClaimsTokenResponse*)response).Result.Token;
            [self getUserClaimsUpdate];
            [self getAccidentTypesUpdate];
        } else {
            if (self.userClaims.Claims.count == 0) {
                self.noClaimsLbl.hidden = NO;
            } else {
                self.noClaimsLbl.hidden = YES;
            }
            [self hidePreloader];
        }
    }] getTokenForClaims:requestToken];
}

- (void)getUserClaimsUpdate {
    
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        if (!error && [response isSuccesful]) {
            self.userClaims = ((ClaimsUserResponse*)response).Result;
            
            NSArray *sortedArray = [self.userClaims.Claims sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [[obj1 valueForKey:@"Id"] compare:[obj2 valueForKey:@"Id"]];
            }];
            NSArray *reversedClaims = [[sortedArray reverseObjectEnumerator] allObjects];
            self.userClaims.Claims = [reversedClaims mutableCopy];
            
            [self hidePreloader];
            [self.tableView reloadData];
            [self.refreshController endRefreshing];
            
            if (self.userClaims.Claims.count == 0) {
                self.noClaimsLbl.hidden = NO;
            } else {
                self.noClaimsLbl.hidden = YES;
            }
        } else {
            self.userClaims = ((ClaimsUserResponse*)response).Result;
            
            NSArray *sortedArray = [self.userClaims.Claims sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [[obj1 valueForKey:@"Id"] compare:[obj2 valueForKey:@"Id"]];
            }];
            NSArray *reversedClaims = [[sortedArray reverseObjectEnumerator] allObjects];
            self.userClaims.Claims = [reversedClaims mutableCopy];
            
            [self hidePreloader];
            [self.tableView reloadData];
            [self.refreshController endRefreshing];
            
            if (self.userClaims.Claims.count == 0) {
                self.noClaimsLbl.hidden = NO;
            } else {
                self.noClaimsLbl.hidden = YES;
            }
        }
    }] getUserClaims];
}

- (void)getAccidentTypesUpdate {
    
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        NSLog(@"%s %@ %@", __func__, response, error);
        if (!error && [response isSuccesful]) {
            [ClaimsService sharedService].AccidentTypes = ((ClaimsAccidentResponse*)response).Result.AccidentTypes;
        } else {
            [ClaimsService sharedService].AccidentTypes = ((ClaimsAccidentResponse*)response).Result.AccidentTypes;
        }
    }] getAccidentTypes];
}

- (void)initRefreshControlSpinnerForClaims {
    self.refreshController = [[UIRefreshControl alloc] init];
    self.refreshController.tintColor = [Color lightGrayColor];
    [self.refreshController addTarget:self action:@selector(getUserClaimsUpdate) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshController];
}

@end
