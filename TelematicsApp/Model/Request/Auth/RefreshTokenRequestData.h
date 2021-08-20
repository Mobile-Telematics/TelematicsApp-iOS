//
//  RefreshTokenRequestData.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 26.01.20.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "RequestData.h"

@interface RefreshTokenRequestData: RequestData

//JWTOKEN & REFRESH TOKEN AUTH MODEL
@property (nonatomic, copy) NSString<Optional>* accessToken;
@property (nonatomic, copy) NSString<Optional>* refreshToken;

@end
