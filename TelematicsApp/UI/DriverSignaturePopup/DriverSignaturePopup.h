//
//  DriverSignaturePopup.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 11.10.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;
#import "GeneralButton.h"

@interface DriverSignaturePopup: UIView

@property (strong, nonatomic) IBOutlet UIButton *event1Btn;
@property (strong, nonatomic) IBOutlet UIButton *event2Btn;
@property (strong, nonatomic) IBOutlet UIButton *event3Btn;
@property (strong, nonatomic) IBOutlet UIButton *event4Btn;
@property (strong, nonatomic) IBOutlet UIButton *event5Btn;
@property (strong, nonatomic) IBOutlet UIButton *event6Btn;
@property (strong, nonatomic) IBOutlet UIButton *event7Btn;
@property (strong, nonatomic) IBOutlet UIButton *event8Btn;

@property (strong, nonatomic) IBOutlet UILabel *event1Lbl;
@property (strong, nonatomic) IBOutlet UILabel *event2Lbl;
@property (strong, nonatomic) IBOutlet UILabel *event3Lbl;
@property (strong, nonatomic) IBOutlet UILabel *event4Lbl;
@property (strong, nonatomic) IBOutlet UILabel *event5Lbl;
@property (strong, nonatomic) IBOutlet UILabel *event6Lbl;
@property (strong, nonatomic) IBOutlet UILabel *event7Lbl;
@property (strong, nonatomic) IBOutlet UILabel *event8Lbl;

@property (strong, nonatomic) IBOutlet GeneralButton *cancelBtn;
@property (strong, nonatomic) IBOutlet GeneralButton *submitBtn;

@end
