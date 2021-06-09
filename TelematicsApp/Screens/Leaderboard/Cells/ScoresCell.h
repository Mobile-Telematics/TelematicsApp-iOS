//
//  ScoresCell.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 07.04.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;
#import "ProgressBarView.h"
#import "UICountingLabel.h"
#import "LeaderboardResultResponse.h"

@interface ScoresCell: UITableViewCell

@property (strong, nonatomic) LeaderboardResultResponse *leaderScore;

@property (nonatomic, assign, readwrite) IBOutlet UIImageView           *icon;
@property (nonatomic, assign, readwrite) IBOutlet UILabel               *titleLbl;
@property (nonatomic, assign, readwrite) IBOutlet UICountingLabel       *positionLbl;
@property (nonatomic) IBOutlet ProgressBarView                          *progressBarOBDView;

- (void)configAccel:(float)value usersNumber:(float)userValue;
- (void)configDecel:(float)value usersNumber:(float)userValue;
- (void)configSpeed:(float)value usersNumber:(float)userValue;
- (void)configPhone:(float)value usersNumber:(float)userValue;
- (void)configCorner:(float)value usersNumber:(float)userValue;

- (void)configTrips:(float)value usersNumber:(float)userValue;
- (void)configMileage:(float)value usersNumber:(float)userValue;
- (void)configTime:(float)value usersNumber:(float)userValue;

@end
