//
//  TripCell.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 11.09.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
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
@property (weak, nonatomic) IBOutlet UIImageView        *sampleLabel;
@property (weak, nonatomic) IBOutlet UIButton           *driverBtn;
@property (weak, nonatomic) IBOutlet UIImageView        *dotAImg;
@property (weak, nonatomic) IBOutlet UIImageView        *dotBImg;

@property (strong, nonatomic) TagsSwitch                *driverSwitcher;

@property (weak, nonatomic) IBOutlet UILabel            *kmLabel;
@property (weak, nonatomic) IBOutlet UILabel            *pointsLabel;

@property (weak, nonatomic) IBOutlet UIButton           *userTripNameBtn;
@property (weak, nonatomic) IBOutlet UILabel            *userTripAdditionalLbl;

@property (weak, nonatomic) IBOutlet UIImageView        *demoCenterImg;
@property (weak, nonatomic) IBOutlet UIImageView        *demoBackgroundImg;
@property (weak, nonatomic) IBOutlet UIImageView        *demoPointsImg;

@end
