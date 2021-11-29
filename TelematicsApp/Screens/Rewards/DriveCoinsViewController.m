//
//  DriveCoinsViewController.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 17.08.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "DriveCoinsViewController.h"
#import "WelcomeRewards.h"
#import "SettingsViewController.h"
#import "ProfileViewController.h"
#import "CoinsResponse.h"
#import "CoinsResultResponse.h"
#import "CoinsDetailsResponse.h"
#import "EcoResponse.h"
#import "EcoResultResponse.h"
#import "IndicatorsResponse.h"
#import "StreaksResponse.h"
#import "UIView+Extension.h"
#import "DriveCoinsSegmentView.h"
#import "DaysCoinsSegmentView.h"
#import "CoinsChart.h"
#import "StreakCell.h"
#import "ProgressBarView.h"
#import "UICountingLabel.h"
#import "NSDate+UI.h"
#import "NSDate+ISO8601.h"
#import "NSString+Date.h"

//DRIVECOINS SCREEN WITH SAMPLE IMPLEMENTATION
@interface DriveCoinsViewController () <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, DriveCoinsSegmentViewDelegate, DaysCoinsSegmentViewDelegate> {
    DriveCoinsSegmentView       *_driveCoinsMainSegmentView;
    DaysCoinsSegmentView        *_daysSegmentView;
}

@property (weak, nonatomic) IBOutlet UIView              *topSegment;
@property (weak, nonatomic) IBOutlet UIView              *mainView;
@property (weak, nonatomic) IBOutlet UIView              *whiteBackView;
@property (weak, nonatomic) IBOutlet UILabel             *userNameLbl;
@property (weak, nonatomic) IBOutlet UIImageView         *avatarImg;

@property (strong, nonatomic) TelematicsAppModel         *appModel;
@property (nonatomic, strong) IBOutlet CoinsChart        *coinsChartView;

@property (weak, nonatomic) IBOutlet UIScrollView        *rewardsScrollView;
@property (strong, nonatomic) CoinsDetailsResponse       *coinsDailyDetails;
@property (strong, nonatomic) IndicatorsResultResponse   *indicators;
@property (strong, nonatomic) StreaksResultResponse      *streaks;
@property (strong, nonatomic) EcoResultResponse          *ecoPercents;
@property (strong, nonatomic) CoinsResultResponse        *coinsReload;

@property (weak, nonatomic) IBOutlet UIView              *segmentBackView;
@property (weak, nonatomic) IBOutlet UIView              *daysSegmentBackView;

@property (weak, nonatomic) IBOutlet UIView              *additional1View;
@property (weak, nonatomic) IBOutlet UIView              *additional2View;
@property (weak, nonatomic) IBOutlet UIView              *additional3View;

@property (weak, nonatomic) IBOutlet UILabel             *dailyLimitLbl;
@property (weak, nonatomic) IBOutlet UICountingLabel     *acquiredRewardsTotalLbl;
@property (weak, nonatomic) IBOutlet UICountingLabel     *mainRewardsAdditionalTotalLbl;

@property (weak, nonatomic) IBOutlet UICountingLabel     *mainTravellingLbl;
@property (weak, nonatomic) IBOutlet UICountingLabel     *mainSafeDrivingLbl;
@property (weak, nonatomic) IBOutlet UICountingLabel     *mainEcoDrivingLbl;

@property (weak, nonatomic) IBOutlet UILabel             *name_travellingLbl;
@property (weak, nonatomic) IBOutlet UILabel             *name_safetyLbl;
@property (weak, nonatomic) IBOutlet UILabel             *name_ecoScoreLbl;

@property (weak, nonatomic) IBOutlet UILabel             *factor_valueMileageLbl;
@property (weak, nonatomic) IBOutlet UILabel             *factor_coinMileageLbl;
@property (weak, nonatomic) IBOutlet UILabel             *factor_valueDurationLbl;
@property (weak, nonatomic) IBOutlet UILabel             *factor_coinDurationLbl;
@property (weak, nonatomic) IBOutlet UILabel             *factor_valueAccelerationLbl;
@property (weak, nonatomic) IBOutlet UILabel             *factor_coinAccelerationLbl;
@property (weak, nonatomic) IBOutlet UILabel             *factor_valueBrakingLbl;
@property (weak, nonatomic) IBOutlet UILabel             *factor_coinBrakingLbl;
@property (weak, nonatomic) IBOutlet UILabel             *factor_valueCorneringLbl;
@property (weak, nonatomic) IBOutlet UILabel             *factor_coinCorneringLbl;
@property (weak, nonatomic) IBOutlet UILabel             *factor_valuePhoneUsageLbl;
@property (weak, nonatomic) IBOutlet UILabel             *factor_coinPhoneUsageLbl;
@property (weak, nonatomic) IBOutlet UILabel             *factor_valueSpeedingLbl;
@property (weak, nonatomic) IBOutlet UILabel             *factor_coinSpeedingLbl;
@property (weak, nonatomic) IBOutlet UILabel             *factor_safeSectorLbl;
@property (weak, nonatomic) IBOutlet UILabel             *factor_ecoScoreLbl;
@property (weak, nonatomic) IBOutlet UILabel             *factor_ecoBrakingLbl;
@property (weak, nonatomic) IBOutlet UILabel             *factor_ecoFuelLbl;
@property (weak, nonatomic) IBOutlet UILabel             *factor_ecoTiresLbl;
@property (weak, nonatomic) IBOutlet UILabel             *factor_ecoCostOwnershipLbl;

@property (nonatomic) IBOutlet ProgressBarView          *coins_progressBarEco;
@property (nonatomic) IBOutlet ProgressBarView          *coins_progressBarBrakes;
@property (nonatomic) IBOutlet ProgressBarView          *coins_progressBarFuel;
@property (nonatomic) IBOutlet ProgressBarView          *coins_progressBarTyres;
@property (nonatomic) IBOutlet ProgressBarView          *coins_progressBarCost;

@property (nonatomic) NSTimer                           *coins_timerEco;
@property (nonatomic) NSTimer                           *coins_timerBrakes;
@property (nonatomic) NSTimer                           *coins_timerFuel;
@property (nonatomic) NSTimer                           *coins_timerTyres;
@property (nonatomic) NSTimer                           *coins_timerCost;

//STREAKS
@property (weak, nonatomic) IBOutlet UITableView        *streaksTableView;

@end

@implementation DriveCoinsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //INITIALIZE USER APP MODEL
    self.appModel = [TelematicsAppModel MR_findFirstByAttribute:@"current_user" withValue:@1];
    
    self.streaksTableView.dataSource = self;
    self.streaksTableView.delegate = self;
    [self.streaksTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.streaksTableView setSeparatorColor:[UIColor lightGrayColor]];
    self.streaksTableView.hidden = YES;
    
    UITabBarItem *tabBarItem2 = [self.tabBarController.tabBar.items objectAtIndex:[[Configurator sharedInstance].rewardsTabBarNumber intValue]];
    [tabBarItem2 setImage:[[UIImage imageNamed:@"rewards_unselected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem2 setSelectedImage:[[UIImage imageNamed:@"rewards_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem2 setTitle:localizeString(@"rewards_title")];
    
    if (![defaults_object(@"notFirstRunRewardsWelcomeScreen") boolValue]) {
        if (![defaults_object(@"userLogOuted") boolValue]) {
            [self openWelcomeRewardsScreen];
            defaults_set_object(@"notFirstRunRewardsWelcomeScreen", @(YES));
        }
    }
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    [[UIImage imageNamed:[Configurator sharedInstance].mainBackgroundImg] drawInRect:self.view.bounds];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:img];
    
    self.mainView.layer.cornerRadius = 16;
    self.mainView.layer.masksToBounds = NO;
    self.mainView.layer.shadowOffset = CGSizeMake(0, 0);
    
    if (IS_IPHONE_4 || IS_IPHONE_5) {
        self.rewardsScrollView.contentSize = CGSizeMake(self.rewardsScrollView.frame.size.width, 830);
    } else {
        self.rewardsScrollView.contentSize = CGSizeMake(self.rewardsScrollView.frame.size.width, 830);
    }
    
    self.additional1View.hidden = NO;
    self.additional2View.hidden = YES;
    self.additional3View.hidden = YES;
    
    _driveCoinsMainSegmentView = [[DriveCoinsSegmentView alloc] initWithItems:@[localizeString(@"DRIVECOINS"),
                                                                                localizeString(@"STREAKS")] andNormalFontColor:[Color darkGrayColor43] andSelectedColor:[Color darkGrayColor43] andLineColor:[Color darkGrayColor43] andFrame:CGRectMake(0, 0, self.segmentBackView.frame.size.width, self.segmentBackView.frame.size.height)];
    _driveCoinsMainSegmentView.delegate = self;
    [self.segmentBackView addSubview:_driveCoinsMainSegmentView];
    self.segmentBackView.hidden = NO;
    
    _daysSegmentView = [[DaysCoinsSegmentView alloc] initWithItems:@[localizeString(@"ALL TIME"),
                                                            localizeString(@"DAY"),
                                                            localizeString(@"THIS MONTH"),
                                                                localizeString(@"LAST MONTH")] andNormalFontColor:[Color darkGrayColor] andSelectedColor:[Color darkGrayColor43] andLineColor:[Color officialMainAppColor] andFrame:CGRectMake(10, 0, self.daysSegmentBackView.frame.size.width-20, self.daysSegmentBackView.frame.size.height)];
    _daysSegmentView.delegate = self;
    [self.daysSegmentBackView addSubview:_daysSegmentView];
    self.daysSegmentBackView.hidden = NO;
    defaults_set_object(@"userCoinsCurrentSegmentSelected", @0);
    
    UITapGestureRecognizer *avaTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avaTapDetect:)];
    self.avatarImg.userInteractionEnabled = YES;
    [self.avatarImg addGestureRecognizer:avaTap];
    
    if (IS_IPHONE_13_PROMAX) {
        NSLayoutConstraint *heightConstraint;
        for (NSLayoutConstraint *constraint in self.whiteBackView.constraints) {
            if (constraint.firstAttribute == NSLayoutAttributeHeight) {
                heightConstraint = constraint;
                heightConstraint.constant = 600;
                break;
            }
        }
    }
    
    self.coins_progressBarEco.barFillColor = [Color officialGreenColor];
    self.coins_progressBarBrakes.barFillColor = [Color officialGreenColor];
    self.coins_progressBarFuel.barFillColor = [Color officialGreenColor];
    self.coins_progressBarTyres.barFillColor = [Color officialGreenColor];
    self.coins_progressBarCost.barFillColor = [Color officialGreenColor];
    
    [self.coins_progressBarEco setBarBackgroundColor:[Color lightSeparatorColor]];
    [self.coins_progressBarBrakes setBarBackgroundColor:[Color lightSeparatorColor]];
    [self.coins_progressBarFuel setBarBackgroundColor:[Color lightSeparatorColor]];
    [self.coins_progressBarTyres setBarBackgroundColor:[Color lightSeparatorColor]];
    [self.coins_progressBarCost setBarBackgroundColor:[Color lightSeparatorColor]];
    
    self.rewardsScrollView.refreshControl = [[UIRefreshControl alloc] init];
    self.rewardsScrollView.refreshControl.tintColor = [Color whiteSpinnerColor];
    [self.rewardsScrollView.refreshControl addTarget:self action:@selector(reloadCoins:) forControlEvents:UIControlEventValueChanged];
    [self.rewardsScrollView.refreshControl setFrame:CGRectMake(5, 0, 20, 20)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startFetchCoinsFactorsFirstTime) name:@"reloadCoinsDashboardSection" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([defaults_object(@"userWantOpenStreaksNow") boolValue]) {
        [self->_driveCoinsMainSegmentView setSelectedIndex:1];
        defaults_set_object(@"userWantOpenStreaksNow", @(0));
    } else {
        [self->_driveCoinsMainSegmentView setSelectedIndex:0];
        defaults_set_object(@"userWantOpenStreaksNow", @(0));
    }
    
    //[self->_driveCoinsMainSegmentView setSelectedIndex:0];
    [self->_daysSegmentView setSelectedIndex:0];
    
    if ([defaults_object(@"userCoinsCurrentSegmentSelected") isEqual: @0]) {
        [self->_daysSegmentView setSelectedIndex:0];
    } else if ([defaults_object(@"userCoinsCurrentSegmentSelected") isEqual: @1]) {
        [self->_daysSegmentView setSelectedIndex:1];
    } else if ([defaults_object(@"userCoinsCurrentSegmentSelected") isEqual: @2]) {
        [self->_daysSegmentView setSelectedIndex:2];
    } else if ([defaults_object(@"userCoinsCurrentSegmentSelected") isEqual: @3]) {
        [self->_daysSegmentView setSelectedIndex:3];
    } else {
        [self->_daysSegmentView setSelectedIndex:0];
    }
    
    [self displayUserNavigationBarInfo];
    
    NSDate *currentDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents14Days = [[NSDateComponents alloc] init];
    [dateComponents14Days setDay:-13]; //-14
    NSDate *dateMinus14Days = [calendar dateByAddingComponents:dateComponents14Days toDate:currentDate options:0];
    NSLog(@"14 days ago: %@", dateMinus14Days); //GRAPH 14 DAYS AGO
    [self getCoinsEverydayDetailsForGraph:dateMinus14Days endDate:currentDate]; //GRAPH
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [Color officialWhiteColor];
    self.navigationController.navigationBar.clipsToBounds = YES;
    
    NSString *dlStr = defaults_object(@"userCoinsDailyLimit") ? defaults_object(@"userCoinsDailyLimit") : @"20";
    self.dailyLimitLbl.text = [NSString stringWithFormat:@"━ ━ ━  Daily limit: %@", dlStr];
    
    self.acquiredRewardsTotalLbl.format = @"%d";
    self.acquiredRewardsTotalLbl.method = UILabelCountingMethodEaseIn;
    NSString *acquiredUserCoins = defaults_object(@"userCoinsCountAcquired") ? defaults_object(@"userCoinsCountAcquired") : @"0";
    [self.acquiredRewardsTotalLbl countFrom:0 to:acquiredUserCoins.intValue]; //main acquired label
    
    NSString *totalUserCoins = defaults_object(@"userCoinsCountAllTime") ? defaults_object(@"userCoinsCountAllTime") : @"0";
    
    self.mainRewardsAdditionalTotalLbl.format = @"%d";
    self.mainRewardsAdditionalTotalLbl.method = UILabelCountingMethodEaseInOut;
    int randomNumber = [self getRandomNumberBetween:9 and:999];
    [self.mainRewardsAdditionalTotalLbl countFrom:0 to:randomNumber];
    
    self.mainTravellingLbl.format = @"%d";
    self.mainTravellingLbl.method = UILabelCountingMethodLinear;
    [self.mainTravellingLbl countFrom:0 to:30];
    
    self.mainSafeDrivingLbl.format = @"%d";
    self.mainSafeDrivingLbl.method = UILabelCountingMethodLinear;
    
    self.mainEcoDrivingLbl.format = @"%d";
    self.mainEcoDrivingLbl.method = UILabelCountingMethodLinear;
    [self.mainEcoDrivingLbl countFrom:0 to:+4];
    
    //DEMO COINS ANIMATION SQMPLE STARTING BLOCK
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([defaults_object(@"userCoinsCurrentSegmentSelected") isEqual: @0]) {
            [self.mainRewardsAdditionalTotalLbl countFrom:randomNumber to:totalUserCoins.intValue];
        } else if ([defaults_object(@"userCoinsCurrentSegmentSelected") isEqual: @1]) {
            NSString *upd = defaults_object(@"userCoinsCountOneDay") ? defaults_object(@"userCoinsCountOneDay") : @"0";
            [self.mainRewardsAdditionalTotalLbl countFrom:randomNumber to:upd.intValue];
        } else if ([defaults_object(@"userCoinsCurrentSegmentSelected") isEqual: @2]) {
            NSString *upd = defaults_object(@"userCoinsCountThisMonth") ? defaults_object(@"userCoinsCountThisMonth") : @"0";
            [self.mainRewardsAdditionalTotalLbl countFrom:randomNumber to:upd.intValue];
        } else if ([defaults_object(@"userCoinsCurrentSegmentSelected") isEqual: @3]) {
            NSString *upd = defaults_object(@"userCoinsCountLastMonth") ? defaults_object(@"userCoinsCountLastMonth") : @"0";
            [self.mainRewardsAdditionalTotalLbl countFrom:randomNumber to:upd.intValue];
        } else {
            [self.mainRewardsAdditionalTotalLbl countFrom:randomNumber to:totalUserCoins.intValue];
        }
    });
    
    [self startFetchCoinsFactorsFirstTime];
    [self startFetchStreaksImmediatily];
    
    if (totalUserCoins.intValue == 0) {
        [self reloadCoins:nil];
    }
    
    if (IS_IPHONE_5 || IS_IPHONE_4)
        [self lowFontsForOldDevices];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


