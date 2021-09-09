//
//  ProfileResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 16.01.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "RootResponse.h"
#import "ProfileResultResponse.h"

@class ProfileResultResponse;

@interface ProfileResponse: RootResponse

@property (nonatomic, strong) ProfileResultResponse<Optional>* Result;

@end
