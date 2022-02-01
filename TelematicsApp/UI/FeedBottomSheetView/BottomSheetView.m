//
//  BottomSheetView.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 21.11.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "BottomSheetView.h"
#import "Color.h"
#import "Helpers.h"
#import "HapticHelper.h"

@interface BottomSheetView()

@end


@implementation BottomSheetView

- (instancetype)initWith:(UIView *)contentView isSheetCollapsed:(BOOL)isCollapsed;
{
    self = [super init];
    if (self) {
        self.contentView = [[[NSBundle mainBundle] loadNibNamed:@"BottomSheetView" owner:nil options:nil] firstObject];
        self.contentView.center = self.superview.center;
        
        if (IS_IPHONE_5 || IS_IPHONE_4) {
            CGRect frameB = self.contentView.legendBlueLbl.frame;
            frameB.origin.x -=15;
            frameB.size.width -=20;
            self.contentView.legendBlueLbl.frame = frameB;
            
            CGRect frameG = self.contentView.legendGreenLbl.frame;
            frameG.origin.x -=15;
            frameG.size.width -=20;
            self.contentView.legendGreenLbl.frame = frameG;
            
            CGRect frameY = self.contentView.legendYellowLbl.frame;
            frameY.origin.x -=15;
            frameY.size.width -=10;
            self.contentView.legendYellowLbl.frame = frameY;
            
            CGRect frameR = self.contentView.legendRedLbl.frame;
            frameR.origin.x -=25;
            frameR.size.width -=10;
            self.contentView.legendRedLbl.frame = frameR;
            
            self.contentView.accelerationTextLbl.font = [Font regular13];
            self.contentView.brakingTextLbl.font = [Font regular13];
            self.contentView.phoneUsageTextLbl.font = [Font regular13];
            self.contentView.speedingTextLbl.font = [Font regular13];
            self.contentView.corneringTextLbl.font = [Font regular13];
        }
        
        [self setup:isCollapsed];
    }
    return self;
}

- (void)setup:(BOOL)isCollapsed
{
    self.backgroundColor = UIColor.whiteColor;
    self.layer.cornerRadius = 16;
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowRadius = 2;
    self.layer.shadowOpacity = 0.1;
    [self setupChevronView:isCollapsed];
    
    [self setupContentView];
    
    [self setupDrivingSignatureButton];
    [self setupDriverSwitcher];
    [self setupPointsColorButtons];
}

- (void)setupDrivingSignatureButton {
    //
}

- (void)setupDriverSwitcher {
    self.tagsSwitcher = [[TagsSwitch alloc] initWithStringsArray:@[localizeString(@"None"), localizeString(@"Personal"), localizeString(@"Business")]];
    
    self.tagsSwitcher.frame = CGRectMake(19, 139, 285, 38);
    self.tagsSwitcher.font = [Font medium15Helvetica];
    self.tagsSwitcher.cornerRadius = 19;
    
    self.tagsSwitcher.labelTextColorOutsideSlider = [UIColor darkGrayColor];
    self.tagsSwitcher.labelTextColorInsideSlider = [Color officialMainAppColor];
    self.tagsSwitcher.backgroundColor = [Color officialMainAppColorAlpha];
    self.tagsSwitcher.sliderColor = [Color officialWhiteColor];
    self.tagsSwitcher.sliderOffset = 1.0;
    [self addSubview:self.tagsSwitcher];
    
    __weak typeof(self) weakSelf = self;
    [self.tagsSwitcher setPressedHandler:^(NSUInteger index) {
        if (index == 1) {
            [weakSelf setPersonalTagActionForSheet:weakSelf.tagsSwitcher];
        } else if (index == 2) {
            [weakSelf setBusinessTagActionForSheet:weakSelf.tagsSwitcher];
        } else {
            [weakSelf resetNoTagActionForSheet:weakSelf.tagsSwitcher];
        }
    }];
}
 
