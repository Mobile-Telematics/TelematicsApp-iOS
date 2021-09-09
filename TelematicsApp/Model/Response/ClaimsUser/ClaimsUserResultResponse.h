//
//  ClaimsUserResultResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 14.03.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ResponseObject.h"
#import "ClaimsUserObject.h"

@interface ClaimsUserResultResponse: ResponseObject

@property (nonatomic, strong) NSMutableArray<Optional> *Claims;

@end
