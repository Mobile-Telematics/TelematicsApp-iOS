//
//  BottomSheetView.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 21.11.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChevronView.h"
#import "TagsSwitch.h"

NS_ASSUME_NONNULL_BEGIN

@interface BottomSheetView : UIView

@property (nonatomic) ChevronView                   *chevronView;
@property (nonatomic) BottomSheetView               *contentView;

@property (nonatomic, weak) IBOutlet UILabel        *aPointLabel;
@property (nonatomic, weak) IBOutlet UILabel        *bPointLabel;
@property (nonatomic, weak) IBOutlet UILabel        *pointsLabel;
@property (nonatomic, weak) IBOutlet UILabel        *kmLabel;
@property (nonatomic, weak) IBOutlet UILabel        *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel        *cityStartLabel;
@property (nonatomic, weak) IBOutlet UILabel        *cityEndLabel;
@property (nonatomic, weak) IBOutlet UILabel        *addressStartLabel;
@property (nonatomic, weak) IBOutlet UILabel        *addressEndLabel;
@property (nonatomic, weak) IBOutlet UILabel        *timeStartLabel;
@property (nonatomic, weak) IBOutlet UILabel        *timeEndLabel;

@property (nonatomic, weak) IBOutlet UILabel        *accelerationTextLbl;
@property (nonatomic, weak) IBOutlet UILabel        *brakingTextLbl;
@property (nonatomic, weak) IBOutlet UILabel        *phoneUsageTextLbl;
@property (nonatomic, weak) IBOutlet UILabel        *speedingTextLbl;
@property (nonatomic, weak) IBOutlet UILabel        *corneringTextLbl;

@property (nonatomic, weak) IBOutlet UILabel        *accelerationScoreLbl;
@property (nonatomic, weak) IBOutlet UILabel        *brakingScoreLbl;
@property (nonatomic, weak) IBOutlet UILabel        *phoneUsageScoreLbl;
@property (nonatomic, weak) IBOutlet UILabel        *speedingScoreLbl;
@property (nonatomic, weak) IBOutlet UILabel        *corneringScoreLbl;

@property (nonatomic, weak) IBOutlet UIView         *accelerationScoreView;
@property (nonatomic, weak) IBOutlet UIView         *brakingScoreView;
@property (nonatomic, weak) IBOutlet UIView         *phoneUsageScoreView;
@property (nonatomic, weak) IBOutlet UIView         *speedingScoreView;
@property (nonatomic, weak) IBOutlet UIView         *corneringScoreView;

@property (nonatomic, weak) IBOutlet UILabel        *legendGreenLbl;
@property (nonatomic, weak) IBOutlet UILabel        *legendBlueLbl;
@property (nonatomic, weak) IBOutlet UILabel        *legendRedLbl;
@property (nonatomic, weak) IBOutlet UILabel        *legendYellowLbl;

@property (nonatomic, weak) IBOutlet UIButton       *driverSignatureOnTripBtn;
@property (nonatomic, weak) IBOutlet UILabel        *driverSignatureOnTripLbl;

@property (nonatomic, weak) IBOutlet UIButton       *hideTripBtn;
@property (nonatomic, weak) IBOutlet UIButton       *hideTripBackgroundBtn;
@property (nonatomic, weak) IBOutlet UIImageView    *hideTripIcon;

@property (nonatomic, weak) IBOutlet UIButton       *deleteTripBtn;
@property (nonatomic, weak) IBOutlet UIButton       *deleteTripBackgroundBtn;
@property (nonatomic, weak) IBOutlet UIImageView    *deleteTripIcon;

@property (strong, nonatomic) TagsSwitch            *tagsSwitcher;

- (instancetype)initWith:(UIView *)contentView isSheetCollapsed:(BOOL)isCollapsed;
- (void)update:(ChevronViewState)state;

- (void)sheetUpdatePointsLabel:(NSString*)points;
- (void)sheetUpdateKmLabel:(NSString*)km;
- (void)sheetUpdateTimeLabel:(NSString*)time;

- (void)sheetUpdateStartCityLabel:(NSString*)city;
- (void)sheetUpdateEndCityLabel:(NSString*)city;

- (void)sheetUpdateStartAddressLabel:(NSString*)address;
- (void)sheetUpdateEndAddressLabel:(NSString*)address;

- (void)sheetUpdateStartTimeLabel:(NSString*)time;
- (void)sheetUpdateEndTimeLabel:(NSString*)time;

- (void)sheetUpdateTrackOriginButton:(NSString*)origin;
- (void)sheetUpdateTagsButton:(NSArray*)tagsArray;

- (void)sheetUpdateScores:(float)acc brake:(float)brake phone:(float)phone speed:(float)speed corner:(float)corner;

@end

NS_ASSUME_NONNULL_END
