//
//  StreaksResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 05.08.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "RootResponse.h"
#import "StreaksResultResponse.h"

@interface StreaksResponse: RootResponse

@property (nonatomic, strong) StreaksResultResponse<Optional>* Result;

@end
