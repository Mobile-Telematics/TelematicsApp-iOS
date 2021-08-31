//
//  TelematicsAppMotionAccessor.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 04.12.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "TelematicsAppMotionAccessor.h"
#import <CoreMotion/CoreMotion.h>
#import "TelematicsAppPrivacyRequestManager+AppUtils.h"

@implementation TelematicsAppMotionAccessor
+ (TelematicsAppAuthorizationStatus)authorizationStatus {
    if (![CMMotionActivityManager isActivityAvailable]) {
        return TelematicsAppAuthorizationStatusNotSupportForCurrentDevice;
    } else {
        CMAuthorizationStatus status = [CMMotionActivityManager authorizationStatus];
        switch (status) {
            case CMAuthorizationStatusNotDetermined:
                return TelematicsAppAuthorizationStatusNotDetermined;
            case CMAuthorizationStatusRestricted:
                return TelematicsAppAuthorizationStatusRestricted;
            case CMAuthorizationStatusDenied:
                return TelematicsAppAuthorizationStatusDenied;
            case CMAuthorizationStatusAuthorized:
                return TelematicsAppAuthorizationStatusAuthorized;
        }
    }
}
- (void)requestAuthorization:(TelematicsAppRequestAuthorizationHandler)handler {
    if (![CMMotionActivityManager isActivityAvailable]) {
        NSAssert(NO, @"current device doesn't support CoreMotion");
        handler(TelematicsAppAuthorizationStatusNotSupportForCurrentDevice);
    } else {
        CMMotionActivityManager *manager = [[CMMotionActivityManager alloc] init];
        __weak typeof(manager) weakManager = manager;
        [manager startActivityUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMMotionActivity *activity) {
            NSLog(@"activity:%@", activity);
            __strong typeof(weakManager) strongManager = weakManager;
            [strongManager stopActivityUpdates];
            dispatch_async(dispatch_get_main_queue(), ^{
                [TelematicsAppPrivacyRequestManager TelematicsApp_storeAuthorizationStatus:TelematicsAppAuthorizationStatusAuthorized forType:TelematicsAppPrivacyTypeMotion];
                handler(TelematicsAppAuthorizationStatusAuthorized);
            });
        }];
    }
}
@end
