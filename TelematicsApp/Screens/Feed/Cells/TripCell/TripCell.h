//
//  TripCell.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 11.09.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "FeedSlideMenuTableViewCell.h"
#import "TagsSwitch.h"

@interface TripCell : FeedSlideMenuTableViewCell

@property (weak, nonatomic) IBOutlet UILabel            *startLabel;
@property (weak, nonatomic) IBOutlet UILabel            *endLabel;
@property (weak, nonatomic) IBOutlet UILabel            *startAreaLabel;
@property (weak, nonatomic) IBOutlet UILabel            *endAreaLabel;
@property (weak, nonatomic) IBOutlet UILabel            *distanceGPSLabel;
@property (weak, nonatomic) IBOutlet UILabel            *ecoScoringLabel;
@property (weak, nonatomic) IBOutlet UIImageView        *taxiLabel;
@property (weak, nonatomic) IBOutlet UIButton           *driverBtn;
@property (weak, nonatomic) IBOutlet UIImageView        *dotAImg;
@property (weak, nonatomic) IBOutlet UIImageView        *dotBImg;

@property (strong, nonatomic) TagsSwitch                *driverSwitcher;

@property (weak, nonatomic) IBOutlet UILabel            *kmLabel;
@property (weak, nonatomic) IBOutlet UILabel            *pointsLabel;

@property (weak, nonatomic) IBOutlet UIButton           *tripGreenBubble;
@property (weak, nonatomic) IBOutlet UILabel            *userTripAdditionalLbl;
@property (weak, nonatomic) IBOutlet UIImageView        *userSharedTripInfoImg;
@property (weak, nonatomic) IBOutlet UIImageView        *userSharedTripAvatarImg;
@property (weak, nonatomic) IBOutlet UIImageView        *userSharedTripArrowImg;

@property (weak, nonatomic) IBOutlet UIImageView        *demoBackgroundImg;
@property (weak, nonatomic) IBOutlet UIImageView        *demoPointsImg;

@property (weak, nonatomic) IBOutlet UILabel            *makeYourTripLbl;
@property (weak, nonatomic) IBOutlet UILabel            *doNotSeeLbl;
@property (weak, nonatomic) IBOutlet UILabel            *openAppPermissionLbl;

@end
