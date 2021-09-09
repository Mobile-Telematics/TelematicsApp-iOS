//
//  WiFiGPSChecker.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 09.01.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "WiFiGPSChecker.h"
#import <SystemServices/SystemServices.h>
#import <CoreLocation/CoreLocation.h>
#import <UserNotifications/UserNotifications.h>
#import "TelematicsAppPrivacyRequestManager.h"

@interface WiFiGPSChecker ()

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) id backgroundTaskIdentifier;
+ (NSDictionary *)wifiDetails;

@end


@implementation WiFiGPSChecker

#pragma mark - Initialization

+ (instancetype)sharedChecker {
    static WiFiGPSChecker *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


#pragma mark - WiFi

+ (BOOL)isWiFiEnabled {
    NSCountedSet * cset = [NSCountedSet new];
    
    struct ifaddrs *interfaces;
    
    if (!getifaddrs(&interfaces)) {
        for( struct ifaddrs *interface = interfaces; interface; interface = interface->ifa_next) {
            if ( (interface->ifa_flags & IFF_UP) == IFF_UP ) {
                [cset addObject:[NSString stringWithUTF8String:interface->ifa_name]];
            }
        }
    }
    return [cset countForObject:@"awdl0"] > 1 ? YES : NO;
}

+ (BOOL)isWiFiConnected {
    return [self.class wifiDetails] == nil ? NO : YES;
}

+ (NSString *)BSSID {
    return [[self.class wifiDetails] objectForKey:@"BSSID"];
}

+ (NSString *)SSID {
    return [[self.class wifiDetails] objectForKey:@"SSID"];
}


#pragma mark - Private

+ (NSDictionary *)wifiDetails {
    return
    (__bridge NSDictionary *)
    CNCopyCurrentNetworkInfo(
                             CFArrayGetValueAtIndex( CNCopySupportedInterfaces(), 0)
                             );
}


#pragma mark - Checking

- (BOOL)networkAvailable {
    BOOL isWiFiEnabled = [WiFiGPSChecker isWiFiEnabled];
    BOOL isReachableVia3G = [[SystemServices sharedServices] connectedToCellNetwork];
    return isWiFiEnabled || isReachableVia3G;
}


- (BOOL)gpsAvailable {
    BOOL isGPSAuthorized = ([CLLocationManager locationServicesEnabled]
                            && ([CLLocationManager authorizationStatus]
                                == kCLAuthorizationStatusAuthorizedAlways));
    return isGPSAuthorized;
}


- (BOOL)motionAvailable {
    BOOL isMotionAuthorized = ([CMMotionActivityManager isActivityAvailable]
                               && ([CMMotionActivityManager authorizationStatus]
                                   == CMAuthorizationStatusAuthorized));
    return isMotionAuthorized;
}


- (BOOL)pushAvailable {

    if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
        UIUserNotificationSettings *grantedSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (grantedSettings.types == UIUserNotificationTypeNone) {
            NSLog(@"Push no permission granted");
            return NO;
        }
        else if (grantedSettings.types & UIUserNotificationTypeSound & UIUserNotificationTypeAlert ){
            NSLog(@"Sound and alert permissions ");
            return YES;
        }
        else if (grantedSettings.types & UIUserNotificationTypeAlert){
            return YES;
        } else {
            NSLog(@"Push no permission granted");
            return NO;
        }
    } else {
        return NO;
    }
}

@end
