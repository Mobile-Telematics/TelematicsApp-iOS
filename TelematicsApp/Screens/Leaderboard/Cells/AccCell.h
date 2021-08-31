//
//  AccCell.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 13.04.20.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;
#import "ProgressBarView.h"
#import "UICountingLabel.h"

@interface AccCell: UITableViewCell

@property (nonatomic, assign, readwrite) IBOutlet UIImageView       *icon;
@property (nonatomic, assign, readwrite) IBOutlet UILabel           *titleLbl;
@property (nonatomic, assign, readwrite) IBOutlet UICountingLabel   *positionLbl;
@property (nonatomic) IBOutlet ProgressBarView                      *progressBarAcc;

- (void)configAcc:(float)value usersNumber:(float)userValue;

@end
