//
//  FeedViewController.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 11.09.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "FeedViewController.h"
#import "TripDetailsViewController.h"
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

static NSString *tripCellIdentifier = @"TripCell";

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
@property (weak, nonatomic) IBOutlet UILabel            *placeholderNoEvents;
@property (nonatomic, strong) UIRefreshControl          *refreshController;
@property (nonatomic, strong) UIRefreshControl          *refreshDemoController;
@property (assign, nonatomic) BOOL                      disableRefresh;
@property (nonatomic, assign) BOOL                      disableReloadPageDown;

@property (strong, nonatomic) TelematicsAppModel               *appModel;
@property (nonatomic, strong) NSString                  *selectedTrackToken;
@property (nonatomic, strong) NSString                  *selectedTrackPoints;
@property (nonatomic, strong) NSString                  *selectedPredicate;
@property (nonatomic, strong) NSString                  *selectedDriverSignatureRole;

@property (nonatomic, strong) PaginationDataSource      *dataSource;
@property (nonatomic, strong) NSMutableArray            *tripsData;

@end

@implementation FeedViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //INITIALIZE USER APP MODEL
    self.appModel = [TelematicsAppModel MR_findFirstByAttribute:@"current_user" withValue:@1];
    
    self.mainTitle.text = localizeString(@"feed_title");
    
    UITabBarItem *tabBarItem1 = [self.tabBarController.tabBar.items objectAtIndex:[[Configurator sharedInstance].feedTabBarNumber intValue]];
    [tabBarItem1 setImage:[[UIImage imageNamed:@"feed_unselected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem1 setSelectedImage:[[UIImage imageNamed:@"feed_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem1 setTitle:localizeString(@"feed_title")];
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    [[UIImage imageNamed:[Configurator sharedInstance].mainBackgroundImg] drawInRect:self.view.bounds];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:img];
    
    self.placeholderNoEvents.hidden = YES;
    self.placeholderNoEvents.text = localizeString(@"Make your first trip! It will appear here soon.");
    
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
    
    //START LOADING SDK TRIPS
    [self showPreloader];
    
    self.tripsData = [[NSMutableArray alloc] init];
    self.dataSource = [[PaginationDataSource alloc] init];
    NSUInteger limit = 10;

    __weak typeof(self) _weakSelf = self;
    [self.dataSource setNextPageBlock:^(NSUInteger offset, PageLoadedBlock pageLoaded) {
        [[RPEntry instance].api getTracksWithOffset:offset limit:limit startDate:nil endDate:nil completion:^(id response, NSError *error) {
            RPFeed* feed = (RPFeed*)response;
            if (feed.tracks.count) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(_weakSelf) _strongSelf = _weakSelf;
                    _strongSelf.placeholderNoEvents.hidden = YES;
                    _strongSelf.demoTableView.hidden = YES;
                    _strongSelf.tableView.hidden = NO;
                });
                pageLoaded(feed.tracks);
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(_weakSelf) _strongSelf = _weakSelf;
                    if (self.tripsData.count == 0) {
                        _strongSelf.placeholderNoEvents.hidden = YES;
                        _strongSelf.demoTableView.hidden = NO;
                        _strongSelf.tableView.hidden = YES;
                    } else {
                        _strongSelf.placeholderNoEvents.hidden = YES;
                        _strongSelf.demoTableView.hidden = YES;
                        _strongSelf.tableView.hidden = NO;
                    }
                    [_strongSelf hidePreloader];
                });
                pageLoaded(@[]);
            }
        }];
    }];
    //LOADING SDK TRIPS
    [self loadLatestUserTrips];
    
    [self displayUserInfo];
    [self initRefreshControlSpinner];
    
    self.segmentBackView.hidden = YES;
    
    UIViewController *currentTopVC = [self currentTopViewController];
    signaturePopup = [[DriverSignaturePopupDelegate alloc] initOnView:currentTopVC.view];
    signaturePopup.delegate = self;
    signaturePopup.dismissOnBackgroundTap = YES;
    
    UITapGestureRecognizer *avaTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avaTapDetect:)];
    self.avatarImg.userInteractionEnabled = YES;
    [self.avatarImg addGestureRecognizer:avaTap];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSDKTrips) name:@"reloadTripPage" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.disableReloadPageDown = NO;
    [self displayUserInfo];
    
    [[self.tabBarController.tabBar.items objectAtIndex:[[Configurator sharedInstance].feedTabBarNumber intValue]] setBadgeValue:nil];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [Color officialWhiteColor];
    self.navigationController.navigationBar.clipsToBounds = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([Configurator sharedInstance].showTrackSignatureCustomButton || [Configurator sharedInstance].showTrackTagCustomButton) {
        if ([defaults_object(@"needUpdateViewForFeedScreen") boolValue]) {
            [self reloadSDKTrips];
            defaults_set_object(@"needUpdateViewForFeedScreen", @(NO));
        }
    }
}


