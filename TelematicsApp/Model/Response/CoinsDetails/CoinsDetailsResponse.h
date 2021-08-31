//
//  CoinsDetailsResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 10.08.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "RootResponse.h"
#import "CoinsDetailsObject.h"

@interface CoinsDetailsResponse: ResponseObject

@property (nonatomic, strong) NSMutableArray<CoinsDetailsObject, Optional> *Result;

@end
