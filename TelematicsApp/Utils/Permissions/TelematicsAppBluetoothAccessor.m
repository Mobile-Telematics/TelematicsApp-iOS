//
//  TelematicsAppBluetoothAccessor.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 04.12.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "TelematicsAppBluetoothAccessor.h"
#import <CoreBluetooth/CoreBluetooth.h>
@implementation TelematicsAppBluetoothAccessor
+ (TelematicsAppAuthorizationStatus)authorizationStatus {
    
    return TelematicsAppAuthorizationStatusNotDetermined;
}

- (void)requestAuthorization:(TelematicsAppRequestAuthorizationHandler)handler {
    
}
@end
