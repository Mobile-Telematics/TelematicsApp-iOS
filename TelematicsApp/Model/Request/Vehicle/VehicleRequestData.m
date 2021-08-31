//
//  VehicleRequestData.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 24.01.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "VehicleRequestData.h"
#import "Helpers.h"

@implementation VehicleRequestData

- (NSArray<NSString *> *)validateCheckVin {
    NSMutableArray* errors = [NSMutableArray array];
    
    if (self.vin.length != 17) {
        [errors addObject:localizeString(@"validation_enter_vin")];
    }
    
    return errors.count ? errors : [super validateCheckVin];
}

@end
