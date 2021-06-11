//
//  DashMainViewController.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 28.05.19.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "DashMainViewController.h"
#import "DashboardResponse.h"
#import "EcoResponse.h"
#import "EcoIndividualResponse.h"
#import "LatestDayScoringResponse.h"
#import "LatestDayScoringResultResponse.h"
#import "DrivingDetailsResponse.h"
#import "AppDelegate.h"
#import "CoreTabBarController.h"
#import "ProfileViewController.h"
#import "ProgressBarView.h"
#import "LineChart.h"
#import "DashLiteCell.h"
#import "UICountingLabel.h"
#import "UserActivityCell.h"
#import "SettingsViewController.h"
#import "SystemServices.h"
#import "WiFiGPSChecker.h"
#import "UIViewController+Preloader.h"
#import "UIImageView+WebCache.h"
#import "GeneralPopupDelegate.h"
#import "CongratulationsPopupDelegate.h"
#import "TelematicsAppPrivacyRequestManager.h"
#import "TelematicsAppLocationAccessor.h"
#import "HapticHelper.h"
#import "CMTabbarView.h"
#import "Helpers.h"
#import "Format.h"
#import "NSDate+UI.h"
#import "NSDate+ISO8601.h"
#import "TelematicsAppCollapsibleConstraints.h"
#import "UIImage+FixOrientation.h"
#import <StoreKit/StoreKit.h>
#import <NMAKit/NMAKit.h>


@interface DashMainViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, GeneralPopupProtocol, CongratulationsPopupProtocol, CMTabbarViewDelegate, CMTabbarViewDatasouce> {
    GeneralPopupDelegate *permissionPopup;
    CongratulationsPopupDelegate *congratulationsPopup;
}

@property (strong, nonatomic) ZenAppModel                       *appModel;
@property (strong, nonatomic) DashboardResultResponse           *dashboard;
@property (strong, nonatomic) LatestDayScoringResultResponse    *latestScoring;
@property (strong, nonatomic) DrivingDetailsResponse            *drivingDetails;
@property (strong, nonatomic) EcoResultResponse                 *eco;
@property (strong, nonatomic) EcoIndividualResultResponse       *ecoIndividual;

@property (nonatomic, weak) IBOutlet UIButton                   *showLeaderBtn;
@property (nonatomic, weak) IBOutlet UILabel                    *showLeaderLbl;
@property (nonatomic, weak) IBOutlet UILabel                    *latestScoredTripLbl;

@property (weak, nonatomic) IBOutlet UIScrollView               *mainScrollView;
@property (weak, nonatomic) IBOutlet UIView                     *mainSuperView;

@property (weak, nonatomic) IBOutlet UIView                     *mainDashboardView;
@property (weak, nonatomic) IBOutlet UIImageView                *mainBackgroundView;

@property (weak, nonatomic) IBOutlet UIView                     *needDistanceView;
@property (weak, nonatomic) IBOutlet UIImageView                *needDistanceDemoView;
@property (weak, nonatomic) IBOutlet UIView                     *needDistanceAverageStatView;
@property (weak, nonatomic) IBOutlet UILabel                    *needDistanceLabel;
@property (nonatomic) IBOutlet ProgressBarView                  *progressBarDistance;

@property (weak, nonatomic) IBOutlet UICollectionView           *collectionViewCurve;
@property (weak, nonatomic) IBOutlet UIPageControl              *curvePageCtrl;

@property (weak, nonatomic) IBOutlet UICollectionView           *collectionViewDemoCurve;
@property (weak, nonatomic) IBOutlet UIPageControl              *demoCurvePageCtrl;
@property (weak, nonatomic) IBOutlet UIImageView                *demoGraphImg;
@property (weak, nonatomic) IBOutlet UIImageView                *demoEcoScoringImg;

@property (weak, nonatomic) IBOutlet UICollectionView           *collectionViewStartAdvice;
@property (weak, nonatomic) IBOutlet UIPageControl              *pageCtrlStartAdvice;
@property (weak, nonatomic) IBOutlet UIImageView                *backImageAdvice;
@property (strong, nonatomic) NSMutableArray                    *collectionAdviceTitleArr;

@property (nonatomic, strong) IBOutlet LineChart                *chartWithDates;
@property (nonatomic, weak) IBOutlet UIButton                   *arrowUpDownBtn;
@property (assign, nonatomic) BOOL                              expanding;

@property (weak, nonatomic) IBOutlet UITableView                *tableViewChallenges;
    
@property (weak, nonatomic) IBOutlet UILabel                    *userNameLbl;
@property (weak, nonatomic) IBOutlet UIImageView                *avatarImg;

@property (weak, nonatomic) IBOutlet UICountingLabel            *totalTripsLbl;
@property (weak, nonatomic) IBOutlet UICountingLabel            *totalMileageLbl;
@property (weak, nonatomic) IBOutlet UICountingLabel            *totalTimeLbl;
@property (weak, nonatomic) IBOutlet UICountingLabel            *totalTripsMainLbl;
@property (weak, nonatomic) IBOutlet UICountingLabel            *totalMileageMainLbl;
@property (weak, nonatomic) IBOutlet UICountingLabel            *totalTimeMainLbl;
@property (nonatomic, weak) IBOutlet UIButton                   *chatButton;
@property (assign, nonatomic) BOOL                              disableCounting;
@property (assign, nonatomic) BOOL                              disableRefreshGraph;
@property (assign, nonatomic) BOOL                              disableRefreshGraphAfterResign;
@property (assign, nonatomic) BOOL                              itsNotAppFirstRun;
@property (assign, nonatomic) BOOL                              needHideLinearGraph;

//LATEST TRIP
@property (nonatomic) RPTrackProcessed                          *track;
@property (nonatomic) NSArray<NMAGeoCoordinates *>              *speedPoints;
@property (weak, nonatomic) IBOutlet UIImageView                *mapSnapshot;
@property (weak, nonatomic) IBOutlet UILabel                    *pointsLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *kmLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *timeLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *startTimeLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *endTimeLbl;

@property (weak, nonatomic) IBOutlet UIImageView                *mapDemo_snapshot;
@property (weak, nonatomic) IBOutlet UILabel                    *mapDemo_pointsLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *mapDemo_kmLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *mapDemo_startTimeLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *mapDemo_endTimeLbl;
@property (weak, nonatomic) IBOutlet UIView                     *mapDemo_noTripsView;
@property (weak, nonatomic) IBOutlet UIButton                   *mapDemo_permissBtn;

//ADDONS
@property (nonatomic, strong) NSTimer                           *alertTimer;
@property (weak, nonatomic) IBOutlet UILabel                    *scoringAvailableIn;
@property (weak, nonatomic) IBOutlet UILabel                    *driveAsYouDo;

@property (weak, nonatomic) IBOutlet UILabel                    *welcomeLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *descNeedTotalTripsLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *descNeedMileageLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *descNeedTimeDrivenLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *descNeedQuantityLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *descNeedKmLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *descNeedHoursLbl;

@property (weak, nonatomic) IBOutlet UILabel                    *descTotalTripsLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *descMileageLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *descTimeDrivenLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *descQuantityLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *descKmLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *descHoursLbl;

@property (weak, nonatomic) IBOutlet UIButton                   *mainDashCoinsBtn;
@property (weak, nonatomic) IBOutlet UILabel                    *mainDashCoinsLbl;
@property (weak, nonatomic) IBOutlet UIImageView                *mainDashCoinsImg;
@property (weak, nonatomic) IBOutlet UIImageView                *mainDashTriangleIcon;
@property (weak, nonatomic) IBOutlet UIImageView                *demo_mainDashTriangleIcon;

//ECO SCORING
@property (weak, nonatomic) IBOutlet UICollectionView           *collectionViewActivity;
@property (nonatomic, assign) CGFloat                           lastContentOffset;
@property (weak, nonatomic) IBOutlet CMTabbarView               *activityTabBarView;
@property (strong, nonatomic) NSArray                           *activityDates;
@property (nonatomic) IBOutlet ProgressBarView                  *progressBarFuel;
@property (nonatomic) IBOutlet ProgressBarView                  *progressBarTires;
@property (nonatomic) IBOutlet ProgressBarView                  *progressBarBrakes;
@property (nonatomic) IBOutlet ProgressBarView                  *progressBarCost;
@property (nonatomic) NSTimer                                   *timerFuel;
@property (nonatomic) NSTimer                                   *timerTires;
@property (nonatomic) NSTimer                                   *timerBrakes;
@property (nonatomic) NSTimer                                   *timerTravelCost;
@property (weak, nonatomic) IBOutlet UILabel                    *percentLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *tipLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *tipAdviceLbl;
@property (weak, nonatomic) IBOutlet UIImageView                *roundPercentImg;
@property (weak, nonatomic) IBOutlet UIImageView                *arrowPercentImg;
@property (weak, nonatomic) IBOutlet UIImageView                *zigzagIndividualImg;

//ECO SCORING DEMO
@property (weak, nonatomic) IBOutlet UICollectionView           *demo_collectionViewActivity;
@property (weak, nonatomic) IBOutlet CMTabbarView               *demo_activityTabBarView;
@property (strong, nonatomic) NSArray                           *demo_activityDates2;
@property (nonatomic) IBOutlet ProgressBarView                  *demo_progressBarFuel;
@property (nonatomic) IBOutlet ProgressBarView                  *demo_progressBarTires;
@property (nonatomic) IBOutlet ProgressBarView                  *demo_progressBarBrakes;
@property (nonatomic) IBOutlet ProgressBarView                  *demo_progressBarCost;
@property (nonatomic) NSTimer                                   *demo_timerFuel;
@property (nonatomic) NSTimer                                   *demo_timerTires;
@property (nonatomic) NSTimer                                   *demo_timerBrakes;
@property (nonatomic) NSTimer                                   *demo_timerTravelCost;
@property (weak, nonatomic) IBOutlet UILabel                    *demo_percentLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *demo_tipLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *demo_tipAdviceLbl;
@property (weak, nonatomic) IBOutlet UIImageView                *demo_roundPercentImg;
@property (weak, nonatomic) IBOutlet UIImageView                *demo_arrowPercentImg;
@property (weak, nonatomic) IBOutlet UIImageView                *demo_zigzagIndividualImg;

@end


@implementation DashMainViewController

@synthesize collectionViewCurve;
@synthesize collectionViewDemoCurve;
@synthesize curvePageCtrl;
@synthesize demoCurvePageCtrl;
@synthesize collectionViewStartAdvice;
@synthesize pageCtrlStartAdvice;
@synthesize progressBarDistance = _progressBarDistance;

- (ProgressBarView *)progressBarDistance {
    if (!_progressBarDistance) {
        _progressBarDistance = [[ProgressBarView alloc] initWithFrame:CGRectZero];
        _progressBarDistance.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _progressBarDistance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //INITIALIZE USER APP MODEL
    self.appModel = [ZenAppModel MR_findFirstByAttribute:@"current_user" withValue:@1];
    
    [self setupRoundViews];
    [self setupTranslation];
    [self setupTabBarTitles];
    [self setupEcoCollectionsForViews];
    
    if (!self.appModel.notFirstRunApp) {
        [self showPreloader];
        [ZenAppModel MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"current_user == 1"]];
        self.appModel = [ZenAppModel MR_createEntity];
        self.appModel.current_user = @1;
        self.appModel.notFirstRunApp = YES;
        self.appModel = [ZenAppModel MR_findFirstByAttribute:@"current_user" withValue:@1];
        
        self.disableCounting = YES;
        [self startFetchStatisticData];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.disableCounting = YES;
            [self getDashboardStatisticsData];
            [self getDashboardEcoDataAllTime];
            [self getDashboardEcoDataWeek];
            [self getDashboardEcoDataMonth];
            [self getDashboardEcoDataYear];
            [self hidePreloader];
        });
    } else {
        self.disableCounting = NO;
        [self updateDataFromCacheForDashboard];
        [self startFetchStatisticData];
    }
    
    self.progressBarDistance.barFillColor = [Color officialMainAppColor];
    [self.progressBarDistance setBarBackgroundColor:[Color lightSeparatorColor]];
    
    [self loadUserViewsDashboardMain];
    
    self.collectionViewCurve.delegate = self;
    self.collectionViewCurve.dataSource = self;
    [self.collectionViewCurve reloadData];
    
    self.collectionViewDemoCurve.delegate = self;
    self.collectionViewDemoCurve.dataSource = self;
    [self.collectionViewDemoCurve reloadData];
    
    self.collectionAdviceTitleArr = [NSMutableArray arrayWithObjects:@"1", @"2", nil];
    
    self.collectionViewStartAdvice.delegate = self;
    self.collectionViewStartAdvice.dataSource = self;
    self.pageCtrlStartAdvice.currentPageIndicatorTintColor = [Color officialMainAppColor];
    self.curvePageCtrl.currentPageIndicatorTintColor = [Color officialMainAppColor];
    self.demoCurvePageCtrl.currentPageIndicatorTintColor = [Color officialMainAppColor];
    [self.collectionViewStartAdvice reloadData];
    
    self.needDisplayAlert = YES;
    
    permissionPopup = [[GeneralPopupDelegate alloc] initOnView:self.view];
    permissionPopup.delegate = self;
    permissionPopup.dismissOnBackgroundTap = NO;
    defaults_set_object(@"permissionPopupShowing", @(NO));
    
    congratulationsPopup = [[CongratulationsPopupDelegate alloc] initOnView:self.view];
    congratulationsPopup.delegate = self;
    congratulationsPopup.dismissOnBackgroundTap = YES;
    
    UITapGestureRecognizer *avaTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avaTapDetect:)];
    self.avatarImg.userInteractionEnabled = YES;
    [self.avatarImg addGestureRecognizer:avaTap];
    
    UITapGestureRecognizer *lastTripTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lastTripTapDetect:)];
    self.mapSnapshot.userInteractionEnabled = YES;
    [self.mapSnapshot addGestureRecognizer:lastTripTap];
    
    UITapGestureRecognizer *lastDemoTripTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lastTripTapDetect:)];
    self.mapDemo_snapshot.userInteractionEnabled = YES;
    [self.mapDemo_snapshot addGestureRecognizer:lastDemoTripTap];
    
    self.mainScrollView.refreshControl = [[UIRefreshControl alloc] init];
    self.mainScrollView.refreshControl.tintColor = [Color whiteSpinnerColor];
    [self.mainScrollView.refreshControl addTarget:self action:@selector(refreshStatisticData:) forControlEvents:UIControlEventValueChanged];
    [self.mainScrollView.refreshControl setFrame:CGRectMake(5, 0, 20, 20)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInfo:) name:@"updateUserInfo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInfo:) name:@"reloadDashboardPage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self mainCheckPermissions];
    });
    
    if (IS_IPHONE_5 || IS_IPHONE_4)
        [self lowFontsForOldDevices];
    
    [curvePageCtrl setNumberOfPages:6];
    [demoCurvePageCtrl setNumberOfPages:6];
    
    [self setupEcoDemoBlock];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self displayUserInfo];
    
    if (self.appModel.detailsAllDrivingScores.count != 0) {
        if (!_itsNotAppFirstRun) {
            [self loadLinearChart:curvePageCtrl.currentPage];
            [self loadLinearChart:demoCurvePageCtrl.currentPage];
            _disableRefreshGraphAfterResign = YES;
        }
    }
    
    [self loadLastCachedEventForDashboardMap];
    [self loadOneEventForDashboardMap];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![defaults_object(@"userDoneWizard") boolValue]) {
        [self startTelematicsBtnClick:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    _itsNotAppFirstRun = YES;
}

- (void)appWillEnterForeground {
    NSLog(@"appResignEnterForeground");
    [self startFetchStatisticData];
    
    [self loadLastCachedEventForDashboardMap];
    [self loadOneEventForDashboardMap];
}

- (void)startFetchStatisticData {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.disableCounting = YES;
        [self getDashboardStatisticsData];
        [self getDashboardEcoDataAllTime];
        [self getDashboardEcoDataWeek];
        [self getDashboardEcoDataMonth];
        [self getDashboardEcoDataYear];
    });
}


