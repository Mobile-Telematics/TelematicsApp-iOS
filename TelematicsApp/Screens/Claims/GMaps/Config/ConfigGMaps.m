//
//  ConfigGMaps.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.04.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ConfigGMaps.h"

@implementation ConfigGMaps


double CURRENT_LATITUDE         = 0.0f;
double CURRENT_LONGITUDE        = 0.0f;
NSString                        *CURRENT_ADDRESS;
CLLocationManager               *locationManager;
CLLocation                      *currentLocation;

@end
