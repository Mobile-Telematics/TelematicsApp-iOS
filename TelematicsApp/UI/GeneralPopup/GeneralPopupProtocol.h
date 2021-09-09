//
//  GeneralPopupProtocol.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.12.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;
@import Foundation;
#import "GeneralPopup.h"

@protocol GeneralPopupProtocol <NSObject>

@required
- (void)gpsButtonAction:(GeneralPopup*)popupView button:(UIButton*)button;
- (void)motionButtonAction:(GeneralPopup*)popupView button:(UIButton*)button;
- (void)pushButtonAction:(GeneralPopup*)popupView button:(UIButton*)button;

@end