#pragma mark - UserInfo fetch

- (void)displayUserInfo {
    self.userNameLbl.text = self.appModel.userFullName ? self.appModel.userFullName : @"";
    
    self.avatarImg.layer.cornerRadius = self.avatarImg.frame.size.width / 2.0;
    self.avatarImg.layer.masksToBounds = YES;
    self.avatarImg.contentMode = UIViewContentModeScaleAspectFill;
    if (self.appModel.userPhotoData != nil) {
        self.avatarImg.image = [UIImage imageWithData:self.appModel.userPhotoData];
    }
}

- (void)loadUserViewsDashboardMain {
    if ([defaults_object(@"needTrackingOnRequired") boolValue]) {
        float requiredDistance = self.appModel.statDistanceForScoring.floatValue;
        float userRealDistance = self.appModel.statSummaryDistance.floatValue;
        if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
            userRealDistance = convertKmToMiles(userRealDistance);
        }
        if (userRealDistance < requiredDistance) {
            self.mainDashboardView.hidden = YES;
            self.needDistanceView.hidden = NO;
        } else {
            self.mainDashboardView.hidden = NO;
            self.needDistanceView.hidden = YES;
        }
    } else {
        if (![defaults_object(@"userLogOuted") boolValue]) {
            self.mainDashboardView.hidden = NO;
            self.needDistanceView.hidden = YES;
        } else {
            BOOL isMotionEnabled = [[WiFiGPSChecker sharedChecker] motionAvailable];
            BOOL isGPSAuthorized = ([CLLocationManager locationServicesEnabled]
                                    && ([CLLocationManager authorizationStatus]
                                        == kCLAuthorizationStatusAuthorizedAlways));
            if (isGPSAuthorized || isMotionEnabled) {
                self.mainDashboardView.hidden = YES;
                self.needDistanceView.hidden = NO;
            } else {
                self.mainDashboardView.hidden = NO;
                self.needDistanceView.hidden = YES;
            }
        }
    }
}

- (void)updateUserInfo:(NSNotification *)notification {
    if ([[notification name] isEqualToString:@"updateUserInfo"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.userNameLbl.text = self.appModel.userFullName ? self.appModel.userFullName : @"";
            if (self.appModel.userPhotoData != nil) {
                self.avatarImg.image = [UIImage imageWithData:self.appModel.userPhotoData];
                self.avatarImg.layer.masksToBounds = YES;
                self.avatarImg.contentMode = UIViewContentModeScaleAspectFill;
            }
        });
    } else if ([[notification name] isEqualToString:@"reloadDashboardPage"]) {
        [self refreshStatisticData:nil];
    }
}


#pragma mark - Statistics

- (void)getDashboardStatisticsData {
    
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        NSLog(@"%s %@ %@", __func__, response, error);
        if (!error && [response isSuccesful]) {
            self.latestScoring = ((LatestDayScoringResponse *)response).Result;
            
            NSString *latestDateOfScoringString = self.latestScoring.LatestScoringDate;
            NSDate *latestDateOfScoring = [NSDate dateWithISO8601String:latestDateOfScoringString];
            if (latestDateOfScoring == nil) {
                latestDateOfScoring = [NSDate date];
            }
            [self fetchUserScoringsAnyway];
        } else {
            [self fetchUserScoringsAnyway];
            [self hidePreloader];
        }
    }] getLatestDayStatisticsScoring];
}

- (void)fetchUserScoringsAnyway {
    
    NSDate *currentDate = [NSDate date];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:-20];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *dateMinusNeedDays = [calendar dateByAddingComponents:dateComponents toDate:currentDate options:0];
    
    [self getDashboardStatisticsIndividualAllTime:dateMinusNeedDays endDate:currentDate];
}

- (void)getDashboardStatisticsIndividualAllTime:(NSDate *)startDate endDate:(NSDate *)endDate {
    
    NSString *sDate = [startDate dateTimeStringSpecial];
    NSString *eDate = [endDate dateTimeStringSpecial];
    
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        NSLog(@"%s %@ %@", __func__, response, error);
        if (!error && [response isSuccesful]) {
            self.dashboard = ((DashboardResponse *)response).Result;
            
            if ([[Configurator sharedInstance].needDistanceForScoringKm isEqual:@0]) {
                self.appModel.statDistanceForScoring = self.dashboard.DistanceForScoring;
                if (self.dashboard.DistanceForScoring.intValue == 0) {
                    self.appModel.statDistanceForScoring = [Configurator sharedInstance].needDistanceForScoringKm;
                }
            } else {
                self.appModel.statDistanceForScoring = [Configurator sharedInstance].needDistanceForScoringKm;
            }
            
            if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
                float miles = convertKmToMiles(self.appModel.statDistanceForScoring.floatValue);
                self.appModel.statDistanceForScoring = @(miles);
            }
            
            self.appModel.statTrackCount = self.dashboard.TripsCount;
            self.appModel.statSummaryDistance = self.dashboard.MileageKm;
            self.appModel.statSummaryDuration = self.dashboard.DrivingTime;
            
            NSDate *currentDate = [NSDate date];
            [self getDashboardScoringsIndividualOnCurrentDay:currentDate endDate:currentDate];
        } else {
            if ([[Configurator sharedInstance].needDistanceForScoringKm isEqual:@0]) {
                self.appModel.statDistanceForScoring = self.dashboard.DistanceForScoring;
                if (self.dashboard.DistanceForScoring.intValue == 0) {
                    self.appModel.statDistanceForScoring = [Configurator sharedInstance].needDistanceForScoringKm;
                }
            } else {
                self.appModel.statDistanceForScoring = [Configurator sharedInstance].needDistanceForScoringKm;
            }
            
            if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
                float miles = convertKmToMiles(self.appModel.statDistanceForScoring.floatValue);
                self.appModel.statDistanceForScoring = @(miles);
            }
            
            [self getDashboardScoringsIndividualOnCurrentDay:startDate endDate:endDate];
        }
    }] getStatisticsIndividualAllTime:sDate endDate:eDate];
}

- (void)getDashboardScoringsIndividualOnCurrentDay:(NSDate *)startDate endDate:(NSDate *)endDate {
    
    NSString *sDate = [startDate dateTimeStringSpecial];
    NSString *eDate = [endDate dateTimeStringSpecial];
    
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        NSLog(@"%s %@ %@", __func__, response, error);
        if (!error && [response isSuccesful]) {
            self.dashboard = ((DashboardResponse *)response).Result;
            
            self.appModel.detailsScoreOverall = self.dashboard.OverallScore;
            self.appModel.detailsScoreAcceleration = self.dashboard.AccelerationScore;
            self.appModel.detailsScoreDeceleration = self.dashboard.BrakingScore;
            self.appModel.detailsScorePhoneUsage = self.dashboard.DistractedScore;
            self.appModel.detailsScoreSpeeding = self.dashboard.SpeedingScore;
            self.appModel.detailsScoreTurn = self.dashboard.CorneringScore;
            
            NSString *latestDateOfScoringString = self.latestScoring.LatestScoringDate;
            NSDate *latestDateOfScoring = [NSDate dateWithISO8601String:latestDateOfScoringString];
            if (latestDateOfScoring == nil) {
                latestDateOfScoring = [NSDate date];
            }
            
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            [dateComponents setDay:-14];
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDate *dateMinus14days = [calendar dateByAddingComponents:dateComponents toDate:latestDateOfScoring options:0];
            
            [self getDashboardScoringsIndividual14daysDaily:dateMinus14days endDate:latestDateOfScoring];
        } else {
            
            self.appModel.detailsScoreOverall = @0;
            self.appModel.detailsScoreAcceleration = @0;
            self.appModel.detailsScoreDeceleration = @0;
            self.appModel.detailsScorePhoneUsage = @0;
            self.appModel.detailsScoreSpeeding = @0;
            self.appModel.detailsScoreTurn = @0;
            
            NSString *latestDateOfScoringString = self.latestScoring.LatestScoringDate;
            NSDate *latestDateOfScoring = [NSDate dateWithISO8601String:latestDateOfScoringString];
            if (latestDateOfScoring == nil) {
                latestDateOfScoring = [NSDate date];
            }
            
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            [dateComponents setDay:-14];
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDate *dateMinus14days = [calendar dateByAddingComponents:dateComponents toDate:latestDateOfScoring options:0];
            
            [self getDashboardScoringsIndividual14daysDaily:dateMinus14days endDate:latestDateOfScoring];
        }
    }] getScoringsIndividualCurrentDay:sDate endDate:eDate];
}

- (void)getDashboardScoringsIndividual14daysDaily:(NSDate *)startDate14 endDate:(NSDate *)endDate14 {
    
    NSString *sDate14 = [startDate14 dateTimeStringSpecial];
    NSString *eDate14 = [endDate14 dateTimeStringSpecial];
    
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        NSLog(@"%s %@ %@", __func__, response, error);
        if (!error && [response isSuccesful]) {
            self.drivingDetails = ((DrivingDetailsResponse *)response);
            
            self.appModel.detailsAllDrivingScores = self.drivingDetails.Result;
            [CoreDataCoordinator saveCoreDataCoordinatorContext];
            
            [self updateDataFromCacheForDashboard];
            [self hidePreloader];
            
            [self.collectionViewCurve reloadData];
            self->_disableRefreshGraphAfterResign = NO;
            [self loadLinearChart:0];
            self->_disableRefreshGraphAfterResign = YES;
            
            [self setupEcoViews];
        } else {
            [self updateDataFromCacheForDashboard];
            [self hidePreloader];
            
            [self.collectionViewCurve reloadData];
            self->_disableRefreshGraphAfterResign = NO;
            [self loadLinearChart:0];
            self->_disableRefreshGraphAfterResign = YES;
            
            [self setupEcoViews];
        }
    }] getScoringsIndividual14daysDaily:sDate14 endDate:eDate14];
}


#pragma mark - Eco Average Statistics

- (void)getDashboardEcoDataAllTime {
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        NSLog(@"%s %@ %@", __func__, response, error);
        if (!error && [response isSuccesful]) {
            self.ecoIndividual = ((EcoIndividualResponse *)response).Result;
            self.appModel.statEcoScoringFuel = self.ecoIndividual.EcoScoringFuel;
            self.appModel.statEcoScoringTyres = self.ecoIndividual.EcoScoringTyres;
            self.appModel.statEcoScoringBrakes = self.ecoIndividual.EcoScoringBrakes;
            self.appModel.statEcoScoringDepreciation = self.ecoIndividual.EcoScoringDepreciation;
            self.appModel.statEco = self.ecoIndividual.EcoScoring;
            self.appModel.statPreviousEcoScoring = self.ecoIndividual.EcoScoring;
        } else {
            self.appModel.statEcoScoringFuel = @90;
            self.appModel.statEcoScoringTyres = @90;
            self.appModel.statEcoScoringBrakes = @90;
            self.appModel.statEcoScoringDepreciation = @90;
            self.appModel.statEco = @90;
            self.appModel.statPreviousEcoScoring = @90;
        }
    }] getEcoDataAllTime];
}

