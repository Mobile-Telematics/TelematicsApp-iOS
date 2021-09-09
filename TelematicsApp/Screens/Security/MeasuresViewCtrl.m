//
//  MeasuresViewCtrl.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.04.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "MeasuresViewCtrl.h"
#import "TagsSwitch.h"
#import "Color.h"
#import "Helpers.h"
#import "UIViewController+Preloader.h"
#import "UITextField+Form.h"
#import "NSDate+UI.h"
#import "NSDate+ISO8601.h"


@interface MeasuresViewCtrl () <UIScrollViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView   *scrollView;
@property (weak, nonatomic) IBOutlet UILabel        *mainMeasuresLbl;
@property (weak, nonatomic) IBOutlet UILabel        *distanceChangeLbl;
@property (weak, nonatomic) IBOutlet UILabel        *dateChangeLabel;
@property (weak, nonatomic) IBOutlet UILabel        *timeChangeLabel;
@property (weak, nonatomic) IBOutlet UIButton       *backBtn;

@property (strong, nonatomic) TelematicsAppModel           *appModel;
@property (strong, nonatomic) TagsSwitch          *distanceSwitcher;
@property (strong, nonatomic) TagsSwitch          *dateSwitcher;
@property (strong, nonatomic) TagsSwitch          *timeSwitcher;

@end

@implementation MeasuresViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //INITIALIZE USER APP MODEL
    self.appModel = [TelematicsAppModel MR_findFirstByAttribute:@"current_user" withValue:@1];
    
    [self setupView];
    [self setupDistanceSwitcher];
    [self setupDateSwitcher];
    [self setupTimeSwitcher];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:true];
}