- (void)setupContentView {
    
    self.contentView.translatesAutoresizingMaskIntoConstraints = false;
    [self addSubview:self.contentView];
    
    NSLayoutConstraint * collectionViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                                     attribute:NSLayoutAttributeLeft
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:self
                                                                                     attribute:NSLayoutAttributeLeft
                                                                                    multiplier:1.0
                                                                                      constant:0];
    
    NSLayoutConstraint * collectionViewRightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                                      attribute:NSLayoutAttributeRight
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:self attribute:NSLayoutAttributeRight
                                                                                     multiplier:1.0f
                                                                                       constant:0];
    
    NSLayoutConstraint * collectionViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                                    attribute:NSLayoutAttributeTop
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:self
                                                                                    attribute:NSLayoutAttributeTop
                                                                                   multiplier:1.0f
                                                                                     constant:25];
    
    NSLayoutConstraint * collectionViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                                       attribute:NSLayoutAttributeBottom
                                                                                       relatedBy:NSLayoutRelationEqual
                                                                                          toItem:self
                                                                                       attribute:NSLayoutAttributeBottom
                                                                                      multiplier:1.0
                                                                                        constant:0];
    
    [self addConstraint:collectionViewLeftConstraint];
    [self addConstraint:collectionViewRightConstraint];
    [self addConstraint:collectionViewTopConstraint];
    [self addConstraint:collectionViewBottomConstraint];
}

- (void)setupChevronView:(BOOL)isCollapsed {
    self.chevronView = [ChevronView new];
    self.chevronView.state = isCollapsed ? ChevronViewStateDown : ChevronViewStateUp;
    self.chevronView.width = 4;
    self.chevronView.color = [Color lightSeparatorColor];// UIColor.lightGrayColor;
    self.chevronView.userInteractionEnabled = YES;
    self.chevronView.translatesAutoresizingMaskIntoConstraints = false;
    [self addSubview:self.chevronView];
    
    NSLayoutConstraint * collectionViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.chevronView
                                                                                    attribute:NSLayoutAttributeTop
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:self
                                                                                    attribute:NSLayoutAttributeTop
                                                                                   multiplier:1.0f
                                                                                     constant:0];
    
    NSLayoutConstraint * heightConstraint = [NSLayoutConstraint constraintWithItem:self.chevronView
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                                        multiplier:1.0
                                                                          constant:25];
    
    NSLayoutConstraint * widthConstraint = [NSLayoutConstraint constraintWithItem:self.chevronView
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:0
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeWidth
                                                                       multiplier:1.f
                                                                         constant:40];
    
    NSLayoutConstraint * centerXConstraint = [NSLayoutConstraint constraintWithItem:self.chevronView
                                                                          attribute:NSLayoutAttributeCenterX
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self
                                                                          attribute:NSLayoutAttributeCenterX
                                                                         multiplier:1.0f
                                                                           constant:0.0f];
    
    [self addConstraint:collectionViewTopConstraint];
    [self addConstraint:heightConstraint];
    [self addConstraint:widthConstraint];
    [self addConstraint:centerXConstraint];
}

- (void)sheetUpdatePointsLabel:(NSString*)points {
    
    if ([points containsString:@"."]) {
        NSRange rangeSearch = [points rangeOfString:@"." options:NSBackwardsSearch];
        points = [points substringToIndex:rangeSearch.location];
    }
    
    float p = [points floatValue];
    
    NSString *pointsLbl1 = points;
    NSString *pointsLbl2 = localizeString(@"dash_points");
    NSString *totalPointsLbl = [NSString stringWithFormat:@"%@ %@", pointsLbl1, pointsLbl2];
    
    NSMutableAttributedString *completeText = [[NSMutableAttributedString alloc] initWithString:totalPointsLbl];
    
    NSRange mainRangeTotalPoints = [totalPointsLbl rangeOfString:pointsLbl1];
    UIFont *mainFontTotalPoints = [Font heavy26];
    if (IS_IPHONE_5 || IS_IPHONE_4)
        mainFontTotalPoints = [Font heavy24];
    
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
    UIFont *mainFontPointsLbl = [Font semibold15];
    if (IS_IPHONE_5 || IS_IPHONE_4)
        mainFontPointsLbl = [Font semibold11];
    
    [completeText addAttribute:NSForegroundColorAttributeName value:[Color lightGrayColor] range:mainRangePointsLbl];
    [completeText addAttribute:NSFontAttributeName value:mainFontPointsLbl range:mainRangePointsLbl];
    
    self.contentView.pointsLabel.attributedText = completeText;
}

