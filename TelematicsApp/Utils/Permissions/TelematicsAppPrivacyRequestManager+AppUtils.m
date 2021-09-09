//
//  TelematicsAppPrivacyRequestManager+AppUtils.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 04.12.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "TelematicsAppPrivacyRequestManager+AppUtils.h"

@implementation TelematicsAppPrivacyRequestManager (TelematicsAppUtils)
+ (void)TelematicsApp_storeAuthorizationStatus:(TelematicsAppAuthorizationStatus)status forType:(TelematicsAppPrivacyType)type {
    NSString *key = [self TelematicsApp_authorizationStatusKey:type];
    if (key == nil) return;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:status forKey:key];
    [userDefaults synchronize];
}



+ (TelematicsAppAuthorizationStatus)TelematicsApp_authorizationStatusFromUserDefault:(TelematicsAppPrivacyType)type{
    NSString *key = [self TelematicsApp_authorizationStatusKey:type];
    if (key == nil) return TelematicsAppAuthorizationStatusNotDetermined;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    TelematicsAppAuthorizationStatus status = [userDefaults integerForKey:key];
    return status;
}

+ (NSString *)TelematicsApp_authorizationStatusKey:(TelematicsAppPrivacyType)type {
    NSString *key = nil;
    switch (type) {
        case TelematicsAppPrivacyTypeMotion:
            key = TelematicsAppCoreMotionAuthorizationStatusKey;
        default:
            break;
    }
    return key;
}
@end