#pragma mark - UserInfo

- (void)displayUserInfo {
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
                    _strongSelf.placeholderNoEvents.hidden = YES;
                    _strongSelf.demoTableView.hidden = NO;
                    _strongSelf.tableView.hidden = YES;
                } else {
                    _strongSelf.placeholderNoEvents.hidden = YES;
                    _strongSelf.demoTableView.hidden = YES;
                    _strongSelf.tableView.hidden = NO;
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self hidePreloader];
                });
            } else {
                
                [self.tripsData removeAllObjects];
                
                NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO];
                NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
                NSArray *sortedEventArray = [loadedItems sortedArrayUsingDescriptors:sortDescriptors];
                NSMutableArray *filteredTrips = [[NSMutableArray alloc] init];

                //SEARCH DELETED TRIPS
                if ([Configurator sharedInstance].needTripsDeleting) {
                    for (int i=0; i <= sortedEventArray.count - 1; i++) {
                        RPTrackProcessed *trip = sortedEventArray[i];

                        if (trip.tags.count != 0) {
                            for (RPTag *tag in trip.tags) {
                                if (![tag.tag isEqualToString:@"DEL"]) {
                                    [filteredTrips addObject:trip];
                                } else {
                                    //NO ACTION
                                }
                            }
                        } else {
                            [filteredTrips addObject:trip];
                        }
                    }
                } else {
                    filteredTrips = [sortedEventArray mutableCopy];
                }

                if (loadedItems.count < 10) {
                    self.disableReloadPageDown = YES;
                }
                    
                [self.tripsData addObjectsFromArray:filteredTrips];
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
                //
            } else {
                
                NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO];
                NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
                NSArray *sortedEventArray = [loadedItems sortedArrayUsingDescriptors:sortDescriptors];
                NSMutableArray *filteredTrips = [[NSMutableArray alloc] init];

                //DELELETE TRIPS
                if ([Configurator sharedInstance].needTripsDeleting) {
                    for (int i=0; i <= sortedEventArray.count - 1; i++) {
                        RPTrackProcessed *trip = sortedEventArray[i];

                        if (trip.tags.count != 0) {
                            for (RPTag *tag in trip.tags) {
                                if (![tag.tag isEqualToString:@"DEL"]) {
                                    [filteredTrips addObject:trip];
                                } else {
                                    //NO ACTION
                                }
                            }
                        } else {
                            [filteredTrips addObject:trip];
                        }
                    }
                } else {
                    filteredTrips = [sortedEventArray mutableCopy];
                }
                
                if (loadedItems.count < 10 && self.tripsData.count < self.appModel.statTrackCount.intValue) {
                    if (!self.disableReloadPageDown) {
                        self.disableReloadPageDown = YES;
                        [self.tripsData addObjectsFromArray:filteredTrips];
                        [self hidePreloader];
                        [_strongSelf.tableView reloadData];
                    }
                }
                
                if (!self.disableReloadPageDown) {
                    if (self.tripsData.count < self.appModel.statTrackCount.intValue) {
                        [self.tripsData addObjectsFromArray:filteredTrips]; //sortedEventArray
                        [self hidePreloader];
                        [_strongSelf.tableView reloadData];
                    }
                }
            }
        });
    }];
}

