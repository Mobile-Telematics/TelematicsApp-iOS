//
//  FeedViewController.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 21.11.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "FeedViewController.h"
#import "CustomLocationPickerVC.h"
#import "DashMainViewController.h"
#import "SettingsViewController.h"
#import "ProfileViewController.h"
#import "AppDelegate.h"
#import "FeedSlideMenuTableViewCell.h"
#import "FeedSlideCellMenuView.h"
#import "TripCell.h"
#import "DriverSignaturePopupDelegate.h"
#import "HapticHelper.h"
#import "UIView+Extension.h"
#import "UIViewController+Preloader.h"
#import "UIImageView+WebCache.h"
#import "UITableView+Preloader.h"
#import "NSDate+UI.h"
#import "NSDate+ISO8601.h"
#import "PaginationDataSource.h"
#import "TagsSwitch.h"
#import "Format.h"
#import "UIActionSheet+Blocks.h"
#import "ProgressBarView.h"

static NSString *tripCellIdentifier = @"TripCell";
static NSString *sharedTripCellIdentifier = @"SharedTripCell";
static NSString *challengeCellIdentifier = @"ChallengeCell";
static NSString *messageCellIdentifier = @"MessageCell";
static NSString *rewardCellIdentifier = @"RewardCell";

@interface FeedViewController () <FeedSlideCellMenuViewDelegate, UITableViewDelegate, UITableViewDataSource, DriverSignaturePopupProtocol> {
    DriverSignaturePopupDelegate *signaturePopup;
}


@property (weak, nonatomic) IBOutlet UITableView        *tableView;
@property (weak, nonatomic) IBOutlet UITableView        *demoTableView;

@property (weak, nonatomic) IBOutlet UIView             *topSegment;
@property (weak, nonatomic) IBOutlet UILabel            *mainTitle;
@property (weak, nonatomic) IBOutlet UIView             *segmentBackView;
@property (weak, nonatomic) IBOutlet UILabel            *userNameLbl;
@property (weak, nonatomic) IBOutlet UIImageView        *avatarImg;
@property (nonatomic, weak) IBOutlet UIButton           *chatButton;
@property (nonatomic, strong) UIRefreshControl          *refreshController;
@property (nonatomic, strong) UIRefreshControl          *refreshDemoController;
@property (assign, nonatomic) BOOL                      disableRefresh;
@property (nonatomic, assign) BOOL                      disableReloadPageDown;

@property (strong, nonatomic) TelematicsAppModel        *appModel;
@property (nonatomic, strong) NSString                  *selectedTrackToken;
@property (nonatomic, strong) NSString                  *selectedTrackPoints;
@property (nonatomic, strong) NSString                  *selectedPredicate;
@property (nonatomic, strong) NSString                  *selectedDriverSignatureRole;

@property (nonatomic, strong) PaginationDataSource      *dataSource;
@property (nonatomic, strong) NSMutableArray            *tripsData;
@property (nonatomic, strong) NSMutableDictionary       *states;

//DEMO MODE
@property (weak, nonatomic) IBOutlet UIView             *feedDemoView;
@property (nonatomic) IBOutlet ProgressBarView          *feedDemoDistanceBar;
@property (weak, nonatomic) IBOutlet UILabel            *feedDemoMainLbl;
@property (weak, nonatomic) IBOutlet UILabel            *feedDemoDistanceLbl;
@property (weak, nonatomic) IBOutlet UILabel            *feedDemoNoTripsMainLbl;
@property (weak, nonatomic) IBOutlet UILabel            *feedDemoNoTripsSecondLbl;
@property (weak, nonatomic) IBOutlet UILabel            *feedDemoCheckAppPermissLbl;

@end

@implementation FeedViewController

@synthesize feedDemoDistanceBar = _feedDemoDistanceBar;

- (ProgressBarView *)_feedDemoDistanceBar {
    if (!_feedDemoDistanceBar) {
        _feedDemoDistanceBar = [[ProgressBarView alloc] initWithFrame:CGRectZero];
        _feedDemoDistanceBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _feedDemoDistanceBar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appModel = [TelematicsAppModel MR_findFirstByAttribute:@"current_user" withValue:@1];
    
    self.mainTitle.text = localizeString(@"feed_title");
    
    UITabBarItem *tabBarItem0 = [self.tabBarController.tabBar.items objectAtIndex:[[Configurator sharedInstance].feedTabBarNumber intValue]];
    [tabBarItem0 setImage:[[UIImage imageNamed:@"feed_unselected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem0 setSelectedImage:[[UIImage imageNamed:@"feed_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem0 setTitle:localizeString(@"feed_title")];
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    [[UIImage imageNamed:[Configurator sharedInstance].mainBackgroundImg] drawInRect:self.view.bounds];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:img];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [UIView new];
    [self.tableView setAllowsSelection:YES];
    [self.tableView addSubview:self.refreshController];
    [self.tableView bringSubviewToFront:self.refreshController];
    self.tableView.hidden = NO;
    
    self.demoTableView.delegate = self;
    self.demoTableView.dataSource = self;
    self.demoTableView.backgroundColor = [UIColor clearColor];
    self.demoTableView.tableFooterView = [UIView new];
    [self.demoTableView setAllowsSelection:YES];
    [self.demoTableView addSubview:self.refreshDemoController];
    [self.demoTableView bringSubviewToFront:self.refreshDemoController];
    self.demoTableView.hidden = YES;
    self.demoTableView.tag = 950;
    
    self.feedDemoDistanceBar.barFillColor = [Color officialWhiteColor];
    [self.feedDemoDistanceBar setBarBackgroundColor:[Color separatorLightGrayColorAlpha]];
    
    //DEMO FEED TOP FOOTER
    self.feedDemoView.height = 0;
    self.feedDemoView.hidden = YES;
    self.feedDemoDistanceBar.barFillColor = [Color officialWhiteColor];
    [self.feedDemoDistanceBar setBarBackgroundColor:[Color separatorLightGrayColorAlpha]];
    
    [self runCheckingFeedDemoBlock];
    
    //NEW SDK TRIPS
    [self showPreloader];
    
    self.tripsData = [[NSMutableArray alloc] init];
    self.states = [[NSMutableDictionary alloc] init];
    self.dataSource = [[PaginationDataSource alloc] init];
    NSUInteger limit = 10;

    __weak typeof(self) _weakSelf = self;
    [self.dataSource setNextPageBlock:^(NSUInteger offset, PageLoadedBlock pageLoaded) {
        [[RPEntry instance].api getTracksWithOffset:offset limit:limit startDate:nil endDate:nil completion:^(id response, NSError *error) {
            RPFeed* feed = (RPFeed*)response;
            if (feed.tracks.count) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(_weakSelf) _strongSelf = _weakSelf;
                    _strongSelf.demoTableView.hidden = NO;
                    _strongSelf.tableView.hidden = YES;
                    [_strongSelf runCheckingFeedDemoBlock];
                });
                pageLoaded(feed.tracks);
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(_weakSelf) _strongSelf = _weakSelf;
//                    if (_strongSelf == nil) {
//                        return;
//                    }
                    if (self.tripsData.count == 0) {
                        _strongSelf.demoTableView.hidden = NO;
                        _strongSelf.tableView.hidden = YES;
                    } else {
                        _strongSelf.demoTableView.hidden = YES;
                        _strongSelf.tableView.hidden = NO;
                    }
                    [_strongSelf runCheckingFeedDemoBlock];
                    [_strongSelf hidePreloader];
                });
                pageLoaded(@[]);
            }
        }];
    }];
    
    [self loadLatestUserTrips];
    
    [self displayUserNavigationBarInfo];
    [self initRefreshControlSpinner];
    
    UIViewController *currentTopVC = [self currentTopViewController];
    signaturePopup = [[DriverSignaturePopupDelegate alloc] initOnView:currentTopVC.view];
    signaturePopup.delegate = self;
    signaturePopup.dismissOnBackgroundTap = YES;
    
    UITapGestureRecognizer *avaTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avaTapDetect:)];
    self.avatarImg.userInteractionEnabled = YES;
    [self.avatarImg addGestureRecognizer:avaTap];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSDKTrips) name:@"reloadAllFeedPage" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterFeedForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[self.tabBarController.tabBar.items objectAtIndex:[[Configurator sharedInstance].feedTabBarNumber intValue]] setBadgeValue:nil];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [Color officialWhiteColor];
    self.navigationController.navigationBar.clipsToBounds = YES;
    
    self.disableReloadPageDown = NO;
    [self displayUserNavigationBarInfo];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([defaults_object(@"needUpdateForFeedScreen") boolValue]) {
        NSString *trackTokenForState = defaults_object(@"selectedTrackToken");
        if ([[self.states allKeys] containsObject:trackTokenForState]) {
            [self.states removeObjectForKey:trackTokenForState];
        } else {
            [self.states setObject:@"1" forKey:trackTokenForState];
        }
        
        if (self->_disableRefresh) {
            [self reloadSDKTrips];
        } else {
            [self reloadSDKTrips];
        }
        
        defaults_set_object(@"needUpdateForFeedScreen", @(NO));
    }
}


