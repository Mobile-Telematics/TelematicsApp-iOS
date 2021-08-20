//
//  CoinsResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 10.08.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "RootResponse.h"
#import "CoinsResultResponse.h"

@interface CoinsResponse: RootResponse

@property (nonatomic, strong) CoinsResultResponse<Optional>* Result;

@end
