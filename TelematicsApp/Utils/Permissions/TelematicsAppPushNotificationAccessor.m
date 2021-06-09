//
//  TelematicsAppPushNotificationAccessor.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 04.12.18.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "TelematicsAppPushNotificationAccessor.h"
@import UIKit;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
#import <UserNotifications/UserNotifications.h>
#endif


@interface TelematicsAppPushNotificationAccessor()
+ (instancetype)shareInstance;
@end


@implementation TelematicsAppPushNotificationAccessor
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static TelematicsAppPushNotificationAccessor *shareInstance = nil;
    dispatch_once(&onceToken, ^{
        shareInstance = [[TelematicsAppPushNotificationAccessor alloc] init];
    });
    return shareInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}


#pragma mark TelematicsAppPrivacyAccessor

+ (TelematicsAppAuthorizationStatus)authorizationStatus {
    __block TelematicsAppAuthorizationStatus status = TelematicsAppAuthorizationStatusUnknown;
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
        UNAuthorizationStatus authorizationStatus = settings.authorizationStatus;
        switch (authorizationStatus) {
            case UNAuthorizationStatusNotDetermined:
                status = TelematicsAppAuthorizationStatusNotDetermined;
                break;
            case UNAuthorizationStatusDenied:
                status = TelematicsAppAuthorizationStatusDenied;
                break;
            case UNAuthorizationStatusAuthorized:
                status = TelematicsAppAuthorizationStatusAuthorized;
                break;
            case UNAuthorizationStatusProvisional:
                status = TelematicsAppAuthorizationStatusNotDetermined;
                break;
            case UNAuthorizationStatusEphemeral:
                status = TelematicsAppAuthorizationStatusNotDetermined;
                break;
        }
    }];
    return status;
}

+ (void)requestAuthorization:(TelematicsAppRequestAuthorizationHandler)handler {
    return [self requestUserNotificationAuthorization:[NSSet set] handler:handler];
}

+ (void)requestUNNotificationAuthorization:(NSSet<UNNotificationCategory *> *)categories handler:(TelematicsAppRequestAuthorizationHandler)handler {
    TelematicsAppAuthorizationStatus status = [self authorizationStatus];
    if (status != TelematicsAppAuthorizationStatusNotDetermined) {
        if (handler) {
            handler(status);
        }
    }else {
        [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:(id)categories];
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:0 completionHandler:^(BOOL granted, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                TelematicsAppAuthorizationStatus status = [self authorizationStatus];
                if (handler) {
                    handler(status);
                }
            });
        }];
    }
}

+ (void)requestUserNotificationAuthorization:(NSSet<UIUserNotificationCategory *> *)categories handler:(TelematicsAppRequestAuthorizationHandler)handler {
    TelematicsAppAuthorizationStatus status = [self authorizationStatus];
    if (status != TelematicsAppAuthorizationStatusNotDetermined) {
        if (handler) {
            handler(status);
        }
    } else {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:categories];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }


}
@end