#pragma mark - Feed Demo Block

- (void)appWillEnterFeedForeground {
    NSDate *date = [NSDate new];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSObject *savedLastMomentObject = defaults_object(@"lastTimeAppResignEnterFeedForeground");
    
    if (savedLastMomentObject != nil) {
        NSDate *savedLastMomentReloading = defaults_object(@"lastTimeAppResignEnterFeedForeground");
        int differenceInMilliSec = (int)([calendar ordinalityOfUnit:NSCalendarUnitSecond inUnit:NSCalendarUnitEra forDate:date] - [calendar ordinalityOfUnit:NSCalendarUnitSecond inUnit:NSCalendarUnitEra forDate:savedLastMomentReloading]);
        
        NSLog(@"appResignEnterFeedForeground %d", differenceInMilliSec);
        
        if (differenceInMilliSec < 0)
            differenceInMilliSec = 121;
        
        if (differenceInMilliSec >= 120) {
            defaults_set_object(@"lastTimeAppResignEnterFeedForeground", date);
            [self loadLatestUserTrips];
        }
    } else {
        defaults_set_object(@"lastTimeAppResignEnterFeedForeground", date);
    }
}


#pragma mark - Feed Demo Block

- (void)runCheckingFeedDemoBlock {
    float reqDst = self.appModel.statDistanceForScoring.floatValue;
    float userDst = self.appModel.statSummaryDistance.floatValue;
    
    NSString *rounded = [NSString stringWithFormat:@"%.0f", self.appModel.statSummaryDistance.floatValue];
    NSString *kmLocalize = localizeString(@"km");
    if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
        userDst = convertKmToMiles(userDst);
        self.feedDemoDistanceBar.progress = userDst/reqDst;
        rounded = [NSString stringWithFormat:@"%.1f", userDst];
        kmLocalize = localizeString(@"mi");
    } else {
        self.feedDemoDistanceBar.progress = userDst/reqDst;
    }
    
    self.feedDemoMainLbl.text = [NSString stringWithFormat:@"To Unlock Trips\nDrive %.0f %@", reqDst, kmLocalize];
    self.feedDemoDistanceLbl.text = [NSString stringWithFormat:@"%@ %@ / %@ %@", rounded, kmLocalize, self.appModel.statDistanceForScoring, kmLocalize];
    self.feedDemoCheckAppPermissLbl.attributedText = [self createVerifedLabelAttentionImgBefore:localizeString(@" Check App Permissions   \u2B95")];
    
    if (userDst <= reqDst) {
        defaults_set_object(@"demoModeEnabled", @(YES));
        
        self.feedDemoView.height = 260;
        self.feedDemoView.hidden = NO;
        self.demoTableView.hidden = NO;
        self.tableView.hidden = YES;
        
        UITapGestureRecognizer *checkPermissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openAppSystemSettings:)];
        self.feedDemoCheckAppPermissLbl.userInteractionEnabled = YES;
        [self.feedDemoCheckAppPermissLbl addGestureRecognizer:checkPermissTap];
        
    } else {
        defaults_set_object(@"demoModeEnabled", @(NO));
        
        self.feedDemoView.height = 0;
        self.feedDemoView.hidden = YES;
        self.demoTableView.hidden = YES;
        self.tableView.hidden = NO;
    }
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


#pragma mark - Events Reload

- (void)loadLatestUserTrips {
    if (self.dataSource.data.count != 0 && !self.dataSource.endOfData) {
        [self.tableView showPreloaderAtTop:NO];
    }
    
    __weak typeof(self) _weakSelf = self;
    [self.dataSource loadNextPage:^(NSArray *loadedItems) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(_weakSelf) _strongSelf = _weakSelf;
            if (!loadedItems.count) {
                [_strongSelf.refreshController endRefreshing];
                [_strongSelf.refreshDemoController endRefreshing];
                [_strongSelf.tableView hidePreloaderAtTop:YES];
                if (self.tripsData.count == 0) {
                    _strongSelf.demoTableView.hidden = NO;
                    _strongSelf.tableView.hidden = YES;
                } else {
                    _strongSelf.demoTableView.hidden = YES;
                    _strongSelf.tableView.hidden = NO;
                }
                [_strongSelf runCheckingFeedDemoBlock];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_IMMEDIATELY_1_SEC * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self hidePreloader];
                });
            } else {
                
                [self.tripsData removeAllObjects];
                
                NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO];
                NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
                NSMutableArray *sortedEventArray = [[loadedItems sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
                
                //DEL TRIPS
                if ([Configurator sharedInstance].needTripsDeleting) {
                    for (int i=0; i <= sortedEventArray.count - 1; i++) {
                        RPTrackProcessed *trip = sortedEventArray[i];

                        if (trip.tags.count != 0) {
                            for (RPTag *tag in trip.tags) {
                                NSLog(@"%@", tag.tag);
                                NSLog(@"%@", tag.source);
                                if ([tag.tag isEqualToString:@"DEL"]) {
                                    [sortedEventArray removeObjectAtIndex:i];
                                } else if ([tag.tag isEqualToString:@"Personal"]) {
                                    [self.states setObject:@"Personal" forKey:trip.trackToken];
                                } else if ([tag.tag isEqualToString:@"Business"]) {
                                    [self.states setObject:@"Business" forKey:trip.trackToken];
                                } else {
                                    NSLog(@"%@",tag.source);
                                }
                            }
                        }
                    }
                }

                if (loadedItems.count < 10) {
                    self.disableReloadPageDown = YES;
                }
                    
                [self.tripsData addObjectsFromArray:sortedEventArray];
                [self hidePreloader];
                [_strongSelf.refreshController endRefreshing];
                [_strongSelf.refreshDemoController endRefreshing];
                
                [UIView transitionWithView: self.tableView
                                  duration: 0.55f
                                   options: UIViewAnimationOptionTransitionCrossDissolve //UIViewAnimationOptionTransitionCrossDissolve
                                animations: ^(void) {
                                                CGPoint contentOffset = _strongSelf.tableView.contentOffset;
                                                [_strongSelf.tableView reloadData];
                                                [_strongSelf.tableView setContentOffset:contentOffset];
                } completion: nil];
            }
        });
    }];
}

- (void)loadNextPageAfter {
    if (self.dataSource.data.count != 0 && !self.dataSource.endOfData) {
        [self.tableView showPreloaderAtTop:NO];
    }
    
    __weak typeof(self) _weakSelf = self;
    [self.dataSource loadNextPage:^(NSArray *loadedItems) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(_weakSelf) _strongSelf = _weakSelf;
            if (!loadedItems.count) {
                //[_strongSelf.tableView hidePreloaderAtTop:NO];
            } else {
                
                NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO];
                NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
                NSMutableArray *sortedEventArray = [[loadedItems sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
                //NSMutableArray *filteredTrips = [sortedEventArray mutableCopy];

                //DEL TRIPS
                if ([Configurator sharedInstance].needTripsDeleting) {
                    for (int i=0; i <= sortedEventArray.count - 1; i++) {
                        RPTrackProcessed *trip = sortedEventArray[i];

                        if (trip.tags.count != 0) {
                            //NSLog(@"TAGS COUNT %lu", (unsigned long)trip.tags.count);
                            for (RPTag *tag in trip.tags) {
                                //NSLog(@"%@", tag.tag);
                                //NSLog(@"%@", tag.source);
                                
                                if ([tag.tag isEqualToString:@"DEL"]) {
                                    [sortedEventArray removeObjectAtIndex:i];
                                } else if ([tag.tag isEqualToString:@"Personal"]) {
                                    [self.states setObject:@"Personal" forKey:trip.trackToken];
                                } else if ([tag.tag isEqualToString:@"Business"]) {
                                    [self.states setObject:@"Business" forKey:trip.trackToken];
                                } else {
                                    NSLog(@"%@",tag.source);
                                }
                            }
                        }
                    }
                }
                
                if (loadedItems.count < 10 && self.tripsData.count < self.appModel.statTrackCount.intValue) {
                    if (!self.disableReloadPageDown) {
                        self.disableReloadPageDown = YES;
                        [self.tripsData addObjectsFromArray:sortedEventArray]; //sortedEventArray
                        [self hidePreloader];
                        [_strongSelf.tableView reloadData];
                    }
                }
                
                if (!self.disableReloadPageDown) {
                    if (self.tripsData.count < self.appModel.statTrackCount.intValue) {
                        [self.tripsData addObjectsFromArray:sortedEventArray]; //sortedEventArray
                        [self hidePreloader];
                        [_strongSelf.tableView reloadData];
                    }
                }
            }
        });
    }];
}