- (void)sheetUpdateKmLabel:(NSString*)km {
    NSString *kmLbl1 = km;
    NSString *kmLbl2 = localizeString(@"dash_km");
    if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
        kmLbl2 = localizeString(@"dash_miles");
    }
    NSString *totalKmLbl = [NSString stringWithFormat:@"%@ %@", kmLbl1, kmLbl2];
    
    NSMutableAttributedString *completeTextKm = [[NSMutableAttributedString alloc] initWithString:totalKmLbl];
    
    NSRange mainRange1 = [totalKmLbl rangeOfString:kmLbl1];
    UIFont *mainFont1 = [Font heavy26];
    if (IS_IPHONE_5 || IS_IPHONE_4)
        mainFont1 = [Font heavy24];
    
    [completeTextKm addAttribute:NSForegroundColorAttributeName value:[Color darkGrayColor] range:mainRange1];
    [completeTextKm addAttribute:NSFontAttributeName value:mainFont1 range:mainRange1];
    
    NSRange mainRange2 = [totalKmLbl rangeOfString:kmLbl2];
    UIFont *mainFont2 = [Font semibold15];
    if (IS_IPHONE_5 || IS_IPHONE_4)
        mainFont2 = [Font semibold11];
    
    [completeTextKm addAttribute:NSForegroundColorAttributeName value:[Color lightGrayColor] range:mainRange2];
    [completeTextKm addAttribute:NSFontAttributeName value:mainFont2 range:mainRange2];
    
    self.contentView.kmLabel.attributedText = completeTextKm;
}

- (void)sheetUpdateTimeLabel:(NSString*)time {
    NSString *timeLbl1;
    if (time.length > 0) {
        timeLbl1 = time;
    } else {
        timeLbl1 = @"0";
    }
    
    NSString *timeLbl2 = localizeString(@"dash_hours");
    NSString *totalTimeLbl = [NSString stringWithFormat:@"%@ %@", timeLbl1, timeLbl2];
    
    NSMutableAttributedString *completeTextTime = [[NSMutableAttributedString alloc] initWithString:totalTimeLbl];
    
    NSRange mainRange1 = [totalTimeLbl rangeOfString:timeLbl1];
    UIFont *mainFont1 = [Font heavy26];
    if (IS_IPHONE_5 || IS_IPHONE_4)
        mainFont1 = [Font heavy18];
    
    [completeTextTime addAttribute:NSForegroundColorAttributeName value:[Color darkGrayColor] range:mainRange1];
    [completeTextTime addAttribute:NSFontAttributeName value:mainFont1 range:mainRange1];
    
    NSRange mainRange2 = [totalTimeLbl rangeOfString:timeLbl2];
    UIFont *mainFont2 = [Font semibold15];
    if (IS_IPHONE_5 || IS_IPHONE_4)
        mainFont2 = [Font medium10];
    
    [completeTextTime addAttribute:NSForegroundColorAttributeName value:[Color lightGrayColor] range:mainRange2];
    [completeTextTime addAttribute:NSFontAttributeName value:mainFont2 range:mainRange2];
    
    self.contentView.timeLabel.attributedText = completeTextTime;
}

- (void)setupPointsColorButtons {
    self.contentView.aPointLabel.textColor = [Color officialMainAppColor];
    self.contentView.bPointLabel.textColor = [Color officialMainAppColor];
}