- (void)getDashboardEcoDataWeek {
    NSDate *nowDate = [NSDate date];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:-7];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *dateMinus7days = [calendar dateByAddingComponents:dateComponents toDate:nowDate options:0];
    
    NSString *nowDateString = [nowDate dateTimeStringSpecial];
    NSString *minus7DateString = [dateMinus7days dateTimeStringSpecial];
    
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        NSLog(@"%s %@ %@", __func__, response, error);
        if (!error && [response isSuccesful]) {
            self.eco = ((EcoResponse *)response).Result;
            self.appModel.statWeeklyMaxSpeed = self.eco.MaxSpeedKmh;
            self.appModel.statWeeklyAverageSpeed = self.eco.AverageSpeedKmh;
            self.appModel.statWeeklyTotalKm = self.eco.MileageKm;
        }
    }] getEcoStatisticForPeriod:minus7DateString endDate:nowDateString];
}

- (void)getDashboardEcoDataMonth {
    NSDate *nowDate = [NSDate date];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:-30];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *dateMinus30days = [calendar dateByAddingComponents:dateComponents toDate:nowDate options:0];
    
    NSString *nowDateString = [nowDate dateTimeStringSpecial];
    NSString *minus30DateString = [dateMinus30days dateTimeStringSpecial];
    
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        NSLog(@"%s %@ %@", __func__, response, error);
        if (!error && [response isSuccesful]) {
            self.eco = ((EcoResponse *)response).Result;
            self.appModel.statMonthlyMaxSpeed = self.eco.MaxSpeedKmh;
            self.appModel.statMonthlyAverageSpeed = self.eco.AverageSpeedKmh;
            self.appModel.statMonthlyTotalKm = self.eco.MileageKm;
            
        }
    }] getEcoStatisticForPeriod:minus30DateString endDate:nowDateString];
}

- (void)getDashboardEcoDataYear {
    NSDate *nowDate = [NSDate date];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:-365];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *dateMinus365days = [calendar dateByAddingComponents:dateComponents toDate:nowDate options:0];
    
    NSString *nowDateString = [nowDate dateTimeStringSpecial];
    NSString *minus365DateString = [dateMinus365days dateTimeStringSpecial];
    
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        if (!error && [response isSuccesful]) {
            self.eco = ((EcoResponse *)response).Result;
            self.appModel.statYearlyMaxSpeed = self.eco.MaxSpeedKmh;
            self.appModel.statYearlyAverageSpeed = self.eco.AverageSpeedKmh;
            self.appModel.statYearlyTotalKm = self.eco.MileageKm;
            
        }
    }] getEcoStatisticForPeriod:minus365DateString endDate:nowDateString];
}


#pragma mark - Dashboard CachedData

- (void)updateDataFromCacheForDashboard {
    
    if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
        float miles = convertKmToMiles(self.appModel.statSummaryDistance.floatValue);
        self.progressBarDistance.progress = miles/self.appModel.statDistanceForScoring.floatValue;
    } else {
        self.progressBarDistance.progress = self.appModel.statSummaryDistance.floatValue/self.appModel.statDistanceForScoring.floatValue;
    }
    
    NSString *rounded = [NSString stringWithFormat:@"%.0f", self.appModel.statSummaryDistance.floatValue];
    NSString *kmLocalize = localizeString(@"km");
    if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
        float miles = convertKmToMiles(self.appModel.statSummaryDistance.floatValue);
        rounded = [NSString stringWithFormat:@"%.1f", miles];
        kmLocalize = localizeString(@"mi");
    }
    
    self.needDistanceLabel.text = [NSString stringWithFormat:@"%@%@ / %@%@", rounded, kmLocalize, self.appModel.statDistanceForScoring, kmLocalize];
    
    float tripsCount = self.appModel.statTrackCount.floatValue;
    float mileageKm = self.appModel.statSummaryDistance.floatValue;
    if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
        float miles = convertKmToMiles(mileageKm);
        mileageKm = miles;
    }
    
    float timeDriven = self.appModel.statSummaryDuration.floatValue / 60;
    
    self.totalTripsLbl.format = @"%d";
    self.totalMileageLbl.format = @"%d";
    self.totalTimeLbl.format = @"%d";
    self.totalTripsMainLbl.format = @"%d";
    self.totalMileageMainLbl.format = @"%d";
    self.totalTimeMainLbl.format = @"%d";
    
    if (_disableCounting) {
        [self.totalTripsLbl countFrom:tripsCount to:tripsCount];
        [self.totalTripsMainLbl countFrom:tripsCount to:tripsCount];
        [self.totalMileageLbl countFrom:mileageKm to:mileageKm];
        [self.totalMileageMainLbl countFrom:mileageKm to:mileageKm];
        [self.totalTimeLbl countFrom:timeDriven to:timeDriven];
        [self.totalTimeMainLbl countFrom:timeDriven to:timeDriven];
        return;
    } else {
        self.totalTripsLbl.method = UILabelCountingMethodLinear;
        [self.totalTripsLbl countFrom:0 to:tripsCount];
        
        self.totalMileageLbl.method = UILabelCountingMethodLinear;
        [self.totalMileageLbl countFrom:0 to:mileageKm];
        
        self.totalTimeLbl.method = UILabelCountingMethodLinear;
        [self.totalTimeLbl countFrom:0 to:timeDriven];
        
        self.totalTripsMainLbl.method = UILabelCountingMethodLinear;
        [self.totalTripsMainLbl countFrom:0 to:tripsCount];
        
        self.totalMileageMainLbl.method = UILabelCountingMethodLinear;
        [self.totalMileageMainLbl countFrom:0 to:mileageKm];
        
        self.totalTimeMainLbl.method = UILabelCountingMethodLinear;
        [self.totalTimeMainLbl countFrom:0 to:timeDriven];
    }
    [self.collectionViewCurve reloadData];
    _disableRefreshGraph = YES;
}


#pragma mark - Linear Chart for Dashboard

- (void)loadLinearChart:(NSInteger)type {
    
    if (_disableRefreshGraphAfterResign) {
        _disableRefreshGraphAfterResign = NO;
        return;
    }
    [_chartWithDates clearChartData];
    
    NSMutableArray* chartData = [NSMutableArray arrayWithCapacity:self.appModel.detailsAllDrivingScores.count];
    if (self.appModel.detailsAllDrivingScores.count == 0) {
        chartData = [NSMutableArray arrayWithCapacity:7];
        for (int i=0; i < 7; i++) {
            chartData[i] = [NSNumber numberWithFloat: (float)i / 55.0f + (float)(rand() % 100) / 500.0f];
        }
    } else {
        for (int i=0; i < self.appModel.detailsAllDrivingScores.count; i++) {
            
            DrivingDetailsObject *ddObj = self.appModel.detailsAllDrivingScores[i];
            NSNumber *value;
            int count = +1;
            if (type == 0 && count == 1) {
                value = ddObj.OverallScore;
            } else if (type == 1) {
                value = ddObj.AccelerationScore;
            } else if (type == 2) {
                value = ddObj.BrakingScore;
            } else if (type == 3) {
                value = ddObj.DistractedScore;
            } else if (type == 4) {
                value = ddObj.SpeedingScore;
            } else if (type == 5) {
                value = ddObj.CorneringScore;
            } else {
                value = ddObj.OverallScore;
            }
            chartData[i] = [NSNumber numberWithFloat:value.floatValue];
            if (self.appModel.detailsAllDrivingScores.count == 1) {
                chartData[i+1] = [NSNumber numberWithFloat:value.floatValue];
            }
        }
    }
    
    NSMutableArray* daysWeek = [NSMutableArray arrayWithObjects:
                                localizeString(@"Monday"),
                                localizeString(@"Tuesday"),
                                localizeString(@"Wednesday"),
                                localizeString(@"Thursday"),
                                localizeString(@"Friday"),
                                localizeString(@"Saturday"),
                                @"", nil];
    if (self.appModel.detailsAllDrivingScores.count == 0) {
        daysWeek = [NSMutableArray arrayWithObjects:localizeString(@"Monday"), localizeString(@"Tuesday"), localizeString(@"Wednesday"), localizeString(@"Thursday"), localizeString(@"Friday"), localizeString(@"Saturday"), @"", nil];
    } else {
        daysWeek = [NSMutableArray arrayWithCapacity:self.appModel.detailsAllDrivingScores.count];
        for (int i=0; i < self.appModel.detailsAllDrivingScores.count; i++) {
            
            DrivingDetailsObject *ddObj = self.appModel.detailsAllDrivingScores[i];
            NSString *currentDateValue = ddObj.CalcDate;
            if (currentDateValue == nil)
                return;
            NSDate *dateStart = [NSDate dateWithISO8601String:currentDateValue];
            NSString *dateStartFormat = [dateStart dayDateShort];
            
            if (i == self.appModel.detailsAllDrivingScores.count - 1) {
                if (self.appModel.detailsAllDrivingScores.count == 1) {
                    daysWeek[i] = dateStartFormat;
                    daysWeek[i+1] = @"";
                } else {
                    daysWeek[i] = dateStartFormat; //daysWeek[i] = @"";
                }
            } else {
                daysWeek[i] = dateStartFormat;
            }
        }
    }
    
    _chartWithDates.verticalGridStep = 4;
    if (self.appModel.detailsAllDrivingScores.count <=4 && self.appModel.detailsAllDrivingScores != nil) {
        _chartWithDates.horizontalGridStep = (int)self.appModel.detailsAllDrivingScores.count;
    } else if (self.appModel.detailsAllDrivingScores != nil) {
        _chartWithDates.horizontalGridStep = (int)self.appModel.detailsAllDrivingScores.count;
    } else {
        _chartWithDates.horizontalGridStep = 5;
    }
    
    _chartWithDates.fillColor = [[Color officialMainAppColor] colorWithAlphaComponent:0.1];
    _chartWithDates.displayDataPoint = YES;
    _chartWithDates.lineWidth = 3;
    _chartWithDates.dataPointColor = [Color officialMainAppColor];
    _chartWithDates.dataPointBackgroundColor = [Color officialMainAppColor];
    _chartWithDates.dataPointRadius = 0;
    _chartWithDates.color = [_chartWithDates.dataPointColor colorWithAlphaComponent:1.0];
    _chartWithDates.valueLabelPosition = ValueLabelLeftMirrored;
    
    _chartWithDates.fd_collapsed = NO;
    _chartWithDates.hidden = NO;
    [self.arrowUpDownBtn setImage:[UIImage imageNamed:@"curve_circle_down"] forState:UIControlStateNormal];
    
    if (self.needHideLinearGraph) {
        _chartWithDates.fd_collapsed = NO;
        _chartWithDates.hidden = NO;
        [self.arrowUpDownBtn setImage:[UIImage imageNamed:@"curve_circle_up"] forState:UIControlStateNormal];
    }
    
    _chartWithDates.labelForValue = ^(CGFloat value) {
        return [NSString stringWithFormat:@"%.f", value];
    };
    
    _chartWithDates.labelForIndex = ^(NSUInteger item) {
        return daysWeek[item];
    };
    
    [_chartWithDates setChartData:chartData];
}