- (void)reloadSDKTrips {
    UITabBarController *tb = (UITabBarController *)[AppDelegate appDelegate].window.rootViewController;
    if (tb.selectedIndex != [[Configurator sharedInstance].feedTabBarNumber intValue])
        return;
    
    [self showPreloader];
    
    self.tripsData = [[NSMutableArray alloc] init];
    self.states = [[NSMutableDictionary alloc] init];
    self.dataSource = [[PaginationDataSource alloc] init];
    self.disableReloadPageDown = NO;
    
    [UIView transitionWithView: self.tableView
                      duration: 0.55f
                       options: UIViewAnimationOptionTransitionCrossDissolve
                    animations: ^(void) {
                                    CGPoint contentOffset = self.tableView.contentOffset;
                                    [self.tableView reloadData];
                                    [self.tableView layoutIfNeeded];
                                    [self.tableView setContentOffset:contentOffset];
    } completion: nil];
    
    NSUInteger limit = 10;
    __weak typeof(self) _weakSelf = self;
    [self.dataSource setNextPageBlock:^(NSUInteger offset, PageLoadedBlock pageLoaded) {
        [[RPEntry instance].api getTracksWithOffset:offset limit:limit startDate:nil endDate:nil completion:^(id response, NSError *error) {
            RPFeed* feed = (RPFeed*)response;
            if (feed.tracks.count) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(_weakSelf) _strongSelf = _weakSelf;
                    _strongSelf.demoTableView.hidden = YES;
                    _strongSelf.tableView.hidden = NO;
                    [_strongSelf runCheckingFeedDemoBlock];
                });
                pageLoaded(feed.tracks);
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(_weakSelf) _strongSelf = _weakSelf;
                    _strongSelf.demoTableView.hidden = YES;
                    _strongSelf.tableView.hidden = NO;
                    [_strongSelf runCheckingFeedDemoBlock];
                    [_strongSelf hidePreloader];
                });
                pageLoaded(@[]);
            }
        }];
    }];
    [self loadLatestUserTrips];
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        NSLog(@"ALLTRIPS %lu", (unsigned long)self.tripsData.count);
        return self.tripsData.count;
    } else if (tableView == self.demoTableView) {
        return 5;
    } else {
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSInteger previousPresnetedCell = 0;
    if (indexPath.row < previousPresnetedCell) {
        //
    } else {
        CATransition *transition = [CATransition animation];
        transition.type = kCATransitionFade;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.fillMode = kCAFillModeForwards;
        transition.duration = 0.35;
        transition.subtype = kCATransitionFromTop;
        [[cell layer] addAnimation:transition forKey:@"UITableViewReloadDataAnimationKey"];
    }
    previousPresnetedCell = indexPath.row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FeedSlideMenuTableViewCell *cell = nil;
    cell = [self customCellAtIndexPath:indexPath];
    
    if (indexPath.row == self.tripsData.count - 1) {
        [self loadNextPageAfter];
    }
    
    NSString *tripNibName = @"TripCellMenuView";
    FeedSlideCellMenuView *menuView = [FeedSlideCellMenuView initWithNib:tripNibName bundle:nil];
    menuView.delegate = self;
    menuView.indexPath = indexPath;
    
    cell.rightMenuView = menuView;
    if (tableView == self.demoTableView)
        cell.rightMenuView = nil;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 190.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1.0;
}


#pragma mark - UITableViewDelegate Methods

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if (self.tripsData.count == 0) {
        CGPoint senderPosition = [sender convertPoint:CGPointZero toView:self.demoTableView];
        NSIndexPath *indexPath = [self.demoTableView indexPathForRowAtPoint:senderPosition];
        if (indexPath != nil && indexPath.row == 0) {
            [self openAppSystemSettings:sender];
        }
        return NO;
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue destinationViewController] isKindOfClass:[CustomLocationPickerVC class]]) {
        CustomLocationPickerVC *detailsVC = (CustomLocationPickerVC *)[segue destinationViewController];
        
        CGPoint senderPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:senderPosition];
        
        RPTrackProcessed *track = self.tripsData[indexPath.row];
        detailsVC.tripToken = track.trackToken;
        
        float rating = track.rating100;
        if (rating == 0)
            rating = track.rating*20;

        
        detailsVC.trackPointsSummary = [NSString stringWithFormat:@"%.0f", rating];
        detailsVC.trackDistanceSummary = [NSString stringWithFormat:@"%.0f", track.distance];
        
        NSDate* dateStart = track.startDate;
        NSDate* dateEnd = track.endDate;
        NSString *dateStartFormat = [dateStart dateTimeStringShort];
        NSString *dateEndFormat = [dateEnd dateTimeStringShort];
        
        if ([Configurator sharedInstance].needAmPmTime || [defaults_object(@"needDateSpecialFormat") boolValue] || [defaults_object(@"needAmPmFormat") boolValue]) {
            if ([defaults_object(@"needDateSpecialFormat") boolValue] && ![defaults_object(@"needAmPmFormat") boolValue]) {
                dateStartFormat = [dateStart dateTimeStringShortMmDd24];
                dateEndFormat = [dateEnd dateTimeStringShortMmDd24];
            } else if (![defaults_object(@"needDateSpecialFormat") boolValue] && [defaults_object(@"needAmPmFormat") boolValue]) {
                dateStartFormat = [dateStart dateTimeStringShortDdMmAmPm];
                dateEndFormat = [dateEnd dateTimeStringShortDdMmAmPm];
            } else if (![defaults_object(@"needDateSpecialFormat") boolValue] && ![defaults_object(@"needAmPmFormat") boolValue]) {
                dateStartFormat = [dateStart dateTimeStringShortDdMm24];
                dateEndFormat = [dateEnd dateTimeStringShortDdMm24];
            } else {
                dateStartFormat = [dateStart dateTimeStringShortMmDdAmPm];
                dateEndFormat = [dateEnd dateTimeStringShortMmDdAmPm];
            }
        }

            
        detailsVC.simpleStartTime = dateStartFormat;
        detailsVC.simpleEndTime = dateEndFormat;
        
        detailsVC.sortedOnlyTrips = self.tripsData;
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)showDetailsForCell:(FeedSlideMenuTableViewCell *)cell {
    //
}


#pragma mark Private Methods Custom Cell

