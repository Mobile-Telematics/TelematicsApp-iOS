//
//  VehiclesDictionaryResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 04.05.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "RootResponse.h"
#import "VehiclesDictionaryResultResponse.h"

@class VehiclesDictionaryResultResponse;

@interface VehiclesDictionaryResponse: RootResponse

@property (nonatomic, strong) NSDictionary<Optional>* Result;

@end
