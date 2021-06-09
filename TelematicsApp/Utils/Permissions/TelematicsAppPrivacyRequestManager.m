//
//  TelematicsAppPrivacyRequestManager.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 04.12.18.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;
@import CoreMotion;
#import "TelematicsAppPrivacyRequestManager.h"
#import "TelematicsAppPhotoLibraryAccessor.h"
#import "TelematicsAppCameraAccessor.h"
#import "TelematicsAppMicrophoneAccessor.h"
#import "TelematicsAppLocationAccessor.h"
#import "TelematicsAppPushNotificationAccessor.h"
#import "TelematicsAppMotionAccessor.h"
#import "TelematicsAppAddressBookAccessor.h"
#import "TelematicsAppContactsAccessor.h"
#import "TelematicsAppFaceIDAccessor.h"

NSString * const TelematicsAppNotificationAuthorizationStatusKey = @"com.privacyPermission.notification";
NSString * const TelematicsAppHomeKitAuthorizationStatusKey = @"com.privacyPermission.homeKit";
NSString * const TelematicsAppCoreMotionAuthorizationStatusKey = @"com.privacyPermission.coreMotion";
@implementation TelematicsAppPrivacyRequestManager

+ (TelematicsAppAuthorizationStatus)authorizationStatusForPrivacyType:(TelematicsAppPrivacyType)privacyType {
    Class<TelematicsAppPrivacyAccessor> privacyAccessor = [self privacyAccessorClass:privacyType];
    return [privacyAccessor authorizationStatus];
}

+ (void)requestUserNotificationAuthorization:(NSSet<UIUserNotificationCategory *> *)categories
                                     handler:(TelematicsAppRequestAuthorizationHandler)handler {
    return [TelematicsAppPushNotificationAccessor requestUserNotificationAuthorization:categories handler:handler];
}

+ (void)requestUNNotificationAuthorization:(NSSet<UNNotificationCategory *> *)categories
                                   handler:(TelematicsAppRequestAuthorizationHandler)handler {
    return [TelematicsAppPushNotificationAccessor requestUNNotificationAuthorization:categories handler:handler];
}

+ (void)requestAuthorization:(TelematicsAppPrivacyType)privacyType
                     handler:(TelematicsAppRequestAuthorizationHandler)handler {
    Class cls = [self privacyAccessorClass:privacyType];
    TelematicsAppAuthorizationStatus status = [cls authorizationStatus];
    id<TelematicsAppPrivacyAccessor> privacyAccessor = [[cls alloc] init];
    if (status != TelematicsAppAuthorizationStatusNotDetermined) {
        handler(status);
    } else {
        [privacyAccessor requestAuthorization:handler];
    }
}

+ (void)requestAuthorizationMotionImmediately {
    CMMotionActivityManager *manager = [[CMMotionActivityManager alloc]init];
    [manager queryActivityStartingFromDate:[NSDate date]
                                    toDate:[NSDate date]
                                   toQueue:[NSOperationQueue mainQueue]
                               withHandler:^(NSArray<CMMotionActivity *> * _Nullable activities, NSError * _Nullable error) {

                                   if ([CMMotionActivityManager authorizationStatus] == CMAuthorizationStatusAuthorized) {
                                       NSLog(@"CMAuthorizationStatusAuthorized");
                                   } else {
                                       NSLog(@"DeniCMAuthorizationStatusDenied");
//                                       CMMotionActivityManager *manager = [[CMMotionActivityManager alloc] init];
//                                       __weak typeof(manager) weakManager = manager;
//                                       [manager startActivityUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMMotionActivity *activity) {
//                                           NSLog(@"activity:%@", activity);
//                                           __strong typeof(weakManager) strongManager = weakManager;
//                                           [strongManager stopActivityUpdates];
//                                       }];
                                   }
                               }];
    
}

+ (void)gotoApplicationSetting {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *settingURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([application canOpenURL:settingURL]) {
        [application openURL:settingURL options:@{} completionHandler:nil];
    }
}


#pragma mark private method
+ (Class<TelematicsAppPrivacyAccessor>)privacyAccessorClass:(TelematicsAppPrivacyType)privacyType {
    switch (privacyType) {
        case TelematicsAppPrivacyTypePhotoLibrary:
            return [TelematicsAppPhotoLibraryAccessor class];
        case TelematicsAppPrivacyTypeCamera:
            return [TelematicsAppCameraAccessor class];
        case TelematicsAppPrivacyTypeMicrophone:
            return [TelematicsAppMicrophoneAccessor class];
        case TelematicsAppPrivacyTypeLocationAlways:
            return [TelematicsAppLocationAlwaysAccessor class];
        case TelematicsAppPrivacyTypeLocationWhenInUse:
            return [TelematicsAppLocationWhenInUseAccessor class];
        case TelematicsAppPrivacyTypeUserNotification:
        case TelematicsAppPrivacyTypeUNNotification:
            return [TelematicsAppPushNotificationAccessor class];
        case TelematicsAppPrivacyTypeMotion:
            return [TelematicsAppMotionAccessor class];
        case TelematicsAppPrivacyTypeAddressBook:
            return [TelematicsAppAddressBookAccessor class];
        case TelematicsAppPrivacyTypeContacts:
            return [TelematicsAppContactsAccessor class];
        case TelematicsAppPrivacyTypeFaceID:
            return [TelematicsAppFaceIDAccessor class];
        default:
            return nil;
    }
}

+(id<TelematicsAppPrivacyAccessor>)privacyAccessor:(TelematicsAppPrivacyType)privacyType {
    Class cls = [self privacyAccessorClass:privacyType];
    return [[cls alloc] init];
}
@end