- (FeedSlideMenuTableViewCell*)customCellAtIndexPath:(NSIndexPath*)indexPath {
    
    TripCell *cell = (TripCell*)[self.tableView dequeueReusableCellWithIdentifier:tripCellIdentifier];
    
    //MEASURES FORMATTING
    if ([defaults_object(@"needAmPmFormat") boolValue]) {
        cell.startLabel.width = 100;
        cell.endLabel.width = 100;
        cell.startAreaLabel.x = 137;
        cell.endAreaLabel.x = 137;
        if (IS_IPHONE_5 || IS_IPHONE_4) {
            cell.startLabel.width = 102;
            cell.endLabel.width = 102;
            cell.startAreaLabel.width = 172;
            cell.endAreaLabel.width = 172;
        } else if (IS_IPHONE_8P) {
            cell.startAreaLabel.width = 225;
            cell.endAreaLabel.width = 225;
        } else if (IS_IPHONE_8) {
            cell.startLabel.width = 104;
            cell.endLabel.width = 104;
        } else if (IS_IPHONE_13_PRO) {
            cell.startLabel.width = 103;
            cell.endLabel.width = 103;
            cell.startAreaLabel.width = 215;
            cell.endAreaLabel.width = 215;
        } else if (IS_IPHONE_13_PROMAX) {
            cell.startLabel.width = 103;
            cell.endLabel.width = 103;
        } else {
            cell.startAreaLabel.width = 205;
            cell.endAreaLabel.width = 205;
        }
    } else if ([defaults_object(@"needDateFormatInverse") boolValue]) {
        cell.startLabel.width = 81;
        cell.endLabel.width = 81;
        cell.startAreaLabel.x = 118;
        cell.endAreaLabel.x = 118;
        if (IS_IPHONE_5 || IS_IPHONE_4) {
            cell.startAreaLabel.width = 193;
            cell.endAreaLabel.width = 193;
        } else if (IS_IPHONE_8P) {
            cell.startAreaLabel.width = 248;
            cell.endAreaLabel.width = 248;
        } else if (IS_IPHONE_13_PROMAX) {
            cell.startLabel.width = 103;
            cell.endLabel.width = 103;
            cell.startAreaLabel.width = 244;
            cell.endAreaLabel.width = 244;
        } else {
            cell.startAreaLabel.width = 224;
            cell.endAreaLabel.width = 224;
        }
    } else {
        cell.startLabel.width = 78;
        cell.endLabel.width = 78;
        cell.startAreaLabel.x = 115;
        cell.endAreaLabel.x = 115;
        if (IS_IPHONE_5 || IS_IPHONE_4) {
            cell.startLabel.width = 80;
            cell.endLabel.width = 80;
            cell.startAreaLabel.width = 190;
            cell.endAreaLabel.width = 190;
        } else if (IS_IPHONE_8P) {
            cell.startAreaLabel.width = 260;
            cell.endAreaLabel.width = 260;
        } else if (IS_IPHONE_11) {
            cell.startLabel.width = 84;
            cell.endLabel.width = 84;
            cell.startAreaLabel.width = 240;
            cell.endAreaLabel.width = 240;
        } else if (IS_IPHONE_13_PRO) {
            cell.startLabel.width = 84;
            cell.endLabel.width = 84;
            cell.startAreaLabel.x = 119;
            cell.endAreaLabel.x = 119;
        } else if (IS_IPHONE_13_PROMAX) {
            cell.startLabel.width = 88;
            cell.endLabel.width = 88;
            cell.startAreaLabel.x = 120;
            cell.endAreaLabel.x = 120;
        } else {
            cell.startLabel.width = 88;
            cell.endLabel.width = 88;
            cell.startAreaLabel.width = 227;
            cell.endAreaLabel.width = 227;
        }
    }
    
    if (indexPath.row < [self.tripsData count]) {
        
        //cell.contentView.userInteractionEnabled = YES;
        cell.demoBackgroundImg.hidden = YES;
        cell.demoPointsImg.hidden = YES;
        
        cell.makeYourTripLbl.hidden = YES;
        cell.doNotSeeLbl.hidden = YES;
        cell.openAppPermissionLbl.hidden = YES;
        
        RPTrackProcessed* trip = self.tripsData[indexPath.row];
        NSDate* startDate = trip.startDate;
        NSDate* endDate = trip.endDate;
        
        NSString *dateStartFormat = [startDate dateTimeStringShort];
        NSString *dateEndFormat = [endDate dateTimeStringShort];
        
        if ([Configurator sharedInstance].needAmPmTime || [defaults_object(@"needDateSpecialFormat") boolValue] || [defaults_object(@"needAmPmFormat") boolValue]) {
            if ([defaults_object(@"needDateSpecialFormat") boolValue] && ![defaults_object(@"needAmPmFormat") boolValue]) {
                dateStartFormat = [startDate dateTimeStringShortMmDd24];
                dateEndFormat = [endDate dateTimeStringShortMmDd24];
            } else if (![defaults_object(@"needDateSpecialFormat") boolValue] && [defaults_object(@"needAmPmFormat") boolValue]) {
                dateStartFormat = [startDate dateTimeStringShortDdMmAmPm];
                dateEndFormat = [endDate dateTimeStringShortDdMmAmPm];
            } else if (![defaults_object(@"needDateSpecialFormat") boolValue] && ![defaults_object(@"needAmPmFormat") boolValue]) {
                dateStartFormat = [startDate dateTimeStringShortDdMm24];
                dateEndFormat = [endDate dateTimeStringShortDdMm24];
            } else {
                dateStartFormat = [startDate dateTimeStringShortMmDdAmPm];
                dateEndFormat = [endDate dateTimeStringShortMmDdAmPm];
            }
        }
        
        NSString *cityStart = [NSString stringWithFormat:@"%@", trip.cityStart];
        NSString *cityFinish = [NSString stringWithFormat:@"%@", trip.cityFinish];

        NSString *districtStart = [NSString stringWithFormat:@", %@", trip.addressStartParts.district];
        NSString *districtFinish = [NSString stringWithFormat:@", %@", trip.addressFinishParts.district];
        if ([trip.addressStartParts.district isEqualToString:@""] || trip.addressStartParts.district == nil)
            districtStart = @"";
        if ([trip.addressFinishParts.district isEqualToString:@""] || trip.addressFinishParts.district == nil)
            districtFinish = @"";
        
        NSString *areaAddrStart = [NSString stringWithFormat:@"  |  %@%@", cityStart, districtStart];
        NSString *areaAddrEnd = [NSString stringWithFormat:@"  |  %@%@", cityFinish, districtFinish];
        
        cell.startLabel.text = dateStartFormat;
        cell.endLabel.text = dateEndFormat;
        cell.startAreaLabel.text = areaAddrStart;
        cell.endAreaLabel.text = areaAddrEnd;
        
        float rating = trip.rating100;
        if (rating == 0)
            rating = trip.rating*20;
        
        cell.ecoScoringLabel.text = [NSString stringWithFormat:@"%.0f", rating];
        cell.distanceGPSLabel.text = [NSString stringWithFormat:@"%.0f", trip.distance];
        
        if (rating > 80) {
            cell.ecoScoringLabel.textColor = [Color officialGreenColor];
        } else if (rating > 60) {
            cell.ecoScoringLabel.textColor = [Color officialYellowColor];
        } else if (rating > 40) {
            cell.ecoScoringLabel.textColor = [Color officialOrangeColor];
        } else {
            cell.ecoScoringLabel.textColor = [Color officialDarkRedColor];
        }
        
        cell.driverBtn.alpha = 1.0;
        cell.driverBtn.userInteractionEnabled = YES;
        cell.driverBtn.hidden = NO;
        cell.userTripAdditionalLbl.hidden = NO;
        
        if ([defaults_object(@"demoModeEnabled") boolValue]) {
            cell.demoBackgroundImg.hidden = NO;
            cell.demoPointsImg.hidden = NO;
            
            cell.makeYourTripLbl.hidden = YES;
            cell.doNotSeeLbl.hidden = YES;
            cell.openAppPermissionLbl.hidden = YES;
            
            cell.distanceGPSLabel.hidden = YES;
            cell.userSharedTripArrowImg.hidden = YES;
            cell.ecoScoringLabel.hidden = YES;
            
            cell.startAreaLabel.hidden = YES;
            cell.endAreaLabel.hidden = YES;\
            
            cell.userInteractionEnabled = NO;
        } else {
            cell.demoBackgroundImg.hidden = YES;
            cell.demoPointsImg.hidden = YES;
            
            cell.makeYourTripLbl.hidden = YES;
            cell.doNotSeeLbl.hidden = YES;
            cell.openAppPermissionLbl.hidden = YES;
            
            cell.distanceGPSLabel.hidden = NO;
            cell.userSharedTripArrowImg.hidden = NO;
            cell.ecoScoringLabel.hidden = NO;
            
            cell.startAreaLabel.hidden = NO;
            cell.endAreaLabel.hidden = NO;
            
            cell.userInteractionEnabled = YES;
        }
        
        if (IS_IPHONE_5 || IS_IPHONE_4) {
            cell.userTripAdditionalLbl.font = [Font semibold11];
            cell.startAreaLabel.font = [Font regular11];
            cell.endAreaLabel.font = [Font regular11];
        }
        
        if ([trip.trackOriginCode isEqual:@"OriginalDriver"]) {
            [cell.driverBtn setBackgroundImage:[UIImage imageNamed:@"driver_green"] forState:UIControlStateNormal];
            cell.userTripAdditionalLbl.text = @"Driver";
        } else if ([trip.trackOriginCode isEqual:@"Passenger"] || [trip.trackOriginCode isEqual:@"Passanger"]) {
            [cell.driverBtn setBackgroundImage:[UIImage imageNamed:@"passenger_green"] forState:UIControlStateNormal];
            cell.userTripAdditionalLbl.text = @"Passenger";
        } else if ([trip.trackOriginCode isEqual:@"Bus"]) {
            [cell.driverBtn setBackgroundImage:[UIImage imageNamed:@"bus_green"] forState:UIControlStateNormal];
            cell.userTripAdditionalLbl.text = @"Bus";
        } else if ([trip.trackOriginCode isEqual:@"Motorcycle"]) {
            [cell.driverBtn setBackgroundImage:[UIImage imageNamed:@"motorcycle_green"] forState:UIControlStateNormal];
            cell.userTripAdditionalLbl.text = @"Motorcycle";
        } else if ([trip.trackOriginCode isEqual:@"Train"]) {
            [cell.driverBtn setBackgroundImage:[UIImage imageNamed:@"train_green"] forState:UIControlStateNormal];
            cell.userTripAdditionalLbl.text = @"Train";
        } else if ([trip.trackOriginCode isEqual:@"Taxi"]) {
            [cell.driverBtn setBackgroundImage:[UIImage imageNamed:@"taxi_green"] forState:UIControlStateNormal];
            cell.userTripAdditionalLbl.text = @"Taxi";
        } else if ([trip.trackOriginCode isEqual:@"Bicycle"]) {
            [cell.driverBtn setBackgroundImage:[UIImage imageNamed:@"bicycle_green"] forState:UIControlStateNormal];
            cell.userTripAdditionalLbl.text = @"Bicycle";
        } else if ([trip.trackOriginCode isEqual:@"Other"]) {
            [cell.driverBtn setBackgroundImage:[UIImage imageNamed:@"other_green"] forState:UIControlStateNormal];
            cell.userTripAdditionalLbl.text = @"Other";
        } else {
            [cell.driverBtn setBackgroundImage:[UIImage imageNamed:@"driver_green"] forState:UIControlStateNormal];
            cell.userTripAdditionalLbl.text = @"Driver";
        }

        [cell.driverBtn addTarget:self action:@selector(changeDriverOriginAction:) forControlEvents:UIControlEventTouchUpInside];
        
        //NEW TRIP TAGS SWITCHER NONE/PERSONAL/BUSINESS
        cell.tagsSwitcher = [[TagsSwitch alloc] initWithStringsArray:@[localizeString(@"None"), localizeString(@"Personal"), localizeString(@"Business")]];
        cell.tagsSwitcher.frame = CGRectMake(29, 126, 219, 34);
        cell.tagsSwitcher.cornerRadius = 17;
        cell.tagsSwitcher.font = [Font regular13Helvetica];
        
        cell.tagsSwitcher.labelTextColorOutsideSlider = [UIColor darkGrayColor];
        cell.tagsSwitcher.labelTextColorInsideSlider = [Color officialMainAppColor];
        cell.tagsSwitcher.backgroundColor = [Color officialMainAppColorAlpha];
        cell.tagsSwitcher.sliderColor = [Color officialWhiteColor];
        cell.tagsSwitcher.sliderOffset = 1.0;
        cell.tagsSwitcher.tag = indexPath.row;

        for (UIView *ds in cell.contentView.subviews) {
            if ([ds isKindOfClass:[TagsSwitch class]]) {
                [ds removeFromSuperview];
            }
        }
        [cell.contentView addSubview:cell.tagsSwitcher];

        __weak TripCell * weakCustomCell = cell;
        [cell.tagsSwitcher setPressedHandler:^(NSUInteger index) {
            NSLog(@"Did press position on first switch at index: %lu", (unsigned long)index);
            if (index == 1) {
                [self setPesonalTagAction:weakCustomCell];
            } else if (index == 2) {
                [self setBusinessTagAction:weakCustomCell];
            } else {
                [self resetNoTagAction:weakCustomCell];
            }
        }];
        
        //TELEMATICS APP TAGS BUTTON SPECIAL INTERFACE
        NSLog(@"%@", self.states);
        if ([[self.states allKeys] containsObject:trip.trackToken]) {
            NSString *tagStringValue = [self.states valueForKey:trip.trackToken];
            if ([tagStringValue isEqualToString:@"Personal"]) {
                [cell.tagsSwitcher selectIndex:1 animated:NO];
            } else if ([tagStringValue isEqualToString:@"Business"]) {
                [cell.tagsSwitcher selectIndex:2 animated:NO];
            } else {
                [cell.tagsSwitcher selectIndex:0 animated:NO];
            }
            cell.tagsSwitcher.userInteractionEnabled = YES;
            cell.tagsSwitcher.alpha = 1;
        }
        
        if ([defaults_object(@"demoModeEnabled") boolValue]) {
            cell.driverBtn.hidden = YES;
            cell.userTripAdditionalLbl.hidden = YES;
            
            cell.distanceGPSLabel.hidden = YES;
            cell.userSharedTripArrowImg.hidden = YES;
            cell.ecoScoringLabel.hidden = YES;
            
            cell.startAreaLabel.hidden = YES;
            cell.endAreaLabel.hidden = YES;
            
            cell.tagsSwitcher.userInteractionEnabled = NO;
            cell.tagsSwitcher.alpha = 0;
        }
        
        cell.kmLabel.text = localizeString(@"km");
        cell.pointsLabel.text = localizeString(@"dash_points");
        
        if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
            cell.kmLabel.text = localizeString(@"mi");
            float miles = convertKmToMiles(trip.distance);
            cell.distanceGPSLabel.text = [NSString stringWithFormat:@"%.1f", miles];
        }
        
        cell.userSharedTripAvatarImg.hidden = YES;
        cell.userTripAdditionalLbl.hidden = NO;
        if ([defaults_object(@"demoModeEnabled") boolValue]) {
            cell.driverBtn.hidden = YES;
            cell.userTripAdditionalLbl.hidden = YES;
        }
        
        [cell.tripGreenBubble setBackgroundImage:[UIImage imageNamed:@"feed_back_green"] forState:UIControlStateNormal];
        cell.dotBImg.image = [UIImage imageNamed:@"feed_round_green"];
        [cell.tripGreenBubble setTitle:localizeString(@"TRIP") forState:UIControlStateNormal];
        return cell;
        
    } else {
        
        [cell.tripGreenBubble setBackgroundImage:[UIImage imageNamed:@"feed_back_green"] forState:UIControlStateNormal];
        cell.dotBImg.image = [UIImage imageNamed:@"feed_round_green"];
        [cell.tripGreenBubble setTitle:localizeString(@"TRIP") forState:UIControlStateNormal];
        cell.tripGreenBubble.hidden = NO;

        cell.demoBackgroundImg.hidden = NO;
        cell.demoPointsImg.hidden = NO;
        
        cell.makeYourTripLbl.hidden = YES;
        cell.doNotSeeLbl.hidden = YES;
        cell.openAppPermissionLbl.hidden = YES;
        
        cell.userSharedTripAvatarImg.hidden = YES;
        cell.userTripAdditionalLbl.hidden = YES;
        cell.driverBtn.hidden = YES;
        cell.dotAImg.hidden = YES;
        cell.dotBImg.hidden = YES;

        cell.distanceGPSLabel.hidden = YES;
        cell.kmLabel.hidden = YES;
        cell.ecoScoringLabel.hidden = YES;
        cell.pointsLabel.hidden = YES;

        cell.startAreaLabel.hidden = YES;
        cell.startLabel.hidden = YES;
        cell.endAreaLabel.hidden = YES;
        cell.endLabel.hidden = YES;

        cell.userSharedTripArrowImg.hidden = YES;
        cell.tagsSwitcher.hidden = YES;
        
        if ([defaults_object(@"demoModeEnabled") boolValue]) {
            cell.userInteractionEnabled = NO;
        } else {
            cell.userInteractionEnabled = YES;
        }
        
        return cell;
    }
    return cell;
}

