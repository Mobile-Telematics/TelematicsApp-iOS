//
//  ResponseObject.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 20.01.20.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ResponseObject.h"
#import "JSONModel.h"

@interface ResponseObject: JSONModel

@property (nonatomic, copy) NSString<Optional>* Title;
@property (nonatomic, copy) NSString<Optional>* Status;
@property (nonatomic, copy) NSArray<Optional>* Errors;

- (BOOL)isSuccesful;

- (NSArray*)validate;

@end