#pragma mark - Graph Dashboard CollectionView

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == self.collectionViewCurve) {
        
        DashLiteCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DashLiteCell class]) forIndexPath:indexPath];
        cell.tag = indexPath.section;
        
        NSInteger numSection = indexPath.section;
        if (numSection == 0) {
            [cell loadGauge:self.appModel.detailsScoreOverall curveName:localizeString(@"dash_overall")];
            //[cell loadGauge:@90 curveName:localizeString(@"dash_overall")]; //test
        } else if (numSection == 1) {
            [cell loadGauge:self.appModel.detailsScoreAcceleration curveName:localizeString(@"dash_acceleration")];
        } else if (numSection == 2) {
            [cell loadGauge:self.appModel.detailsScoreDeceleration curveName:localizeString(@"dash_braking")];
        } else if (numSection == 3) {
            [cell loadGauge:self.appModel.detailsScorePhoneUsage curveName:localizeString(@"dash_phone")];
        } else if (numSection == 4) {
            [cell loadGauge:self.appModel.detailsScoreSpeeding curveName:localizeString(@"dash_speeding")];
        } else {
            [cell loadGauge:self.appModel.detailsScoreTurn curveName:localizeString(@"dash_cornering")];
        }
        return cell;
        
    } else if (collectionView == self.collectionViewDemoCurve) {
        
        DashLiteCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DashLiteCell class]) forIndexPath:indexPath];
        cell.tag = indexPath.section;
        
        NSInteger numSection = indexPath.section;
        if (numSection == 0) {
            [cell loadDemoGauge:@97 curveName:localizeString(@"dash_overall")];
        } else if (numSection == 1) {
            [cell loadDemoGauge:@85 curveName:localizeString(@"dash_acceleration")];
        } else if (numSection == 2) {
            [cell loadDemoGauge:@76 curveName:localizeString(@"dash_braking")];
        } else if (numSection == 3) {
            [cell loadDemoGauge:@65 curveName:localizeString(@"dash_phone")];
        } else if (numSection == 4) {
            [cell loadDemoGauge:@71 curveName:localizeString(@"dash_speeding")];
        } else {
            [cell loadDemoGauge:@90 curveName:localizeString(@"dash_cornering")];
        }
        return cell;
        
    } else if (collectionView == self.collectionViewActivity) {
        
        UserActivityCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UserActivityCell class]) forIndexPath:indexPath];
        if (indexPath.row == 0) {
            if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
                float mi1 = convertKmToMiles(self.appModel.statWeeklyAverageSpeed.floatValue);
                float mi2 = convertKmToMiles(self.appModel.statWeeklyMaxSpeed.floatValue);
                float mi3 = convertKmToMiles(self.appModel.statWeeklyTotalKm.floatValue);
                cell.averageSpeed.text = [NSString stringWithFormat:@"%.0f mi/h", mi1];
                cell.maxSpeed.text = [NSString stringWithFormat:@"%.0f mi/h", mi2];
                cell.averageTrip.text = [NSString stringWithFormat:@"%.0f mi", mi3];
            } else {
                cell.averageSpeed.text = [NSString stringWithFormat:@"%@ km/h", self.appModel.statWeeklyAverageSpeed];
                cell.maxSpeed.text = [NSString stringWithFormat:@"%@ km/h", self.appModel.statWeeklyMaxSpeed];
                cell.averageTrip.text = [NSString stringWithFormat:@"%@ km", self.appModel.statWeeklyTotalKm];
            }
        } else if (indexPath.row == 1) {
            if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
                float mi1 = convertKmToMiles(self.appModel.statMonthlyAverageSpeed.floatValue);
                float mi2 = convertKmToMiles(self.appModel.statMonthlyMaxSpeed.floatValue);
                float mi3 = convertKmToMiles(self.appModel.statMonthlyTotalKm.floatValue);
                cell.averageSpeed.text = [NSString stringWithFormat:@"%.0f mi/h", mi1];
                cell.maxSpeed.text = [NSString stringWithFormat:@"%.0f mi/h", mi2];
                cell.averageTrip.text = [NSString stringWithFormat:@"%.0f mi", mi3];
            } else {
                cell.averageSpeed.text = [NSString stringWithFormat:@"%@ km/h", self.appModel.statMonthlyAverageSpeed];
                cell.maxSpeed.text = [NSString stringWithFormat:@"%@ km/h", self.appModel.statMonthlyMaxSpeed];
                cell.averageTrip.text = [NSString stringWithFormat:@"%@ km", self.appModel.statMonthlyTotalKm];
            }
        } else if (indexPath.row == 2) {
            if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
                float mi1 = convertKmToMiles(self.appModel.statYearlyAverageSpeed.floatValue);
                float mi2 = convertKmToMiles(self.appModel.statYearlyMaxSpeed.floatValue);
                float mi3 = convertKmToMiles(self.appModel.statYearlyTotalKm.floatValue);
                cell.averageSpeed.text = [NSString stringWithFormat:@"%.0f mi/h", mi1];
                cell.maxSpeed.text = [NSString stringWithFormat:@"%.0f mi/h", mi2];
                cell.averageTrip.text = [NSString stringWithFormat:@"%.0f mi", mi3];
            } else {
                cell.averageSpeed.text = [NSString stringWithFormat:@"%@ km/h", self.appModel.statYearlyAverageSpeed];
                cell.maxSpeed.text = [NSString stringWithFormat:@"%@ km/h", self.appModel.statYearlyMaxSpeed];
                cell.averageTrip.text = [NSString stringWithFormat:@"%@ km", self.appModel.statYearlyTotalKm];
            }
        }
        return cell;
        
    } else if (collectionView == self.demo_collectionViewActivity) {
        UserActivityCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UserActivityCell class]) forIndexPath:indexPath];
        cell.averageSpeed.text = @"?";
        cell.maxSpeed.text = @"?";
        cell.averageTrip.text = @"?";
        return cell;
    } else {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
        UILabel *lbl = [cell viewWithTag:10];
        
        NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
        imageAttachment.image = [UIImage imageNamed:@"info"];
        CGFloat imageOffsetY = -2.0;
        imageAttachment.bounds = CGRectMake(-4.0, imageOffsetY, imageAttachment.image.size.width/2, imageAttachment.image.size.height/2);
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
        NSMutableAttributedString *completeText = [[NSMutableAttributedString alloc] initWithString:@""];
        [completeText appendAttributedString:attachmentString];
        
        NSNumber *numSection = [self.collectionAdviceTitleArr objectAtIndex:indexPath.section];
        NSString *totalLbl1 = localizeString(@"Users drive ");
        NSString *totalLbl2 = localizeString(@"60% safer");
        NSString *totalLbl3 = localizeString(@" with our awesome app!");
        NSString *totalMainLbl = [NSString stringWithFormat:@"%@%@%@", totalLbl1, totalLbl2, totalLbl3];
        NSString *additionalLbl = localizeString(@"Save time & money when searching for the best auto, life, home, or health insurance policy online");
        
        if (numSection.intValue == 2) {
            totalLbl1 = localizeString(@"Always listen ");
            totalLbl2 = localizeString(@"carefully");
            totalLbl3 = localizeString(@" to our advices!");
            totalMainLbl = [NSString stringWithFormat:@"%@%@%@", totalLbl1, totalLbl2, totalLbl3];
            additionalLbl = localizeString(@"Inappropriate braking behaviour has a cumulative effect on a vehicle safety systems. This leads to increased risk!");
        }
        
        NSMutableAttributedString *textAfterIcon = [[NSMutableAttributedString alloc] initWithString:totalMainLbl];
        
        NSRange mainRange = [totalMainLbl rangeOfString:totalMainLbl];
        UIFont *mainFont = [Font medium14];
        if (IS_IPHONE_5 || IS_IPHONE_4)
            mainFont = [Font medium10];
        
        [textAfterIcon addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:mainRange];
        [textAfterIcon addAttribute:NSFontAttributeName value:mainFont range:mainRange];
        
        NSRange range = [totalMainLbl rangeOfString:totalLbl2];
        [textAfterIcon addAttribute:NSForegroundColorAttributeName value:[Color officialMainAppColor] range:range];
        [textAfterIcon addAttribute:NSFontAttributeName value:[Font bold14] range:range];
        
        [completeText appendAttributedString:textAfterIcon];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.attributedText = completeText;
        
        UILabel *lbl2 = [cell viewWithTag:11];
        [lbl2 setText:additionalLbl];
        lbl2.numberOfLines = 2;
        lbl2.lineBreakMode = NSLineBreakByWordWrapping;
        [lbl2 setFont:[Font regular11]];
        
        return cell;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (collectionView == self.collectionViewCurve || collectionView == self.collectionViewDemoCurve) {
        return 6;
    } else if (collectionView == self.collectionViewActivity || collectionView == self.demo_collectionViewActivity) {
        return 1;
    } else {
        return 2;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.collectionViewCurve || collectionView == self.collectionViewDemoCurve) {
        return 1;
    } else if (collectionView == self.collectionViewActivity || collectionView == self.demo_collectionViewActivity) {
        return self.activityDates.count;
    } else {
        return 1;
    }
}


#pragma mark - Graph Dashboard Scroll

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.collectionViewCurve) {
        [self.collectionViewCurve layoutIfNeeded];
        for (DashLiteCell *cell in [self.collectionViewCurve visibleCells]) {
            NSIndexPath *indexPath = [self.collectionViewCurve indexPathForCell:cell];
            [self loadLinearChart:(long)indexPath.section];
        }
    } else if (scrollView == self.collectionViewDemoCurve) {
        [self.collectionViewDemoCurve layoutIfNeeded];
        for (DashLiteCell *cell in [self.collectionViewDemoCurve visibleCells]) {
            NSIndexPath *indexPath = [self.collectionViewDemoCurve indexPathForCell:cell];
            [self loadLinearChart:(long)indexPath.section];
        }
    }
}