- (NSMutableAttributedString*)createVerifedLabelAttentionImgBefore:(NSString*)text {
    if IS_OS_12_OR_OLD
        text = @"Check App Permissions";
    NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
    imageAttachment.image = [UIImage imageNamed:@"demo_mapAlert"];
    imageAttachment.bounds = CGRectMake(-12, -5, imageAttachment.image.size.width/2.1, imageAttachment.image.size.height/2.1);
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
    NSMutableAttributedString *completeText = [[NSMutableAttributedString alloc] initWithString:@""];
    [completeText appendAttributedString:attachmentString];
    NSMutableAttributedString *textAfterIcon = [[NSMutableAttributedString alloc] initWithString:text];
    [completeText appendAttributedString:textAfterIcon];
    return completeText;
}


#pragma mark - Passenger Origin Methods

- (IBAction)changeDriverOriginAlert:(id)sender {
    
    [HapticHelper generateFeedback:FeedbackTypeImpactMedium];
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:nil
                                message:localizeString(@"passenger_title")
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesButton = [UIAlertAction
                                actionWithTitle:localizeString(@"Yes")
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction *action) {
                                    [self changeDriverOriginAction:sender];
                                }];
    UIAlertAction *noButton = [UIAlertAction
                               actionWithTitle:localizeString(@"No")
                               style:UIAlertActionStyleDestructive
                               handler:^(UIAlertAction *action) {}];
    [alert addAction:yesButton];
    [alert addAction:noButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)changeDriverOriginAction:(id)sender {
    
//    [[RPEntry instance].api getTrackOriginsWithCompletion:^(id response, NSError *error) {
//        NSLog(@"Dictionary with Driver Signature Role");
//    }];
//    return;
    
    CGPoint senderPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:senderPosition];
    
    [HapticHelper generateFeedback:FeedbackTypeImpactMedium];
    
    if (indexPath.row < [self.tripsData count]) {
        RPTrackProcessed *track = self.tripsData[indexPath.row];
        self.selectedTrackToken = track.trackToken;
        
        if ([track.trackOriginCode isEqual:@"OriginalDriver"]) {
            [signaturePopup showDriverSignaturePopup:@"OriginalDriver"];
        } else if ([track.trackOriginCode isEqual:@"Passenger"] || [track.trackOriginCode isEqual:@"Passanger"]) {
            [signaturePopup showDriverSignaturePopup:@"Passenger"];
        } else if ([track.trackOriginCode isEqual:@"Bus"]) {
            [signaturePopup showDriverSignaturePopup:@"Bus"];
        } else if ([track.trackOriginCode isEqual:@"Motorcycle"]) {
            [signaturePopup showDriverSignaturePopup:@"Motorcycle"];
        } else if ([track.trackOriginCode isEqual:@"Train"]) {
            [signaturePopup showDriverSignaturePopup:@"Train"];
        } else if ([track.trackOriginCode isEqual:@"Taxi"]) {
            [signaturePopup showDriverSignaturePopup:@"Taxi"];
        } else if ([track.trackOriginCode isEqual:@"Bicycle"]) {
            [signaturePopup showDriverSignaturePopup:@"Bicycle"];
        } else if ([track.trackOriginCode isEqual:@"Other"]) {
            [signaturePopup showDriverSignaturePopup:@"Other"];
        } else {
            [signaturePopup showDriverSignaturePopup:@"OriginalDriver"];
        }
    }
}