#pragma mark - DriveCoins Main Segment Methods

- (void)segmentDriveCoinsChose:(NSInteger)index {
    if (index == 0) {
        self.streaksTableView.hidden = YES;
        self.rewardsScrollView.scrollEnabled = YES;
    } else if (index == 1) {
        self.streaksTableView.hidden = NO;
        [_rewardsScrollView setContentOffset:CGPointZero animated:YES];
        self.rewardsScrollView.scrollEnabled = NO;
    }
}


#pragma mark - Days Segment Methods

- (void)segmentChose:(NSInteger)index {
    if (index == 0) {
        self.mainRewardsAdditionalTotalLbl.text = defaults_object(@"userCoinsCountAllTime") ? defaults_object(@"userCoinsCountAllTime") : @"0"; //total
        defaults_set_object(@"userCoinsCurrentSegmentSelected", @0);
        [self startFetchCoinsFactorsFirstTime];
        
    } else if (index == 1) {
        NSString *dayOut = defaults_object(@"userCoinsCountOneDay") ? defaults_object(@"userCoinsCountOneDay") : @"0";
        self.mainRewardsAdditionalTotalLbl.text = [NSString stringWithFormat:@"%@", dayOut];
        defaults_set_object(@"userCoinsCurrentSegmentSelected", @1);
        
        NSDate *currentDate = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        NSDateComponents *dateComponentsOneDay = [[NSDateComponents alloc] init];
        [dateComponentsOneDay setDay:-1];
        NSDate *dateMinusNeedOneDays = [calendar dateByAddingComponents:dateComponentsOneDay toDate:currentDate options:0];
        NSLog(@"One day today: %@", dateMinusNeedOneDays);
        
        [self getCoinsAllFactorsDetails:dateMinusNeedOneDays endDate:currentDate];
        [self getIndicatorsForCoinsStatisticTime:dateMinusNeedOneDays endDate:currentDate];
        [self getCoinsForEcoPercentCalculateWithDetails:dateMinusNeedOneDays endDate:currentDate];
        
    } else if (index == 2) {
        NSString *currentMonthOut = defaults_object(@"userCoinsCountThisMonth") ? defaults_object(@"userCoinsCountThisMonth") : @"0";
        self.mainRewardsAdditionalTotalLbl.text = [NSString stringWithFormat:@"%@", currentMonthOut];
        defaults_set_object(@"userCoinsCurrentSegmentSelected", @2);
        
        NSDate *currentDate = [NSDate date];
        NSDateComponents *dateComponentsThisMonth = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
        dateComponentsThisMonth.day = 1;
        NSDate *firstDayOfCurrentMonthDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponentsThisMonth];
        NSLog(@"First day of current month: %@", [firstDayOfCurrentMonthDate descriptionWithLocale:[NSLocale currentLocale]]);
        
        [self getCoinsAllFactorsDetails:firstDayOfCurrentMonthDate endDate:currentDate];
        [self getIndicatorsForCoinsStatisticTime:firstDayOfCurrentMonthDate endDate:currentDate];
        [self getCoinsForEcoPercentCalculateWithDetails:firstDayOfCurrentMonthDate endDate:currentDate];
        
    } else if (index == 3) {
        NSString *currentLastMonthOut = defaults_object(@"userCoinsCountLastMonth") ? defaults_object(@"userCoinsCountLastMonth") : @"0";
        self.mainRewardsAdditionalTotalLbl.text = [NSString stringWithFormat:@"%@", currentLastMonthOut];
        defaults_set_object(@"userCoinsCurrentSegmentSelected", @3);
        
        //NSDate *currentDate = [NSDate date];
        NSDateComponents *dateComponentsLastMonth = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
        dateComponentsLastMonth.day = 1;
        dateComponentsLastMonth.month = dateComponentsLastMonth.month - 1;
        NSDate *firstDayOLastMonthDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponentsLastMonth];
        NSLog(@"First day of last month: %@", [firstDayOLastMonthDate descriptionWithLocale:[NSLocale currentLocale]]);
        
        NSDateComponents *dateComponentsThisMonth = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
        dateComponentsThisMonth.day = 1;
        NSDate *firstDayOfCurrentMonthDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponentsThisMonth];
        NSLog(@"First day of current month: %@", [firstDayOfCurrentMonthDate descriptionWithLocale:[NSLocale currentLocale]]);
        
        [self getCoinsAllFactorsDetails:firstDayOLastMonthDate endDate:firstDayOfCurrentMonthDate];
        [self getIndicatorsForCoinsStatisticTime:firstDayOLastMonthDate endDate:firstDayOfCurrentMonthDate];
        [self getCoinsForEcoPercentCalculateWithDetails:firstDayOLastMonthDate endDate:firstDayOfCurrentMonthDate];
    }
}


#pragma mark - Coins Detailed Information

- (void)startFetchCoinsFactorsFirstTime {
    NSDate *currentDate = [NSDate date];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:-20];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *dateMinusNeedDays = [calendar dateByAddingComponents:dateComponents toDate:currentDate options:0];
    
    [self getCoinsAllFactorsDetails:dateMinusNeedDays endDate:currentDate]; //1 FIRST
    [self getIndicatorsForCoinsStatisticTime:dateMinusNeedDays endDate:currentDate]; //2 SECOND
    [self getCoinsForEcoPercentCalculateWithDetails:dateMinusNeedDays endDate:currentDate]; //3 THIRD
}

