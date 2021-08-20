//
//  CongratulationsPopupProtocol.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 31.07.20.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;
@import Foundation;
#import "CongratulationsPopup.h"

@protocol CongratulationsPopupProtocol <NSObject>

@required

- (void)okButtonAction:(CongratulationsPopup*)popupView button:(UIButton*)button;

@end
