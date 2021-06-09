//
//  CongratulationsPopup.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 31.07.19.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;
#import "GeneralButton.h"

@interface CongratulationsPopup: UIView

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UILabel *ad1Text;
@property (strong, nonatomic) IBOutlet UILabel *ad2Text;
@property (strong, nonatomic) IBOutlet UILabel *ad3Text;
@property (strong, nonatomic) IBOutlet GeneralButton *okBtn;

@end
