//
//  CheckResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 24.08.18.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "RootResponse.h"
#import "CheckResultResponse.h"

@interface CheckResponse: ResponseObject

@property (nonatomic, strong) CheckResultResponse<Optional>* Result;

@end
