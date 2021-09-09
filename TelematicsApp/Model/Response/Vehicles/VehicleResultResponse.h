//
//  VehicleResultResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 24.01.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ResponseObject.h"
#import "VehicleObject.h"

@interface VehicleResultResponse: ResponseObject

@property (nonatomic, strong) NSMutableArray<VehicleObject, Optional> *Cars;

@end
