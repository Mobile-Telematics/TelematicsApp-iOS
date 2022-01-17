//
//  GeneralPermissionsPopupProtocol.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.12.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;
@import Foundation;
#import "GeneralPermissionsPopup.h"

@protocol GeneralPermissionsPopupProtocol <NSObject>

@required
- (void)gpsButtonAction:(GeneralPermissionsPopup*)popupView button:(UIButton*)button;
- (void)motionButtonAction:(GeneralPermissionsPopup*)popupView button:(UIButton*)button;
- (void)pushButtonAction:(GeneralPermissionsPopup*)popupView button:(UIButton*)button;

@end
