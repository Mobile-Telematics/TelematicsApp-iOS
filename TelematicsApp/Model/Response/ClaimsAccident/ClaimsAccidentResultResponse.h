//
//  ClaimsAccidentResultResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 14.03.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ResponseObject.h"

@interface ClaimsAccidentResultResponse: ResponseObject

@property (nonatomic, strong) NSArray<Optional> *AccidentTypes;

@end