#pragma mark - Tag Origin Methods

- (void)resetNoTagAction:(id)sender {
    
    CGPoint senderPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:senderPosition];
    
    RPTrackProcessed *track = self.tripsData[indexPath.row];
    self.selectedTrackToken = track.trackToken;
    
    RPTag *tagPersonal = [[RPTag alloc] init];
    tagPersonal.tag = @"Personal";
    tagPersonal.source = localizeString(@"TelematicsApp");
    
    RPTag *tagBusiness = [[RPTag alloc] init];
    tagBusiness.tag = @"Business";
    tagBusiness.source = localizeString(@"TelematicsApp");
    
    [[RPEntry instance].api removeTrackTags:[[NSArray alloc] initWithObjects:tagPersonal, tagBusiness, nil] from:track.trackToken completion:^(id response, NSArray *error) {
        if ([[self.states allKeys] containsObject:track.trackToken]) {
            NSLog(@"!!!DELETE ALL TAGS COMPLETED!!!");
            [self.states removeObjectForKey:track.trackToken];
        }
    }];
}

- (void)setPesonalTagAction:(id)sender {
    
    CGPoint senderPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:senderPosition];
    
    if (indexPath.row < [self.tripsData count]) {
        RPTrackProcessed *track = self.tripsData[indexPath.row];
        self.selectedTrackToken = track.trackToken;
        
        RPTag *tagPersonal = [[RPTag alloc] init];
        tagPersonal.tag = @"Personal";
        tagPersonal.source = localizeString(@"TelematicsApp");
        
        RPTag *tagBusiness = [[RPTag alloc] init];
        tagBusiness.tag = @"Business";
        tagBusiness.source = localizeString(@"TelematicsApp");
        
        [[RPEntry instance].api removeTrackTags:[[NSArray alloc] initWithObjects:tagBusiness, nil] from:track.trackToken completion:^(id response, NSArray *error) {
            if ([[self.states allKeys] containsObject:track.trackToken]) {
                NSLog(@"!!!TAG STATE DELETE BUSINESS!!!");
                [self.states removeObjectForKey:track.trackToken];
            }
            
            [[RPEntry instance].api addTrackTags:[[NSArray alloc] initWithObjects:tagPersonal, nil] to:track.trackToken completion:^(id response, NSArray *error) {
                if (![[self.states allKeys] containsObject:track.trackToken]) {
                    NSLog(@"!!!TAG STATE PERSONAL NOW CONTAIN THIS TOKEN!!!");
                    [self.states setObject:@"Personal" forKey:track.trackToken];
                }
            }];
        }];
    }
}

- (void)setBusinessTagAction:(id)sender {
    
    CGPoint senderPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:senderPosition];
    
    RPTrackProcessed *track = self.tripsData[indexPath.row];
    self.selectedTrackToken = track.trackToken;
    
    RPTag *tagPersonal = [[RPTag alloc] init];
    tagPersonal.tag = @"Personal";
    tagPersonal.source = localizeString(@"TelematicsApp");
    
    RPTag *tagBusiness = [[RPTag alloc] init];
    tagBusiness.tag = @"Business";
    tagBusiness.source = localizeString(@"TelematicsApp");
    
    [[RPEntry instance].api removeTrackTags:[[NSArray alloc] initWithObjects:tagPersonal, nil] from:track.trackToken completion:^(id response, NSArray *error) {
        if ([[self.states allKeys] containsObject:track.trackToken]) {
            NSLog(@"!!!TAG STATE DELETE PERSONAL!!!");
            [self.states removeObjectForKey:track.trackToken];
        }
        
        [[RPEntry instance].api addTrackTags:[[NSArray alloc] initWithObjects:tagBusiness, nil] to:track.trackToken completion:^(id response, NSArray *error) {
            if (![[self.states allKeys] containsObject:track.trackToken]) {
                NSLog(@"!!!TAG STATE BUSINESS NOW CONTAIN THIS TRACK TOKEN!!!");
                [self.states setObject:@"Business" forKey:track.trackToken];
            }
        }];
    }];
}


#pragma mark - Hide Trip

- (void)cellMenuViewHideTripBtnTapped:(FeedSlideCellMenuView *)menuView {
    
    [HapticHelper generateFeedback:FeedbackTypeImpactMedium];
    RPTrackProcessed* track = self.tripsData[menuView.indexPath.row];
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:nil
                                message:localizeString(@"hide_trip")
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesButton = [UIAlertAction
                                actionWithTitle:localizeString(@"Yes")
                                style: UIAlertActionStyleDestructive
                                handler:^(UIAlertAction *action) {
                                    [self showPreloader];
        
                                    RPTag *tag = [[RPTag alloc] init];
                                    tag.tag = @"DEL";
                                    tag.source = localizeString(@"TelematicsApp");

                                    [[RPEntry instance].api addTrackTags:[[NSArray alloc] initWithObjects:tag, nil] to:track.trackToken completion:^(id response, NSArray *error) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            if ([self.tripsData count] > menuView.indexPath.row) {
                                                NSLog(@"%ld", (long)menuView.indexPath.row);
                                                NSLog(@"%lu", (unsigned long)self.tripsData.count);
                                                [self.tripsData removeObjectAtIndex:menuView.indexPath.row];
                                                [self.tableView reloadData];
                                            }
                                        });
                                    }];
        
                                    [self hidePreloader];
                                }];
    UIAlertAction *noButton = [UIAlertAction
                               actionWithTitle:localizeString(@"No")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   //no action
                               }];
    [alert addAction:yesButton];
    [alert addAction:noButton];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - Delete Trip

- (void)cellMenuViewDeleteBtnTapped:(FeedSlideCellMenuView *)menuView {
    
    [HapticHelper generateFeedback:FeedbackTypeImpactMedium];
    RPTrackProcessed* track = self.tripsData[menuView.indexPath.row];
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:nil
                                message:localizeString(@"delete_trip")
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesButton = [UIAlertAction
                                actionWithTitle:localizeString(@"Yes")
                                style: UIAlertActionStyleDestructive
                                handler:^(UIAlertAction *action) {
                                    [self showPreloader];
        
                                    if ([self.tripsData count] > menuView.indexPath.row) {
                                        NSLog(@"%ld", (long)menuView.indexPath.row);
                                        NSLog(@"%lu", (unsigned long)self.tripsData.count);
                                        [self.tripsData removeObjectAtIndex:menuView.indexPath.row];
                                        [self.tableView reloadData];
                                        
                                        [self deleteThisTripSendStatusForBackEnd:track.trackToken];
                                    }
        
                                    [self hidePreloader];
                                }];
    UIAlertAction *noButton = [UIAlertAction
                               actionWithTitle:localizeString(@"No")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   //
                               }];
    [alert addAction:yesButton];
    [alert addAction:noButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)deleteThisTripSendStatusForBackEnd:(NSString *)trackToken {
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        if (!error && [response isSuccesful]) {
            NSLog(@"Success Deleting Track");
        } else {
            NSLog(@"%@", error);
        }
    }] deleteThisTripSendStatusForBackEnd:trackToken];
}