- (IBAction)scrollCurveCollectionBackToPage:(id)sender {
    NSInteger firstSectionIndex = MAX(0, 1);
    NSInteger firstRowIndex = MAX(0, 1);
    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:firstRowIndex inSection:firstSectionIndex - 1];
    
    NSArray *visibleItems = [self.collectionViewCurve indexPathsForVisibleItems];
    NSIndexPath *currentItem = [visibleItems objectAtIndex:0];
    if (currentItem.section == 0) {
        NSIndexPath *backtItem = [NSIndexPath indexPathForItem:0 inSection:5];
        [self.collectionViewCurve scrollToItemAtIndexPath:backtItem atScrollPosition:UICollectionViewScrollPositionCenteredVertically | UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        [self loadLinearChart:backtItem.section];
        return;
    }
    
    NSIndexPath *backtItem = [NSIndexPath indexPathForItem:0 inSection:currentItem.section - 1];
    if (backtItem == firstIndexPath)
        return;
    
    [self.collectionViewCurve scrollToItemAtIndexPath:backtItem atScrollPosition:UICollectionViewScrollPositionCenteredVertically | UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    [self loadLinearChart:backtItem.section];
}

- (IBAction)scrollCurveCollectionNextToPage:(id)sender {
    NSInteger lastSectionIndex = MAX(0, [self.collectionViewCurve numberOfSections] - 1);
    NSInteger lastRowIndex = MAX(0, [self.collectionViewCurve numberOfItemsInSection:lastSectionIndex] - 1);
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex + 1];
    
    NSArray *visibleItems = [self.collectionViewCurve indexPathsForVisibleItems];
    if (visibleItems.count == 0) {
        return;
    }
    NSIndexPath *currentItem = [visibleItems objectAtIndex:0];
    NSIndexPath *nextItem = [NSIndexPath indexPathForItem:0 inSection:currentItem.section + 1];
    if (nextItem == lastIndexPath) {
        nextItem = [NSIndexPath indexPathForItem:0 inSection:0];
        [self.collectionViewCurve scrollToItemAtIndexPath:nextItem atScrollPosition:UICollectionViewScrollPositionCenteredVertically | UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        [self loadLinearChart:nextItem.section];
        return;
    }
    
    [self.collectionViewCurve scrollToItemAtIndexPath:nextItem atScrollPosition:UICollectionViewScrollPositionCenteredVertically | UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    [self loadLinearChart:nextItem.section];
}

- (IBAction)scrollDemoCurveCollectionBackToPage:(id)sender {
    NSInteger firstSectionIndex = MAX(0, 1);
    NSInteger firstRowIndex = MAX(0, 1);
    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:firstRowIndex inSection:firstSectionIndex - 1];
    
    NSArray *visibleItems = [self.collectionViewDemoCurve indexPathsForVisibleItems];
    NSIndexPath *currentItem = [visibleItems objectAtIndex:0];
    if (currentItem.section == 0) {
        NSIndexPath *backtItem = [NSIndexPath indexPathForItem:0 inSection:5];
        
        [self.collectionViewDemoCurve scrollToItemAtIndexPath:backtItem atScrollPosition:UICollectionViewScrollPositionCenteredVertically | UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        [self loadLinearChart:backtItem.section];
        return;
    }
    
    NSIndexPath *backtItem = [NSIndexPath indexPathForItem:0 inSection:currentItem.section - 1];
    if (backtItem == firstIndexPath)
        return;
    
    [self.collectionViewDemoCurve scrollToItemAtIndexPath:backtItem atScrollPosition:UICollectionViewScrollPositionCenteredVertically | UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    [self loadLinearChart:backtItem.section];
}

- (IBAction)scrollDemoCurveCollectionNextToPage:(id)sender {
    NSInteger lastSectionIndex = MAX(0, [self.collectionViewCurve numberOfSections] - 1);
    NSInteger lastRowIndex = MAX(0, [self.collectionViewCurve numberOfItemsInSection:lastSectionIndex] - 1);
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex + 1];
    
    NSArray *visibleItems = [self.collectionViewDemoCurve indexPathsForVisibleItems];
    if (visibleItems.count == 0) {
        return;
    }
    NSIndexPath *currentItem = [visibleItems objectAtIndex:0];
    NSIndexPath *nextItem = [NSIndexPath indexPathForItem:0 inSection:currentItem.section + 1];
    if (nextItem == lastIndexPath) {
        nextItem = [NSIndexPath indexPathForItem:0 inSection:0];
        [self.collectionViewDemoCurve scrollToItemAtIndexPath:nextItem atScrollPosition:UICollectionViewScrollPositionCenteredVertically | UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        [self loadLinearChart:nextItem.section];
        return;
    }
    
    [self.collectionViewDemoCurve scrollToItemAtIndexPath:nextItem atScrollPosition:UICollectionViewScrollPositionCenteredVertically | UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    [self loadLinearChart:nextItem.section];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.mainScrollView) {
        CGFloat y =  - scrollView.contentOffset.y - scrollView.contentInset.top;
        self.mainScrollView.layer.cornerRadius = 16;
        
        if (scrollView.contentOffset.y < 0) {
            self.mainBackgroundView.frame = CGRectMake(self.mainBackgroundView.frame.origin.x, self.mainBackgroundView.frame.origin.y, self.mainBackgroundView.frame.size.width, y + 156);
        }
    } else if (scrollView == self.collectionViewStartAdvice) {
            int index = scrollView.contentOffset.x / scrollView.frame.size.width;
            pageCtrlStartAdvice.currentPage = index;
    } else if (scrollView == self.collectionViewActivity) {
        if (self.lastContentOffset > scrollView.contentOffset.x || self.lastContentOffset < scrollView.contentOffset.x) {
            [_activityTabBarView setTabbarOffsetX:(scrollView.contentOffset.x)/self.collectionViewActivity.bounds.size.width];
        }
    } else if (scrollView == self.demo_collectionViewActivity) {
        if (self.lastContentOffset > scrollView.contentOffset.x || self.lastContentOffset < scrollView.contentOffset.x) {
            [_demo_activityTabBarView setTabbarOffsetX:(scrollView.contentOffset.x)/self.demo_collectionViewActivity.bounds.size.width];
        }
    } else if (scrollView == self.collectionViewDemoCurve) {
        float contentOffsetWhenFullyScrolledRight = self.collectionViewDemoCurve.frame.size.width * 5;
            
        if (scrollView.contentOffset.x >= (contentOffsetWhenFullyScrolledRight + 50.0f)) {
            NSIndexPath *firstIndex = [NSIndexPath indexPathForItem:0 inSection:0];
            [self.collectionViewDemoCurve scrollToItemAtIndexPath:firstIndex atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
            [self loadLinearChart:firstIndex.section];
        } else if (scrollView.contentOffset.x <= -50.0f)  {
            NSIndexPath *lastIndex = [NSIndexPath indexPathForItem:0 inSection:5];
            [self.collectionViewDemoCurve scrollToItemAtIndexPath:lastIndex atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
            [self loadLinearChart:lastIndex.section];
        }
        
        int index = scrollView.contentOffset.x / scrollView.frame.size.width;
        demoCurvePageCtrl.currentPage = index;
    } else {
        float contentOffsetWhenFullyScrolledRight = self.collectionViewCurve.frame.size.width * 5;
            
        if (scrollView.contentOffset.x >= (contentOffsetWhenFullyScrolledRight + 50.0f)) {
            NSIndexPath *firstIndex = [NSIndexPath indexPathForItem:0 inSection:0];
            [self.collectionViewCurve scrollToItemAtIndexPath:firstIndex atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
            [self loadLinearChart:firstIndex.section];
        } else if (scrollView.contentOffset.x <= -50.0f)  {
            NSIndexPath *lastIndex = [NSIndexPath indexPathForItem:0 inSection:5];
            [self.collectionViewCurve scrollToItemAtIndexPath:lastIndex atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
            [self loadLinearChart:lastIndex.section];
        }
        
        int index = scrollView.contentOffset.x / scrollView.frame.size.width;
        curvePageCtrl.currentPage = index;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.frame.size.width/1.0f, ceilf(collectionView.frame.size.height/1.0f));
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Check Permissions Timer

- (void)mainCheckPermissions {
    
    BOOL isMotionEnabled = [[WiFiGPSChecker sharedChecker] motionAvailable];
    BOOL isGPSAuthorized = ([CLLocationManager locationServicesEnabled]
                            && ([CLLocationManager authorizationStatus]
                                == kCLAuthorizationStatusAuthorizedAlways));
    
#if TARGET_IPHONE_SIMULATOR
    isMotionEnabled = YES;
#endif
    
    if (!isGPSAuthorized) {
        permissionPopup.disabledGPS = YES;
    }
    if (!isMotionEnabled) {
        permissionPopup.disabledMotion = YES;
    }
    
    //always NO if needed
    permissionPopup.disabledPush = NO;
        
    if ([defaults_object(@"needTrackingOnRequired") boolValue]) {
        
        if (permissionPopup.disabledGPS || permissionPopup.disabledMotion || permissionPopup.disabledPush) {
            self.mainDashboardView.hidden = NO;
            self.needDistanceView.hidden = YES;
            
            if ([defaults_object(@"userDoneWizard") boolValue]) {
                float requiredDistance = self.appModel.statDistanceForScoring.floatValue;
                float userRealDistance = self.appModel.statSummaryDistance.floatValue;
                if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
                    userRealDistance = convertKmToMiles(userRealDistance);
                }
                
                if (userRealDistance < requiredDistance) {
                    self.mainDashboardView.hidden = YES;
                    self.needDistanceView.hidden = NO;
                    [self updateMainConstraints];
                } else {
                    self.mainDashboardView.hidden = NO;
                    self.needDistanceView.hidden = YES;
                    [self updateMainConstraints];
                }
                [permissionPopup showPopup];
                defaults_set_object(@"permissionPopupShowing", @(YES));
            } else {
                if (!isGPSAuthorized || !isMotionEnabled) {
                    if (![defaults_object(@"permissionPopupShowing") boolValue]) {
                        if (isGPSAuthorized) {
                            self->permissionPopup.disabledGPS = NO;
                        } else {
                            self->permissionPopup.disabledGPS = YES;
                        }
                            
                        if (isMotionEnabled) {
                            self->permissionPopup.disabledMotion = NO;
                        } else {
                            self->permissionPopup.disabledMotion = YES;
                        }
                        [permissionPopup showPopup];
                        defaults_set_object(@"permissionPopupShowing", @(YES));
                    }
                }
            }
            
        } else {
            
            float requiredDistance = self.appModel.statDistanceForScoring.floatValue;
            float userRealDistance = self.appModel.statSummaryDistance.floatValue;
            if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
                userRealDistance = convertKmToMiles(userRealDistance);
            }
            
            if (userRealDistance < requiredDistance) {
                self.mainDashboardView.hidden = YES;
                self.needDistanceView.hidden = NO;
            } else {
                self.mainDashboardView.hidden = NO;
                self.needDistanceView.hidden = YES;
                [self updateMainConstraints];
            }
        }
    } else {
        if ([defaults_object(@"userDidNotNeedTrackingOnRequired") boolValue]) {
            if (permissionPopup.disabledGPS || permissionPopup.disabledMotion || permissionPopup.disabledPush) {
                self.mainDashboardView.hidden = NO;
                self.needDistanceView.hidden = YES;
                [permissionPopup showPopup];
                defaults_set_object(@"permissionPopupShowing", @(YES));
            }
        } else {
            if ([defaults_object(@"needTrackingOnRequired") boolValue]) {
                defaults_set_object(@"userDidNotNeedTrackingOnRequired", @(YES));
                
                self.mainDashboardView.hidden = NO;
                self.needDistanceView.hidden = YES;
            }
        }
    }
}

- (void)setNeedDisplayAlert:(BOOL)needDisplayAlert {
    _needDisplayAlert = needDisplayAlert;
    
    if (self.needDisplayAlert) {
        if (!self.alertTimer.isValid) {
            self.alertTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(checkAlertRunTimer) userInfo:nil repeats:YES];
        }
    } else {
        [self.alertTimer invalidate];
        self.alertTimer = nil;
    }
}

- (void)checkAlertRunTimer {
    [self timerCheckPermissions];
}

- (void)timerCheckPermissions {
    
    BOOL isMotionEnabled = [[WiFiGPSChecker sharedChecker] motionAvailable];
    BOOL isGPSAuthorized = ([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways));
    
#if TARGET_IPHONE_SIMULATOR
    isMotionEnabled = YES;
#endif
    
    if (!isGPSAuthorized || !isMotionEnabled) {
        
        self.mainDashboardView.hidden = NO;
        self.needDistanceView.hidden = YES;
        
        if ([defaults_object(@"userDoneWizard") boolValue]) {
            float requiredDistance = self.appModel.statDistanceForScoring.floatValue;
            float userRealDistance = self.appModel.statSummaryDistance.floatValue;
            if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
                userRealDistance = convertKmToMiles(userRealDistance);
            }
            
            if (userRealDistance < requiredDistance) {
                self.mainDashboardView.hidden = YES;
                self.needDistanceView.hidden = NO;
                [self updateMainConstraints];
            } else {
                self.mainDashboardView.hidden = NO;
                self.needDistanceView.hidden = YES;
                [self updateMainConstraints];
            }
            
            if (isGPSAuthorized) {
                self->permissionPopup.disabledGPS = NO;
            } else if (isMotionEnabled) {
                self->permissionPopup.disabledMotion = NO;
            }
            
            if (!isGPSAuthorized || !isMotionEnabled) {
                if (![defaults_object(@"permissionPopupShowing") boolValue]) {
                    if (isGPSAuthorized) {
                        self->permissionPopup.disabledGPS = NO;
                    } else {
                        self->permissionPopup.disabledGPS = YES;
                    }
                        
                    if (isMotionEnabled) {
                        self->permissionPopup.disabledMotion = NO;
                    } else {
                        self->permissionPopup.disabledMotion = YES;
                    }
                    [permissionPopup showPopup];
                    defaults_set_object(@"permissionPopupShowing", @(YES));
                }
            }
        } else {
            if (!isGPSAuthorized || !isMotionEnabled) {
                if (![defaults_object(@"permissionPopupShowing") boolValue]) {
                    if (isGPSAuthorized) {
                        self->permissionPopup.disabledGPS = NO;
                    } else {
                        self->permissionPopup.disabledGPS = YES;
                    }
                        
                    if (isMotionEnabled) {
                        self->permissionPopup.disabledMotion = NO;
                    } else {
                        self->permissionPopup.disabledMotion = YES;
                    }
                    
                    [permissionPopup showPopup];
                    defaults_set_object(@"permissionPopupShowing", @(YES));
                }
            }
            
            float requiredDistance = self.appModel.statDistanceForScoring.floatValue;
            float userRealDistance = self.appModel.statSummaryDistance.floatValue;
            if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
                userRealDistance = convertKmToMiles(userRealDistance);
            }
                
            if (userRealDistance < requiredDistance) {
                self.mainDashboardView.hidden = YES;
                self.needDistanceView.hidden = NO;
            } else {
                self.mainDashboardView.hidden = NO;
                self.needDistanceView.hidden = YES;
            }
            [self updateMainConstraints];
        }
        
    } else {
        
        float requiredDistance = self.appModel.statDistanceForScoring.floatValue;
        float userRealDistance = self.appModel.statSummaryDistance.floatValue;
        if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
            userRealDistance = convertKmToMiles(userRealDistance);
        }
        if (userRealDistance < requiredDistance) {
            self.mainDashboardView.hidden = YES;
            self.needDistanceView.hidden = NO;
            self->permissionPopup.disabledGPS = NO;
            [self updateMainConstraints];
        } else {
            self.mainDashboardView.hidden = NO;
            self.needDistanceView.hidden = YES;
            [self updateMainConstraints];
            
            if ([defaults_object(@"permissionPopupShowing") boolValue]) {
                [permissionPopup hidePopup];
                defaults_set_object(@"permissionPopupShowing", @(NO));
            }
            
            if (!_disableRefreshGraph) {
                [self.collectionViewCurve reloadData];
                _disableRefreshGraph = YES;
            }
            
            defaults_set_object(@"needTrackingOnRequired", @(YES));
            self->permissionPopup.disabledGPS = NO;
            
            if ([defaults_object(@"userDoneWizard") boolValue]) {
                if ([defaults_object(@"userWorkingWithPermissionsWizardNow") boolValue]) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        defaults_set_object(@"userWorkingWithPermissionsWizardNow", @(NO));
                    });
                }
            }
        }
    }
    [self->permissionPopup setupButtonGPS];
    
    if (![defaults_object(@"needShowCongratulations") boolValue]) {
        if (!permissionPopup.disabledGPS && !permissionPopup.disabledMotion && !permissionPopup.disabledPush) {
            [self->permissionPopup hidePopup];
            defaults_set_object(@"permissionPopupShowing", @(NO));
            [self->congratulationsPopup showCongratulationsPopup];
            defaults_set_object(@"needShowCongratulations", @(YES));
        }
    }
}


#pragma mark - Telematics SDK initialization on DASHBOARD

- (void)initPermissionsLocation {
    [TelematicsAppPrivacyRequestManager requestAuthorization:TelematicsAppPrivacyTypeLocationAlways handler:^(TelematicsAppAuthorizationStatus status) {
        if (status == TelematicsAppAuthorizationStatusAuthorizedAlways) {
            self->permissionPopup.disabledGPS = NO;
            [self->permissionPopup setupButtonGPS];
            
            [RPEntry initializeWithRequestingPermissions:NO];
            [RPEntry instance].virtualDeviceToken = [GeneralService sharedInstance].device_token_number;
            
            if ([Configurator sharedInstance].sdkEnableHF) {
                [RPEntry enableHF:YES];
            } else {
                [RPEntry enableHF:NO];
            }
        }
        defaults_set_object(@"needTrackingOnRequired", @(YES));
    }];
}

- (void)initPermissionsMotion {
    [TelematicsAppPrivacyRequestManager requestAuthorization:TelematicsAppPrivacyTypeMotion handler:^(TelematicsAppAuthorizationStatus status) {
        if (status == TelematicsAppAuthorizationStatusAuthorized) {
            self->permissionPopup.disabledMotion = NO;
            [self->permissionPopup setupButtonMotion];
        }
        defaults_set_object(@"needMotionOn", @(YES));
    }];
}

- (void)initPushNotifications {
    //TODO PUSH-NOTIFICATIONS
}


#pragma mark - GeneralPopup Permission Warning Actions

