//
//  ClaimsTokenRequestData.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 24.04.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "RequestData.h"

@interface ClaimsTokenRequestData: RequestData

@property (nonatomic, copy) NSString<Optional>* device_token;

@end