- (IBAction)usefulTapBtn:(id)sender {
    
    [HapticHelper generateFeedback:FeedbackTypeImpactLight];
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:localizeString(@"opinion_title")
                                message:localizeString(@"opinion_message")
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction
                               actionWithTitle:localizeString(@"Ok")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                               }];
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - Feed Segment Methods

- (void)segmentChose:(NSInteger)index
{
    NSLog(@"Segment selected: %ld", index);
    self.demoTableView.hidden = YES;
    self.tableView.hidden = NO;
    
    [self.tableView setContentOffset:self.tableView.contentOffset animated:NO];
    
    if (index == 0) {
        self.disableReloadPageDown = NO;
        [self enableRefreshControl];
    } else if (index == 1) {
        self.disableReloadPageDown = YES;
        [self disableRefreshControl];
    } else if (index == 2) {
        self.disableReloadPageDown = YES;
        [self disableRefreshControl];
    } else if (index == 3) {
        self.disableReloadPageDown = YES;
        [self disableRefreshControl];
    }
    [self.tableView reloadData];
}


#pragma mark - Share Trips Methods Deprecated

- (void)cellMenuViewShareBtnTapped:(FeedSlideCellMenuView *)menuView {
    
    [HapticHelper generateFeedback:FeedbackTypeImpactMedium];
    RPTrackProcessed* event = self.tripsData[menuView.indexPath.row];
    
    NSString *mes = localizeString(@"share_trip");
    if ([event.shareType isEqual:@"Shared"]) {
        mes = localizeString(@"unshare_trip");
    }
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:nil
                                message:mes
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesButton = [UIAlertAction
                                actionWithTitle:localizeString(@"Yes")
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction *action) {
                                    [self shareTrackToFriendsNow:menuView];
                                }];
    UIAlertAction *noButton = [UIAlertAction
                               actionWithTitle:localizeString(@"No")
                               style:UIAlertActionStyleDestructive
                               handler:^(UIAlertAction *action) {}];
    [alert addAction:yesButton];
    [alert addAction:noButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)shareTrackToFriendsNow:(id)sender {
    
    CGPoint senderPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:senderPosition];
    
    RPTrackProcessed* track = self.tripsData[indexPath.row];
    
    NSString *shareStatus = @"Shared";
    NSString *shareMessage = localizeString(@"share_trip_ok");
    BOOL needShare = YES;
    if ([track.shareType isEqual:@"Shared"]) {
        shareStatus = @"NotShared";
        shareMessage = localizeString(@"unshare_trip_ok");
        needShare = NO;
    }
    
    [[RPEntry instance].api makeTrack:track.trackToken shared:needShare completion:^(id response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hidePreloader];
            NSLog(needShare ? @"YES" : @"NO");
            if (!error) {
                UIAlertController *alert = [UIAlertController
                                            alertControllerWithTitle:localizeString(@"Successful")
                                            message:shareMessage
                                            preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okButton = [UIAlertAction
                                           actionWithTitle:localizeString(@"Ok")
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action) {
                                               dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_IMMEDIATELY_04_SEC * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                   [self.tableView reloadData];
                                               });
                                           }];
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
            }
        });
        
    }];
}

- (void)cellUnshareBtnTapped:(FeedSlideCellMenuView *)menuView {
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:nil
                                message:localizeString(@"unshare_trip")
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesButton = [UIAlertAction
                                actionWithTitle:localizeString(@"Yes")
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction *action) {
                                    [self shareTrackToFriendsNow:menuView];
                                }];
    UIAlertAction *noButton = [UIAlertAction
                               actionWithTitle:localizeString(@"No")
                               style:UIAlertActionStyleDestructive
                               handler:^(UIAlertAction *action) {}];
    [alert addAction:yesButton];
    [alert addAction:noButton];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - Driver Signature Role

- (void)event1_Driver_ButtonAction:(DriverSignaturePopup *)popupView newType:(NSString *)newType button:(UIButton *)button {
    [HapticHelper generateFeedback:FeedbackTypeImpactMedium];
    [popupView.event1Btn setBackgroundImage:[UIImage imageNamed:@"driver_green"] forState:UIControlStateNormal];
    [popupView.event2Btn setBackgroundImage:[UIImage imageNamed:@"passenger_white"] forState:UIControlStateNormal];
    [popupView.event3Btn setBackgroundImage:[UIImage imageNamed:@"bus_white"] forState:UIControlStateNormal];
    [popupView.event4Btn setBackgroundImage:[UIImage imageNamed:@"motorcycle_white"] forState:UIControlStateNormal];
    [popupView.event5Btn setBackgroundImage:[UIImage imageNamed:@"train_white"] forState:UIControlStateNormal];
    [popupView.event6Btn setBackgroundImage:[UIImage imageNamed:@"taxi_white"] forState:UIControlStateNormal];
    [popupView.event7Btn setBackgroundImage:[UIImage imageNamed:@"bicycle_white"] forState:UIControlStateNormal];
    [popupView.event8Btn setBackgroundImage:[UIImage imageNamed:@"other_white"] forState:UIControlStateNormal];
    self.selectedDriverSignatureRole = @"OriginalDriver";
}

- (void)event2_Passenger_ButtonAction:(DriverSignaturePopup *)popupView newType:(NSString *)newType button:(UIButton *)button {
    [HapticHelper generateFeedback:FeedbackTypeImpactMedium];
    [popupView.event1Btn setBackgroundImage:[UIImage imageNamed:@"driver_white"] forState:UIControlStateNormal];
    [popupView.event2Btn setBackgroundImage:[UIImage imageNamed:@"passenger_green"] forState:UIControlStateNormal];
    [popupView.event3Btn setBackgroundImage:[UIImage imageNamed:@"bus_white"] forState:UIControlStateNormal];
    [popupView.event4Btn setBackgroundImage:[UIImage imageNamed:@"motorcycle_white"] forState:UIControlStateNormal];
    [popupView.event5Btn setBackgroundImage:[UIImage imageNamed:@"train_white"] forState:UIControlStateNormal];
    [popupView.event6Btn setBackgroundImage:[UIImage imageNamed:@"taxi_white"] forState:UIControlStateNormal];
    [popupView.event7Btn setBackgroundImage:[UIImage imageNamed:@"bicycle_white"] forState:UIControlStateNormal];
    [popupView.event8Btn setBackgroundImage:[UIImage imageNamed:@"other_white"] forState:UIControlStateNormal];
    self.selectedDriverSignatureRole = @"Passenger";
}

- (void)event3_Bus_ButtonAction:(DriverSignaturePopup *)popupView newType:(NSString *)newType button:(UIButton *)button {
    [HapticHelper generateFeedback:FeedbackTypeImpactMedium];
    [popupView.event1Btn setBackgroundImage:[UIImage imageNamed:@"driver_white"] forState:UIControlStateNormal];
    [popupView.event2Btn setBackgroundImage:[UIImage imageNamed:@"passenger_white"] forState:UIControlStateNormal];
    [popupView.event3Btn setBackgroundImage:[UIImage imageNamed:@"bus_green"] forState:UIControlStateNormal];
    [popupView.event4Btn setBackgroundImage:[UIImage imageNamed:@"motorcycle_white"] forState:UIControlStateNormal];
    [popupView.event5Btn setBackgroundImage:[UIImage imageNamed:@"train_white"] forState:UIControlStateNormal];
    [popupView.event6Btn setBackgroundImage:[UIImage imageNamed:@"taxi_white"] forState:UIControlStateNormal];
    [popupView.event7Btn setBackgroundImage:[UIImage imageNamed:@"bicycle_white"] forState:UIControlStateNormal];
    [popupView.event8Btn setBackgroundImage:[UIImage imageNamed:@"other_white"] forState:UIControlStateNormal];
    self.selectedDriverSignatureRole = @"Bus";
}