//1
- (void)getCoinsAllFactorsDetails:(NSDate *)startDate endDate:(NSDate *)endDate {
    if (startDate == nil) {
        startDate = [NSDate date];
    }
    if (endDate == nil) {
        endDate = [NSDate date];
    }
    
    NSString *sDate = [startDate dateTimeStringSpecial];
    NSString *eDate = [endDate dateTimeStringSpecial];
    
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        NSLog(@"%s %@ %@", __func__, response, error);
        if (!error && [response isSuccesful]) {
            self.coinsDailyDetails = ((CoinsDetailsResponse *)response);
            
            NSMutableDictionary* coinsAllInfoDict = [NSMutableDictionary dictionaryWithCapacity:self.coinsDailyDetails.Result.count];
            for (int i=0; i < self.coinsDailyDetails.Result.count; i++) {
                CoinsDetailsObject *individualObj = self.coinsDailyDetails.Result[i];
                NSString *factorName = individualObj.CoinFactor;
                NSString *factorValue = individualObj.CoinsSum;
                [coinsAllInfoDict setValue:factorValue forKey:factorName];
            }
            NSLog(@"%@", coinsAllInfoDict);
            
            //TRAVELLING COINS
            NSNumber *t_one = [coinsAllInfoDict valueForKey:@"Mileage"] ? [coinsAllInfoDict valueForKey:@"Mileage"] : @"0";
            NSNumber *t_two = [coinsAllInfoDict valueForKey:@"DurationSec"] ? [coinsAllInfoDict valueForKey:@"DurationSec"] : @"0";
            NSNumber *t_three = [coinsAllInfoDict valueForKey:@"AccelerationCount"] ? [coinsAllInfoDict valueForKey:@"AccelerationCount"] : @"0";
            NSNumber *t_four = [coinsAllInfoDict valueForKey:@"BrakingCount"] ? [coinsAllInfoDict valueForKey:@"BrakingCount"] : @"0";
            NSNumber *t_five = [coinsAllInfoDict valueForKey:@"CorneringCount"] ? [coinsAllInfoDict valueForKey:@"CorneringCount"] : @"0";
            NSNumber *t_six = [coinsAllInfoDict valueForKey:@"PhoneUsage"] ? [coinsAllInfoDict valueForKey:@"PhoneUsage"] : @"0";
            NSNumber *t_seven = [coinsAllInfoDict valueForKey:@"HighSpeedingMileage"] ? [coinsAllInfoDict valueForKey:@"HighSpeedingMileage"] : @"0";
            NSNumber *t_eight = [coinsAllInfoDict valueForKey:@"MidSpeedingMileage"] ? [coinsAllInfoDict valueForKey:@"MidSpeedingMileage"] : @"0";
            
            NSNumber *speedingSpecialCalculate = @(t_seven.intValue + t_eight.intValue); //sum
            NSNumber *travelValCalculate = @(t_one.intValue + t_two.intValue + t_three.intValue + t_four.intValue + t_five.intValue + t_six.intValue + t_seven.intValue + t_eight.intValue);
            [self.mainTravellingLbl countFrom:0 to:travelValCalculate.intValue];
            if (travelValCalculate.intValue < 0) { self.mainTravellingLbl.textColor = [Color officialRedColor]; } else if (travelValCalculate.intValue == 0) { self.mainTravellingLbl.textColor = [Color darkGrayColor83]; } else { self.mainTravellingLbl.textColor = [Color officialMainAppColor]; };
            
            self.factor_coinMileageLbl.text = [coinsAllInfoDict valueForKey:@"Mileage"] ? [coinsAllInfoDict valueForKey:@"Mileage"] : @"0";
            self.factor_coinDurationLbl.text = [coinsAllInfoDict valueForKey:@"DurationSec"] ? [coinsAllInfoDict valueForKey:@"DurationSec"] : @"0";
            self.factor_coinAccelerationLbl.text = [coinsAllInfoDict valueForKey:@"AccelerationCount"] ? [coinsAllInfoDict valueForKey:@"AccelerationCount"] : @"0";
            self.factor_coinBrakingLbl.text = [coinsAllInfoDict valueForKey:@"BrakingCount"] ? [coinsAllInfoDict valueForKey:@"BrakingCount"] : @"0";
            self.factor_coinCorneringLbl.text = [coinsAllInfoDict valueForKey:@"CorneringCount"] ? [coinsAllInfoDict valueForKey:@"CorneringCount"] : @"0";
            self.factor_coinPhoneUsageLbl.text = [coinsAllInfoDict valueForKey:@"PhoneUsage"] ? [coinsAllInfoDict valueForKey:@"PhoneUsage"] : @"0";
            self.factor_coinSpeedingLbl.text = speedingSpecialCalculate.stringValue;
            
            if (t_one.intValue < 0) { self.factor_coinMileageLbl.textColor = [Color officialRedColor]; } else if (t_one.intValue == 0) { self.factor_coinMileageLbl.textColor = [Color darkGrayColor83]; } else { self.factor_coinMileageLbl.textColor = [Color officialMainAppColor]; };
            if (t_two.intValue < 0) { self.factor_coinDurationLbl.textColor = [Color officialRedColor]; } else if (t_two.intValue == 0) { self.factor_coinDurationLbl.textColor = [Color darkGrayColor83]; } else { self.factor_coinDurationLbl.textColor = [Color officialMainAppColor]; };
            if (t_three.intValue < 0) { self.factor_coinAccelerationLbl.textColor = [Color officialRedColor]; } else if (t_three.intValue == 0) { self.factor_coinAccelerationLbl.textColor = [Color darkGrayColor83]; } else { self.factor_coinAccelerationLbl.textColor = [Color officialMainAppColor]; };
            if (t_four.intValue < 0) { self.factor_coinBrakingLbl.textColor = [Color officialRedColor]; } else if (t_four.intValue == 0) { self.factor_coinBrakingLbl.textColor = [Color darkGrayColor83]; }  else { self.factor_coinBrakingLbl.textColor = [Color officialMainAppColor]; };
            if (t_five.intValue < 0) { self.factor_coinCorneringLbl.textColor = [Color officialRedColor]; } else if (t_five.intValue == 0) { self.factor_coinCorneringLbl.textColor = [Color darkGrayColor83]; } else { self.factor_coinCorneringLbl.textColor = [Color officialMainAppColor]; };
            if (t_six.intValue < 0) { self.factor_coinPhoneUsageLbl.textColor = [Color officialRedColor]; } else if (t_six.intValue == 0) { self.factor_coinPhoneUsageLbl.textColor = [Color darkGrayColor83]; } else { self.factor_coinPhoneUsageLbl.textColor = [Color officialMainAppColor]; };
            if (speedingSpecialCalculate.intValue < 0) { self.factor_coinSpeedingLbl.textColor = [Color officialRedColor]; } else if (speedingSpecialCalculate.intValue == 0) { self.factor_coinSpeedingLbl.textColor = [Color darkGrayColor83]; } else { self.factor_coinSpeedingLbl.textColor = [Color officialMainAppColor]; };
            
            //SAFE COINS
            NSNumber *safeVal = [coinsAllInfoDict valueForKey:@"SafeScore"] ? [coinsAllInfoDict valueForKey:@"SafeScore"] : @"0";
            [self.mainSafeDrivingLbl countFrom:0 to:safeVal.intValue];
            
            NSString *safeValStr = [NSString stringWithFormat:@"%@", safeVal];
            self.factor_safeSectorLbl.text = safeValStr;
            if (safeVal.intValue < 0) { self.mainSafeDrivingLbl.textColor = [Color officialRedColor]; } else if (safeVal.intValue == 0) { self.mainSafeDrivingLbl.textColor = [Color darkGrayColor83]; } else { self.mainSafeDrivingLbl.textColor = [Color officialMainAppColor]; };
            if (safeVal.intValue < 0) { self.factor_safeSectorLbl.textColor = [Color officialRedColor]; } else if (safeVal.intValue == 0) { self.factor_safeSectorLbl.textColor = [Color darkGrayColor83]; } else { self.factor_safeSectorLbl.textColor = [Color officialMainAppColor]; };
            
            //ECO COINS
            NSNumber *e_one = [coinsAllInfoDict valueForKey:@"EcoScore"] ? [coinsAllInfoDict valueForKey:@"EcoScore"] : @"0";
            NSNumber *e_two = [coinsAllInfoDict valueForKey:@"EcoScoreBrakes"] ? [coinsAllInfoDict valueForKey:@"EcoScoreBrakes"] : @"0";
            NSNumber *e_three = [coinsAllInfoDict valueForKey:@"EcoScoreFuel"] ? [coinsAllInfoDict valueForKey:@"EcoScoreFuel"] : @"0";
            NSNumber *e_four = [coinsAllInfoDict valueForKey:@"EcoScoreTyres"] ? [coinsAllInfoDict valueForKey:@"EcoScoreTyres"] : @"0";
            NSNumber *e_five = [coinsAllInfoDict valueForKey:@"EcoScoreDepreciation"] ? [coinsAllInfoDict valueForKey:@"EcoScoreDepreciation"] : @"0";
            NSNumber *ecoValCalculate = @(e_one.intValue + e_two.intValue + e_three.intValue + e_four.intValue + e_five.intValue);
            [self.mainEcoDrivingLbl countFrom:0 to:ecoValCalculate.intValue];
            if (ecoValCalculate.intValue < 0) { self.mainEcoDrivingLbl.textColor = [Color officialRedColor]; } else if (ecoValCalculate.intValue == 0) { self.mainEcoDrivingLbl.textColor = [Color darkGrayColor83]; } else { self.mainEcoDrivingLbl.textColor = [Color officialMainAppColor]; };
            
            self.factor_ecoScoreLbl.text = [coinsAllInfoDict valueForKey:@"EcoScore"] ? [coinsAllInfoDict valueForKey:@"EcoScore"] : @"0";
            self.factor_ecoBrakingLbl.text = [coinsAllInfoDict valueForKey:@"EcoScoreBrakes"] ? [coinsAllInfoDict valueForKey:@"EcoScoreBrakes"] : @"0";
            self.factor_ecoFuelLbl.text = [coinsAllInfoDict valueForKey:@"EcoScoreFuel"] ? [coinsAllInfoDict valueForKey:@"EcoScoreFuel"] : @"0";
            self.factor_ecoTiresLbl.text = [coinsAllInfoDict valueForKey:@"EcoScoreTyres"] ? [coinsAllInfoDict valueForKey:@"EcoScoreTyres"] : @"0";
            self.factor_ecoCostOwnershipLbl.text = [coinsAllInfoDict valueForKey:@"EcoScoreDepreciation"] ? [coinsAllInfoDict valueForKey:@"EcoScoreDepreciation"] : @"0";
            
            if (e_one.intValue < 0) { self.factor_ecoScoreLbl.textColor = [Color officialRedColor]; } else if (e_one.intValue == 0) { self.factor_ecoScoreLbl.textColor = [Color darkGrayColor83]; } else { self.factor_ecoScoreLbl.textColor = [Color officialMainAppColor]; };
            if (e_two.intValue < 0) { self.factor_ecoBrakingLbl.textColor = [Color officialRedColor]; } else if (e_two.intValue == 0) { self.factor_ecoBrakingLbl.textColor = [Color darkGrayColor83]; } else { self.factor_ecoBrakingLbl.textColor = [Color officialMainAppColor]; };
            if (e_three.intValue < 0) { self.factor_ecoFuelLbl.textColor = [Color officialRedColor]; } else if (e_three.intValue == 0) { self.factor_ecoFuelLbl.textColor = [Color darkGrayColor83]; } else { self.factor_ecoFuelLbl.textColor = [Color officialMainAppColor]; };
            if (e_four.intValue < 0) { self.factor_ecoTiresLbl.textColor = [Color officialRedColor]; } else if (e_four.intValue == 0) { self.factor_ecoTiresLbl.textColor = [Color darkGrayColor83]; } else { self.factor_ecoTiresLbl.textColor = [Color officialMainAppColor]; };
            if (e_five.intValue < 0) { self.factor_ecoCostOwnershipLbl.textColor = [Color officialRedColor]; } else if (e_five.intValue == 0) { self.factor_ecoCostOwnershipLbl.textColor = [Color darkGrayColor83]; } else { self.factor_ecoCostOwnershipLbl.textColor = [Color officialMainAppColor]; };
            
        } else {
            NSLog(@"%s %@ %@", __func__, response, error);
            self.factor_coinMileageLbl.text = @"0";
            self.factor_coinDurationLbl.text = @"0";
            self.factor_coinAccelerationLbl.text = @"0";
            self.factor_coinBrakingLbl.text = @"0";
            self.factor_coinCorneringLbl.text = @"0";
            self.factor_coinPhoneUsageLbl.text = @"0";
            self.factor_coinSpeedingLbl.text = @"0";
            
            [self.mainSafeDrivingLbl countFrom:0 to:0];
            self.factor_safeSectorLbl.text = @"0";
            [self.mainEcoDrivingLbl countFrom:0 to:0];
            
            self.factor_ecoScoreLbl.text = @"0";
            self.factor_ecoBrakingLbl.text = @"0";
            self.factor_ecoFuelLbl.text = @"0";
            self.factor_ecoTiresLbl.text = @"0";
            self.factor_ecoCostOwnershipLbl.text = @"0";
        }
    }] getCoinsDetailed:sDate endDate:eDate];
}


#pragma mark - Fetch detailed indicators

