//
//  RegResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 24.08.18.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "RootResponse.h"
#import "RegResultResponse.h"

//@class RegResultResponse;

@interface RegResponse: ResponseObject

@property (nonatomic, strong) RegResultResponse<Optional>* Result;

@end
