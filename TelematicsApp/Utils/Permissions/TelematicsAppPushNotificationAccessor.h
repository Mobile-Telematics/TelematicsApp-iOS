//
//  TelematicsAppPushNotificationAccessor.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 04.12.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "TelematicsAppPrivacyRequestManager.h"
@interface TelematicsAppPushNotificationAccessor : NSObject<TelematicsAppPrivacyAccessor>

+ (void)requestUserNotificationAuthorization:(NSSet<UIUserNotificationCategory *> *)categories
                                     handler:(TelematicsAppRequestAuthorizationHandler)handler;

+ (void)requestUNNotificationAuthorization:(NSSet<UNNotificationCategory *> *)categories
                                   handler:(TelematicsAppRequestAuthorizationHandler)handler API_AVAILABLE(ios(10.0));
@end
