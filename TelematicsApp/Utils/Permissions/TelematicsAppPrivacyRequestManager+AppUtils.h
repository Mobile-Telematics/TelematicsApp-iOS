//
//  TelematicsAppPrivacyRequestManager+AppUtils.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 04.12.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "TelematicsAppPrivacyRequestManager.h"

@interface TelematicsAppPrivacyRequestManager (TelematicsAppUtils)
+ (void)TelematicsApp_storeAuthorizationStatus:(TelematicsAppAuthorizationStatus)status forType:(TelematicsAppPrivacyType)type;
+ (TelematicsAppAuthorizationStatus)TelematicsApp_authorizationStatusFromUserDefault:(TelematicsAppPrivacyType)type;
@end
