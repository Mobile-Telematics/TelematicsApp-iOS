//
//  TelematicsAppPhotoLibraryAccessor.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 04.12.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "TelematicsAppPhotoLibraryAccessor.h"
#import <Photos/Photos.h>
@implementation TelematicsAppPhotoLibraryAccessor
+ (TelematicsAppAuthorizationStatus)authorizationStatus {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusNotDetermined:
            return TelematicsAppAuthorizationStatusNotDetermined;
        case PHAuthorizationStatusRestricted:
            return TelematicsAppAuthorizationStatusRestricted;
        case PHAuthorizationStatusDenied:
            return TelematicsAppAuthorizationStatusDenied;
        case PHAuthorizationStatusAuthorized:
            return TelematicsAppAuthorizationStatusAuthorized;
        case PHAuthorizationStatusLimited:
            return TelematicsAppAuthorizationStatusNotDetermined;
            break;
    }
}

- (void)requestAuthorization:(TelematicsAppRequestAuthorizationHandler)handler {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            handler([TelematicsAppPhotoLibraryAccessor authorizationStatus]);
        });
    }];
}
@end
