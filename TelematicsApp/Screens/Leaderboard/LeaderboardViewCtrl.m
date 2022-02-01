//
//  LeaderboardViewCtrl.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 07.04.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "LeaderboardViewCtrl.h"
#import "ProfileViewController.h"
#import "UIViewController+Preloader.h"
#import "OverallCell.h"
#import "AccCell.h"
#import "DecCell.h"
#import "SpeedCell.h"
#import "PhoneCell.h"
#import "CornerCell.h"
#import "TotalTripsCell.h"
#import "MileageCell.h"
#import "TimeCell.h"
#import "SettingsViewController.h"
#import "LeaderboardResultResponse.h"
#import "LeaderboardResponse.h"
#import "ProfileResultResponse.h"
#import "ProfileResponse.h"
#import "MainScoresViewCtrl.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "Color.h"

@interface LeaderboardViewCtrl () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel                *mainTitle;
@property (weak, nonatomic) IBOutlet UITableView            *tableView;
@property (weak, nonatomic) IBOutlet UIView                 *mainBackground;
@property (weak, nonatomic) IBOutlet UIImageView            *avatarImg;
@property (weak, nonatomic) IBOutlet UIButton               *backButton;
@property (weak, nonatomic) IBOutlet UILabel                *userNameLbl;
@property (nonatomic, strong) UIRefreshControl              *refreshController;
@property (weak, nonatomic) IBOutlet UIView                 *placeholderMainView;
@property (weak, nonatomic) IBOutlet UIImageView            *placeholderMainImg;
@property (weak, nonatomic) IBOutlet UIButton               *settingsBtn;
@property (weak, nonatomic) IBOutlet UIButton               *chatBtn;

@property (strong, nonatomic) TelematicsAppModel            *appModel;
@property (strong, nonatomic) TelematicsLeaderboardModel    *leaderboardModel;

@property (nonatomic, strong) NSArray<NSArray *>            *sections;
@property (strong, nonatomic) LeaderboardResponse           *leaderboard;

@property (weak, nonatomic) IBOutlet UIView                 *noUsersInLeaderboardView;
@property (weak, nonatomic) IBOutlet UILabel                *noUsersInLeaderboardLbl;

@end