- (void)sheetUpdateStartCityLabel:(NSString*)city
{
    self.contentView.cityStartLabel.text = city;
}

- (void)sheetUpdateEndCityLabel:(NSString*)city
{
    self.contentView.cityEndLabel.text = city;
}

- (void)sheetUpdateStartAddressLabel:(NSString*)address
{
    self.contentView.addressStartLabel.text = address;
}

- (void)sheetUpdateEndAddressLabel:(NSString*)address
{
    self.contentView.addressEndLabel.text = address;
}

- (void)sheetUpdateStartTimeLabel:(NSString*)time
{
    self.contentView.timeStartLabel.text = time;
}

- (void)sheetUpdateEndTimeLabel:(NSString*)time
{
    self.contentView.timeEndLabel.text = time;
}

- (void)sheetUpdateTrackOriginButton:(NSString*)origin
{
    if ([origin isEqual:@"OriginalDriver"]) {
        [self.contentView.driverSignatureOnTripBtn setBackgroundImage:[UIImage imageNamed:@"driver_green"] forState:UIControlStateNormal];
        self.contentView.driverSignatureOnTripLbl.text = @"Driver";
    } else if ([origin isEqual:@"Passenger"] || [origin isEqual:@"Passanger"]) {
        [self.contentView.driverSignatureOnTripBtn setBackgroundImage:[UIImage imageNamed:@"passenger_green"] forState:UIControlStateNormal];
        self.contentView.driverSignatureOnTripLbl.text = @"Passenger";
    } else if ([origin isEqual:@"Bus"]) {
        [self.contentView.driverSignatureOnTripBtn setBackgroundImage:[UIImage imageNamed:@"bus_green"] forState:UIControlStateNormal];
        self.contentView.driverSignatureOnTripLbl.text = @"Bus";
    } else if ([origin isEqual:@"Motorcycle"]) {
        [self.contentView.driverSignatureOnTripBtn setBackgroundImage:[UIImage imageNamed:@"motorcycle_green"] forState:UIControlStateNormal];
        self.contentView.driverSignatureOnTripLbl.text = @"Motorcycle";
    } else if ([origin isEqual:@"Train"]) {
        [self.contentView.driverSignatureOnTripBtn setBackgroundImage:[UIImage imageNamed:@"train_green"] forState:UIControlStateNormal];
        self.contentView.driverSignatureOnTripLbl.text = @"Train";
    } else if ([origin isEqual:@"Taxi"]) {
        [self.contentView.driverSignatureOnTripBtn setBackgroundImage:[UIImage imageNamed:@"taxi_green"] forState:UIControlStateNormal];
        self.contentView.driverSignatureOnTripLbl.text = @"Taxi";
    } else if ([origin isEqual:@"Bicycle"]) {
        [self.contentView.driverSignatureOnTripBtn setBackgroundImage:[UIImage imageNamed:@"bicycle_green"] forState:UIControlStateNormal];
        self.contentView.driverSignatureOnTripLbl.text = @"Bicycle";
    } else if ([origin isEqual:@"Other"]) {
        [self.contentView.driverSignatureOnTripBtn setBackgroundImage:[UIImage imageNamed:@"other_green"] forState:UIControlStateNormal];
        self.contentView.driverSignatureOnTripLbl.text = @"Other";
    } else {
        [self.contentView.driverSignatureOnTripBtn setBackgroundImage:[UIImage imageNamed:@"driver_green"] forState:UIControlStateNormal];
        self.contentView.driverSignatureOnTripLbl.text = @"Driver";
    }
}

- (void)sheetUpdateTagsButton:(NSArray*)tagsArray {
    self.tagsSwitcher.alpha = 1;
    self.tagsSwitcher.userInteractionEnabled = YES;
    [self.tagsSwitcher selectIndex:0 animated:NO];
    
    if (tagsArray.count != 0) {
        for (RPTag *tag in tagsArray) {
            if ([tag.tag isEqualToString:@"Business"]) {
                self.tagsSwitcher.alpha = 1;
                self.tagsSwitcher.userInteractionEnabled = YES;
                [self.tagsSwitcher selectIndex:1 animated:NO];
            }
        }
    }
}

