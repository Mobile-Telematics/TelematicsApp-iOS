//
//  LoginResultResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 24.01.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ResponseObject.h"
#import "AccessTokenObject.h"

@interface LoginResultResponse: ResponseObject

@property (nonatomic, strong) NSString<Optional>* DeviceToken;
@property (nonatomic, strong) NSString<Optional>* RefreshToken;
@property (nonatomic, strong) AccessTokenObject<Optional>* AccessToken;

@end