- (IBAction)startTelematicsBtnClick:(id)sender {
    if ([defaults_object(@"userDoneWizard") boolValue]) {
        [permissionPopup showPopup];
        defaults_set_object(@"permissionPopupShowing", @(YES));
        defaults_set_object(@"userWorkingWithPermissionsWizardNow", @(NO));
    } else {
        if (@available(iOS 13.0, *)) {
            
            defaults_set_object(@"userWorkingWithPermissionsWizardNow", @(YES));
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                defaults_set_object(@"userWorkingWithPermissionsWizardNow", @(NO));
            });
            
            [[RPCSettings returnInstance] setWizardNextButtonBgColor:[Color officialMainAppColor]];
            [[RPCSettings returnInstance] setAppName:localizeString(@"TelematicsApp")];
            
#warning TODO: Production
            [[RPCPermissionsWizard returnInstance] setupBluetoothEnabled]; //IF YOU USE ELM BLUETOOTH CONNECTION ENABLE THIS LINE FOR TELEMATICS SDK
            
            [[RPCPermissionsWizard returnInstance] launchWithFinish:^(BOOL showWizzard) {
                [RPEntry initializeWithRequestingPermissions:YES];
                [RPEntry instance].disableTracking = NO;
                [RPEntry instance].virtualDeviceToken = [GeneralService sharedInstance].device_token_number;
                
                if ([Configurator sharedInstance].sdkEnableHF) {
                    [RPEntry enableHF:YES];
                } else {
                    [RPEntry enableHF:NO];
                }
                
                defaults_set_object(@"userDoneWizard", @(YES));
                defaults_set_object(@"needTrackingOnRequired", @(YES));
            }];
            
            [[RPCPermissionsWizard returnInstance] setupHandlersWithUserNotificationResponce:^(BOOL granted, NSError * _Nullable error) {
                NSLog(@"PUSH_NOTIFICATIONS INIT SUCCESS");
                [self initPushNotifications];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    defaults_set_object(@"userWorkingWithPermissionsWizardNow", @(NO));
                });
            } motionManagerResponce:^(BOOL granted, NSError * _Nullable error) {
                NSLog(@"MOTION INIT SUCCESS");
                NSString *xs = @"Btn tapped now";
                
                switch ([CMMotionActivityManager authorizationStatus]) {
                    case CMAuthorizationStatusNotDetermined:
                    {
                        NSLog(@"NotDetermined");
                        xs = @"NotDetermined";
                        [TelematicsAppPrivacyRequestManager requestAuthorizationMotionImmediately];
                            //defaults_set_object(@"needMotionOn", @(YES));
                    }
                        break;
                    case CMAuthorizationStatusRestricted:
                    {
                        NSLog(@"Restricted");
                        xs = @"Restricted";
                        [TelematicsAppPrivacyRequestManager requestAuthorizationMotionImmediately];
                    }
                        break;
                    case CMAuthorizationStatusDenied:
                    {
                        NSLog(@"Denied");
                        xs = @"Denied";
                    }
                        break;
                    case CMAuthorizationStatusAuthorized:
                    {
                        NSLog(@"Authorized");
                        xs = @"Authorized";
                    }
                    default:
                        break;
                }
            } locationManagerResponce:^(CLAuthorizationStatus status) {
                NSLog(@"LOCATION INIT SUCCESS");
            }];
            
        } else {
            if (![defaults_object(@"permissionPopupShowing") boolValue]) {
                [permissionPopup showPopup];
                defaults_set_object(@"permissionPopupShowing", @(YES));
                defaults_set_object(@"userWorkingWithPermissionsWizardNow", @(NO));
            }
        }
    }
}

- (void)gpsButtonAction:(GeneralPopup *)popupView button:(UIButton *)button {
    if ([defaults_object(@"needTrackingOnRequired") boolValue]) {
        [TelematicsAppPrivacyRequestManager gotoApplicationSetting];
    } else {
        if ([CLLocationManager locationServicesEnabled]) {
            if (![defaults_object(@"userDoneWizard") boolValue]) {
                [self startTelematicsBtnClick:button];
            } else {
                [self initPermissionsLocation];
            }
        } else {
            [TelematicsAppPrivacyRequestManager gotoApplicationSetting];
        }
    }
}

- (void)motionButtonAction:(GeneralPopup *)popupView button:(UIButton *)button {
    switch ([CMMotionActivityManager authorizationStatus]) {
        case CMAuthorizationStatusNotDetermined:
        {
            [TelematicsAppPrivacyRequestManager requestAuthorizationMotionImmediately];
            defaults_set_object(@"needMotionOn", @(NO));
        }
            break;
        case CMAuthorizationStatusRestricted:
        {
            [TelematicsAppPrivacyRequestManager requestAuthorizationMotionImmediately];
            defaults_set_object(@"needMotionOn", @(NO));
        }
            break;
        case CMAuthorizationStatusDenied:
        {
            [TelematicsAppPrivacyRequestManager gotoApplicationSetting];
            defaults_set_object(@"needMotionOn", @(NO));
        }
            break;
        case CMAuthorizationStatusAuthorized:
        {
            defaults_set_object(@"needMotionOn", @(YES));
        }
        default:
            break;
    }
}

- (void)pushButtonAction:(GeneralPopup *)popupView button:(UIButton *)button {
    [permissionPopup hidePopup];
    defaults_set_object(@"permissionPopupShowing", @(NO));
    [TelematicsAppPrivacyRequestManager gotoApplicationSetting];
}


#pragma mark - Dashboard refresh spinner

- (void)refreshStatisticData:(id)sender {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [sender endRefreshing];
    });
    [self getDashboardStatisticsData];
    [self getDashboardEcoDataAllTime];
    [self getDashboardEcoDataWeek];
    [self getDashboardEcoDataMonth];
    [self getDashboardEcoDataYear];
    
    [self setupTranslation];
    defaults_set_object(@"LatestTripTokenTempory", @"");
    [sender endRefreshing];
}


#pragma mark - CongratulationsPopup Actions

- (IBAction)showCongratulationsPopup:(id)sender {
    [congratulationsPopup showCongratulationsPopup];
}

- (void)okButtonAction:(CongratulationsPopup *)popupView button:(UIButton *)button {
    [congratulationsPopup hideCongratulationsPopup];
}


#pragma mark - EcoScoring

- (void)setupEcoViews {
    self.progressBarFuel.progress = 0.0f;
    self.progressBarTires.progress = 0.0f;
    self.progressBarBrakes.progress = 0.0f;
    self.progressBarCost.progress = 0.0f;
    
    self.timerFuel = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(incrementProgressFuel:) userInfo:nil repeats:YES];
    self.timerTires = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(incrementProgressTires:) userInfo:nil repeats:YES];
    self.timerBrakes = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(incrementProgressBrakes:) userInfo:nil repeats:YES];
    self.timerTravelCost = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(incrementProgressTravelCost:) userInfo:nil repeats:YES];
    
    _activityTabBarView.indicatorAttributes = @{CMTabIndicatorColor:[UIColor blackColor], CMTabIndicatorViewHeight:@(2.5f), CMTabBoxBackgroundColor:[UIColor blackColor]};
    _activityTabBarView.normalAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:10.0f]};
    _activityTabBarView.selectedAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:10.0f]};
    [_activityTabBarView setTabIndex:0 animated:NO];
    [_activityTabBarView reloadData];
    
    if (self.appModel.statEcoScoringFuel.intValue > 80) {
        self.progressBarFuel.barFillColor = [Color officialGreenColor];
    } else if (self.appModel.statEcoScoringFuel.intValue > 60) {
        self.progressBarFuel.barFillColor = [Color officialYellowColor];
    } else if (self.appModel.statEcoScoringFuel.intValue > 40) {
        self.progressBarFuel.barFillColor = [Color officialOrangeColor];
    } else {
        self.progressBarFuel.barFillColor = [Color officialRedColor];
    }
    
    if (self.appModel.statEcoScoringTyres.intValue > 80) {
        self.progressBarTires.barFillColor = [Color officialGreenColor];
    } else if (self.appModel.statEcoScoringTyres.intValue > 60) {
        self.progressBarTires.barFillColor = [Color officialYellowColor];
    } else if (self.appModel.statEcoScoringTyres.intValue > 40) {
        self.progressBarTires.barFillColor = [Color officialOrangeColor];
    } else {
        self.progressBarTires.barFillColor = [Color officialRedColor];
    }
    
    if (self.appModel.statEcoScoringBrakes.intValue > 80) {
        self.progressBarBrakes.barFillColor = [Color officialGreenColor];
    } else if (self.appModel.statEcoScoringBrakes.intValue > 60) {
        self.progressBarBrakes.barFillColor = [Color officialYellowColor];
    } else if (self.appModel.statEcoScoringBrakes.intValue > 40) {
        self.progressBarBrakes.barFillColor = [Color officialOrangeColor];
    } else {
        self.progressBarBrakes.barFillColor = [Color officialRedColor];
    }
    
    if (self.appModel.statEcoScoringDepreciation.intValue > 80) {
        self.progressBarCost.barFillColor = [Color officialGreenColor];
    } else if (self.appModel.statEcoScoringDepreciation.intValue > 60) {
        self.progressBarCost.barFillColor = [Color officialYellowColor];
    } else if (self.appModel.statEcoScoringDepreciation.intValue > 40) {
        self.progressBarCost.barFillColor = [Color officialOrangeColor];
    } else {
        self.progressBarCost.barFillColor = [Color officialRedColor];
    }
    
    [self.progressBarFuel setBarBackgroundColor:[Color lightSeparatorColor]];
    [self.progressBarTires setBarBackgroundColor:[Color lightSeparatorColor]];
    [self.progressBarBrakes setBarBackgroundColor:[Color lightSeparatorColor]];
    [self.progressBarCost setBarBackgroundColor:[Color lightSeparatorColor]];
    
    if (self.appModel.statRating >= self.appModel.statPreviousRating)
        self.arrowPercentImg.image = [UIImage imageNamed:@"arrow_up_green"];
    else
        self.arrowPercentImg.image = [UIImage imageNamed:@"arrow_down_red"];
    self.percentLbl.text = [NSString stringWithFormat:@"%.0f", self.appModel.statEco.floatValue];
    
    if (self.appModel.statEco.floatValue > 80) {
        self.roundPercentImg.image = [UIImage imageNamed:@"round_green"];
    } else if (self.appModel.statEco.floatValue > 60) {
        self.roundPercentImg.image = [UIImage imageNamed:@"round_yellow"];
    } else if (self.appModel.statEco.floatValue > 40) {
        self.roundPercentImg.image = [UIImage imageNamed:@"round_orange"];
    } else {
        self.roundPercentImg.image = [UIImage imageNamed:@"round_red"];
    }
    
    [self setAccident];
}

- (void)setAccident {
    self.tipAdviceLbl.text = @"Driving style impacts on your expenses on fuel, tires and brakes. Improve your driving style and reduce expenses.";
}

- (void)setupEcoDemoBlock {
    //DEMO DASHBOARD FOR NEW USERS LOWER 10km
    self.mapDemo_noTripsView.hidden = NO;
    self.mapDemo_snapshot.hidden = YES;
    self.mapDemo_pointsLbl.hidden = YES;
    self.mapDemo_kmLbl.hidden = YES;
    self.mapDemo_startTimeLbl.hidden = YES;
    self.mapDemo_endTimeLbl.hidden = YES;
    [self.mapDemo_permissBtn setAttributedTitle:[self createOpenAppSettingsLblImgBefore:@"Check App Permissions"] forState:UIControlStateNormal];
    
    _demo_activityTabBarView.indicatorAttributes = @{CMTabIndicatorColor:[UIColor blackColor], CMTabIndicatorViewHeight:@(2.5f), CMTabBoxBackgroundColor:[UIColor blackColor]};
    _demo_activityTabBarView.normalAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:10.0f]};
    _demo_activityTabBarView.selectedAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:10.0f]};
    [_demo_activityTabBarView setTabIndex:0 animated:NO];
    [_demo_activityTabBarView reloadData];

    self.demo_progressBarFuel.progress = 0.90f;
    self.demo_progressBarTires.progress = 0.80f;
    self.demo_progressBarBrakes.progress = 0.70f;
    self.demo_progressBarCost.progress = 0.60f;

    self.demo_progressBarFuel.barFillColor = [Color officialGreenColor];
    self.demo_progressBarTires.barFillColor = [Color officialYellowColor];
    self.demo_progressBarBrakes.barFillColor = [Color officialOrangeColor];
    self.demo_progressBarCost.barFillColor = [Color officialRedColor];

    [self.demo_progressBarFuel setBarBackgroundColor:[Color lightSeparatorColor]];
    [self.demo_progressBarTires setBarBackgroundColor:[Color lightSeparatorColor]];
    [self.demo_progressBarBrakes setBarBackgroundColor:[Color lightSeparatorColor]];
    [self.demo_progressBarCost setBarBackgroundColor:[Color lightSeparatorColor]];

    self.demo_progressBarFuel.alpha = 0.55;
    self.demo_progressBarTires.alpha = 0.55;
    self.demo_progressBarBrakes.alpha = 0.55;
    self.demo_progressBarCost.alpha = 0.55;

    self.demo_arrowPercentImg.image = [UIImage imageNamed:@"arrow_up_green"];
    self.demo_roundPercentImg.image = [UIImage imageNamed:@"round_lightgrey"];
    self.demo_percentLbl.text = @"?";
    self.demo_percentLbl.font = [Font heavy44];

    self.demo_tipAdviceLbl.text = @"Driving style impacts on your expenses on fuel, tires and brakes. Improve your driving style and reduce expenses.";
}

