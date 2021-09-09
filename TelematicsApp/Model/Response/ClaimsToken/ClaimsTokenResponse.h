//
//  ClaimsTokenResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 14.03.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "RootResponse.h"
#import "ClaimsTokenResultResponse.h"

@interface ClaimsTokenResponse: ResponseObject

@property (nonatomic, strong) ClaimsTokenResultResponse<Optional>* Result;

@end
