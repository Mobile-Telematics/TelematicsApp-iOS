//
//  CheckResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 24.08.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "RootResponse.h"
#import "CheckResultResponse.h"

@interface CheckResponse: ResponseObject

@property (nonatomic, strong) CheckResultResponse<Optional>* Result;

@end
