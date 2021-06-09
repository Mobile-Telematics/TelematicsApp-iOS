//
//  AccessTokenObject.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 15.01.20.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ResponseObject.h"

@protocol AccessTokenObject;

@interface AccessTokenObject: ResponseObject

@property (nonatomic, strong) NSString<Optional>* Token;
@property (nonatomic, strong) NSString<Optional>* ExpiresIn;

@end