@implementation LeaderboardViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    [[UIImage imageNamed:[Configurator sharedInstance].mainBackgroundImg] drawInRect:self.view.bounds];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:img];
    
    //INITIALIZE USER APP MODEL
    self.appModel = [TelematicsAppModel MR_findFirstByAttribute:@"current_user" withValue:@1];
    
    //INITIALIZE USER LEADERBOARD MODEL
    self.leaderboardModel = [TelematicsLeaderboardModel MR_findFirstByAttribute:@"leaderboard_user" withValue:@1];
    
    self.mainTitle.text = localizeString(@"leaderboard_title_summary");
    
    self.mainBackground.layer.cornerRadius = 16;
    self.mainBackground.layer.masksToBounds = NO;
    self.mainBackground.layer.shadowOffset = CGSizeMake(0, 0);
    self.mainBackground.layer.shadowRadius = 2;
    self.mainBackground.layer.shadowOpacity = 0.1;
    
    self.placeholderMainView.hidden = YES;
    
    self.navigationController.navigationBar.topItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                                                         initWithTitle:@""
                                                                         style:UIBarButtonItemStylePlain
                                                                         target:nil
                                                                         action:nil];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorColor = [UIColor clearColor];
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.tableView addSubview:self.refreshController];
    [self.tableView bringSubviewToFront:self.refreshController];
    
    if (self.leaderboardModel.leaderboardGlobal.count == 0) {
        self.placeholderMainView.hidden = NO;
        //[self showPreloader];
        [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
            if (!error && [response isSuccesful]) {
                self.leaderboard = response;
                
                self.leaderboardModel.leaderboardGlobal = @[self.leaderboard.Result];
                
                if (self.leaderboard.Result.Users.count == 0)
                    self.placeholderMainView.hidden = YES;
                else
                    self.placeholderMainView.hidden = YES;
                [CoreDataCoordinator saveCoreDataCoordinatorContext];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self hidePreloader];
                });
            } else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (self.leaderboard.Result.Users.count == 0)
                        self.placeholderMainView.hidden = NO;
                    else
                        self.placeholderMainView.hidden = YES;
                    [self.tableView reloadData];
                    [self hidePreloader];
                });
            }
        }] getLeaderboardForUser];
    } else {
        [self.tableView reloadData];
    }
    
    if (self.hideBackButton == YES) {
        self.backButton.hidden = YES;
        self.avatarImg.hidden = NO;
        self.settingsBtn.hidden = NO;
        self.chatBtn.hidden = NO;
    } else {
        self.backButton.hidden = NO;
        self.avatarImg.hidden = YES;
        self.settingsBtn.hidden = YES;
        self.chatBtn.hidden = YES;
    }
    
    [self displayUserNavigationBarInfo];
    [self initRefreshControlSpinner];
    
    self.noUsersInLeaderboardView.layer.cornerRadius = 16;
    self.noUsersInLeaderboardView.layer.masksToBounds = NO;
    self.noUsersInLeaderboardView.hidden = YES;
    self.noUsersInLeaderboardLbl.text = localizeString(@"Keep driving!\nLeaderboard appears soon.");
    if (self.leaderboardModel.leaderboardGlobal.count == 0) {
        self.noUsersInLeaderboardView.hidden = NO;
    }
    
    UITapGestureRecognizer *avaTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avaTapDetect:)];
    self.avatarImg.userInteractionEnabled = YES;
    [self.avatarImg addGestureRecognizer:avaTap];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
    [self displayUserNavigationBarInfo];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}


#pragma mark - UserInfo

- (void)displayUserNavigationBarInfo {
    self.userNameLbl.text = self.appModel.userFullName ? self.appModel.userFullName : @"";
    self.avatarImg.layer.cornerRadius = self.avatarImg.frame.size.width / 2.0;
    self.avatarImg.layer.masksToBounds = YES;
    self.avatarImg.contentMode = UIViewContentModeScaleAspectFill;
    if (self.appModel.userPhotoData != nil) {
        self.avatarImg.image = [UIImage imageWithData:self.appModel.userPhotoData];
    }
}