- (void)setupView {
    self.scrollView.scrollEnabled = NO;
    
    self.mainMeasuresLbl.text = localizeString(@"Measures");
    self.distanceChangeLbl.text = localizeString(@"Distance");
    self.dateChangeLabel.text = localizeString(@"Date format");
    self.timeChangeLabel.text = localizeString(@"Time format");
    
    [self.backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupDistanceSwitcher {
    
    self.distanceSwitcher = [[TagsSwitch alloc] initWithStringsArray:@[localizeString(@"km"), localizeString(@"mi")]];
    if (@available(iOS 13.0, *)) {
        self.distanceSwitcher.frame = CGRectMake(self.view.frame.size.width - 170, 115, 150, 30);
    } else {
        if (IS_IPHONE_8P || IS_IPHONE_8 || IS_IPHONE_5 || IS_IPHONE_4)
            self.distanceSwitcher.frame = CGRectMake(self.view.frame.size.width - 170, 135, 150, 30);
        else
            self.distanceSwitcher.frame = CGRectMake(self.view.frame.size.width - 170, 158, 150, 30);
    }
    
    self.distanceSwitcher.font = [Font medium15Helvetica];
    self.distanceSwitcher.labelTextColorOutsideSlider = [UIColor darkGrayColor];
    self.distanceSwitcher.labelTextColorInsideSlider = [Color officialMainAppColor];
    self.distanceSwitcher.backgroundColor = [Color officialMainAppColorAlpha];
    self.distanceSwitcher.sliderColor = [Color officialWhiteColor];
    self.distanceSwitcher.sliderOffset = 1.0;
    self.distanceSwitcher.cornerRadius = 15;
    [self.view addSubview:self.distanceSwitcher];
    
    if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
        [self.distanceSwitcher selectIndex:1 animated:NO];
    } else {
        [self.distanceSwitcher selectIndex:0 animated:NO];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.distanceSwitcher setPressedHandler:^(NSUInteger index) {
        if (index == 0)
            defaults_set_object(@"needDistanceInMiles", @(NO));
        else
            defaults_set_object(@"needDistanceInMiles", @(YES));
        
        [weakSelf saveMeasuresParameters];
    }];
}

- (void)setupDateSwitcher {
    
    self.dateSwitcher = [[TagsSwitch alloc] initWithStringsArray:@[localizeString(@"dd/mm"), localizeString(@"mm/dd")]];
    if (@available(iOS 13.0, *)) {
        self.dateSwitcher.frame = CGRectMake(self.view.frame.size.width - 170, 175, 150, 30);
    } else {
        if (IS_IPHONE_8P || IS_IPHONE_8 || IS_IPHONE_5 || IS_IPHONE_4)
            self.dateSwitcher.frame = CGRectMake(self.view.frame.size.width - 170, 195, 150, 30);
        else
            self.dateSwitcher.frame = CGRectMake(self.view.frame.size.width - 170, 218, 150, 30);
    }
    
    self.dateSwitcher.font = [Font medium15Helvetica];
    self.dateSwitcher.labelTextColorOutsideSlider = [UIColor darkGrayColor];
    self.dateSwitcher.labelTextColorInsideSlider = [Color officialMainAppColor];
    self.dateSwitcher.backgroundColor = [Color officialMainAppColorAlpha];
    self.dateSwitcher.sliderColor = [Color officialWhiteColor];
    self.dateSwitcher.sliderOffset = 1.0;
    self.dateSwitcher.cornerRadius = 15;
    [self.view addSubview:self.dateSwitcher];
    
    if ([Configurator sharedInstance].needAmPmTime || [defaults_object(@"needDateSpecialFormat") boolValue]) {
        [self.dateSwitcher selectIndex:1 animated:NO];
    } else {
        [self.dateSwitcher selectIndex:0 animated:NO];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.dateSwitcher setPressedHandler:^(NSUInteger index) {
        if (index == 0)
            defaults_set_object(@"needDateSpecialFormat", @(NO));
        else
            defaults_set_object(@"needDateSpecialFormat", @(YES));
        
        [weakSelf saveMeasuresParameters];
    }];
}

- (void)setupTimeSwitcher {
    
    self.timeSwitcher = [[TagsSwitch alloc] initWithStringsArray:@[localizeString(@"24h"), localizeString(@"12h")]];
    if (@available(iOS 13.0, *)) {
        self.timeSwitcher.frame = CGRectMake(self.view.frame.size.width - 170, 235, 150, 30);
    } else {
        if (IS_IPHONE_8P || IS_IPHONE_8 || IS_IPHONE_5 || IS_IPHONE_4)
            self.timeSwitcher.frame = CGRectMake(self.view.frame.size.width - 170, 255, 150, 30);
        else
            self.timeSwitcher.frame = CGRectMake(self.view.frame.size.width - 170, 278, 150, 30);
    }
    
    self.timeSwitcher.font = [Font medium15Helvetica];
    self.timeSwitcher.labelTextColorOutsideSlider = [UIColor darkGrayColor];
    self.timeSwitcher.labelTextColorInsideSlider = [Color officialMainAppColor];
    self.timeSwitcher.backgroundColor = [Color officialMainAppColorAlpha];
    self.timeSwitcher.sliderColor = [Color officialWhiteColor];
    self.timeSwitcher.sliderOffset = 1.0;
    self.timeSwitcher.cornerRadius = 15;
    [self.view addSubview:self.timeSwitcher];
        
    if ([Configurator sharedInstance].needAmPmTime || [defaults_object(@"needAmPmFormat") boolValue]) {
        [self.timeSwitcher selectIndex:1 animated:NO];
    } else {
        [self.timeSwitcher selectIndex:0 animated:NO];
    }
        
    __weak typeof(self) weakSelf = self;
    [self.timeSwitcher setPressedHandler:^(NSUInteger index) {
        if (index == 0)
            defaults_set_object(@"needAmPmFormat", @(NO));
        else
            defaults_set_object(@"needAmPmFormat", @(YES));
        
        [weakSelf saveMeasuresParameters];
    }];
}

- (void)saveMeasuresParameters {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadDashboardPage" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTripPage" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadCoinsDashboardSection" object:self];
    
    defaults_set_object(@"needUpdateViewForFeedScreen", @(YES));
}


#pragma mark - Navigation

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