- (void)reloadSDKTrips {
    UITabBarController *tmp = (UITabBarController *)[AppDelegate appDelegate].window.rootViewController;
    if (tmp.selectedIndex != [[Configurator sharedInstance].feedTabBarNumber intValue])
        return;
    
    [self showPreloader];
    
    self.tripsData = [[NSMutableArray alloc] init];
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
                    _strongSelf.placeholderNoEvents.hidden = YES;
                    _strongSelf.demoTableView.hidden = YES;
                    _strongSelf.tableView.hidden = NO;
                });
                pageLoaded(feed.tracks);
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(_weakSelf) _strongSelf = _weakSelf;
                    _strongSelf.placeholderNoEvents.hidden = YES;
                    _strongSelf.demoTableView.hidden = YES;
                    _strongSelf.tableView.hidden = NO;
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
        NSLog(@"ALLTRIPS COUNT NOW %lu", (unsigned long)self.tripsData.count);
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130.0;
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
    
    if ([segue.destinationViewController isKindOfClass:[TripDetailsViewController class]]) {
        
        CGPoint senderPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:senderPosition];
        
        TripDetailsViewController *detailsVC = segue.destinationViewController;
        
        if (indexPath.row < [self.tripsData count]) {
            
            RPTrackProcessed *selectedTrack = self.tripsData[indexPath.row];
            detailsVC.track = selectedTrack;
            detailsVC.trackToken = selectedTrack.trackToken;
            
            float rating = selectedTrack.rating100;
            if (rating == 0)
                rating = selectedTrack.rating*20;
            
            detailsVC.trackPointsSummary = [NSString stringWithFormat:@"%.0f", rating];
            detailsVC.trackDistanceSummary = [NSString stringWithFormat:@"%.0f", selectedTrack.distance];
            
            NSDate* dateStart = selectedTrack.startDate;
            NSDate* dateEnd = selectedTrack.endDate;
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

            if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
                float miles = convertKmToMiles(selectedTrack.distance);
                detailsVC.trackDistanceSummary = [NSString stringWithFormat:@"%.1f", miles];
            }

            detailsVC.simpleStartTime = dateStartFormat;
            detailsVC.simpleEndTime = dateEndFormat;

            detailsVC.sortedOnlyTrips = self.tripsData;

            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
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

    if ([defaults_object(@"needAmPmFormat") boolValue]) {
        cell.startLabel.width = 96;
        cell.endLabel.width = 96;
        cell.startAreaLabel.x = 137;
        cell.endAreaLabel.x = 137;
        if (IS_IPHONE_5 || IS_IPHONE_4) {
            cell.startAreaLabel.width = 170;
            cell.endAreaLabel.width = 170;
        } else if (IS_IPHONE_8P) {
            cell.startAreaLabel.width = 225;
            cell.endAreaLabel.width = 225;
        } else {
            cell.startAreaLabel.width = 205;
            cell.endAreaLabel.width = 205;
        }
    } else if ([defaults_object(@"needDateSpecialFormat") boolValue]) {
        cell.startLabel.width = 77;
        cell.endLabel.width = 77;
        cell.startAreaLabel.x = 118;
        cell.endAreaLabel.x = 118;
        if (IS_IPHONE_5 || IS_IPHONE_4) {
            cell.startAreaLabel.width = 189;
            cell.endAreaLabel.width = 189;
        } else if (IS_IPHONE_8P) {
            cell.startAreaLabel.width = 244;
            cell.endAreaLabel.width = 244;
        } else {
            cell.startAreaLabel.width = 224;
            cell.endAreaLabel.width = 224;
        }
    } else {
        cell.startLabel.width = 74;
        cell.endLabel.width = 74;
        cell.startAreaLabel.x = 115;
        cell.endAreaLabel.x = 115;
        if (IS_IPHONE_5 || IS_IPHONE_4) {
            cell.startAreaLabel.width = 192;
            cell.endAreaLabel.width = 192;
        } else if (IS_IPHONE_8P) {
            cell.startAreaLabel.width = 247;
            cell.endAreaLabel.width = 247;
        } else {
            cell.startAreaLabel.width = 227;
            cell.endAreaLabel.width = 227;
        }
    }
    
    if (indexPath.row < [self.tripsData count]) {
        
        cell.userInteractionEnabled = YES;
        cell.demoBackgroundImg.hidden = YES;
        cell.demoPointsImg.hidden = YES;
        cell.demoCenterImg.hidden = YES;
        
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
        
        [cell.userTripNameBtn setBackgroundImage:[UIImage imageNamed:@"feed_back_green"] forState:UIControlStateNormal];
        
        if ([Configurator sharedInstance].showTrackSignatureCustomButton) {
            
            cell.driverBtn.alpha = 1.0;
            cell.driverBtn.userInteractionEnabled = YES;
            cell.driverBtn.hidden = NO;
            cell.userTripAdditionalLbl.hidden = NO;
            if (IS_IPHONE_5 || IS_IPHONE_4)
                cell.userTripAdditionalLbl.font = [Font semibold11];

            if ([trip.trackOriginCode isEqual:@"OriginalDriver"]) {
                [cell.driverBtn setBackgroundImage:[UIImage imageNamed:@"driver_green"] forState:UIControlStateNormal];
                cell.userTripAdditionalLbl.text = @"Driver";
            } else if ([trip.trackOriginCode isEqual:@"Passanger"]) {
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
            
        } else {
            
            if ([Configurator sharedInstance].showTrackTagCustomButton) {
                
                //ONLY TAGS SWITCHER
                cell.driverBtn.alpha = 0.0;
                cell.driverBtn.userInteractionEnabled = NO;
                cell.driverBtn.hidden = YES;
                cell.userTripAdditionalLbl.hidden = YES;
                
                cell.driverSwitcher = [[TagsSwitch alloc] initWithStringsArray:@[localizeString(@"Personal"), localizeString(@"Business")]];
                cell.driverSwitcher.frame = CGRectMake(23, 32, 134, 26);
                cell.driverSwitcher.cornerRadius = 13;
                cell.driverSwitcher.font = [Font regular12Helvetica];
                if (IS_IPHONE_5 || IS_IPHONE_4) {
                    cell.driverSwitcher.frame = CGRectMake(15, 37, 88, 18);
                    cell.driverSwitcher.cornerRadius = 9;
                    cell.driverSwitcher.font = [Font light8Helvetica];
                }
                cell.driverSwitcher.labelTextColorOutsideSlider = [UIColor darkGrayColor];
                cell.driverSwitcher.labelTextColorInsideSlider = [Color officialMainAppColor];
                cell.driverSwitcher.backgroundColor = [Color officialMainAppColorAlpha];
                cell.driverSwitcher.sliderColor = [Color officialWhiteColor];
                cell.driverSwitcher.sliderOffset = 1.0;
                cell.driverSwitcher.tag = indexPath.row;

                for (UIView *ds in cell.contentView.subviews) {
                    if ([ds isKindOfClass:[TagsSwitch class]]) {
                        [ds removeFromSuperview];
                    }
                }
                [cell.contentView addSubview:cell.driverSwitcher];

                __weak TripCell * weakCustomCell = cell;
                [cell.driverSwitcher setPressedHandler:^(NSUInteger index) {
                    NSLog(@"Did press position on first switch at index: %lu", (unsigned long)index);
                    if (index == 1) {
                        [self changeTagAction:weakCustomCell];
                    } else {
                        [self resetTagAction:weakCustomCell];
                    }
                }];

                if (trip.tags.count != 0) {
                    for (RPTag *tag in trip.tags) {
                        NSLog(@"TAG finded %@ | %@", tag.tag, tag.source);
                        if ([tag.tag isEqualToString:@"Business"]) {
                            [cell.driverSwitcher selectIndex:1 animated:NO];
                            cell.driverSwitcher.userInteractionEnabled = YES;
                            cell.driverSwitcher.alpha = 1;
                        }
                    }
                }
            }
        }
        
        cell.kmLabel.text = localizeString(@"km");
        cell.pointsLabel.text = localizeString(@"dash_points");
        
        if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
            cell.kmLabel.text = localizeString(@"mi");
            float miles = convertKmToMiles(trip.distance);
            cell.distanceGPSLabel.text = [NSString stringWithFormat:@"%.1f", miles];
        }
        
        return cell;
        
    } else {
        
        [cell.userTripNameBtn setBackgroundImage:[UIImage imageNamed:@"feed_back_green"] forState:UIControlStateNormal];
        cell.dotBImg.image = [UIImage imageNamed:@"feed_round_green"];

        [cell.userTripNameBtn setTitle:localizeString(@"TRIP") forState:UIControlStateNormal];

        if (indexPath.row == 0) {
            cell.demoCenterImg.hidden = NO;
            cell.demoBackgroundImg.hidden = YES;
            cell.demoPointsImg.hidden = YES;
        } else {
            cell.demoCenterImg.hidden = YES;
            cell.demoBackgroundImg.hidden = NO;
            cell.demoPointsImg.hidden = NO;
        }
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

        cell.userInteractionEnabled = YES;
        
        return cell;
    }
    return cell;
}

