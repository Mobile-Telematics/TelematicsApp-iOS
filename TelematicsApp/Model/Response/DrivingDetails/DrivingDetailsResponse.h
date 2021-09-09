//
//  DrivingDetailsResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 14.08.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "RootResponse.h"
#import "DrivingDetailsObject.h"

@interface DrivingDetailsResponse: ResponseObject

@property (nonatomic, strong) NSMutableArray<DrivingDetailsObject, Optional> *Result;

@end
