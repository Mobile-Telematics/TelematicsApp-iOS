//
//  ClaimsUserResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 14.03.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "RootResponse.h"
#import "ClaimsUserResultResponse.h"

@interface ClaimsUserResponse: RootResponse

@property (nonatomic, strong) ClaimsUserResultResponse<Optional>* Result;

@end