//2
- (void)getIndicatorsForCoinsStatisticTime:(NSDate *)startDate endDate:(NSDate *)endDate {
    
    NSString *sDate = [startDate dateTimeStringSpecial];
    NSString *eDate = [endDate dateTimeStringSpecial];
    
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        NSLog(@"%s %@ %@", __func__, response, error);
        if (!error && [response isSuccesful]) {
            self.indicators = ((IndicatorsResponse *)response).Result;
            
            NSString *mileageKmIndicator = [NSString stringWithFormat:@"%.0f km", self.indicators.MileageKm.floatValue];
            if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
                float konvertInMiles = convertKmToMiles(self.indicators.MileageKm.floatValue);
                mileageKmIndicator = [NSString stringWithFormat:@"%.1f mi", konvertInMiles];
            }
            self.factor_valueMileageLbl.text = mileageKmIndicator;
            
            float durationHours = self.indicators.DrivingTime.floatValue/60;
            NSString *durationIndicator = [NSString stringWithFormat:@"%.0f h", durationHours];
            if (durationHours < 1) {
                durationIndicator = [NSString stringWithFormat:@"%.0f m", self.indicators.DrivingTime.floatValue]; //min
            }
            self.factor_valueDurationLbl.text = durationIndicator;

            NSString *accIndicator = [NSString stringWithFormat:@"%.0f", self.indicators.AccelerationCount.floatValue];
            self.factor_valueAccelerationLbl.text = accIndicator;

            NSString *brakeIndicator = [NSString stringWithFormat:@"%.0f", self.indicators.BrakingCount.floatValue];
            self.factor_valueBrakingLbl.text = brakeIndicator;

            NSString *corneringIndicator = [NSString stringWithFormat:@"%.0f", self.indicators.CorneringCount.floatValue];
            self.factor_valueCorneringLbl.text = corneringIndicator;

            float phoneUsageHours = self.indicators.DrivingTime.floatValue/60;
            NSString *phoneUsageIndicator = [NSString stringWithFormat:@"%.0f h", phoneUsageHours];
            if (phoneUsageHours < 1) {
                phoneUsageIndicator = [NSString stringWithFormat:@"%.0f m", self.indicators.PhoneUsageDurationMin.floatValue];
            }
            self.factor_valuePhoneUsageLbl.text = phoneUsageIndicator;

            NSString *speedIndicator = [NSString stringWithFormat:@"%.0f km", self.indicators.TotalSpeedingKm.floatValue];
            self.factor_valueSpeedingLbl.text = speedIndicator;
            if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
                float milesSpeeding = convertKmToMiles(self.indicators.TotalSpeedingKm.floatValue);
                self.factor_valueSpeedingLbl.text = [NSString stringWithFormat:@"%.1f mi", milesSpeeding];
            }
            
        } else {
            NSLog(@"%s %@ %@", __func__, response, error);
            
            self.factor_valueMileageLbl.text = @"";
            self.factor_valueDurationLbl.text = @"";
            self.factor_valueAccelerationLbl.text = @"";
            self.factor_valueBrakingLbl.text = @"";
            self.factor_valueCorneringLbl.text = @"";
            self.factor_valuePhoneUsageLbl.text = @"";
            self.factor_valueSpeedingLbl.text = @"";
        }
    }] getCoinsStatisticsIndividualForPeriod:sDate endDate:eDate];
}


#pragma mark - EcoPercent Backend

//3
- (void)getCoinsForEcoPercentCalculateWithDetails:(NSDate *)startDate endDate:(NSDate *)endDate {
    if (startDate == nil) {
        startDate = [NSDate date];
    }
    
    if (endDate == nil) {
        endDate = [NSDate date];
    }
    
    NSString *sDate = [startDate dateTimeStringSpecial];
    NSString *eDate = [endDate dateTimeStringSpecial];
    
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        NSLog(@"%s %@ %@", __func__, response, error);
        if (!error && [response isSuccesful]) {
            self.ecoPercents = ((EcoResponse *)response).Result;
            
            if (self.ecoPercents.EcoScore.floatValue > 81) {
                self.coins_progressBarEco.barFillColor = [Color officialGreenColor];
            } else if (self.ecoPercents.EcoScore.floatValue > 61) {
                self.coins_progressBarEco.barFillColor = [Color officialYellowColor];
            } else if (self.ecoPercents.EcoScore.floatValue > 41) {
                self.coins_progressBarEco.barFillColor = [Color officialOrangeColor];
            } else {
                self.coins_progressBarEco.barFillColor = [Color officialDarkRedColor];
            }
            
            if (self.ecoPercents.EcoScoreBrakes.floatValue > 81) {
                self.coins_progressBarBrakes.barFillColor = [Color officialGreenColor];
            } else if (self.ecoPercents.EcoScore.floatValue > 61) {
                self.coins_progressBarBrakes.barFillColor = [Color officialYellowColor];
            } else if (self.ecoPercents.EcoScore.floatValue > 41) {
                self.coins_progressBarBrakes.barFillColor = [Color officialOrangeColor];
            } else {
                self.coins_progressBarBrakes.barFillColor = [Color officialDarkRedColor];
            }
            
            if (self.ecoPercents.EcoScoreTyres.floatValue > 81) {
                self.coins_progressBarTyres.barFillColor = [Color officialGreenColor];
            } else if (self.ecoPercents.EcoScoreTyres.floatValue > 61) {
                self.coins_progressBarTyres.barFillColor = [Color officialYellowColor];
            } else if (self.ecoPercents.EcoScoreTyres.floatValue > 41) {
                self.coins_progressBarTyres.barFillColor = [Color officialOrangeColor];
            } else {
                self.coins_progressBarTyres.barFillColor = [Color officialDarkRedColor];
            }
            
            if (self.ecoPercents.EcoScoreFuel.floatValue > 81) {
                self.coins_progressBarFuel.barFillColor = [Color officialGreenColor];
            } else if (self.ecoPercents.EcoScoreFuel.floatValue > 61) {
                self.coins_progressBarFuel.barFillColor = [Color officialYellowColor];
            } else if (self.ecoPercents.EcoScoreFuel.floatValue > 41) {
                self.coins_progressBarFuel.barFillColor = [Color officialOrangeColor];
            } else {
                self.coins_progressBarFuel.barFillColor = [Color officialDarkRedColor];
            }
            
            if (self.ecoPercents.EcoScoreDepreciation.floatValue > 81) {
                self.coins_progressBarCost.barFillColor = [Color officialGreenColor];
            } else if (self.ecoPercents.EcoScoreDepreciation.floatValue > 61) {
                self.coins_progressBarCost.barFillColor = [Color officialYellowColor];
            } else if (self.ecoPercents.EcoScoreDepreciation.floatValue > 41) {
                self.coins_progressBarCost.barFillColor = [Color officialOrangeColor];
            } else {
                self.coins_progressBarCost.barFillColor = [Color officialDarkRedColor];
            }
        } else {
            self.ecoPercents = nil;
            self.coins_progressBarEco.barFillColor = [Color officialGreenColor];
            self.coins_progressBarBrakes.barFillColor = [Color officialGreenColor];
            self.coins_progressBarTyres.barFillColor = [Color officialGreenColor];
            self.coins_progressBarFuel.barFillColor = [Color officialGreenColor];
            self.coins_progressBarCost.barFillColor = [Color officialGreenColor];
        }
        
        self.coins_progressBarEco.progress = 0.0f;
        self.coins_progressBarBrakes.progress = 0.0f;
        self.coins_progressBarFuel.progress = 0.0f;
        self.coins_progressBarTyres.progress = 0.0f;
        self.coins_progressBarCost.progress = 0.0f;
        
        self.coins_timerEco = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(incrementCoinsTimerEco:) userInfo:nil repeats:YES];
        self.coins_timerBrakes = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(incrementCoinsTimerBrakes:) userInfo:nil repeats:YES];
        self.coins_timerFuel = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(incrementCoinsTimerFuel:) userInfo:nil repeats:YES];
        self.coins_timerTyres = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(incrementCoinsTimerTyres:) userInfo:nil repeats:YES];
        self.coins_timerCost = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(incrementCoinsTimerCost:) userInfo:nil repeats:YES];
    }] getIndicatorsIndividualForPeriod:sDate endDate:eDate];
}


#pragma mark - Streaks Backend

- (void)startFetchStreaksImmediatily {
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        NSLog(@"%s %@ %@", __func__, response, error);
        if (!error && [response isSuccesful]) {
            self.streaks = ((StreaksResponse *)response).Result;
            NSLog(@"Streaks Ok");
            [self.streaksTableView reloadData];
        } else {
            NSLog(@"%s %@ %@", __func__, response, error);
        }
    }] getIndicatorsStreaksSection];
}


#pragma mark - Fetch daily coins 2 weeks & graph setup

- (void)getCoinsEverydayDetailsForGraph:(NSDate *)startDate endDate:(NSDate *)endDate {
    if (startDate == nil) {
        startDate = [NSDate date];
    }
    if (endDate == nil) {
        endDate = [NSDate date];
    }
    
    NSString *sDate = [startDate dateTimeStringSpecial];
    NSString *eDate = [endDate dateTimeStringSpecial];
    
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        NSLog(@"%s %@ %@", __func__, response, error);
        if (!error && [response isSuccesful]) {
            self.coinsDailyDetails = ((CoinsDetailsResponse *)response);
            [self loadDriveCoinsChart:0];
        } else {
            NSLog(@"%s %@ %@", __func__, response, error);
        }
    }] getCoinsDaily:sDate endDate:eDate];
}

- (void)loadDriveCoinsChart:(NSInteger)type {
    
    [_coinsChartView clearChartData];
    
    NSMutableArray* chartData = [NSMutableArray arrayWithCapacity:self.coinsDailyDetails.Result.count];
    if (self.coinsDailyDetails.Result.count == 0) {
        chartData = [NSMutableArray arrayWithCapacity:7];
        for (int i=0; i < 7; i++) {
            chartData[i] = [NSNumber numberWithFloat: (float)i / 55.0f + (float)(rand() % 100) / 500.0f];
        }
    } else {
        for (int i=0; i < self.coinsDailyDetails.Result.count; i++) {
            
            CoinsDetailsObject *ddObj = self.coinsDailyDetails.Result[i];
            NSNumber *valueCoins = ddObj.TotalEarnedCoins;
            chartData[i] = [NSNumber numberWithFloat:valueCoins.floatValue];
            if (self.coinsDailyDetails.Result.count == 1) {
                chartData[i+1] = [NSNumber numberWithFloat:valueCoins.floatValue];
            }
        }
    }
    
    if (chartData.count == 2) {
        int firstValue = [[chartData objectAtIndex:0] intValue];
        int secondValue = [[chartData objectAtIndex:1] intValue];
        int fakeValueAverage = firstValue + secondValue / 2;
        int fakeValueAdditional = firstValue + secondValue / 6;
        
        int finValue = fakeValueAverage + fakeValueAdditional;
        NSNumber *needNumber = [NSNumber numberWithInteger:finValue];
        [chartData insertObject:needNumber atIndex:1];
    }
    
    //SAMPLE DEMO DAYS IF NO DATA
    NSMutableArray* daysWeek = [NSMutableArray arrayWithObjects:
                                localizeString(@"Monday"),
                                localizeString(@"Tuesday"),
                                localizeString(@"Wednesday"),
                                localizeString(@"Thursday"),
                                localizeString(@"Friday"),
                                localizeString(@"Saturday"),
                                @"", nil];
    if (self.coinsDailyDetails.Result.count == 0) {
        daysWeek = [NSMutableArray arrayWithObjects:localizeString(@"Monday"), localizeString(@"Tuesday"), localizeString(@"Wednesday"), localizeString(@"Thursday"), localizeString(@"Friday"), localizeString(@"Saturday"), @"", nil];
    } else {
        daysWeek = [NSMutableArray arrayWithCapacity:self.coinsDailyDetails.Result.count];
        
        for (int i=0; i < self.coinsDailyDetails.Result.count; i++) {
            
            CoinsDetailsObject *ccObj = self.coinsDailyDetails.Result[i];
            NSString *currentDateValue = ccObj.DateUpdated;
            if (currentDateValue == nil)
                return;
            NSDate *dateStart = [NSDate dateWithISO8601String:currentDateValue];
            NSString *dateStartFormat = [dateStart dayDateShort];

            if (i == self.coinsDailyDetails.Result.count - 1) {
                if (self.coinsDailyDetails.Result.count == 1) {
                    daysWeek[i] = dateStartFormat;
                    daysWeek[i+1] = @"";
                } else {
                    daysWeek[i] = dateStartFormat;
                }
            } else {
                daysWeek[i] = dateStartFormat;
            }
        }
    }
    
    if (daysWeek.count == 2) {
        [daysWeek insertObject:@"" atIndex:1];
    }
    
    _coinsChartView.verticalGridStep = 1;
    if (self.coinsDailyDetails.Result.count <=4 && self.coinsDailyDetails.Result != nil) {
        _coinsChartView.horizontalGridStep = (int)self.coinsDailyDetails.Result.count;
    } else if (self.coinsDailyDetails.Result != nil) {
        _coinsChartView.horizontalGridStep = (int)self.coinsDailyDetails.Result.count;
    } else {
        _coinsChartView.horizontalGridStep = 5;
    }
    
    _coinsChartView.fillColor = [[Color officialGreenColor] colorWithAlphaComponent:0.1];
    _coinsChartView.displayDataPoint = YES;
    _coinsChartView.lineWidth = 3;
    _coinsChartView.dataPointColor = [Color officialGreenColor];
    _coinsChartView.dataPointBackgroundColor = [Color officialGreenColor];
    _coinsChartView.dataPointRadius = 0;
    _coinsChartView.color = [_coinsChartView.dataPointColor colorWithAlphaComponent:1.0];
    _coinsChartView.valueLabelPosition = ValueLabelLeftMirrored;
    _coinsChartView.hidden = NO;
    
    _coinsChartView.labelForValue = ^(CGFloat value) {
        return [NSString stringWithFormat:@"%.f", value];
    };
    _coinsChartView.labelForIndex = ^(NSUInteger item) {
        return daysWeek[item];
    };
    
    [_coinsChartView setChartData:chartData];
}


