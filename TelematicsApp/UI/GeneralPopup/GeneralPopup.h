//
//  GeneralPopup.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.12.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;
#import "GeneralButton.h"

@interface GeneralPopup: UIView

@property (strong, nonatomic) IBOutlet UIImageView *iconView;
@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet GeneralButton *gpsButton;
@property (strong, nonatomic) IBOutlet GeneralButton *motionButton;
@property (strong, nonatomic) IBOutlet GeneralButton *pushButton;

@end
