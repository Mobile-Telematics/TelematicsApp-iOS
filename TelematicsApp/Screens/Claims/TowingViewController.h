//
//  TowingViewController.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.04.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TowingSwitch.h"

@class TowingSwitch;

@interface TowingViewController : UIViewController

@property (strong, nonatomic) TowingSwitch *drivableSwitcher;
@property (strong, nonatomic) TowingSwitch *towingSwitcher;

@end

