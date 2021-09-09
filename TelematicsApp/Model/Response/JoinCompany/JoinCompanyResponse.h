//
//  JoinCompanyResponse.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 09.09.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "RootResponse.h"
#import "JoinCompanyResultResponse.h"

@interface JoinCompanyResponse: ResponseObject

@property (nonatomic, strong) JoinCompanyResultResponse<Optional>* Result;

@end
