//
//  DriveModeViewCtrl.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 20.11.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "DriveModeViewCtrl.h"
//#import "ProfileRequestData.h"
#import "Color.h"
#import "Helpers.h"
#import "UIViewController+Preloader.h"

@interface DriveModeViewCtrl () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView               *scrollView;
@property (weak, nonatomic) IBOutlet UILabel                    *mainTitle;
@property (weak, nonatomic) IBOutlet UILabel                    *mainDescription;

@property (weak, nonatomic) IBOutlet UIButton                   *autoModeBtn;
@property (weak, nonatomic) IBOutlet UIButton                   *deliberyModeBtn;
@property (weak, nonatomic) IBOutlet UIButton                   *disabledModeBtn;

@property (weak, nonatomic) IBOutlet UIImageView                *autoModeOnImg;
@property (weak, nonatomic) IBOutlet UIImageView                *autoModeOffImg;

@property (weak, nonatomic) IBOutlet UIImageView                *deliveryModeOnImg;
@property (weak, nonatomic) IBOutlet UIImageView                *deliveryModeOffImg;

@property (weak, nonatomic) IBOutlet UIImageView                *disabledModeOnImg;
@property (weak, nonatomic) IBOutlet UIImageView                *disabledModeOffImg;

@property (weak, nonatomic) IBOutlet UILabel                    *autoModeTitleLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *deliveryTitleModeLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *disableTitleModeLbl;

@property (weak, nonatomic) IBOutlet UILabel                    *autoModeDescLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *deliveryDescModeLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *disableDescModeLbl;

@property (weak, nonatomic) IBOutlet UIButton                   *proceedBtn;
@property (weak, nonatomic) IBOutlet UIButton                   *backBtn;

@property (strong, nonatomic) TelematicsAppModel                *appModel;
@property int                                                   modeSelect;

@end

@implementation DriveModeViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appModel = [TelematicsAppModel MR_findFirstByAttribute:@"current_user" withValue:@1];
    _modeSelect = 0;
    
    [self setupView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:true];
}

- (void)setupView {
    self.mainTitle.text = localizeString(@"Select Tracking Mode");
    
    self.proceedBtn.layer.borderWidth = 0.8;
    self.proceedBtn.layer.borderColor = [Color officialMainAppColor].CGColor;
    self.proceedBtn.backgroundColor = [Color officialMainAppColor];
    [self.proceedBtn setTitleColor:[Color officialWhiteColor] forState:UIControlStateNormal];
    
    if ([RPEntry instance].disableTracking) {
        self.autoModeOnImg.hidden = YES;
        self.autoModeOffImg.hidden = NO;

        self.deliveryModeOnImg.hidden = YES;
        self.deliveryModeOffImg.hidden = NO;

        self.disabledModeOnImg.hidden = NO;
        self.disabledModeOffImg.hidden = YES;
        
        NSMutableAttributedString *onDemandText = [[NSMutableAttributedString alloc] initWithString:localizeString(@"PROCEED WITH DISABLED TRACKING MODE")];
        [onDemandText addAttribute:NSForegroundColorAttributeName value:[Color officialWhiteColor] range:NSMakeRange(0, [onDemandText length])];
        [onDemandText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(13, 8)];
        [self.proceedBtn setAttributedTitle:onDemandText forState:UIControlStateNormal];
    } else {
        self.autoModeOnImg.hidden = NO;
        self.autoModeOffImg.hidden = YES;

        self.deliveryModeOnImg.hidden = YES;
        self.deliveryModeOffImg.hidden = NO;

        self.disabledModeOnImg.hidden = YES;
        self.disabledModeOffImg.hidden = NO;
        
        NSMutableAttributedString *onDemandText = [[NSMutableAttributedString alloc] initWithString:localizeString(@"PROCEED WITH AUTOMATIC TRACKING MODE")];
        [onDemandText addAttribute:NSForegroundColorAttributeName value:[Color officialWhiteColor] range:NSMakeRange(0, [onDemandText length])];
        [self.proceedBtn setAttributedTitle:onDemandText forState:UIControlStateNormal];
    }
    
    if ([defaults_object(@"onDemandTracking") boolValue]) {
        self.autoModeOnImg.hidden = YES;
        self.autoModeOffImg.hidden = NO;

        self.deliveryModeOnImg.hidden = NO;
        self.deliveryModeOffImg.hidden = YES;

        self.disabledModeOnImg.hidden = YES;
        self.disabledModeOffImg.hidden = NO;
        
        NSMutableAttributedString *onDemandText = [[NSMutableAttributedString alloc] initWithString:localizeString(@"PROCEED WITH ON-DEMAND TRACKING MODE")];
        [onDemandText addAttribute:NSForegroundColorAttributeName value:[Color officialWhiteColor] range:NSMakeRange(0, [onDemandText length])];
        [self.proceedBtn setAttributedTitle:onDemandText forState:UIControlStateNormal];
    }
    
    if (IS_IPHONE_5 || IS_IPHONE_4) {
        [self lowFontsForOldDevices];
    } else if (IS_IPHONE_8) {
        [self lowFontsSpeciallyFor8];
    }
}


#pragma mark - Navigation

- (IBAction)autoModeAction:(id)sender {
    _modeSelect = 1;
    
    self.autoModeOnImg.hidden = NO;
    self.autoModeOffImg.hidden = YES;

    self.deliveryModeOnImg.hidden = YES;
    self.deliveryModeOffImg.hidden = NO;

    self.disabledModeOnImg.hidden = YES;
    self.disabledModeOffImg.hidden = NO;
    
    NSMutableAttributedString *onDemandText = [[NSMutableAttributedString alloc] initWithString:localizeString(@"PROCEED WITH AUTOMATIC TRACKING MODE")];
    [onDemandText addAttribute:NSForegroundColorAttributeName value:[Color officialWhiteColor] range:NSMakeRange(0, [onDemandText length])];
    [self.proceedBtn setAttributedTitle:onDemandText forState:UIControlStateNormal];
}

