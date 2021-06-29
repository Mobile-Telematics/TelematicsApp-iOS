//
//  TelematicsAppFaceIDAccessor.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 04.12.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "TelematicsAppFaceIDAccessor.h"

#import <LocalAuthentication/LocalAuthentication.h>
@implementation TelematicsAppFaceIDAccessor
+ (TelematicsAppAuthorizationStatus)authorizationStatus {
    return TelematicsAppAuthorizationStatusNotDetermined;
}

- (void)requestAuthorization:(TelematicsAppRequestAuthorizationHandler)handler {
    LAContext *context = [[LAContext alloc] init];
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"  " reply:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                handler(TelematicsAppAuthorizationStatusAuthorized);
            }else if (error) {
                NSLog(@"error:%@", error);
                handler(TelematicsAppAuthorizationStatusNotSupportForCurrentDevice);
            }
        }];
    }
}
@end
