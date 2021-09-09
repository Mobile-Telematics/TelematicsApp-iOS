//
//  LoginResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 24.01.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "RootResponse.h"
#import "LoginResultResponse.h"

@interface LoginResponse: ResponseObject

@property (nonatomic, strong) LoginResultResponse<Optional>* Result;

@end