#pragma mark - Streaks TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 185;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StreakCell *streakCell = [tableView dequeueReusableCellWithIdentifier:@"StreakCell"];
    if (indexPath.row == 0) {
        
        //STREAK TITLE ACCELERATION
        streakCell.mainTitleLbl.text = @"Trips Without Harsh Acceleration";
        streakCell.mainStreakImg.image = [UIImage imageNamed:@"streak_up"];
        
        //FIRST SECTION
        float roundCurrentDistance = [self.streaks.StreakAccelerationCurrentDistanceKm floatValue];
        NSString *currentDistanceString = [NSString stringWithFormat:@"%.0f km", roundCurrentDistance];
        
        float roundCurrentDuration = [self.streaks.StreakAccelerationCurrentDurationSec floatValue] / 60;
        NSString *currentDurationString = [NSString stringWithFormat:@"%.0f m", roundCurrentDuration];
        
        float roundBestDistance = [self.streaks.StreakAccelerationBestDistanceKm floatValue];
        NSString *bestDistanceString = [NSString stringWithFormat:@"%.f km", roundBestDistance];
        
        float roundBestDuration = [self.streaks.StreakAccelerationBestDurationSec floatValue] / 60;
        NSString *bestDurationString = [NSString stringWithFormat:@"%.0f m", roundBestDuration];
        
        //Miles convert
        if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
            float currentInMiles = convertKmToMiles(roundCurrentDistance);
            currentDistanceString = [NSString stringWithFormat:@"%.1f mi", currentInMiles];
            float bestInMiles = convertKmToMiles(roundBestDistance);
            bestDistanceString = [NSString stringWithFormat:@"%.1f mi", bestInMiles];
        }
        
        NSString *currentFinal = [NSString stringWithFormat:@"%@  |  %@", currentDistanceString, currentDurationString];
        NSString *bestFinal = [NSString stringWithFormat:@"%@  |  %@", bestDistanceString, bestDurationString];
        
        streakCell.currentValueLbl.text = currentFinal;
        streakCell.bestValueLbl.text = bestFinal;
        
        //SECOND SECTION ATTRIBUTED STRING CURRENT
        NSString *currentStreakCounter = self.streaks.StreakAccelerationCurrentStreak.stringValue ? self.streaks.StreakAccelerationCurrentStreak.stringValue : @"0";
        NSString *currentStreakItem = localizeString(@"trips"); //if ([currentStreakCounter isEqualToString:@""]) { currentStreakItem = @""; };
        NSString *currentStreakString = [NSString stringWithFormat:@"%@ %@", currentStreakCounter, currentStreakItem];
        
        NSMutableAttributedString *currentStreakCompleteText = [[NSMutableAttributedString alloc] initWithString:currentStreakString];
        
        NSRange currentRangeTotalPoints = [currentStreakString rangeOfString:currentStreakCounter];
        UIFont *currentFontTotalPoints = [Font heavy26];
        [currentStreakCompleteText addAttribute:NSForegroundColorAttributeName value:[Color officialGreenColor] range:currentRangeTotalPoints];
        [currentStreakCompleteText addAttribute:NSFontAttributeName value:currentFontTotalPoints range:currentRangeTotalPoints];
        
        NSRange currentRangeTripsAdd = [currentStreakString rangeOfString:currentStreakItem];
        UIFont *currentFontTripsAdd = [Font medium15];
        [currentStreakCompleteText addAttribute:NSForegroundColorAttributeName value:[Color tabBarDarkColor] range:currentRangeTripsAdd];
        [currentStreakCompleteText addAttribute:NSFontAttributeName value:currentFontTripsAdd range:currentRangeTripsAdd];
        
        //SECOND SECTION ATTRIBUTED STRING BEST
        NSString *bestStreakCounter = self.streaks.StreakAccelerationBest.stringValue ? self.streaks.StreakAccelerationBest.stringValue : @"0";
        NSString *bestStreakItem = localizeString(@"trips");
        NSString *bestStreakString = [NSString stringWithFormat:@"%@ %@", bestStreakCounter, bestStreakItem];
        
        NSMutableAttributedString *bestStreakCompleteText = [[NSMutableAttributedString alloc] initWithString:bestStreakString];
        
        NSRange bestRangeTotalPoints = [bestStreakString rangeOfString:bestStreakCounter];
        UIFont *bestFontTotalPoints = [Font heavy26];
        [bestStreakCompleteText addAttribute:NSForegroundColorAttributeName value:[Color tabBarDarkColor] range:bestRangeTotalPoints];
        [bestStreakCompleteText addAttribute:NSFontAttributeName value:bestFontTotalPoints range:bestRangeTotalPoints];
        
        NSRange bestRangeTripsAdd = [bestStreakString rangeOfString:bestStreakItem];
        UIFont *bestFontTripsAdd = [Font medium15];
        [bestStreakCompleteText addAttribute:NSForegroundColorAttributeName value:[Color tabBarDarkColor] range:bestRangeTripsAdd];
        [bestStreakCompleteText addAttribute:NSFontAttributeName value:bestFontTripsAdd range:bestRangeTripsAdd];
        
        streakCell.section1ValueLbl.attributedText = currentStreakCompleteText;
        streakCell.section2ValueLbl.attributedText = bestStreakCompleteText;
        
        //THIRD SECTION
        NSDate *currentStartDate = [NSDate dateWithISO8601String:self.streaks.StreakAccelerationCurrentFromDate];
        NSDate *currentEndDate = [NSDate dateWithISO8601String:self.streaks.StreakAccelerationCurrentToDate];
        NSString *currentStartDateString = [currentStartDate dateStringShortYear];
        NSString *currentEndDateString = [currentEndDate dateStringShortYear];
        
        NSDate *bestStartDate = [NSDate dateWithISO8601String:self.streaks.StreakAccelerationBestFromDate];
        NSDate *bestEndDate = [NSDate dateWithISO8601String:self.streaks.StreakAccelerationBestToDate];
        NSString *bestStartDateString = [bestStartDate dateStringShortYear];
        NSString *bestEndDateString = [bestEndDate dateStringShortYear];
        
        if ([defaults_object(@"needDateFormatInverse") boolValue]) {
            currentStartDateString = [currentStartDate dateStringShortYearInverse];
            currentEndDateString = [currentEndDate dateStringShortYearInverse];
            bestStartDateString = [bestStartDate dateStringShortYearInverse];
            bestEndDateString = [bestEndDate dateStringShortYearInverse];
        }
        
        NSString *currentTimeFinal = [NSString stringWithFormat:@"%@ to %@", currentStartDateString, currentEndDateString];
        NSString *bestTimeFinal = [NSString stringWithFormat:@"%@ to %@", bestStartDateString, bestEndDateString];
        
        streakCell.dateTimeSection1Lbl.text = currentTimeFinal;
        streakCell.dateTimeSection2Lbl.text = bestTimeFinal;
        
        if (currentStartDate == nil) {
            streakCell.currentValueLbl.text = localizeString(@"You haven’t had");
            streakCell.bestValueLbl.text = localizeString(@"You haven’t had");
            streakCell.dateTimeSection1Lbl.text = localizeString(@"a best yet");
            streakCell.dateTimeSection2Lbl.text = localizeString(@"a best yet");
            streakCell.currentValueLbl.textColor = [Color darkGrayColor83];
            streakCell.bestValueLbl.textColor = [Color darkGrayColor83];
            streakCell.dateTimeSection1Lbl.textColor = [Color darkGrayColor83];
            streakCell.dateTimeSection2Lbl.textColor = [Color darkGrayColor83];
        }
        
    } else if (indexPath.row == 1) {
        
        //STREAK TITLE BRAKING
        streakCell.mainTitleLbl.text = @"Trips Without Hard Braking";
        streakCell.mainStreakImg.image = [UIImage imageNamed:@"lead_deceleration"];
        
        //FIRST SECTION
        float roundCurrentDistance = [self.streaks.StreakBrakingCurrentDistanceKm floatValue];
        NSString *currentDistanceString = [NSString stringWithFormat:@"%.0f km", roundCurrentDistance];
        
        float roundCurrentDuration = [self.streaks.StreakBrakingCurrentDurationSec floatValue] / 60;
        NSString *currentDurationString = [NSString stringWithFormat:@"%.0f m", roundCurrentDuration];
        
        float roundBestDistance = [self.streaks.StreakBrakingBestDistanceKm floatValue];
        NSString *bestDistanceString = [NSString stringWithFormat:@"%.f km", roundBestDistance];
        
        float roundBestDuration = [self.streaks.StreakBrakingBestDurationSec floatValue] / 60;
        NSString *bestDurationString = [NSString stringWithFormat:@"%.0f m", roundBestDuration];
        
        //Miles convert
        if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
            float currentInMiles = convertKmToMiles(roundCurrentDistance);
            currentDistanceString = [NSString stringWithFormat:@"%.1f mi", currentInMiles];
            float bestInMiles = convertKmToMiles(roundBestDistance);
            bestDistanceString = [NSString stringWithFormat:@"%.1f mi", bestInMiles];
        }
        
        NSString *currentFinal = [NSString stringWithFormat:@"%@  |  %@", currentDistanceString, currentDurationString];
        NSString *bestFinal = [NSString stringWithFormat:@"%@  |  %@", bestDistanceString, bestDurationString];
        
        streakCell.currentValueLbl.text = currentFinal;
        streakCell.bestValueLbl.text = bestFinal;
        
        //SECOND SECTION ATTRIBUTED STRING CURRENT
        NSString *currentStreakCounter = self.streaks.StreakBrakingCurrentStreak.stringValue ? self.streaks.StreakBrakingCurrentStreak.stringValue : @"0";
        NSString *currentStreakItem = localizeString(@"trips");
        NSString *currentStreakString = [NSString stringWithFormat:@"%@ %@", currentStreakCounter, currentStreakItem];
        
        NSMutableAttributedString *currentStreakCompleteText = [[NSMutableAttributedString alloc] initWithString:currentStreakString];
        
        NSRange currentRangeTotalPoints = [currentStreakString rangeOfString:currentStreakCounter];
        UIFont *currentFontTotalPoints = [Font heavy26];
        [currentStreakCompleteText addAttribute:NSForegroundColorAttributeName value:[Color officialGreenColor] range:currentRangeTotalPoints];
        [currentStreakCompleteText addAttribute:NSFontAttributeName value:currentFontTotalPoints range:currentRangeTotalPoints];
        
        NSRange currentRangeTripsAdd = [currentStreakString rangeOfString:currentStreakItem];
        UIFont *currentFontTripsAdd = [Font medium15];
        [currentStreakCompleteText addAttribute:NSForegroundColorAttributeName value:[Color tabBarDarkColor] range:currentRangeTripsAdd];
        [currentStreakCompleteText addAttribute:NSFontAttributeName value:currentFontTripsAdd range:currentRangeTripsAdd];
        
        //SECOND SECTION ATTRIBUTED STRING BEST
        NSString *bestStreakCounter = self.streaks.StreakBrakingBest.stringValue ? self.streaks.StreakBrakingBest.stringValue : @"0";
        NSString *bestStreakItem = localizeString(@"trips");
        NSString *bestStreakString = [NSString stringWithFormat:@"%@ %@", bestStreakCounter, bestStreakItem];
        
        NSMutableAttributedString *bestStreakCompleteText = [[NSMutableAttributedString alloc] initWithString:bestStreakString];
        
        NSRange bestRangeTotalPoints = [bestStreakString rangeOfString:bestStreakCounter];
        UIFont *bestFontTotalPoints = [Font heavy26];
        [bestStreakCompleteText addAttribute:NSForegroundColorAttributeName value:[Color tabBarDarkColor] range:bestRangeTotalPoints];
        [bestStreakCompleteText addAttribute:NSFontAttributeName value:bestFontTotalPoints range:bestRangeTotalPoints];
        
        NSRange bestRangeTripsAdd = [bestStreakString rangeOfString:bestStreakItem];
        UIFont *bestFontTripsAdd = [Font medium15];
        [bestStreakCompleteText addAttribute:NSForegroundColorAttributeName value:[Color tabBarDarkColor] range:bestRangeTripsAdd];
        [bestStreakCompleteText addAttribute:NSFontAttributeName value:bestFontTripsAdd range:bestRangeTripsAdd];
        
        streakCell.section1ValueLbl.attributedText = currentStreakCompleteText;
        streakCell.section2ValueLbl.attributedText = bestStreakCompleteText;
        
        //THIRD SECTION
        NSDate *currentStartDate = [NSDate dateWithISO8601String:self.streaks.StreakBrakingCurrentFromDate];
        NSDate *currentEndDate = [NSDate dateWithISO8601String:self.streaks.StreakBrakingCurrentToDate];
        NSString *currentStartDateString = [currentStartDate dateStringShortYear];
        NSString *currentEndDateString = [currentEndDate dateStringShortYear];
        
        NSDate *bestStartDate = [NSDate dateWithISO8601String:self.streaks.StreakBrakingBestFromDate];
        NSDate *bestEndDate = [NSDate dateWithISO8601String:self.streaks.StreakBrakingBestToDate];
        NSString *bestStartDateString = [bestStartDate dateStringShortYear];
        NSString *bestEndDateString = [bestEndDate dateStringShortYear];
        
        if ([defaults_object(@"needDateFormatInverse") boolValue]) {
            currentStartDateString = [currentStartDate dateStringShortYearInverse];
            currentEndDateString = [currentEndDate dateStringShortYearInverse];
            bestStartDateString = [bestStartDate dateStringShortYearInverse];
            bestEndDateString = [bestEndDate dateStringShortYearInverse];
        }
        
        NSString *currentTimeFinal = [NSString stringWithFormat:@"%@ to %@", currentStartDateString, currentEndDateString];
        NSString *bestTimeFinal = [NSString stringWithFormat:@"%@ to %@", bestStartDateString, bestEndDateString];
        
        streakCell.dateTimeSection1Lbl.text = currentTimeFinal;
        streakCell.dateTimeSection2Lbl.text = bestTimeFinal;
        
        if (currentStartDate == nil) {
            streakCell.currentValueLbl.text = localizeString(@"You haven’t had");
            streakCell.bestValueLbl.text = localizeString(@"You haven’t had");
            streakCell.dateTimeSection1Lbl.text = localizeString(@"a best yet");
            streakCell.dateTimeSection2Lbl.text = localizeString(@"a best yet");
            streakCell.currentValueLbl.textColor = [Color darkGrayColor83];
            streakCell.bestValueLbl.textColor = [Color darkGrayColor83];
            streakCell.dateTimeSection1Lbl.textColor = [Color darkGrayColor83];
            streakCell.dateTimeSection2Lbl.textColor = [Color darkGrayColor83];
        }
        
    } else if (indexPath.row == 2) {
        
        //STREAK TITLE CORNERING
        streakCell.mainTitleLbl.text = @"Trips Without Hard Cornering";
        streakCell.mainStreakImg.image = [UIImage imageNamed:@"lead_cornering"];
        
        //FIRST SECTION
        float roundCurrentDistance = [self.streaks.StreakCorneringCurrentDistanceKm floatValue];
        NSString *currentDistanceString = [NSString stringWithFormat:@"%.0f km", roundCurrentDistance];
        
        float roundCurrentDuration = [self.streaks.StreakCorneringCurrentDurationSec floatValue] / 60;
        NSString *currentDurationString = [NSString stringWithFormat:@"%.0f m", roundCurrentDuration];
        
        float roundBestDistance = [self.streaks.StreakCorneringBestDistanceKm floatValue];
        NSString *bestDistanceString = [NSString stringWithFormat:@"%.f km", roundBestDistance];
        
        float roundBestDuration = [self.streaks.StreakCorneringBestDurationSec floatValue] / 60;
        NSString *bestDurationString = [NSString stringWithFormat:@"%.0f m", roundBestDuration];
        
        //Miles convert
        if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
            float currentInMiles = convertKmToMiles(roundCurrentDistance);
            currentDistanceString = [NSString stringWithFormat:@"%.1f mi", currentInMiles];
            float bestInMiles = convertKmToMiles(roundBestDistance);
            bestDistanceString = [NSString stringWithFormat:@"%.1f mi", bestInMiles];
        }
        
        NSString *currentFinal = [NSString stringWithFormat:@"%@  |  %@", currentDistanceString, currentDurationString];
        NSString *bestFinal = [NSString stringWithFormat:@"%@  |  %@", bestDistanceString, bestDurationString];
        
        streakCell.currentValueLbl.text = currentFinal;
        streakCell.bestValueLbl.text = bestFinal;
        
        //SECOND SECTION ATTRIBUTED STRING CURRENT
        NSString *currentStreakCounter = self.streaks.StreakCorneringCurrentStreak.stringValue ? self.streaks.StreakCorneringCurrentStreak.stringValue : @"0";
        NSString *currentStreakItem = localizeString(@"trips");
        NSString *currentStreakString = [NSString stringWithFormat:@"%@ %@", currentStreakCounter, currentStreakItem];
        
        NSMutableAttributedString *currentStreakCompleteText = [[NSMutableAttributedString alloc] initWithString:currentStreakString];
        
        NSRange currentRangeTotalPoints = [currentStreakString rangeOfString:currentStreakCounter];
        UIFont *currentFontTotalPoints = [Font heavy26];
        [currentStreakCompleteText addAttribute:NSForegroundColorAttributeName value:[Color officialGreenColor] range:currentRangeTotalPoints];
        [currentStreakCompleteText addAttribute:NSFontAttributeName value:currentFontTotalPoints range:currentRangeTotalPoints];
        
        NSRange currentRangeTripsAdd = [currentStreakString rangeOfString:currentStreakItem];
        UIFont *currentFontTripsAdd = [Font medium15];
        [currentStreakCompleteText addAttribute:NSForegroundColorAttributeName value:[Color tabBarDarkColor] range:currentRangeTripsAdd];
        [currentStreakCompleteText addAttribute:NSFontAttributeName value:currentFontTripsAdd range:currentRangeTripsAdd];
        
        //SECOND SECTION ATTRIBUTED STRING BEST
        NSString *bestStreakCounter = self.streaks.StreakCorneringBest.stringValue ? self.streaks.StreakCorneringBest.stringValue : @"0";
        NSString *bestStreakItem = localizeString(@"trips");
        NSString *bestStreakString = [NSString stringWithFormat:@"%@ %@", bestStreakCounter, bestStreakItem];
        
        NSMutableAttributedString *bestStreakCompleteText = [[NSMutableAttributedString alloc] initWithString:bestStreakString];
        
        NSRange bestRangeTotalPoints = [bestStreakString rangeOfString:bestStreakCounter];
        UIFont *bestFontTotalPoints = [Font heavy26];
        [bestStreakCompleteText addAttribute:NSForegroundColorAttributeName value:[Color tabBarDarkColor] range:bestRangeTotalPoints];
        [bestStreakCompleteText addAttribute:NSFontAttributeName value:bestFontTotalPoints range:bestRangeTotalPoints];
        
        NSRange bestRangeTripsAdd = [bestStreakString rangeOfString:bestStreakItem];
        UIFont *bestFontTripsAdd = [Font medium15];
        [bestStreakCompleteText addAttribute:NSForegroundColorAttributeName value:[Color tabBarDarkColor] range:bestRangeTripsAdd];
        [bestStreakCompleteText addAttribute:NSFontAttributeName value:bestFontTripsAdd range:bestRangeTripsAdd];
        
        streakCell.section1ValueLbl.attributedText = currentStreakCompleteText;
        streakCell.section2ValueLbl.attributedText = bestStreakCompleteText;
        
        //THIRD SECTION
        NSDate *currentStartDate = [NSDate dateWithISO8601String:self.streaks.StreakCorneringCurrentFromDate];
        NSDate *currentEndDate = [NSDate dateWithISO8601String:self.streaks.StreakCorneringCurrentToDate];
        NSString *currentStartDateString = [currentStartDate dateStringShortYear];
        NSString *currentEndDateString = [currentEndDate dateStringShortYear];
        
        NSDate *bestStartDate = [NSDate dateWithISO8601String:self.streaks.StreakCorneringBestFromDate];
        NSDate *bestEndDate = [NSDate dateWithISO8601String:self.streaks.StreakCorneringBestToDate];
        NSString *bestStartDateString = [bestStartDate dateStringShortYear];
        NSString *bestEndDateString = [bestEndDate dateStringShortYear];
        
        if ([defaults_object(@"needDateFormatInverse") boolValue]) {
            currentStartDateString = [currentStartDate dateStringShortYearInverse];
            currentEndDateString = [currentEndDate dateStringShortYearInverse];
            bestStartDateString = [bestStartDate dateStringShortYearInverse];
            bestEndDateString = [bestEndDate dateStringShortYearInverse];
        }
        
        NSString *currentTimeFinal = [NSString stringWithFormat:@"%@ to %@", currentStartDateString, currentEndDateString];
        NSString *bestTimeFinal = [NSString stringWithFormat:@"%@ to %@", bestStartDateString, bestEndDateString];
        
        streakCell.dateTimeSection1Lbl.text = currentTimeFinal;
        streakCell.dateTimeSection2Lbl.text = bestTimeFinal;
        
        if (currentStartDate == nil) {
            streakCell.currentValueLbl.text = localizeString(@"You haven’t had");
            streakCell.bestValueLbl.text = localizeString(@"You haven’t had");
            streakCell.dateTimeSection1Lbl.text = localizeString(@"a best yet");
            streakCell.dateTimeSection2Lbl.text = localizeString(@"a best yet");
            streakCell.currentValueLbl.textColor = [Color darkGrayColor83];
            streakCell.bestValueLbl.textColor = [Color darkGrayColor83];
            streakCell.dateTimeSection1Lbl.textColor = [Color darkGrayColor83];
            streakCell.dateTimeSection2Lbl.textColor = [Color darkGrayColor83];
        }
        
    } else if (indexPath.row == 3) {
        
        //STREAK TITLE SPEEDING
        streakCell.mainTitleLbl.text = @"Trips Without Speeding";
        streakCell.mainStreakImg.image = [UIImage imageNamed:@"lead_acceleration"];
        
        //FIRST SECTION
        float roundCurrentDistance = [self.streaks.StreakOverSpeedCurrentDistanceKm floatValue];
        NSString *currentDistanceString = [NSString stringWithFormat:@"%.0f km", roundCurrentDistance];
        
        float roundCurrentDuration = [self.streaks.StreakOverSpeedCurrentDurationSec floatValue] / 60;
        NSString *currentDurationString = [NSString stringWithFormat:@"%.0f m", roundCurrentDuration];
        
        float roundBestDistance = [self.streaks.StreakOverSpeedBestDistanceKm floatValue];
        NSString *bestDistanceString = [NSString stringWithFormat:@"%.f km", roundBestDistance];
        
        float roundBestDuration = [self.streaks.StreakOverSpeedBestDurationSec floatValue] / 60;
        NSString *bestDurationString = [NSString stringWithFormat:@"%.0f m", roundBestDuration];
        
        //Miles convert
        if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
            float currentInMiles = convertKmToMiles(roundCurrentDistance);
            currentDistanceString = [NSString stringWithFormat:@"%.1f mi", currentInMiles];
            float bestInMiles = convertKmToMiles(roundBestDistance);
            bestDistanceString = [NSString stringWithFormat:@"%.1f mi", bestInMiles];
        }
        
        NSString *currentFinal = [NSString stringWithFormat:@"%@  |  %@", currentDistanceString, currentDurationString];
        NSString *bestFinal = [NSString stringWithFormat:@"%@  |  %@", bestDistanceString, bestDurationString];
        
        streakCell.currentValueLbl.text = currentFinal;
        streakCell.bestValueLbl.text = bestFinal;
        
        //SECOND SECTION ATTRIBUTED STRING CURRENT
        NSString *currentStreakCounter = self.streaks.StreakOverSpeedCurrentStreak.stringValue ? self.streaks.StreakOverSpeedCurrentStreak.stringValue : @"0";
        NSString *currentStreakItem = localizeString(@"trips");
        NSString *currentStreakString = [NSString stringWithFormat:@"%@ %@", currentStreakCounter, currentStreakItem];
        
        NSMutableAttributedString *currentStreakCompleteText = [[NSMutableAttributedString alloc] initWithString:currentStreakString];
        
        NSRange currentRangeTotalPoints = [currentStreakString rangeOfString:currentStreakCounter];
        UIFont *currentFontTotalPoints = [Font heavy26];
        [currentStreakCompleteText addAttribute:NSForegroundColorAttributeName value:[Color officialGreenColor] range:currentRangeTotalPoints];
        [currentStreakCompleteText addAttribute:NSFontAttributeName value:currentFontTotalPoints range:currentRangeTotalPoints];
        
        NSRange currentRangeTripsAdd = [currentStreakString rangeOfString:currentStreakItem];
        UIFont *currentFontTripsAdd = [Font medium15];
        [currentStreakCompleteText addAttribute:NSForegroundColorAttributeName value:[Color tabBarDarkColor] range:currentRangeTripsAdd];
        [currentStreakCompleteText addAttribute:NSFontAttributeName value:currentFontTripsAdd range:currentRangeTripsAdd];
        
        //SECOND SECTION ATTRIBUTED STRING BEST
        NSString *bestStreakCounter = self.streaks.StreakOverSpeedBest.stringValue ? self.streaks.StreakOverSpeedBest.stringValue : @"0";
        NSString *bestStreakItem = localizeString(@"trips");
        NSString *bestStreakString = [NSString stringWithFormat:@"%@ %@", bestStreakCounter, bestStreakItem];
        
        NSMutableAttributedString *bestStreakCompleteText = [[NSMutableAttributedString alloc] initWithString:bestStreakString];
        
        NSRange bestRangeTotalPoints = [bestStreakString rangeOfString:bestStreakCounter];
        UIFont *bestFontTotalPoints = [Font heavy26];
        [bestStreakCompleteText addAttribute:NSForegroundColorAttributeName value:[Color tabBarDarkColor] range:bestRangeTotalPoints];
        [bestStreakCompleteText addAttribute:NSFontAttributeName value:bestFontTotalPoints range:bestRangeTotalPoints];
        
        NSRange bestRangeTripsAdd = [bestStreakString rangeOfString:bestStreakItem];
        UIFont *bestFontTripsAdd = [Font medium15];
        [bestStreakCompleteText addAttribute:NSForegroundColorAttributeName value:[Color tabBarDarkColor] range:bestRangeTripsAdd];
        [bestStreakCompleteText addAttribute:NSFontAttributeName value:bestFontTripsAdd range:bestRangeTripsAdd];
        
        streakCell.section1ValueLbl.attributedText = currentStreakCompleteText;
        streakCell.section2ValueLbl.attributedText = bestStreakCompleteText;
        
        //THIRD SECTION
        NSDate *currentStartDate = [NSDate dateWithISO8601String:self.streaks.StreakOverSpeedCurrentFromDate];
        NSDate *currentEndDate = [NSDate dateWithISO8601String:self.streaks.StreakOverSpeedCurrentToDate];
        NSString *currentStartDateString = [currentStartDate dateStringShortYear];
        NSString *currentEndDateString = [currentEndDate dateStringShortYear];
        
        NSDate *bestStartDate = [NSDate dateWithISO8601String:self.streaks.StreakOverSpeedBestFromDate];
        NSDate *bestEndDate = [NSDate dateWithISO8601String:self.streaks.StreakOverSpeedBestToDate];
        NSString *bestStartDateString = [bestStartDate dateStringShortYear];
        NSString *bestEndDateString = [bestEndDate dateStringShortYear];
        
        if ([defaults_object(@"needDateFormatInverse") boolValue]) {
            currentStartDateString = [currentStartDate dateStringShortYearInverse];
            currentEndDateString = [currentEndDate dateStringShortYearInverse];
            bestStartDateString = [bestStartDate dateStringShortYearInverse];
            bestEndDateString = [bestEndDate dateStringShortYearInverse];
        }
        
        NSString *currentTimeFinal = [NSString stringWithFormat:@"%@ to %@", currentStartDateString, currentEndDateString];
        NSString *bestTimeFinal = [NSString stringWithFormat:@"%@ to %@", bestStartDateString, bestEndDateString];
        
        streakCell.dateTimeSection1Lbl.text = currentTimeFinal;
        streakCell.dateTimeSection2Lbl.text = bestTimeFinal;
        
        if (currentStartDate == nil) {
            streakCell.currentValueLbl.text = localizeString(@"You haven’t had");
            streakCell.bestValueLbl.text = localizeString(@"You haven’t had");
            streakCell.dateTimeSection1Lbl.text = localizeString(@"a best yet");
            streakCell.dateTimeSection2Lbl.text = localizeString(@"a best yet");
            streakCell.currentValueLbl.textColor = [Color darkGrayColor83];
            streakCell.bestValueLbl.textColor = [Color darkGrayColor83];
            streakCell.dateTimeSection1Lbl.textColor = [Color darkGrayColor83];
            streakCell.dateTimeSection2Lbl.textColor = [Color darkGrayColor83];
        }
        
    } else if (indexPath.row == 4) {
        
        //STREAK TITLE DISTRACTION
        streakCell.mainTitleLbl.text = @"Trips Without Phone Usage";
        streakCell.mainStreakImg.image = [UIImage imageNamed:@"lead_phone"];
        
        //FIRST SECTION
        float roundCurrentDistance = [self.streaks.StreakPhoneUsageCurrentDistanceKm floatValue];
        NSString *currentDistanceString = [NSString stringWithFormat:@"%.0f km", roundCurrentDistance];
        
        float roundCurrentDuration = [self.streaks.StreakPhoneUsageCurrentDurationSec floatValue] / 60;
        NSString *currentDurationString = [NSString stringWithFormat:@"%.0f m", roundCurrentDuration];
        
        float roundBestDistance = [self.streaks.StreakPhoneUsageBestDistanceKm floatValue];
        NSString *bestDistanceString = [NSString stringWithFormat:@"%.f km", roundBestDistance];
        
        float roundBestDuration = [self.streaks.StreakPhoneUsageBestDurationSec floatValue] / 60;
        NSString *bestDurationString = [NSString stringWithFormat:@"%.0f m", roundBestDuration];
        
        //Miles convert
        if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
            float currentInMiles = convertKmToMiles(roundCurrentDistance);
            currentDistanceString = [NSString stringWithFormat:@"%.1f mi", currentInMiles];
            float bestInMiles = convertKmToMiles(roundBestDistance);
            bestDistanceString = [NSString stringWithFormat:@"%.1f mi", bestInMiles];
        }
        
        NSString *currentFinal = [NSString stringWithFormat:@"%@  |  %@", currentDistanceString, currentDurationString];
        NSString *bestFinal = [NSString stringWithFormat:@"%@  |  %@", bestDistanceString, bestDurationString];
        
        streakCell.currentValueLbl.text = currentFinal;
        streakCell.bestValueLbl.text = bestFinal;
        
        //SECOND SECTION ATTRIBUTED STRING CURRENT
        NSString *currentStreakCounter = self.streaks.StreakPhoneUsageCurrentStreak.stringValue ? self.streaks.StreakPhoneUsageCurrentStreak.stringValue : @"0";
        NSString *currentStreakItem = localizeString(@"trips");
        NSString *currentStreakString = [NSString stringWithFormat:@"%@ %@", currentStreakCounter, currentStreakItem];
        
        NSMutableAttributedString *currentStreakCompleteText = [[NSMutableAttributedString alloc] initWithString:currentStreakString];
        
        NSRange currentRangeTotalPoints = [currentStreakString rangeOfString:currentStreakCounter];
        UIFont *currentFontTotalPoints = [Font heavy26];
        [currentStreakCompleteText addAttribute:NSForegroundColorAttributeName value:[Color officialGreenColor] range:currentRangeTotalPoints];
        [currentStreakCompleteText addAttribute:NSFontAttributeName value:currentFontTotalPoints range:currentRangeTotalPoints];
        
        NSRange currentRangeTripsAdd = [currentStreakString rangeOfString:currentStreakItem];
        UIFont *currentFontTripsAdd = [Font medium15];
        [currentStreakCompleteText addAttribute:NSForegroundColorAttributeName value:[Color tabBarDarkColor] range:currentRangeTripsAdd];
        [currentStreakCompleteText addAttribute:NSFontAttributeName value:currentFontTripsAdd range:currentRangeTripsAdd];
        
        //SECOND SECTION ATTRIBUTED STRING BEST
        NSString *bestStreakCounter = self.streaks.StreakPhoneUsageBest.stringValue ? self.streaks.StreakPhoneUsageBest.stringValue : @"0";
        NSString *bestStreakItem = localizeString(@"trips");
        NSString *bestStreakString = [NSString stringWithFormat:@"%@ %@", bestStreakCounter, bestStreakItem];
        
        NSMutableAttributedString *bestStreakCompleteText = [[NSMutableAttributedString alloc] initWithString:bestStreakString];
        
        NSRange bestRangeTotalPoints = [bestStreakString rangeOfString:bestStreakCounter];
        UIFont *bestFontTotalPoints = [Font heavy26];
        [bestStreakCompleteText addAttribute:NSForegroundColorAttributeName value:[Color tabBarDarkColor] range:bestRangeTotalPoints];
        [bestStreakCompleteText addAttribute:NSFontAttributeName value:bestFontTotalPoints range:bestRangeTotalPoints];
        
        NSRange bestRangeTripsAdd = [bestStreakString rangeOfString:bestStreakItem];
        UIFont *bestFontTripsAdd = [Font medium15];
        [bestStreakCompleteText addAttribute:NSForegroundColorAttributeName value:[Color tabBarDarkColor] range:bestRangeTripsAdd];
        [bestStreakCompleteText addAttribute:NSFontAttributeName value:bestFontTripsAdd range:bestRangeTripsAdd];
        
        streakCell.section1ValueLbl.attributedText = currentStreakCompleteText;
        streakCell.section2ValueLbl.attributedText = bestStreakCompleteText;
        
        //THIRD SECTION
        NSDate *currentStartDate = [NSDate dateWithISO8601String:self.streaks.StreakPhoneUsageCurrentFromDate];
        NSDate *currentEndDate = [NSDate dateWithISO8601String:self.streaks.StreakPhoneUsageCurrentToDate];
        NSString *currentStartDateString = [currentStartDate dateStringShortYear];
        NSString *currentEndDateString = [currentEndDate dateStringShortYear];
        
        NSDate *bestStartDate = [NSDate dateWithISO8601String:self.streaks.StreakPhoneUsageBestFromDate];
        NSDate *bestEndDate = [NSDate dateWithISO8601String:self.streaks.StreakPhoneUsageBestToDate];
        NSString *bestStartDateString = [bestStartDate dateStringShortYear];
        NSString *bestEndDateString = [bestEndDate dateStringShortYear];
        
        NSString *currentTimeFinal = [NSString stringWithFormat:@"%@ to %@", currentStartDateString, currentEndDateString];
        NSString *bestTimeFinal = [NSString stringWithFormat:@"%@ to %@", bestStartDateString, bestEndDateString];
        
        streakCell.dateTimeSection1Lbl.text = currentTimeFinal;
        streakCell.dateTimeSection2Lbl.text = bestTimeFinal;
        
        if (currentStartDate == nil) {
            streakCell.currentValueLbl.text = localizeString(@"You haven’t had");
            streakCell.bestValueLbl.text = localizeString(@"You haven’t had");
            streakCell.dateTimeSection1Lbl.text = localizeString(@"a best yet");
            streakCell.dateTimeSection2Lbl.text = localizeString(@"a best yet");
            streakCell.currentValueLbl.textColor = [Color darkGrayColor83];
            streakCell.bestValueLbl.textColor = [Color darkGrayColor83];
            streakCell.dateTimeSection1Lbl.textColor = [Color darkGrayColor83];
            streakCell.dateTimeSection2Lbl.textColor = [Color darkGrayColor83];
        }
    }
    
    return streakCell;
}