- (void)sheetUpdateScores:(float)acc brake:(float)brake phone:(float)phone speed:(float)speed corner:(float)corner {
    
    self.contentView.accelerationTextLbl.text = localizeString(@"sheet_acc");
    self.contentView.brakingTextLbl.text = localizeString(@"sheet_braking");
    self.contentView.phoneUsageTextLbl.text = localizeString(@"sheet_phone");
    self.contentView.speedingTextLbl.text = localizeString(@"sheet_speeding");
    self.contentView.corneringTextLbl.text = localizeString(@"sheet_cornering");
    
    self.contentView.accelerationScoreLbl.text = [NSString stringWithFormat:@"%.0f", acc];
    self.contentView.brakingScoreLbl.text = [NSString stringWithFormat:@"%.0f", brake];
    self.contentView.phoneUsageScoreLbl.text = [NSString stringWithFormat:@"%.0f", phone];
    self.contentView.speedingScoreLbl.text = [NSString stringWithFormat:@"%.0f", speed];
    self.contentView.corneringScoreLbl.text = [NSString stringWithFormat:@"%.0f", corner];
    
    if (acc > 80) {
        self.contentView.accelerationScoreLbl.textColor = [Color officialGreenColor];
        self.contentView.accelerationScoreView.backgroundColor = [Color officialGreenColor];
    } else if (acc > 60) {
        self.contentView.accelerationScoreLbl.textColor = [Color officialYellowColor];
        self.contentView.accelerationScoreView.backgroundColor = [Color officialYellowColor];
    } else if (acc > 40) {
        self.contentView.accelerationScoreLbl.textColor = [Color officialOrangeColor];
        self.contentView.accelerationScoreView.backgroundColor = [Color officialOrangeColor];
    } else {
        self.contentView.accelerationScoreLbl.textColor = [Color officialDarkRedColor];
        self.contentView.accelerationScoreView.backgroundColor = [Color officialDarkRedColor];
    }
    
    if (brake > 80) {
        self.contentView.brakingScoreLbl.textColor = [Color officialGreenColor];
        self.contentView.brakingScoreView.backgroundColor = [Color officialGreenColor];
    } else if (brake > 60) {
        self.contentView.brakingScoreLbl.textColor = [Color officialYellowColor];
        self.contentView.brakingScoreView.backgroundColor = [Color officialYellowColor];
    } else if (brake > 40) {
        self.contentView.brakingScoreLbl.textColor = [Color officialOrangeColor];
        self.contentView.brakingScoreView.backgroundColor = [Color officialOrangeColor];
    } else {
        self.contentView.brakingScoreLbl.textColor = [Color officialDarkRedColor];
        self.contentView.brakingScoreView.backgroundColor = [Color officialDarkRedColor];
    }
    
    if (phone > 80) {
        self.contentView.phoneUsageScoreLbl.textColor = [Color officialGreenColor];
        self.contentView.phoneUsageScoreView.backgroundColor = [Color officialGreenColor];
    } else if (phone > 60) {
        self.contentView.phoneUsageScoreLbl.textColor = [Color officialYellowColor];
        self.contentView.phoneUsageScoreView.backgroundColor = [Color officialYellowColor];
    } else if (phone > 40) {
        self.contentView.phoneUsageScoreLbl.textColor = [Color officialOrangeColor];
        self.contentView.phoneUsageScoreView.backgroundColor = [Color officialOrangeColor];
    } else {
        self.contentView.phoneUsageScoreLbl.textColor = [Color officialDarkRedColor];
        self.contentView.phoneUsageScoreView.backgroundColor = [Color officialDarkRedColor];
    }
    
    if (speed > 80) {
        self.contentView.speedingScoreLbl.textColor = [Color officialGreenColor];
        self.contentView.speedingScoreView.backgroundColor = [Color officialGreenColor];
    } else if (speed > 60) {
        self.contentView.speedingScoreLbl.textColor = [Color officialYellowColor];
        self.contentView.speedingScoreView.backgroundColor = [Color officialYellowColor];
    } else if (speed > 40) {
        self.contentView.speedingScoreLbl.textColor = [Color officialOrangeColor];
        self.contentView.speedingScoreView.backgroundColor = [Color officialOrangeColor];
    } else {
        self.contentView.speedingScoreLbl.textColor = [Color officialDarkRedColor];
        self.contentView.speedingScoreView.backgroundColor = [Color officialDarkRedColor];
    }
    
    if (corner > 80) {
        self.contentView.corneringScoreLbl.textColor = [Color officialGreenColor];
        self.contentView.corneringScoreView.backgroundColor = [Color officialGreenColor];
    } else if (corner > 60) {
        self.contentView.corneringScoreLbl.textColor = [Color officialYellowColor];
        self.contentView.corneringScoreView.backgroundColor = [Color officialYellowColor];
    } else if (corner > 40) {
        self.contentView.corneringScoreLbl.textColor = [Color officialOrangeColor];
        self.contentView.corneringScoreView.backgroundColor = [Color officialOrangeColor];
    } else {
        self.contentView.corneringScoreLbl.textColor = [Color officialDarkRedColor];
        self.contentView.corneringScoreView.backgroundColor = [Color officialDarkRedColor];
    }
}

