//
//  JobsCompletedCell.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 22.11.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "JobsCompletedCell.h"

@interface JobsCompletedCell ()

@end

@implementation JobsCompletedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    if (IS_IPHONE_5 || IS_IPHONE_4)
        self.jobCompletedNameLbl.font = [Font medium12];
}

@end
