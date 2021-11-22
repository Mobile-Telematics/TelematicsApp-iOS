//
//  SettingsAccidentCell.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 11.10.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "SettingsAccidentCell.h"

@implementation SettingsAccidentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.accidentSwitch.onTintColor = [Color officialMainAppColor];
    //[self.accidentSwitch addTarget:self action:@selector(accidentSwitchToggled:) forControlEvents:UIControlEventValueChanged];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)accidentSwitchToggled:(id)sender {
    //
}

@end
