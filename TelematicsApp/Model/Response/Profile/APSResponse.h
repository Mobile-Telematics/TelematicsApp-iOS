//
//  APSResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 16.01.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ResponseObject.h"

@interface APSResponse: ResponseObject

@property (nonatomic, copy) NSString<Optional>* alert;
@property (nonatomic, copy) NSString<Optional>* sound;

@end
