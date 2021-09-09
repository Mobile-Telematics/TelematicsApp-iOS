//
//  WiFiGPSChecker.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 09.01.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import Foundation;
#import <ifaddrs.h>
#import <net/if.h>
#import <SystemConfiguration/CaptiveNetwork.h>

@interface WiFiGPSChecker : NSObject

@property (assign, nonatomic) BOOL checkAccess;

+ (instancetype)sharedChecker;

+ (BOOL)isWiFiEnabled;
+ (BOOL)isWiFiConnected;
+ (NSString *)BSSID;
+ (NSString *)SSID;

- (BOOL)networkAvailable;
- (BOOL)gpsAvailable;
- (BOOL)motionAvailable;
- (BOOL)pushAvailable;

@end