#pragma mark - Additional Buttons UI Views Tap

- (IBAction)show1ViewAction:(id)sender {
    self.additional1View.hidden = NO;
    self.additional2View.hidden = YES;
    self.additional3View.hidden = YES;
}

- (IBAction)show2ViewAction:(id)sender {
    self.additional1View.hidden = YES;
    self.additional2View.hidden = NO;
    self.additional3View.hidden = YES;
}

- (IBAction)show3ViewAction:(id)sender {
    self.additional1View.hidden = YES;
    self.additional2View.hidden = YES;
    self.additional3View.hidden = NO;
    
    self.coins_progressBarEco.progress = 0.0f;
    self.coins_progressBarBrakes.progress = 0.0f;
    self.coins_progressBarFuel.progress = 0.0f;
    self.coins_progressBarTyres.progress = 0.0f;
    self.coins_progressBarCost.progress = 0.0f;
    
    self.coins_timerEco = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(incrementCoinsTimerEco:) userInfo:nil repeats:YES];
    self.coins_timerBrakes = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(incrementCoinsTimerBrakes:) userInfo:nil repeats:YES];
    self.coins_timerFuel = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(incrementCoinsTimerFuel:) userInfo:nil repeats:YES];
    self.coins_timerTyres = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(incrementCoinsTimerTyres:) userInfo:nil repeats:YES];
    self.coins_timerCost = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(incrementCoinsTimerCost:) userInfo:nil repeats:YES];
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

