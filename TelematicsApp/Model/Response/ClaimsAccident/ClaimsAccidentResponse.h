//
//  ClaimsAccidentResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 14.03.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "RootResponse.h"
#import "ClaimsAccidentResultResponse.h"

@interface ClaimsAccidentResponse: RootResponse

@property (nonatomic, strong) ClaimsAccidentResultResponse<Optional>* Result;

@end
