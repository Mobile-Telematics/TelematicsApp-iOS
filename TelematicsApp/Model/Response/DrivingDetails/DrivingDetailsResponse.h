//
//  DrivingDetailsResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 14.08.19.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "RootResponse.h"
#import "DrivingDetailsObject.h"

@interface DrivingDetailsResponse: ResponseObject

@property (nonatomic, strong) NSMutableArray<DrivingDetailsObject, Optional> *Result;

@end
