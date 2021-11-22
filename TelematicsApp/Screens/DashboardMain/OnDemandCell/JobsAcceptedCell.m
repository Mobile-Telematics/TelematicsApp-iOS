//
//  JobsAcceptedCell.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 22.11.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "JobsAcceptedCell.h"

@interface JobsAcceptedCell ()

@end

@implementation JobsAcceptedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.jobDeclineBtn.layer.borderWidth = 0.8;
    self.jobDeclineBtn.layer.borderColor = [Color officialRedColor].CGColor;
    self.jobDeclineBtn.backgroundColor = [Color officialWhiteColor];
    [self.jobDeclineBtn setTitleColor:[Color officialRedColor] forState:UIControlStateNormal];
    
    self.jobPauseBtn.layer.borderWidth = 0.8;
    self.jobPauseBtn.layer.borderColor = [Color officialOrangeColor].CGColor;
    self.jobPauseBtn.backgroundColor = [Color officialWhiteColor];
    [self.jobPauseBtn setTitleColor:[Color officialOrangeColor] forState:UIControlStateNormal];
    
    if (IS_IPHONE_5 || IS_IPHONE_4)
        self.jobNameLbl.font = [Font medium12];
}
@end
