//
//  SettingsBatteryCell.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 11.10.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "SettingsBatteryCell.h"

@implementation SettingsBatteryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.bleSwitch.onTintColor = [Color officialMainAppColor];
    [self.bleSwitch addTarget:self action:@selector(batterySwitchToggled:) forControlEvents:UIControlEventValueChanged];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)batterySwitchToggled:(id)sender {
    
    UISwitch *enableSwitch = (UISwitch *)sender;
    
    if ([enableSwitch isOn]) {
        [[RPEntry instance] setAggressiveHeartbeats:false];
    } else {
        [[RPEntry instance] setAggressiveHeartbeats:true];
    }
}

@end