- (void)cellMenuViewFlagBtnTapped:(FeedSlideCellMenuView *)menuView {
    // No action
}


#pragma mark - Passenger Origin Methods

- (IBAction)changeDriverOriginAlert:(id)sender {
    
    [HapticHelper generateFeedback:FeedbackTypeImpactMedium];
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:nil
                                message:localizeString(@"passanger_title")
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
    
    CGPoint senderPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:senderPosition];
    
    [HapticHelper generateFeedback:FeedbackTypeImpactMedium];
    
    if (indexPath.row < [self.tripsData count]) {
        RPTrackProcessed *track = self.tripsData[indexPath.row];
        self.selectedTrackToken = track.trackToken;
        
        if ([track.trackOriginCode isEqual:@"OriginalDriver"]) {
            [signaturePopup showDriverSignaturePopup:@"OriginalDriver"];
        } else if ([track.trackOriginCode isEqual:@"Passanger"]) {
            [signaturePopup showDriverSignaturePopup:@"Passanger"];
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

- (IBAction)changeTagOriginAlert:(id)sender {
    
    [HapticHelper generateFeedback:FeedbackTypeImpactMedium];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:localizeString(@"passanger_tag_title")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *personalAction = [UIAlertAction actionWithTitle:localizeString(@"Personal") style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action) {
        [self resetTagAction:sender];
    }];
    UIAlertAction *setTagAction = [UIAlertAction actionWithTitle:localizeString(@"TelematicsApp") style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action) {
        [self changeTagAction:sender];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:localizeString(@"Cancel") style:UIAlertActionStyleCancel
    handler:^(UIAlertAction *action) {
        
    }];
    [alert addAction:personalAction];
    [alert addAction:setTagAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:NO completion:nil];
}

- (void)changeTagAction:(id)sender {
    
    CGPoint senderPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:senderPosition];
    
    RPTrackProcessed *track = self.tripsData[indexPath.row];
    self.selectedTrackToken = track.trackToken;
    
    [self showPreloader];
    
    RPTag *tag = [[RPTag alloc] init];
    tag.tag = @"Business";
    tag.source = @"TelematicsApp";
    
    [[RPEntry instance].api addTrackTags:[[NSArray alloc] initWithObjects:tag, nil] to:track.trackToken completion:^(id response, NSArray *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadSDKTrips];
        });
    }];
    [self hidePreloader];
}

