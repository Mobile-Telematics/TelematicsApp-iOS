//
//  RootResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 20.01.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ResponseObject.h"
#import "ErrorsResponse.h"

@interface RootResponse: ResponseObject

@property (nonatomic, copy) ErrorsResponse<Optional>* Errors;

- (__kindof ResponseObject<Optional>*)Result;

@end
