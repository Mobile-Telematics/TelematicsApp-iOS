//
//  CheckResultResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 24.08.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ResponseObject.h"

@interface CheckResultResponse: ResponseObject

@property (nonatomic, strong) NSNumber<Optional>* UserExists;
@property (nonatomic, strong) NSString<Optional>* FirstName;
@property (nonatomic, strong) NSString<Optional>* LastName;
@property (nonatomic, strong) NSString<Optional>* Nickname;
@property (nonatomic, strong) NSString<Optional>* ImageUrl;
@property (nonatomic, strong) NSString<Optional>* ConfirmationResult;

@end