- (void)incrementProgressFuel:(NSTimer *)timer {
    int rate = [self.appModel.statEcoScoringFuel intValue];
    int rateProg = [@(self.progressBarFuel.progress*100) intValue];
    
    if (rateProg <= rate) {
        self.progressBarFuel.progress = self.progressBarFuel.progress + 0.01f;
    }
    if (rate == rateProg || rateProg > rate) {
        [_timerFuel invalidate];
    }
}

- (void)incrementProgressTires:(NSTimer *)timer {
    int rate = [self.appModel.statEcoScoringTyres intValue];
    int rateProg = [@(self.progressBarTires.progress*100) intValue];
    
    if (rateProg <= rate) {
        self.progressBarTires.progress = self.progressBarTires.progress + 0.01f;
    }
    if (rate == rateProg || rateProg > rate) {
        [_timerTires invalidate];
    }
}

- (void)incrementProgressBrakes:(NSTimer *)timer {
    int rate = [self.appModel.statEcoScoringBrakes intValue];
    int rateProg = [@(self.progressBarBrakes.progress*100) intValue];
    
    if (rateProg <= rate) {
        self.progressBarBrakes.progress = self.progressBarBrakes.progress + 0.01f;
    }
    if (rate == rateProg || rateProg > rate) {
        [_timerBrakes invalidate];
    }
}

- (void)incrementProgressTravelCost:(NSTimer *)timer {
    int rate = [self.appModel.statEcoScoringDepreciation intValue];
    int rateProg = [@(self.progressBarCost.progress*100) intValue];
    
    if (rateProg <= rate) {
        self.progressBarCost.progress = self.progressBarCost.progress + 0.01f;
    }
    if (rate == rateProg || rateProg > rate) {
        [_timerTravelCost invalidate];
    }
}


#pragma mark - ActivityTabBarView Datasource

- (NSArray<NSString *> *)tabbarTitlesForTabbarView:(CMTabbarView *)activityTabBarView {
    return self.activityDates;
}

- (void)tabbarView:(CMTabbarView *)activityTabBarView didSelectedAtIndex:(NSInteger)index {
    [self.collectionViewActivity scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:false];
    [self.demo_collectionViewActivity scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:false];
}


#pragma mark - Visual for Activity Eco Collection

- (void)setupEcoCollectionsForViews {
    self.activityDates = @[@"WEEK", @"MONTH", @"YEAR"];
    
    [self.collectionViewActivity setContentOffset:CGPointMake(self.collectionViewActivity.bounds.size.width * 0, 0)];
    [self.collectionViewActivity registerNib:[UINib nibWithNibName:NSStringFromClass([UserActivityCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([UserActivityCell class])];
    [self.collectionViewActivity reloadData];
    
    [self.demo_collectionViewActivity setContentOffset:CGPointMake(self.demo_collectionViewActivity.bounds.size.width * 0, 0)];
    [self.demo_collectionViewActivity registerNib:[UINib nibWithNibName:NSStringFromClass([UserActivityCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([UserActivityCell class])];
    [self.demo_collectionViewActivity reloadData];
}


#pragma mark - Last Trip for Dashboard

- (void)loadOneEventForDashboardMap {
    [[RPEntry instance].api getTracksWithOffset:0 limit:1 startDate:nil endDate:nil completion:^(id response, NSError *error) {
        RPFeed* feed = (RPFeed*)response;
        if (feed.tracks.count) {
            NSString *ttk = feed.tracks.firstObject.trackToken;
            NSString *latestTt = defaults_object(@"LatestTripTokenTempory");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.mapDemo_noTripsView.hidden = YES;
                self.mapDemo_snapshot.hidden = NO;
                self.mapDemo_pointsLbl.hidden = NO;
                self.mapDemo_kmLbl.hidden = NO;
                self.mapDemo_startTimeLbl.hidden = NO;
                self.mapDemo_endTimeLbl.hidden = NO;
            });
            
            if (![ttk isEqualToString:latestTt])
                [self loadLastTrackData:ttk];
        } else {
            NSLog(@"NO LAST TRIP REQUEST ERROR");
        }
    }];
}

- (void)loadLastTrackData:(NSString*)ttk {
    [[RPEntry instance].api getTrackWithTrackToken:ttk completion:^(id response, NSError *error) {
        self.track = response;
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL loadMainData = NO;
            if (!self.track) {
                loadMainData = YES;
            }
            
            float rating = self.track.rating100;
            if (rating == 0)
                rating = self.track.rating*20;
            
            [self sheetUpdatePointsLabel:[NSString stringWithFormat:@"%.0f", rating]];
            
            if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
                float miles = convertKmToMiles(self.track.distance);
                [self sheetUpdateKmLabel:[NSString stringWithFormat:@"%.1f", miles]];
            } else {
                [self sheetUpdateKmLabel:[NSString stringWithFormat:@"%.0f", self.track.distance]];
            }
            
            [self sheetUpdateStartEndTimeLabel:self.track.startDate timeEnd:self.track.endDate];
            
            [self loadMainMapPointsToSnapshot];
            
            if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
                float miles = convertKmToMiles(self.track.distance);
                defaults_set_object(@"LatestTripDistance", [NSString stringWithFormat:@"%.1f", miles]);
            } else {
                defaults_set_object(@"LatestTripDistance", [NSString stringWithFormat:@"%.0f", self.track.distance]);
            }
            defaults_set_object(@"LatestTripTokenTempory", ttk);
            defaults_set_object(@"LatestTripRating", [NSString stringWithFormat:@"%.0f", rating]);
            defaults_set_object(@"LatestTripTimeStart", self.track.startDate);
            defaults_set_object(@"LatestTripTimeEnd", self.track.endDate);
        });
    }];
}

- (void)sheetUpdatePointsLabel:(NSString*)points {
    if ([points containsString:@"."]) {
        NSRange rangeSearch = [points rangeOfString:@"." options:NSBackwardsSearch];
        points = [points substringToIndex:rangeSearch.location];
    }
    
    float p = [points floatValue];
    
    NSString *pointsLbl1 = points;
    NSString *pointsLbl2 = localizeString(@"dash_points");
    
    if (points.length > 0) {
        //
    } else {
        pointsLbl1 = @"";
        pointsLbl2 = @"";
    }
    
    NSString *totalPointsLbl = [NSString stringWithFormat:@"%@ %@", pointsLbl1, pointsLbl2];
    NSMutableAttributedString *completeText = [[NSMutableAttributedString alloc] initWithString:totalPointsLbl];
    
    NSRange mainRangeTotalPoints = [totalPointsLbl rangeOfString:pointsLbl1];
    UIFont *mainFontTotalPoints = [Font heavy24];
    if (IS_IPHONE_5 || IS_IPHONE_4)
        mainFontTotalPoints = [Font heavy18];
    
    if (p > 80) {
        [completeText addAttribute:NSForegroundColorAttributeName value:[Color officialGreenColor] range:mainRangeTotalPoints];
    } else if (p > 60) {
        [completeText addAttribute:NSForegroundColorAttributeName value:[Color officialYellowColor] range:mainRangeTotalPoints];
    } else if (p > 40) {
        [completeText addAttribute:NSForegroundColorAttributeName value:[Color officialOrangeColor] range:mainRangeTotalPoints];
    } else {
        [completeText addAttribute:NSForegroundColorAttributeName value:[Color officialDarkRedColor] range:mainRangeTotalPoints];
    }
    
    [completeText addAttribute:NSFontAttributeName value:mainFontTotalPoints range:mainRangeTotalPoints];
    
    NSRange mainRangePointsLbl = [totalPointsLbl rangeOfString:pointsLbl2];
    UIFont *mainFontPointsLbl = [Font semibold13];
    if (IS_IPHONE_5 || IS_IPHONE_4)
        mainFontPointsLbl = [Font semibold11];
    
    [completeText addAttribute:NSForegroundColorAttributeName value:[Color lightGrayColor] range:mainRangePointsLbl];
    [completeText addAttribute:NSFontAttributeName value:mainFontPointsLbl range:mainRangePointsLbl];
    
    self.pointsLbl.attributedText = completeText;
    self.mapDemo_pointsLbl.attributedText = completeText;
}

- (void)sheetUpdateKmLabel:(NSString*)km {
    NSString *kmLbl1 = km;
    NSString *kmLbl2 = localizeString(@"dash_km");
    if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
        kmLbl2 = localizeString(@"dash_miles");
    }
    
    if (km.length > 0) {
        //
    } else {
        kmLbl1 = @"";
        kmLbl2 = @"";
    }
    
    NSString *totalKmLbl = [NSString stringWithFormat:@"%@ %@", kmLbl1, kmLbl2];
    NSMutableAttributedString *completeTextKm = [[NSMutableAttributedString alloc] initWithString:totalKmLbl];
    
    NSRange mainRange1 = [totalKmLbl rangeOfString:kmLbl1];
    UIFont *mainFont1 = [Font heavy24];
    if (IS_IPHONE_5 || IS_IPHONE_4)
        mainFont1 = [Font heavy18];
    
    [completeTextKm addAttribute:NSForegroundColorAttributeName value:[Color darkGrayColor] range:mainRange1];
    [completeTextKm addAttribute:NSFontAttributeName value:mainFont1 range:mainRange1];
    
    NSRange mainRange2 = [totalKmLbl rangeOfString:kmLbl2];
    UIFont *mainFont2 = [Font semibold13];
    if (IS_IPHONE_5 || IS_IPHONE_4)
        mainFont2 = [Font semibold11];
    
    [completeTextKm addAttribute:NSForegroundColorAttributeName value:[Color lightGrayColor] range:mainRange2];
    [completeTextKm addAttribute:NSFontAttributeName value:mainFont2 range:mainRange2];
    
    self.kmLbl.attributedText = completeTextKm;
    self.mapDemo_kmLbl.attributedText = completeTextKm;
}

- (void)sheetUpdateStartEndTimeLabel:(NSDate*)timeStart timeEnd:(NSDate*)timeEnd {
    NSString *stDate = [timeStart dateTimeStringShort];
    NSString *endDate = [timeEnd dateTimeStringShort];
    
    if ([Configurator sharedInstance].needAmPmTime || [defaults_object(@"needDateSpecialFormat") boolValue] || [defaults_object(@"needAmPmFormat") boolValue]) {
        if ([defaults_object(@"needDateSpecialFormat") boolValue] && ![defaults_object(@"needAmPmFormat") boolValue]) {
            stDate = [timeStart dateTimeStringShortMmDd24];
            endDate = [timeEnd dateTimeStringShortMmDd24];
        } else if (![defaults_object(@"needDateSpecialFormat") boolValue] && [defaults_object(@"needAmPmFormat") boolValue]) {
            stDate = [timeStart dateTimeStringShortDdMmAmPm];
            endDate = [timeEnd dateTimeStringShortDdMmAmPm];
        } else if (![defaults_object(@"needDateSpecialFormat") boolValue] && ![defaults_object(@"needAmPmFormat") boolValue]) {
            stDate = [timeStart dateTimeStringShortDdMm24];
            endDate = [timeEnd dateTimeStringShortDdMm24];
        } else {
            stDate = [timeStart dateTimeStringShortMmDdAmPm];
            endDate = [timeEnd dateTimeStringShortMmDdAmPm];
        }
    }
    
    self.startTimeLbl.attributedText = [self createStartDateLabelImgBefore:stDate];
    self.endTimeLbl.attributedText = [self createEndDateLabelImgBefore:endDate];
    self.mapDemo_startTimeLbl.attributedText = [self createStartDateLabelImgBefore:stDate];
    self.mapDemo_endTimeLbl.attributedText = [self createEndDateLabelImgBefore:endDate];
    if (IS_IPHONE_5 || IS_IPHONE_4) {
        self.startTimeLbl.font = [Font semibold11];
        self.endTimeLbl.font = [Font semibold11];
    }
}

- (void)loadMainMapPointsToSnapshot {
    NSMutableArray *allPointsArr = [[NSMutableArray alloc] init];
    NSMutableArray *markerPointsArr = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.track.points.count; i++) {
        RPTrackPointProcessed *point = self.track.points[i];
        
        NSString *la = [[NSNumber numberWithDouble:point.latitude] stringValue];
        NSString *lo = [[NSNumber numberWithDouble:point.longitude] stringValue];
        [allPointsArr addObject:la];
        [allPointsArr addObject:lo];
        
        if (i == 0 || i == self.track.points.count-1) {
            [markerPointsArr addObject:la];
            [markerPointsArr addObject:lo];
        }
    }
    
    NSString *specialAllPointsArrForHERE = [allPointsArr componentsJoinedByString:@","];
    NSString *specialMarkersPointsArrForHERE = [markerPointsArr componentsJoinedByString:@","];
    NSString *imgW = @"900";
    if (IS_IPHONE_5 || IS_IPHONE_4)
        imgW = @"700";
    
    NSString *resParams = [NSString stringWithFormat:@"?apiKey=%@&w=%@&h=%@&nocp=%@&ml=%@&mtxc=%@&lc=%@&mthm=%@&t=%@&ppi=%@&lw=%@&f=%@&mfc=%@&m=%@", [Configurator sharedInstance].mapsRestApiKey, imgW, @"360", @"1", @"eng", @"20", @"54C751", @"1", @"7", @"100", @"7", @"0", @"000000", specialMarkersPointsArrForHERE];
    NSString *finalURL = [NSString stringWithFormat:@"https://image.maps.ls.hereapi.com/mia/1.6/route%@", resParams];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:finalURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    NSDictionary *headers = @{@"Content-Type":@"application/x-www-form-urlencoded"};
    [request setAllHTTPHeaderFields:headers];
    
    NSString *rPoints = [NSString stringWithFormat:@"r=%@", specialAllPointsArrForHERE];
    NSData *postData = [[NSData alloc] initWithData:[rPoints dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:postData];
    [request setHTTPMethod:@"POST"];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
          UIImage *image = [UIImage imageWithData:data];
          dispatch_async(dispatch_get_main_queue(), ^{
              if (image != nil) {
                  self.mapSnapshot.layer.cornerRadius = 16;
                  self.mapSnapshot.contentMode = UIViewContentModeScaleAspectFill;
                  self.mapSnapshot.image = image;
                  
                  self.mapDemo_snapshot.layer.cornerRadius = 16;
                  self.mapDemo_snapshot.contentMode = UIViewContentModeScaleAspectFill;
                  self.mapDemo_snapshot.image = image;

                  NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:data];
                  defaults_set_object(@"LatestTripPhotoTempory", encodedObject);
              }
          });
      }
    }];
    [dataTask resume];
}

