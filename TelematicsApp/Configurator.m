//
//  Configurator.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 03.03.20.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "Configurator.h"
#import <UIKit/UIKit.h>

@implementation Configurator


#pragma mark - App Appearance

+ (void)setMainAppConfigurationFromPlist {
    
    [[Configurator sharedInstance] setupWithPlist:@"Configurator"];
    [[Configurator sharedInstance] setCurrentconfigName:TelematicsApp_CONFIG];
    
}

@end
