//
//  TelematicsAppLocationAccessor.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 04.12.18.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "TelematicsAppLocationAccessor.h"
#import <CoreLocation/CoreLocation.h>

@interface TelematicsAppLocationAccessor() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) TelematicsAppRequestAuthorizationHandler handler;

@end

@implementation TelematicsAppLocationAccessor
#pragma mark getter
- (CLLocationManager *)locationManager {
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static TelematicsAppLocationAccessor *shareInstance = nil;
    dispatch_once(&onceToken, ^{
        shareInstance = [[TelematicsAppLocationAccessor alloc] init];
    });
    return shareInstance;
}

+ (TelematicsAppAuthorizationStatus)authorizationStatus {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            return TelematicsAppAuthorizationStatusNotDetermined;
        case kCLAuthorizationStatusRestricted:
            return TelematicsAppAuthorizationStatusRestricted;
        case kCLAuthorizationStatusDenied:
            return TelematicsAppAuthorizationStatusDenied;
        case kCLAuthorizationStatusAuthorizedAlways:
            return TelematicsAppAuthorizationStatusAuthorizedAlways;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            return TelematicsAppAuthorizationStatusAuthorizedWhenInUse;
    }
}

- (void)requestAlwaysAuthorization:(TelematicsAppRequestAuthorizationHandler)handler {
    TelematicsAppAuthorizationStatus status = [TelematicsAppLocationAccessor authorizationStatus];
    if (status != TelematicsAppAuthorizationStatusNotDetermined) {
        if (handler) {
            handler(status);
        }
    } else {
        self.handler = handler;
        [self.locationManager requestAlwaysAuthorization];
        [self.locationManager startUpdatingLocation];
    }
}


- (void)requestWhenInUseAuthorization:(TelematicsAppRequestAuthorizationHandler)handler {
    TelematicsAppAuthorizationStatus status = [TelematicsAppLocationAccessor authorizationStatus];
    if (status != TelematicsAppAuthorizationStatusNotDetermined) {
        if (handler) {
            handler(status);
        }
    } else {
        self.handler = handler;
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
    }
}

#pragma mark CLLocation Manager Delegate
- (void)locationManager:(CLLocationManager *)manager
       didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.locationManager stopUpdatingLocation];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.handler) {
            self.handler(TelematicsAppAuthorizationStatusNotSupportForCurrentDevice);
            self.handler = nil;
        }
    });
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusNotDetermined) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.handler) {
            self.handler([TelematicsAppLocationAccessor authorizationStatus]);
            self.handler = nil;
        }
    });
}
@end


@implementation TelematicsAppLocationAlwaysAccessor
+ (TelematicsAppAuthorizationStatus)authorizationStatus {
    return [TelematicsAppLocationAccessor authorizationStatus];
}

- (void)requestAuthorization:(TelematicsAppRequestAuthorizationHandler)handler {
    [[TelematicsAppLocationAccessor shareInstance] requestAlwaysAuthorization:handler];
}
@end


@implementation TelematicsAppLocationWhenInUseAccessor
+ (TelematicsAppAuthorizationStatus)authorizationStatus {
    return [TelematicsAppLocationAccessor authorizationStatus];
}

- (void)requestAuthorization:(TelematicsAppRequestAuthorizationHandler)handler {
    [[TelematicsAppLocationAccessor shareInstance] requestWhenInUseAuthorization:handler];
}
@end