- (void)update:(ChevronViewState)state {
    [self.chevronView setState:state animated:YES];
}


#pragma mark - Passenger Origin Methods

- (IBAction)changeDriverOriginAlert:(id)sender {
    [HapticHelper generateFeedback:FeedbackTypeImpactMedium];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:localizeString(@"passenger_title")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesButton = [UIAlertAction actionWithTitle:localizeString(@"Yes")
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction *action) {
                                                          [self changeDriverOriginAction:sender];
                                                      }];
    UIAlertAction *noButton = [UIAlertAction actionWithTitle:localizeString(@"No")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {}];
    [alert addAction:yesButton];
    [alert addAction:noButton];
    
    UIViewController *currentTopVC = [self currentTopViewController];
    [currentTopVC presentViewController:alert animated:YES completion:nil];
}

- (IBAction)changeDriverOriginAction:(id)sender {
    [HapticHelper generateFeedback:FeedbackTypeImpactMedium];
    
    NSString *tToken = defaults_object(@"selectedTrackToken");
    NSString *sOriginalRole = defaults_object(@"selectedTrackSignatureOriginalRole");
    
    NSDictionary *userInfo = @{@"driverToken": tToken,
                        @"driverOriginalRole": sOriginalRole };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"openDriverSignaturePopup" object:nil userInfo:userInfo];
}


#pragma mark - Tags Personal/Business Origin Methods

- (void)resetNoTagActionForSheet:(id)sender {
    
    defaults_set_object(@"needUpdateForFeedScreen", @(YES));
    NSString *tToken = defaults_object(@"selectedTrackToken");
    
    RPTag *tagPersonal = [[RPTag alloc] init];
    tagPersonal.tag = @"Personal";
    tagPersonal.source = localizeString(@"TelematicsApp");
    
    RPTag *tagBusiness = [[RPTag alloc] init];
    tagBusiness.tag = @"Business";
    tagBusiness.source = localizeString(@"TelematicsApp");
    
    [[RPEntry instance].api removeTrackTags:[[NSArray alloc] initWithObjects:tagPersonal, tagBusiness, nil] from:tToken completion:^(id response, NSArray *error) {
        NSLog(@"DELETE ALL TAGS COMPLETED ON SHEET");
    }];
}