- (IBAction)avaTapDetect:(id)sender {
    ProfileViewController *profileVC = [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateInitialViewController];
    profileVC.hideBackButton = YES;
    CATransition *transition = [[CATransition alloc] init];
    transition.duration = 0.5;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [self.view.window.layer addAnimation:transition forKey:kCATransition];
    [self presentViewController:profileVC animated:NO completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0)
            return 100;
        else
            return 90;
    } else {
        return 90;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 6;
    } else {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    self.tableView.separatorColor = [UIColor clearColor];
    
    LeaderboardResultResponse *objGlobal = self.leaderboardModel.leaderboardGlobal[0];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            OverallCell *cellOverall = [tableView dequeueReusableCellWithIdentifier:@"OverallCell"];
            if (!cellOverall) {
                cellOverall = [[OverallCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"OverallCell"];
            }
            cellOverall.titleLbl.text = localizeString(@"Overall Safety Score");
            cellOverall.positionLbl.format = @"#%d";
            cellOverall.positionLbl.animationDuration = 1.0;
            cellOverall.positionLbl.method = UILabelCountingMethodLinear;
            
            NSString *objPlace = objGlobal.Place.stringValue ? objGlobal.Place.stringValue : @"";
            NSString *lblText = cellOverall.positionLbl.text;
            NSString *controlText = [NSString stringWithFormat:@"#%@", objPlace];
            if (![lblText isEqualToString:controlText])
                [cellOverall.positionLbl countFrom:0 to:[objPlace floatValue]];
            [cellOverall configOverall:objGlobal.Place.floatValue usersNumber:objGlobal.UsersNumber.floatValue];
            
            return cellOverall;
            
        } else {
            
            if (indexPath.row == 1) {
                AccCell *cellAcc = [tableView dequeueReusableCellWithIdentifier:@"AccCell"];
                if (!cellAcc) {
                    cellAcc = [[AccCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AccCell"];
                }
                cellAcc.titleLbl.text = localizeString(@"Acceleration");
                [cellAcc.icon sd_setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"lead_acceleration"]];
                cellAcc.positionLbl.format = @"#%d";
                cellAcc.positionLbl.animationDuration = 1.0;
                cellAcc.positionLbl.method = UILabelCountingMethodLinear;
                
                NSString *objPlace = objGlobal.AccelerationPlace.stringValue ? objGlobal.AccelerationPlace.stringValue : @"";
                NSString *lblText = cellAcc.positionLbl.text;
                NSString *controlText = [NSString stringWithFormat:@"#%@", objPlace];
                if (![lblText isEqualToString:controlText])
                    [cellAcc.positionLbl countFrom:0 to:[objPlace floatValue]];
                [cellAcc configAcc:objGlobal.AccelerationPlace.floatValue usersNumber:objGlobal.UsersNumber.floatValue];
                return cellAcc;
                
            } else if (indexPath.row == 2) {
                DecCell *cellDec = [tableView dequeueReusableCellWithIdentifier:@"DecCell"];
                if (!cellDec) {
                    cellDec = [[DecCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DecCell"];
                }
                cellDec.titleLbl.text = localizeString(@"Braking");
                [cellDec.icon sd_setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"lead_deceleration"]];
                cellDec.positionLbl.format = @"#%d";
                cellDec.positionLbl.animationDuration = 1.0;
                cellDec.positionLbl.method = UILabelCountingMethodLinear;
                
                NSString *objPlace = objGlobal.DecelerationPlace.stringValue ? objGlobal.DecelerationPlace.stringValue : @"";
                NSString *lblText = cellDec.positionLbl.text;
                NSString *controlText = [NSString stringWithFormat:@"#%@", objPlace];
                if (![lblText isEqualToString:controlText])
                    [cellDec.positionLbl countFrom:0 to:[objPlace floatValue]];
                [cellDec configDec:objGlobal.DecelerationPlace.floatValue usersNumber:objGlobal.UsersNumber.floatValue];
                return cellDec;
                
            } else if (indexPath.row == 3) {
                SpeedCell *cellSpeed = [tableView dequeueReusableCellWithIdentifier:@"SpeedCell"];
                if (!cellSpeed) {
                    cellSpeed = [[SpeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SpeedCell"];
                }
                cellSpeed.titleLbl.text = localizeString(@"Speeding");
                [cellSpeed.icon sd_setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"lead_speeding"]];
                cellSpeed.positionLbl.format = @"#%d";
                cellSpeed.positionLbl.animationDuration = 1.0;
                cellSpeed.positionLbl.method = UILabelCountingMethodLinear;
                
                NSString *objPlace = objGlobal.SpeedingPlace.stringValue ? objGlobal.SpeedingPlace.stringValue : @"";
                NSString *lblText = cellSpeed.positionLbl.text;
                NSString *controlText = [NSString stringWithFormat:@"#%@", objPlace];
                if (![lblText isEqualToString:controlText])
                    [cellSpeed.positionLbl countFrom:0 to:[objPlace floatValue]];
                [cellSpeed configSpeed:objGlobal.SpeedingPlace.floatValue usersNumber:objGlobal.UsersNumber.floatValue];
                return cellSpeed;
                
            } else if (indexPath.row == 4) {
                PhoneCell *cellPhone = [tableView dequeueReusableCellWithIdentifier:@"PhoneCell"];
                if (!cellPhone) {
                    cellPhone = [[PhoneCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PhoneCell"];
                }
                cellPhone.titleLbl.text = localizeString(@"Distraction");
                [cellPhone.icon sd_setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"lead_phone"]];
                cellPhone.positionLbl.format = @"#%d";
                cellPhone.positionLbl.animationDuration = 1.0;
                cellPhone.positionLbl.method = UILabelCountingMethodLinear;
                
                NSString *objPlace = objGlobal.DistractionPlace.stringValue ? objGlobal.DistractionPlace.stringValue : @"";
                NSString *lblText = cellPhone.positionLbl.text;
                NSString *controlText = [NSString stringWithFormat:@"#%@", objPlace];
                if (![lblText isEqualToString:controlText])
                    [cellPhone.positionLbl countFrom:0 to:[objPlace floatValue]];
                [cellPhone configPhone:objGlobal.DistractionPlace.floatValue usersNumber:objGlobal.UsersNumber.floatValue];
                return cellPhone;
                
            } else if (indexPath.row == 5) {
                CornerCell *cellCorner = [tableView dequeueReusableCellWithIdentifier:@"CornerCell"];
                if (!cellCorner) {
                    cellCorner = [[CornerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CornerCell"];
                }
                cellCorner.titleLbl.text = localizeString(@"Cornering");
                [cellCorner.icon sd_setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"lead_cornering"]];
                cellCorner.positionLbl.format = @"#%d";
                cellCorner.positionLbl.animationDuration = 1.0;
                cellCorner.positionLbl.method = UILabelCountingMethodLinear;
                
                NSString *objPlace = objGlobal.TurnPlace.stringValue ? objGlobal.TurnPlace.stringValue : @"";
                NSString *lblText = cellCorner.positionLbl.text;
                NSString *controlText = [NSString stringWithFormat:@"#%@", objPlace];
                if (![lblText isEqualToString:controlText])
                    [cellCorner.positionLbl countFrom:0 to:[objPlace floatValue]];
                [cellCorner configCorner:objGlobal.TurnPlace.floatValue usersNumber:objGlobal.UsersNumber.floatValue];
                return cellCorner;
            }
        }
    } else if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            TotalTripsCell *cellTotalTrips = [tableView dequeueReusableCellWithIdentifier:@"TotalTripsCell"];
            if (!cellTotalTrips) {
                cellTotalTrips = [[TotalTripsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TotalTripsCell"];
            }
            cellTotalTrips.titleLbl.text = localizeString(@"Total Trips");
            [cellTotalTrips.icon sd_setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"lead_trips"]];
            cellTotalTrips.positionLbl.format = @"#%d";
            cellTotalTrips.positionLbl.animationDuration = 1.0;
            cellTotalTrips.positionLbl.method = UILabelCountingMethodLinear;
            
            NSString *objPlace = objGlobal.TripsPlace.stringValue ? objGlobal.TripsPlace.stringValue : @"";
            NSString *lblText = cellTotalTrips.positionLbl.text;
            NSString *controlText = [NSString stringWithFormat:@"#%@", objPlace];
            if (![lblText isEqualToString:controlText])
                [cellTotalTrips.positionLbl countFrom:0 to:[objPlace floatValue]];
            [cellTotalTrips configTotalTrips:objGlobal.TripsPlace.floatValue usersNumber:objGlobal.UsersNumber.floatValue];
            return cellTotalTrips;
            
        } else if (indexPath.row == 1) {
            MileageCell *cellMileage = [tableView dequeueReusableCellWithIdentifier:@"MileageCell"];
            if (!cellMileage) {
                cellMileage = [[MileageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MileageCell"];
            }
            cellMileage.titleLbl.text = localizeString(@"Mileage");
            [cellMileage.icon sd_setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"lead_mileage"]];
            cellMileage.positionLbl.format = @"#%d";
            cellMileage.positionLbl.animationDuration = 1.0;
            cellMileage.positionLbl.method = UILabelCountingMethodLinear;
            
            NSString *objPlace = objGlobal.DistancePlace.stringValue ? objGlobal.DistancePlace.stringValue : @"";
            NSString *lblText = cellMileage.positionLbl.text;
            NSString *controlText = [NSString stringWithFormat:@"#%@", objPlace];
            if (![lblText isEqualToString:controlText])
                [cellMileage.positionLbl countFrom:0 to:[objPlace floatValue]];
            [cellMileage configMileage:objGlobal.DistancePlace.floatValue usersNumber:objGlobal.UsersNumber.floatValue];
            return cellMileage;
            
        } else if (indexPath.row == 2) {
            TimeCell *cellTime = [tableView dequeueReusableCellWithIdentifier:@"TimeCell"];
            if (!cellTime) {
                cellTime = [[TimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TimeCell"];
            }
            cellTime.titleLbl.text = localizeString(@"Time Driven");
            [cellTime.icon sd_setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"lead_time"]];
            cellTime.positionLbl.format = @"#%d";
            cellTime.positionLbl.animationDuration = 1.0;
            cellTime.positionLbl.method = UILabelCountingMethodLinear;
            
            NSString *objPlace = objGlobal.DurationPlace.stringValue ? objGlobal.DurationPlace.stringValue : @"";
            NSString *lblText = cellTime.positionLbl.text;
            NSString *controlText = [NSString stringWithFormat:@"#%@", objPlace];
            if (![lblText isEqualToString:controlText])
                [cellTime.positionLbl countFrom:0 to:[objPlace floatValue]];
            //float userValue = objGlobal.DurationPlace.floatValue;
            //float maxValue = objGlobal.UsersNumber.floatValue;
            [cellTime configTime:objGlobal.DurationPlace.floatValue usersNumber:objGlobal.UsersNumber.floatValue];
            return cellTime;
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath{
    //
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1)
        return 45;
    else
        return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return [[UIView alloc] initWithFrame:CGRectZero];

    NSArray *names = @[localizeString(@"Statistics")];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    [view setBackgroundColor:[UIColor clearColor]];
    
    UILabel *lblSection = [[UILabel alloc] initWithFrame:CGRectMake(25, 0, tableView.frame.size.width, 45)];
    
    if (section == 0) {
        UIView *viewS = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 58)];
        [viewS setBackgroundColor:[Color officialWhiteColor]];
        viewS.layer.cornerRadius = 16.0f;
        viewS.layer.masksToBounds = YES;
        [view addSubview:viewS];
    } else if (section == 1) {
        UIView *viewS = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 35)];
        [viewS setBackgroundColor:[Color officialWhiteColor]];
        viewS.layer.masksToBounds = YES;
        [view addSubview:viewS];
    }
    
    [lblSection setFont:[Font bold17]];
    NSString *stName = [names objectAtIndex:0];
    [lblSection setText:stName];
    [lblSection setTextColor:[Color blackColor]];
    [view addSubview:lblSection];
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MainScoresViewCtrl *scoresVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MainScoresViewCtrl"];
    if (indexPath.section == 0)
        scoresVC.showPageNumber = indexPath.row;
    else
        scoresVC.showPageNumber = indexPath.row+6;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:scoresVC];
    navController.navigationBar.hidden = YES;
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)initRefreshControlSpinner {
    self.refreshController = [[UIRefreshControl alloc] init];
    self.refreshController.tintColor = [Color lightGrayColor];
    [self.refreshController addTarget:self action:@selector(reloadLeaderboard) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshController];
}

- (void)reloadLeaderboard {
    [self.refreshController endRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Navigation

- (IBAction)chatOpenAction:(id)sender {
    //
}

- (IBAction)backAction:(id)sender {
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

- (IBAction)settingsBtnAction:(id)sender {
    SettingsViewController *settingsVC = [[UIStoryboard storyboardWithName:@"Settings" bundle:nil] instantiateInitialViewController];
    [self presentViewController:settingsVC animated:YES completion:nil];
}

@end
