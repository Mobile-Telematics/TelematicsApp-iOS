//
//  TelematicsAppMicrophoneAccessor.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 04.12.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "TelematicsAppMicrophoneAccessor.h"
#import <AVFoundation/AVFoundation.h>
@implementation TelematicsAppMicrophoneAccessor

+ (TelematicsAppAuthorizationStatus)authorizationStatus {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
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
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            handler([TelematicsAppMicrophoneAccessor authorizationStatus]);
        });
    }];
}
@end
