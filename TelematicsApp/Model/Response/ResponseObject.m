//
//  ResponseObject.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 20.01.20.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ResponseObject.h"
#import "JSONModelClassProperty.h"

@implementation ResponseObject

- (BOOL)isSuccesful {
    return YES;
}

- (NSArray*)validate {
    return nil;
}

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"id":@"objectId",
                                                                  @"description":@"objectDescription",
                                                                  }];
}

@end
