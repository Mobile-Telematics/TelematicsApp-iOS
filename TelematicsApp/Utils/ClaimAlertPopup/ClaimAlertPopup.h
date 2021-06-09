//
//  ClaimAlertPopup.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.05.20.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;
#import "GeneralButton.h"

@interface ClaimAlertPopup: UIView

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;

@property (strong, nonatomic) IBOutlet UILabel *noEventTextLbl;
@property (strong, nonatomic) IBOutlet UILabel *event1TextLbl;
@property (strong, nonatomic) IBOutlet UILabel *event2TextLbl;
@property (strong, nonatomic) IBOutlet UILabel *event3TextLbl;

@property (strong, nonatomic) IBOutlet UIButton *noEventBtn;
@property (strong, nonatomic) IBOutlet UIButton *event1Btn;
@property (strong, nonatomic) IBOutlet UIButton *event2Btn;
@property (strong, nonatomic) IBOutlet UIButton *event3Btn;

@property (strong, nonatomic) IBOutlet GeneralButton *cancelBtn;

@end
