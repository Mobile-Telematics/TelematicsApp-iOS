//
//  TelematicsAppCameraAccessor.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 04.12.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "TelematicsAppCameraAccessor.h"
#import <AVFoundation/AVFoundation.h>

@implementation TelematicsAppCameraAccessor

+ (TelematicsAppAuthorizationStatus)authorizationStatus {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:
            return TelematicsAppAuthorizationStatusNotDetermined;
        case AVAuthorizationStatusRestricted:
            return TelematicsAppAuthorizationStatusRestricted;
        case AVAuthorizationStatusDenied:
            return TelematicsAppAuthorizationStatusDenied;
        case AVAuthorizationStatusAuthorized:
            return TelematicsAppAuthorizationStatusAuthorized;
    }
}

- (void)requestAuthorization:(TelematicsAppRequestAuthorizationHandler)handler {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            handler([TelematicsAppCameraAccessor authorizationStatus]);
        });
    }];
}
@end