- (void)loadLastCachedEventForDashboardMap {
    NSString *latestRating = defaults_object(@"LatestTripRating") ? defaults_object(@"LatestTripRating") : @"";
    NSString *latestDistance = defaults_object(@"LatestTripDistance") ? defaults_object(@"LatestTripDistance") : @"";
    NSDate *latestTimeStart = defaults_object(@"LatestTripTimeStart") ? defaults_object(@"LatestTripTimeStart") : nil;
    NSDate *latestTimeEnd = defaults_object(@"LatestTripTimeEnd") ? defaults_object(@"LatestTripTimeEnd") : nil;
    [self sheetUpdatePointsLabel:latestRating];
    [self sheetUpdateKmLabel:latestDistance];
    if (latestTimeStart != nil && latestTimeEnd != nil)
        [self sheetUpdateStartEndTimeLabel:latestTimeStart timeEnd:latestTimeEnd];
    
    NSData *encodedSavedObject = defaults_object(@"LatestTripPhotoTempory");
    UIImage *savedImg = [UIImage imageWithData:[NSKeyedUnarchiver unarchiveObjectWithData:encodedSavedObject]];
    if (savedImg != nil) {
        self.mapSnapshot.layer.cornerRadius = 16;
        self.mapSnapshot.contentMode = UIViewContentModeScaleAspectFill;
        self.mapSnapshot.image = savedImg;
        
        self.mapDemo_snapshot.layer.cornerRadius = 16;
        self.mapDemo_snapshot.contentMode = UIViewContentModeScaleAspectFill;
        self.mapDemo_snapshot.image = savedImg;
    }
}


#pragma mark - UI Elements updates

- (void)setupRoundViews {
    self.mainBackgroundView.image = [UIImage imageNamed:[Configurator sharedInstance].additionalBackgroundImg];
    self.mainSuperView.layer.cornerRadius = 16;
    self.mainSuperView.layer.masksToBounds = NO;
    self.mainSuperView.layer.shadowOffset = CGSizeMake(0, 0);
    self.mainSuperView.layer.shadowRadius = 2;
    self.mainSuperView.layer.shadowOpacity = 0.1;
    
    self.needDistanceView.layer.cornerRadius = 16;
    self.needDistanceView.layer.masksToBounds = NO;
    self.needDistanceView.layer.shadowOffset = CGSizeMake(0, 0);
    self.needDistanceView.layer.shadowRadius = 2;
    self.needDistanceView.layer.shadowOpacity = 0.1;
    
    self.mainDashboardView.layer.cornerRadius = 16;
    self.mainDashboardView.layer.masksToBounds = NO;
    self.mainDashboardView.layer.shadowOffset = CGSizeMake(0, 0);
    self.mainDashboardView.layer.shadowRadius = 2;
    self.mainDashboardView.layer.shadowOpacity = 0.1;
    
    [self updateMainConstraints];
}

- (void)updateMainConstraints {
    float requiredDistance = self.appModel.statDistanceForScoring.floatValue;
    float userRealDistance = self.appModel.statSummaryDistance.floatValue;
    if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
        userRealDistance = convertKmToMiles(userRealDistance);
    }
    
    //Real-time update
    NSLayoutConstraint *heightConstraint;
    for (NSLayoutConstraint *constraint in self.mainScrollView.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            heightConstraint = constraint;
            break;
        }
    }
    if (userRealDistance >= requiredDistance) {
        if (IS_IPHONE_5 || IS_IPHONE_4) {
            heightConstraint.constant = 850;
        } else if (IS_IPHONE_8) {
            heightConstraint.constant = 740;
        } else if (IS_IPHONE_8P) {
            heightConstraint.constant = 700;
        } else if (IS_IPHONE_11 || IS_IPHONE_12_PRO) {
            heightConstraint.constant = 680;
        } else if (IS_IPHONE_11_PROMAX || IS_IPHONE_12_PROMAX) {
            heightConstraint.constant = 580;
        }
    } else if (userRealDistance < requiredDistance) {
        if (IS_IPHONE_5 || IS_IPHONE_4) {
            heightConstraint.constant = 940;
        } else if (IS_IPHONE_8 || IS_IPHONE_8P) {
            heightConstraint.constant = 860;
        } else if (IS_IPHONE_11 || IS_IPHONE_12_PRO) {
            heightConstraint.constant = 770;
        } else if (IS_IPHONE_11_PROMAX || IS_IPHONE_12_PROMAX) {
            heightConstraint.constant = 700;
        }
    }
}


#pragma mark - TabBar Titles

- (void)setupTabBarTitles {
    
    UITabBarItem *tabBarItem0 = [self.tabBarController.tabBar.items objectAtIndex:[[Configurator sharedInstance].dashboardTabBarNumber intValue]];
    [tabBarItem0 setImage:[[UIImage imageNamed:@"dashboard_unselected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem0 setSelectedImage:[[UIImage imageNamed:@"dashboard_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem0 setTitle:localizeString(@"dashboard_title")];
    
    UITabBarItem *tabBarItem1 = [self.tabBarController.tabBar.items objectAtIndex:[[Configurator sharedInstance].feedTabBarNumber intValue]];
    [tabBarItem1 setImage:[[UIImage imageNamed:@"feed_unselected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem1 setSelectedImage:[[UIImage imageNamed:@"feed_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem1 setTitle:localizeString(@"feed_title")];
    
    UITabBarItem *tabBarItem3 = [self.tabBarController.tabBar.items objectAtIndex:[[Configurator sharedInstance].profileTabBarNumber intValue]];
    [tabBarItem3 setImage:[[UIImage imageNamed:@"profile_unselected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem3 setSelectedImage:[[UIImage imageNamed:@"profile_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem3 setTitle:localizeString(@"profile_title")];
}


#pragma mark - Translation

- (void)setupTranslation {
    
    self.welcomeLbl.text = localizeString(@"Welcome aboard!");
    self.welcomeLbl.textColor = [Color officialMainAppColor];
    self.showLeaderLbl.text = localizeString(@"Rank");
    self.latestScoredTripLbl.text = localizeString(@"LATEST SCORED TRIP");
    
    self.descNeedTotalTripsLbl.text = localizeString(@"Total Trips");
    self.descNeedMileageLbl.text = localizeString(@"Mileage");
    self.descNeedTimeDrivenLbl.text = localizeString(@"Time Driven");
    self.descNeedQuantityLbl.text = localizeString(@"quantity");
    self.descNeedKmLbl.text = localizeString(@"km");
    self.descNeedHoursLbl.text = localizeString(@"hours");
    
    self.descTotalTripsLbl.text = localizeString(@"Total Trips");
    self.descMileageLbl.text = localizeString(@"Mileage");
    self.descTimeDrivenLbl.text = localizeString(@"Time Driven");
    self.descQuantityLbl.text = localizeString(@"quantity");
    self.descKmLbl.text = localizeString(@"km");
    self.descHoursLbl.text = localizeString(@"hours");
    
    if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
        self.descNeedKmLbl.text = localizeString(@"dash_miles");
        self.descKmLbl.text = localizeString(@"dash_miles");
    }
    
    self.scoringAvailableIn.text = localizeString(@"Scoring is available in:");
    self.driveAsYouDo.text = localizeString(@"Drive as you do normally");
}


#pragma mark - Helpers for labels

- (IBAction)lastTripTapDetect:(id)sender {
    UITabBarController *tabBar = (UITabBarController *)[AppDelegate appDelegate].window.rootViewController;
    [tabBar setSelectedIndex:[[Configurator sharedInstance].feedTabBarNumber intValue]];
}

- (NSMutableAttributedString*)createStartDateLabelImgBefore:(NSString*)text {
    NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
    imageAttachment.image = [UIImage imageNamed:@"feed_round_grey"];
    imageAttachment.bounds = CGRectMake(0, 0, imageAttachment.image.size.width/1.5, imageAttachment.image.size.height/1.5);
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
    NSMutableAttributedString *completeText = [[NSMutableAttributedString alloc] initWithString:@""];
    [completeText appendAttributedString:attachmentString];
    NSString *spaceText = [NSString stringWithFormat:@"  %@", text];
    NSMutableAttributedString *textAfterIcon = [[NSMutableAttributedString alloc] initWithString:spaceText];
    [completeText appendAttributedString:textAfterIcon];
    return completeText;
}

- (NSMutableAttributedString*)createEndDateLabelImgBefore:(NSString*)text {
    NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
    imageAttachment.image = [UIImage imageNamed:@"feed_round_green_mini"];
    imageAttachment.bounds = CGRectMake(0, 0, imageAttachment.image.size.width/1.5, imageAttachment.image.size.height/1.5);
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
    NSMutableAttributedString *completeText = [[NSMutableAttributedString alloc] initWithString:@""];
    [completeText appendAttributedString:attachmentString];
    NSString *spaceText = [NSString stringWithFormat:@"  %@", text];
    NSMutableAttributedString *textAfterIcon = [[NSMutableAttributedString alloc] initWithString:spaceText];
    [completeText appendAttributedString:textAfterIcon];
    return completeText;
}

- (NSMutableAttributedString*)createOpenAppSettingsLblImgBefore:(NSString*)text {
    NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
    imageAttachment.image = [UIImage imageNamed:@"demo_mapAlert"];
    imageAttachment.bounds = CGRectMake(0, -2, imageAttachment.image.size.width/2.8, imageAttachment.image.size.height/2.8);
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
    NSMutableAttributedString *completeText = [[NSMutableAttributedString alloc] initWithString:@""];
    [completeText appendAttributedString:attachmentString];
    NSString *spaceText = [NSString stringWithFormat:@"  %@", text];
    NSMutableAttributedString *textAfterIcon = [[NSMutableAttributedString alloc] initWithString:spaceText];
    [completeText appendAttributedString:textAfterIcon];
    return completeText;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    if (@available(iOS 13.0, *)) {
        CGFloat y =  - self.mainScrollView.contentOffset.y - self.mainScrollView.contentInset.top;
         if (self.mainScrollView.contentOffset.y < 0) {
            self.mainBackgroundView.frame = CGRectMake(self.mainBackgroundView.frame.origin.x, self.mainBackgroundView.frame.origin.y, self.mainBackgroundView.frame.size.width, y + 156);
        }
    }

    self.mapSnapshot.layer.borderWidth = 1.0;
    self.mapSnapshot.layer.borderColor = [UIColor clearColor].CGColor;
    self.mapSnapshot.layer.masksToBounds = true;
    self.mapSnapshot.clipsToBounds = true;
    
    self.mapDemo_snapshot.layer.borderWidth = 1.0;
    self.mapDemo_snapshot.layer.borderColor = [UIColor clearColor].CGColor;
    self.mapDemo_snapshot.layer.masksToBounds = true;
    self.mapDemo_snapshot.clipsToBounds = true;
}


#pragma mark - Actions

- (IBAction)inviteMoreAction:(id)sender {
    [HapticHelper generateFeedback:FeedbackTypeImpactMedium];
    [self.tabBarController setSelectedIndex:1];
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

- (void)lowFontsForOldDevices {
    self.needDistanceLabel.font = [Font heavy21];
    
    self.descNeedTotalTripsLbl.font = [Font medium10];
    self.descNeedMileageLbl.font = [Font medium10];
    self.descNeedTimeDrivenLbl.font = [Font medium10];

    self.descTotalTripsLbl.font = [Font medium10];
    self.descMileageLbl.font = [Font medium10];
    self.descTimeDrivenLbl.font = [Font medium10];
    
    self.tipLbl.font = [Font regular11];
    self.tipAdviceLbl.font = [Font regular11];
    
    self.demo_tipLbl.font = [Font regular11];
    self.demo_tipAdviceLbl.font = [Font regular11];
    
    [self.arrowUpDownBtn addConstraint:[NSLayoutConstraint constraintWithItem:self.arrowUpDownBtn
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1
                                                                       constant:35]];
    
    [self.arrowUpDownBtn addConstraint:[NSLayoutConstraint constraintWithItem:self.arrowUpDownBtn
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1
                                                                       constant:35]];
    
}


@end
