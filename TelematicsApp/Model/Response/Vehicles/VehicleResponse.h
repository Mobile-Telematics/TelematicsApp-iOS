//
//  VehicleResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 24.01.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "RootResponse.h"
#import "VehicleResultResponse.h"

@class VehicleResultResponse;

@interface VehicleResponse: RootResponse

@property (nonatomic, strong) VehicleResultResponse<Optional>* Result;
//@property (nonatomic, strong) NSDictionary<Optional>* Result;

@end