- (void)event4_Motorcycle_ButtonAction:(DriverSignaturePopup *)popupView newType:(NSString *)newType button:(UIButton *)button {
    [HapticHelper generateFeedback:FeedbackTypeImpactMedium];
    [popupView.event1Btn setBackgroundImage:[UIImage imageNamed:@"driver_white"] forState:UIControlStateNormal];
    [popupView.event2Btn setBackgroundImage:[UIImage imageNamed:@"passenger_white"] forState:UIControlStateNormal];
    [popupView.event3Btn setBackgroundImage:[UIImage imageNamed:@"bus_white"] forState:UIControlStateNormal];
    [popupView.event4Btn setBackgroundImage:[UIImage imageNamed:@"motorcycle_green"] forState:UIControlStateNormal];
    [popupView.event5Btn setBackgroundImage:[UIImage imageNamed:@"train_white"] forState:UIControlStateNormal];
    [popupView.event6Btn setBackgroundImage:[UIImage imageNamed:@"taxi_white"] forState:UIControlStateNormal];
    [popupView.event7Btn setBackgroundImage:[UIImage imageNamed:@"bicycle_white"] forState:UIControlStateNormal];
    [popupView.event8Btn setBackgroundImage:[UIImage imageNamed:@"other_white"] forState:UIControlStateNormal];
    self.selectedDriverSignatureRole = @"Motorcycle";
}

- (void)event5_Train_ButtonAction:(DriverSignaturePopup *)popupView newType:(NSString *)newType button:(UIButton *)button {
    [HapticHelper generateFeedback:FeedbackTypeImpactMedium];
    [popupView.event1Btn setBackgroundImage:[UIImage imageNamed:@"driver_white"] forState:UIControlStateNormal];
    [popupView.event2Btn setBackgroundImage:[UIImage imageNamed:@"passenger_white"] forState:UIControlStateNormal];
    [popupView.event3Btn setBackgroundImage:[UIImage imageNamed:@"bus_white"] forState:UIControlStateNormal];
    [popupView.event4Btn setBackgroundImage:[UIImage imageNamed:@"motorcycle_white"] forState:UIControlStateNormal];
    [popupView.event5Btn setBackgroundImage:[UIImage imageNamed:@"train_green"] forState:UIControlStateNormal];
    [popupView.event6Btn setBackgroundImage:[UIImage imageNamed:@"taxi_white"] forState:UIControlStateNormal];
    [popupView.event7Btn setBackgroundImage:[UIImage imageNamed:@"bicycle_white"] forState:UIControlStateNormal];
    [popupView.event8Btn setBackgroundImage:[UIImage imageNamed:@"other_white"] forState:UIControlStateNormal];
    self.selectedDriverSignatureRole = @"Train";
}

- (void)event6_Taxi_ButtonAction:(DriverSignaturePopup *)popupView newType:(NSString *)newType button:(UIButton *)button {
    [HapticHelper generateFeedback:FeedbackTypeImpactMedium];
    [popupView.event1Btn setBackgroundImage:[UIImage imageNamed:@"driver_white"] forState:UIControlStateNormal];
    [popupView.event2Btn setBackgroundImage:[UIImage imageNamed:@"passenger_white"] forState:UIControlStateNormal];
    [popupView.event3Btn setBackgroundImage:[UIImage imageNamed:@"bus_white"] forState:UIControlStateNormal];
    [popupView.event4Btn setBackgroundImage:[UIImage imageNamed:@"motorcycle_white"] forState:UIControlStateNormal];
    [popupView.event5Btn setBackgroundImage:[UIImage imageNamed:@"train_white"] forState:UIControlStateNormal];
    [popupView.event6Btn setBackgroundImage:[UIImage imageNamed:@"taxi_green"] forState:UIControlStateNormal];
    [popupView.event7Btn setBackgroundImage:[UIImage imageNamed:@"bicycle_white"] forState:UIControlStateNormal];
    [popupView.event8Btn setBackgroundImage:[UIImage imageNamed:@"other_white"] forState:UIControlStateNormal];
    self.selectedDriverSignatureRole = @"Taxi";
}

- (void)event7_Bicycle_ButtonAction:(DriverSignaturePopup *)popupView newType:(NSString *)newType button:(UIButton *)button {
    [HapticHelper generateFeedback:FeedbackTypeImpactMedium];
    [popupView.event1Btn setBackgroundImage:[UIImage imageNamed:@"driver_white"] forState:UIControlStateNormal];
    [popupView.event2Btn setBackgroundImage:[UIImage imageNamed:@"passenger_white"] forState:UIControlStateNormal];
    [popupView.event3Btn setBackgroundImage:[UIImage imageNamed:@"bus_white"] forState:UIControlStateNormal];
    [popupView.event4Btn setBackgroundImage:[UIImage imageNamed:@"motorcycle_white"] forState:UIControlStateNormal];
    [popupView.event5Btn setBackgroundImage:[UIImage imageNamed:@"train_white"] forState:UIControlStateNormal];
    [popupView.event6Btn setBackgroundImage:[UIImage imageNamed:@"taxi_white"] forState:UIControlStateNormal];
    [popupView.event7Btn setBackgroundImage:[UIImage imageNamed:@"bicycle_green"] forState:UIControlStateNormal];
    [popupView.event8Btn setBackgroundImage:[UIImage imageNamed:@"other_white"] forState:UIControlStateNormal];
    self.selectedDriverSignatureRole = @"Bicycle";
}

- (void)event8_Other_ButtonAction:(DriverSignaturePopup *)popupView newType:(NSString *)newType button:(UIButton *)button {
    [HapticHelper generateFeedback:FeedbackTypeImpactMedium];
    [popupView.event1Btn setBackgroundImage:[UIImage imageNamed:@"driver_white"] forState:UIControlStateNormal];
    [popupView.event2Btn setBackgroundImage:[UIImage imageNamed:@"passenger_white"] forState:UIControlStateNormal];
    [popupView.event3Btn setBackgroundImage:[UIImage imageNamed:@"bus_white"] forState:UIControlStateNormal];
    [popupView.event4Btn setBackgroundImage:[UIImage imageNamed:@"motorcycle_white"] forState:UIControlStateNormal];
    [popupView.event5Btn setBackgroundImage:[UIImage imageNamed:@"train_white"] forState:UIControlStateNormal];
    [popupView.event6Btn setBackgroundImage:[UIImage imageNamed:@"taxi_white"] forState:UIControlStateNormal];
    [popupView.event7Btn setBackgroundImage:[UIImage imageNamed:@"bicycle_white"] forState:UIControlStateNormal];
    [popupView.event8Btn setBackgroundImage:[UIImage imageNamed:@"other_green"] forState:UIControlStateNormal];
    self.selectedDriverSignatureRole = @"Other";
}

- (void)submitSignatureButtonAction:(DriverSignaturePopup *)popupView button:(UIButton *)button {
    
    UIViewController *currentTopVC = [self currentTopViewController];
    [currentTopVC showPreloader];
    
    [[RPEntry instance].api changeTrackOrigin:self.selectedDriverSignatureRole forTrackToken:self.selectedTrackToken completion:^(id response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [currentTopVC hidePreloader];
            [self->signaturePopup hideDriverSignaturePopup];
            if (!error) {
                if (self->_disableRefresh) {
                    [self reloadSDKTrips];
                } else {
                    [self reloadSDKTrips];
                }
            }
        });
    }];
}

- (void)cancelSignatureButtonAction:(DriverSignaturePopup *)popupView button:(UIButton *)button {
    [signaturePopup hideDriverSignaturePopup];
}


#pragma mark - Navigation

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

- (IBAction)settingsBtnAction:(id)sender {
    SettingsViewController *settingsVC = [[UIStoryboard storyboardWithName:@"Settings" bundle:nil] instantiateInitialViewController];
    [self presentViewController:settingsVC animated:YES completion:nil];
}

- (IBAction)chatOpenAction:(id)sender {
    //TODO
}

- (IBAction)openAppSystemSettings:(id)sender {
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [Configurator sharedInstance].telematicsSettingsOS13]];
    if IS_OS_12_OR_OLD
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [Configurator sharedInstance].telematicsSettingsOS12]];
    SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:URL];
    svc.delegate = self;
    svc.preferredControlTintColor = [Color officialMainAppColor];
    [self presentViewController:svc animated:YES completion:nil];
}

- (void)initRefreshControlSpinner {
    self.refreshController = [[UIRefreshControl alloc] init];
    self.refreshController.tintColor = [Color whiteSpinnerColor];
    [self.refreshController addTarget:self action:@selector(reloadSDKTrips) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshController];
    
    self.refreshDemoController = [[UIRefreshControl alloc] init];
    self.refreshDemoController.tintColor = [Color whiteSpinnerColor];
    [self.refreshDemoController addTarget:self action:@selector(reloadSDKTrips) forControlEvents:UIControlEventValueChanged];
    [self.demoTableView addSubview:self.refreshDemoController];
}

- (void)enableRefreshControl {
    _disableRefresh = NO;
}

- (void)disableRefreshControl {
    _disableRefresh = YES;
}

- (UIViewController *)currentTopViewController {
    UIViewController *topVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