- (void)resetTagAction:(id)sender {
    
    CGPoint senderPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:senderPosition];
    
    RPTrackProcessed *track = self.tripsData[indexPath.row];
    self.selectedTrackToken = track.trackToken;
    
    [self showPreloader];
    
    RPTag *tag = [[RPTag alloc] init];
    tag.tag = @"Business";
    tag.source = @"TelematicsApp";
    
    [[RPEntry instance].api removeTrackTags:[[NSArray alloc] initWithObjects:tag, nil] from:track.trackToken completion:^(id response, NSArray *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadSDKTrips];
        });
    }];
    [self hidePreloader];
}


#pragma mark - Delete Track Methods

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
        
                                    RPTag *tag = [[RPTag alloc] init];
                                    tag.tag = @"DEL";
                                    tag.source = @"TelematicsApp";

                                    [[RPEntry instance].api addTrackTags:[[NSArray alloc] initWithObjects:tag, nil] to:track.trackToken completion:^(id response, NSArray *error) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            if ([self.tripsData count] > menuView.indexPath.row) {
                                                [self.tripsData removeObjectAtIndex:menuView.indexPath.row];
                                                [self.tableView reloadData];
                                                
                                                [self deleteTrackSendStatusForBackEnd:track.trackToken];
                                            }
                                        });
                                    }];
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
- (void)deleteTrackSendStatusForBackEnd:(NSString *)tk {
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        if (!error && [response isSuccesful]) {
            //
        } else {
            //
        }
    }] deleteTrackSendStatusForBackEnd:tk];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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
    //
}

- (IBAction)openAppSystemSettings:(id)sender {
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [Configurator sharedInstance].telematicsSettingsOS13]];
    if IS_OS_13_OR_OLD
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [Configurator sharedInstance].telematicsSettingsOS12]];
    SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:URL];
    svc.delegate = self;
    svc.preferredControlTintColor = [Color officialGreenColor];
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

- (UIViewController *)currentTopViewController {
    UIViewController *topVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}


#pragma mark - Driver Signature

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
    self.selectedDriverSignatureRole = @"Passanger";
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
    [[RPEntry instance].api changeTrackOrigin:self.selectedDriverSignatureRole forTrackToken:self.selectedTrackToken completion:^(id response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hidePreloader];
            [self->signaturePopup hideDriverSignaturePopup];
            if (!error) {
                [self reloadSDKTrips];
            }
        });
    }];
    [self hidePreloader];
}

- (void)cancelSignatureButtonAction:(DriverSignaturePopup *)popupView button:(UIButton *)button {
    [signaturePopup hideDriverSignaturePopup];
}

@end
