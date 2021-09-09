//
//  StreakCell.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 17.08.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "StreakCell.h"
#import "UIImageView+WebCache.h"

@interface StreakCell ()

@end

@implementation StreakCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    if (IS_IPHONE_5 || IS_IPHONE_4) {
        self.mainTitleLbl.font = [Font bold14];
        
        self.currentNameLbl.font = [Font bold11];
        self.bestNameLbl.font = [Font bold11];
        
        self.currentValueLbl.font = [Font medium11];
        self.bestValueLbl.font = [Font medium11];
        
        self.dateTimeSection1Lbl.font = [Font medium11];
        self.dateTimeSection2Lbl.font = [Font medium11];
        
    } else if (IS_IPHONE_8) {
        
        self.dateTimeSection1Lbl.font = [Font medium12];
        self.dateTimeSection2Lbl.font = [Font medium12];
    }
}


@end