- (void)setPersonalTagActionForSheet:(id)sender {
    
    defaults_set_object(@"needUpdateForFeedScreen", @(YES));
    NSString *tToken = defaults_object(@"selectedTrackToken");
    
    RPTag *tagPersonal = [[RPTag alloc] init];
    tagPersonal.tag = @"Personal";
    tagPersonal.source = localizeString(@"TelematicsApp");
    
    RPTag *tagBusiness = [[RPTag alloc] init];
    tagBusiness.tag = @"Business";
    tagBusiness.source = localizeString(@"TelematicsApp");
    
    [[RPEntry instance].api removeTrackTags:[[NSArray alloc] initWithObjects:tagBusiness, nil] from:tToken completion:^(id response, NSArray *error) {
        NSLog(@"TAG BUSINESS DELETED ON SHEET");
        
        [[RPEntry instance].api addTrackTags:[[NSArray alloc] initWithObjects:tagPersonal, nil] to:tToken completion:^(id response, NSArray *error) {
            NSLog(@"TAG PERSONAL ADDED ON SHEET");
        }];
    }];
}

- (void)setBusinessTagActionForSheet:(id)sender {
    
    defaults_set_object(@"needUpdateForFeedScreen", @(YES));
    NSString *tToken = defaults_object(@"selectedTrackToken");
    
    RPTag *tagPersonal = [[RPTag alloc] init];
    tagPersonal.tag = @"Personal";
    tagPersonal.source = localizeString(@"TelematicsApp");
    
    RPTag *tagBusiness = [[RPTag alloc] init];
    tagBusiness.tag = @"Business";
    tagBusiness.source = localizeString(@"TelematicsApp");
    
    [[RPEntry instance].api removeTrackTags:[[NSArray alloc] initWithObjects:tagPersonal, nil] from:tToken completion:^(id response, NSArray *error) {
        NSLog(@"TAG PERSONAL DELETED ON SHEET");
        
        [[RPEntry instance].api addTrackTags:[[NSArray alloc] initWithObjects:tagBusiness, nil] to:tToken completion:^(id response, NSArray *error) {
            NSLog(@"TAG BUSINESS ADDED ON SHEET");
        }];
    }];
}


#pragma mark - Hide Trip status

- (IBAction)hideTripSheetAlert:(id)sender {
    
    [HapticHelper generateFeedback:FeedbackTypeImpactMedium];
    
    UIAlertController *alert = [UIAlertController
                                   alertControllerWithTitle:nil
                                   message:localizeString(@"hide_trip")
                                   preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesButton = [UIAlertAction actionWithTitle:localizeString(@"Yes")
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction *action) {
                                                          [self hideTripFinalAction:sender];
                                                      }];
    UIAlertAction *noButton = [UIAlertAction actionWithTitle:localizeString(@"No")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {}];
    [alert addAction:yesButton];
    [alert addAction:noButton];
    
    UIViewController *currentTopVC = [self currentTopViewController];
    [currentTopVC presentViewController:alert animated:YES completion:nil];
}

- (IBAction)hideTripFinalAction:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"readyHideThisTrip" object:nil];
}


#pragma mark - Delete Trip status

- (IBAction)deleteTripSheetAlert:(id)sender {
    
    [HapticHelper generateFeedback:FeedbackTypeImpactMedium];
    
    UIAlertController *alert = [UIAlertController
                                   alertControllerWithTitle:nil
                                   message:localizeString(@"delete_trip")
                                   preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesButton = [UIAlertAction actionWithTitle:localizeString(@"Yes")
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction *action) {
                                                          [self deleteTripFinalAction:sender];
                                                      }];
    UIAlertAction *noButton = [UIAlertAction actionWithTitle:localizeString(@"No")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {}];
    [alert addAction:yesButton];
    [alert addAction:noButton];
    
    UIViewController *currentTopVC = [self currentTopViewController];
    [currentTopVC presentViewController:alert animated:YES completion:nil];
}

- (IBAction)deleteTripFinalAction:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"readyDeleteThisTrip" object:nil];
}


#pragma mark - View Detecting

- (UIViewController *)currentTopViewController {
    UIViewController *topVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

@end
