//
//  ErrorObject.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 13.02.20.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ResponseObject.h"

@protocol ErrorObject;

@interface ErrorObject: NSMutableArray

@property (nonatomic, strong) NSString<Optional>* Key;
@property (nonatomic, strong) NSString<Optional>* Message;

@end
