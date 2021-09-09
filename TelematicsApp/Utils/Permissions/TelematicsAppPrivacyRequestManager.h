//
//  TelematicsAppPrivacyRequestManager.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 04.12.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;
@import Foundation;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
#import <UserNotifications/UserNotifications.h>
#endif

typedef NS_ENUM(NSInteger, TelematicsAppAuthorizationStatus) {
    TelematicsAppAuthorizationStatusNotDetermined = 0,
    TelematicsAppAuthorizationStatusRestricted = 1,
    TelematicsAppAuthorizationStatusDenied = 2,
    TelematicsAppAuthorizationStatusAuthorized = 3,
    TelematicsAppAuthorizationStatusAuthorizedWhenInUse = 4,
    TelematicsAppAuthorizationStatusAuthorizedAlways = TelematicsAppAuthorizationStatusAuthorized,
    TelematicsAppAuthorizationStatusNotSupportForCurrentDevice = 5,
    TelematicsAppAuthorizationStatusNotSupportForLowerOSVersion = 6,
    TelematicsAppAuthorizationStatusUnavailable = 7,
    TelematicsAppAuthorizationStatusUnknown = 8,
};

typedef NS_ENUM(NSInteger, TelematicsAppPrivacyType) {
    TelematicsAppPrivacyTypePhotoLibrary = 0,
    TelematicsAppPrivacyTypeCamera,
    TelematicsAppPrivacyTypeMicrophone,
//    TelematicsAppPrivacyTypeBluetooth,
    TelematicsAppPrivacyTypeLocationAlways,
    TelematicsAppPrivacyTypeLocationWhenInUse,
    TelematicsAppPrivacyTypeUserNotification,
    TelematicsAppPrivacyTypeUNNotification,
    TelematicsAppPrivacyTypeMotion,
    TelematicsAppPrivacyTypeAddressBook,
    TelematicsAppPrivacyTypeContacts,
    TelematicsAppPrivacyTypeEvent,
    TelematicsAppPrivacyTypeReminder,
    TelematicsAppPrivacyTypeHomeKit,
    TelematicsAppPrivacyTypeHealth,
    TelematicsAppPrivacyTypeSpeech,
    TelematicsAppPrivacyTypeSiri,
    TelematicsAppPrivacyTypeNFC,
    TelematicsAppPrivacyTypeFaceID,
};
typedef NS_OPTIONS(NSInteger, TelematicsAppPushNotificationType) {
    TelematicsAppPushNotificationTypeNone    = 0,
    TelematicsAppPushNotificationTypeBadge   = (1 << 0),
    TelematicsAppPushNotificationTypeSound   = (1 << 1),
    TelematicsAppPushNotificationTypeAlert   = (1 << 2),
    TelematicsAppPushNotificationTypeCarPlay = (1 << 3),
};

typedef void(^TelematicsAppRequestAuthorizationHandler)(TelematicsAppAuthorizationStatus status);


FOUNDATION_EXTERN NSString * const TelematicsAppCoreMotionAuthorizationStatusKey;
FOUNDATION_EXTERN NSString * const TelematicsAppNotificationAuthorizationStatusKey;
FOUNDATION_EXTERN NSString * const TelematicsAppHomeKitAuthorizationStatusKey;


@protocol TelematicsAppPrivacyAccessor <NSObject>
@required
+ (TelematicsAppAuthorizationStatus)authorizationStatus;
- (void)requestAuthorization:(TelematicsAppRequestAuthorizationHandler)handler;

@optional
@end

@interface TelematicsAppPrivacyRequestManager : NSObject

+ (TelematicsAppAuthorizationStatus)authorizationStatusForPrivacyType:(TelematicsAppPrivacyType)privacyType;
+ (void)requestAuthorization:(TelematicsAppPrivacyType)privacyType
                     handler:(TelematicsAppRequestAuthorizationHandler)handler;

+ (void)requestUNNotificationAuthorization:(NSSet<UNNotificationCategory *> *)categories
                                   handler:(TelematicsAppRequestAuthorizationHandler)handler API_AVAILABLE(ios(10.0));

+ (void)requestAuthorizationMotionImmediately;
+ (void)gotoApplicationSystemSettings;

@end
