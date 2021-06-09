//
//  ClaimAlertPopupProtocol.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.05.20.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;
@import Foundation;
#import "ClaimAlertPopup.h"

@protocol ClaimAlertPopupProtocol <NSObject>

@required

- (void)cancelClaimButtonAction:(ClaimAlertPopup*)popupView button:(UIButton*)button;
- (void)noEventButtonAction:(ClaimAlertPopup *)popupView button:(UIButton *)button;
- (void)event1ButtonAction:(ClaimAlertPopup *)popupView newType:(NSString *)newType button:(UIButton *)button;
- (void)event2ButtonAction:(ClaimAlertPopup *)popupView newType:(NSString *)newType button:(UIButton *)button;
- (void)event3ButtonAction:(ClaimAlertPopup *)popupView newType:(NSString *)newType button:(UIButton *)button;

@end