- (IBAction)deliveryModeAction:(id)sender {
    _modeSelect = 2;
    
    self.autoModeOnImg.hidden = YES;
    self.autoModeOffImg.hidden = NO;

    self.deliveryModeOnImg.hidden = NO;
    self.deliveryModeOffImg.hidden = YES;

    self.disabledModeOnImg.hidden = YES;
    self.disabledModeOffImg.hidden = NO;
    
    NSMutableAttributedString *onDemandText = [[NSMutableAttributedString alloc] initWithString:localizeString(@"PROCEED WITH ON-DEMAND TRACKING MODE")];
    [onDemandText addAttribute:NSForegroundColorAttributeName value:[Color officialWhiteColor] range:NSMakeRange(0, [onDemandText length])];
    [self.proceedBtn setAttributedTitle:onDemandText forState:UIControlStateNormal];
}

- (IBAction)offModeAction:(id)sender {
    _modeSelect = 3;
    
    self.autoModeOnImg.hidden = YES;
    self.autoModeOffImg.hidden = NO;

    self.deliveryModeOnImg.hidden = YES;
    self.deliveryModeOffImg.hidden = NO;

    self.disabledModeOnImg.hidden = NO;
    self.disabledModeOffImg.hidden = YES;
    
    NSMutableAttributedString *onDemandText = [[NSMutableAttributedString alloc] initWithString:localizeString(@"PROCEED WITH DISABLED TRACKING MODE")];
    [onDemandText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(13, 8)];
    [onDemandText addAttribute:NSForegroundColorAttributeName value:[Color officialWhiteColor] range:NSMakeRange(0, [onDemandText length])];
    [self.proceedBtn setAttributedTitle:onDemandText forState:UIControlStateNormal];
}

- (IBAction)proceedBtnAction:(id)sender {
    NSString *jobName = defaults_object(@"currentJobNameTitle");
    if (![jobName isEqualToString:@""] && jobName.length > 0) {
        [self closeAllJobsWithPauseStatusAlert:sender];
    } else {

        BOOL needPauseToCancelAllPausedJobs = NO;
        
        NSMutableArray *accJobs = defaults_object(@"acceptedJobs");
        for (int i = 0; i < accJobs.count; i++) {
            NSString *jobStatus = [[accJobs objectAtIndex:i] valueForKey:@"currentJobStatus"];
            if ([jobStatus isEqualToString:@"Pause"]) {
                [self closeAllJobsWithPauseStatusAlert:sender];
                needPauseToCancelAllPausedJobs = YES;
                break;
            }
        }
        
        if (!needPauseToCancelAllPausedJobs) {
            [self confirmProceedBtnAction:sender];
        }
    }
}

- (IBAction)closeAllJobsWithPauseStatusAlert:(id)sender {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:localizeString(@"Job in progress")
                                message:localizeString(@"All current jobs will be completed. Are you sure?")
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                                actionWithTitle:localizeString(@"Yes")
                                style:UIAlertActionStyleDestructive
                                handler:^(UIAlertAction *action) {
                                    [self confirmProceedBtnAction:sender];
                                }];
    UIAlertAction *noAction = [UIAlertAction
                                actionWithTitle:localizeString(@"No")
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction *action) {
                                    [self backAction:sender];
                                }];
    [alert addAction:okAction];
    [alert addAction:noAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)confirmProceedBtnAction:(id)sender {
    [self showPreloader];
    
    if (_modeSelect == 0) {
        [self dismissViewControllerAnimated:NO completion:nil];
        return;
    }
    
    if (_modeSelect == 1) {
        defaults_set_object(@"onDemandTracking", @(NO));
        [RPEntry instance].disableTracking = NO;
        [[RPEntry instance] setEnableSdk:YES];
    } else if (_modeSelect == 2) {
        defaults_set_object(@"onDemandTracking", @(YES));
        [RPEntry instance].disableTracking = YES;
        [[RPEntry instance] setEnableSdk:NO];
    } else {
        defaults_set_object(@"onDemandTracking", @(NO));
        [RPEntry instance].disableTracking = YES;
        [[RPEntry instance] setEnableSdk:YES];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"finishOnDemandDashboardSection" object:self];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[RPEntry instance].api removeAllFutureTrackTagsWithСompletion:^(RPTagStatus status, NSInteger timestamp) {}];
        defaults_set_object(@"currentJobNameTitle", @"");
        defaults_set_object(@"currentJobNameTimeStamp", @"");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadOnDemandSettingsPage" object:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadOnDemandDashboardSection" object:self];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self backAction:sender];
        [self hidePreloader];
    });
}

- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)lowFontsForOldDevices {
    self.mainDescription.font = [Font regular15];
    
    self.autoModeTitleLbl.font = [Font medium13];
    self.deliveryTitleModeLbl.font = [Font medium13];
    self.disableTitleModeLbl.font = [Font medium13];

    self.autoModeDescLbl.font = [Font regular12];
    self.deliveryDescModeLbl.font = [Font regular12];
    self.disableDescModeLbl.font = [Font regular12];
    
    [self.proceedBtn.titleLabel setFont:[Font medium10]];
}

- (void)lowFontsSpeciallyFor8 {
    self.autoModeDescLbl.font = [Font regular13];
    self.deliveryDescModeLbl.font = [Font regular13];
    self.disableDescModeLbl.font = [Font regular13];
}


@end