- (void)openWelcomeRewardsScreen {
    WelcomeRewards* wVc = [[UIStoryboard storyboardWithName:@"WelcomeRewards" bundle:nil] instantiateInitialViewController];
    CATransition *transition = [[CATransition alloc] init];
    transition.duration = 0.5;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromBottom;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [self.view.window.layer addAnimation:transition forKey:kCATransition];
    [self presentViewController:wVc animated:NO completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


#pragma mark - HelpViewDelegate

- (void)alertOnboardingCompleted {
    NSLog(@"completed");
}

- (void)alertOnboardingNext:(NSInteger)nextStep {
    NSLog(@"next");
}

- (void)alertOnboardingSkipped:(NSInteger)currentStep maxStep:(NSInteger)maxStep {
    NSLog(@"skipped");
}

//iPHONE 5S DEPRECATED EXCUSE US, LOW FONTS IF YOU NEEDED HELPERS FOR SOME ELEMENTS
- (void)lowFontsForOldDevices {
    self.name_travellingLbl.font = [Font medium13];
    self.name_safetyLbl.font = [Font medium13];
    self.name_ecoScoreLbl.font = [Font medium13];
    
    self.factor_ecoScoreLbl.font = [Font medium15];
    self.factor_ecoBrakingLbl.font = [Font medium15];
    self.factor_ecoFuelLbl.font = [Font medium15];
    self.factor_ecoTiresLbl.font = [Font medium15];
    self.factor_ecoCostOwnershipLbl.font = [Font medium15];
}


#pragma mark - Coins Backend if lost connection

- (void)reloadCoins:(id)sender {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_IMMEDIATELY_2_SEC * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [sender endRefreshing];
    });
    
    //RELOAD PAGE
    self.additional1View.hidden = NO;
    self.additional2View.hidden = YES;
    self.additional3View.hidden = YES;
    [self->_daysSegmentView setSelectedIndex:0];
    
    NSDate *currentDate = [NSDate date];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:-20];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *dateMinusNeedDays = [calendar dateByAddingComponents:dateComponents toDate:currentDate options:0];
    
    NSDateComponents *dateComponentsOneDay = [[NSDateComponents alloc] init];
    [dateComponentsOneDay setDay:-1];
    NSDate *dateMinusNeedOneDays = [calendar dateByAddingComponents:dateComponentsOneDay toDate:currentDate options:0];
    NSLog(@"One day ago: %@", dateMinusNeedOneDays);
    
    NSDateComponents *dateComponentsThisMonth = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    dateComponentsThisMonth.day = 1;
    NSDate *firstDayOfCurrentMonthDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponentsThisMonth];
    NSLog(@"First day of current month: %@", [firstDayOfCurrentMonthDate descriptionWithLocale:[NSLocale currentLocale]]);
    
    NSDateComponents *dateComponentsLastMonth = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    dateComponentsLastMonth.day = 1;
    dateComponentsLastMonth.month = dateComponentsLastMonth.month - 1;
    NSDate *firstDayOfLastMonthDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponentsLastMonth];
    NSLog(@"First day of last month: %@", [firstDayOfLastMonthDate descriptionWithLocale:[NSLocale currentLocale]]);
    
    NSDateComponents *dateComponents14Days = [[NSDateComponents alloc] init];
    [dateComponents14Days setDay:-13];
    NSDate *dateMinus14Days = [calendar dateByAddingComponents:dateComponents14Days toDate:currentDate options:0];
    NSLog(@"14 days ago: %@", dateMinus14Days);
    
    [self getCoinsEverydayDetailsForGraph:dateMinus14Days endDate:currentDate]; //GRAPH RELOAD
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getDashboardCoinsAllTime:dateMinusNeedDays endDate:currentDate];
        [self getDashboardCoinsOneDayTime:dateMinusNeedOneDays endDate:currentDate];
        [self getDashboardCoinsThisMonthTime:firstDayOfCurrentMonthDate endDate:currentDate];
        [self getDashboardCoinsLastMonthTime:firstDayOfLastMonthDate endDate:firstDayOfCurrentMonthDate];
        [self getCoinsLimitAllTimeNow];
    });
}

- (void)getCoinsLimitAllTimeNow {
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        if (!error && [response isSuccesful]) {
            self.coinsReload = ((CoinsResponse *)response).Result;
            defaults_set_object(@"userCoinsDailyLimit", self.coinsReload.DailyLimit);
        } else {
            defaults_set_object(@"userCoinsDailyLimit", @20);
        }
    }] getCoinsDailyLimit];
}

- (void)getDashboardCoinsAllTime:(NSDate *)startDate endDate:(NSDate *)endDate {
    NSString *sCoinsDate = [startDate dateTimeStringSpecial];
    NSString *eCoinsDate = [endDate dateTimeStringSpecial];
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        if (!error && [response isSuccesful]) {
            self.coinsReload = ((CoinsResponse *)response).Result;
            
            defaults_set_object(@"userCoinsCountAllTime", self.coinsReload.TotalEarnedCoins);
            defaults_set_object(@"userCoinsCountAcquired", self.coinsReload.AcquiredCoins);
            
            NSString *acquiredUserCoins = defaults_object(@"userCoinsCountAcquired") ? defaults_object(@"userCoinsCountAcquired") : @"0";
            [self.acquiredRewardsTotalLbl countFrom:0 to:acquiredUserCoins.intValue];
            
            NSString *totalUserCoins = defaults_object(@"userCoinsCountAllTime") ? defaults_object(@"userCoinsCountAllTime") : @"0";
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.mainRewardsAdditionalTotalLbl countFrom:0 to:totalUserCoins.intValue];
            });
            
        } else {
            self.acquiredRewardsTotalLbl.text = @"0";
        }
    }] getCoinsTotal:sCoinsDate endDate:eCoinsDate];
}

- (void)getDashboardCoinsOneDayTime:(NSDate *)startDate endDate:(NSDate *)endDate {
    NSString *sCoinsDate = [startDate dateTimeStringSpecial];
    NSString *eCoinsDate = [endDate dateTimeStringSpecial];
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        if (!error && [response isSuccesful]) {
            self.coinsReload = ((CoinsResponse *)response).Result;
            defaults_set_object(@"userCoinsCountOneDay", self.coinsReload.TotalEarnedCoins);
        } else {
            defaults_set_object(@"userCoinsCountOneDay", @0);
        }
    }] getCoinsTotal:sCoinsDate endDate:eCoinsDate];
}

- (void)getDashboardCoinsThisMonthTime:(NSDate *)startDate endDate:(NSDate *)endDate {
    NSString *sCoinsDate = [startDate dateTimeStringSpecial];
    NSString *eCoinsDate = [endDate dateTimeStringSpecial];
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        if (!error && [response isSuccesful]) {
            self.coinsReload = ((CoinsResponse *)response).Result;
            defaults_set_object(@"userCoinsCountThisMonth", self.coinsReload.TotalEarnedCoins);
        } else {
            defaults_set_object(@"userCoinsCountThisMonth", 0);
        }
    }] getCoinsTotal:sCoinsDate endDate:eCoinsDate];
}

- (void)getDashboardCoinsLastMonthTime:(NSDate *)startDate endDate:(NSDate *)endDate {
    NSString *sCoinsDate = [startDate dateTimeStringSpecial];
    NSString *eCoinsDate = [endDate dateTimeStringSpecial];
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        if (!error && [response isSuccesful]) {
            self.coinsReload = ((CoinsResponse *)response).Result;
            defaults_set_object(@"userCoinsCountLastMonth", self.coinsReload.TotalEarnedCoins);
        } else {
            defaults_set_object(@"userCoinsCountLastMonth", 0);
        }
    }] getCoinsTotal:sCoinsDate endDate:eCoinsDate];
}


#pragma mark - ProgressTimers

- (void)incrementCoinsTimerEco:(NSTimer *)timer {
    int rate = self.ecoPercents.EcoScore.floatValue ? self.ecoPercents.EcoScore.floatValue : 0;
    int rateProg = [@(self.coins_progressBarEco.progress*100) intValue];
    
    if (rateProg <= rate) {
        self.coins_progressBarEco.progress = self.coins_progressBarEco.progress + 0.01f;
    }
    if (rate == rateProg || rateProg > rate) {
        [_coins_timerEco invalidate];
    }
}

- (void)incrementCoinsTimerBrakes:(NSTimer *)timer {
    int rate = self.ecoPercents.EcoScoreBrakes.floatValue ? self.ecoPercents.EcoScoreBrakes.floatValue : 0;
    int rateProg = [@(self.coins_progressBarBrakes.progress*100) intValue];

    if (rateProg <= rate) {
        self.coins_progressBarBrakes.progress = self.coins_progressBarBrakes.progress + 0.01f;
    }
    if (rate == rateProg || rateProg > rate) {
        [_coins_timerBrakes invalidate];
    }
}

- (void)incrementCoinsTimerFuel:(NSTimer *)timer {
    int rate = self.ecoPercents.EcoScoreFuel.floatValue ? self.ecoPercents.EcoScoreFuel.floatValue : 0;
    int rateProg = [@(self.coins_progressBarFuel.progress*100) intValue];

    if (rateProg <= rate) {
        self.coins_progressBarFuel.progress = self.coins_progressBarFuel.progress + 0.01f;
    }
    if (rate == rateProg || rateProg > rate) {
        [_coins_timerFuel invalidate];
    }
}

- (void)incrementCoinsTimerTyres:(NSTimer *)timer {
    int rate = self.ecoPercents.EcoScoreTyres.floatValue ? self.ecoPercents.EcoScoreTyres.floatValue : 0;
    int rateProg = [@(self.coins_progressBarTyres.progress*100) intValue];

    if (rateProg <= rate) {
        self.coins_progressBarTyres.progress = self.coins_progressBarTyres.progress + 0.01f;
    }
    if (rate == rateProg || rateProg > rate) {
        [_coins_timerTyres invalidate];
    }
}

- (void)incrementCoinsTimerCost:(NSTimer *)timer {
    int rate = self.ecoPercents.EcoScoreDepreciation.floatValue ? self.ecoPercents.EcoScoreDepreciation.floatValue : 0;
    int rateProg = [@(self.coins_progressBarCost.progress*100) intValue];

    if (rateProg <= rate) {
        self.coins_progressBarCost.progress = self.coins_progressBarCost.progress + 0.01f;
    }
    if (rate == rateProg || rateProg > rate) {
        [_coins_timerCost invalidate];
    }
}

- (int)getRandomNumberBetween:(int)from and:(int)to {
    return (int)from + arc4random() % (to-from+1);
}


@end
