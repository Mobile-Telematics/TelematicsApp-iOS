//
//  RootResponse.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 20.01.20.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "RootResponse.h"

@implementation RootResponse

- (ResponseObject<Optional> *)Result {
    return nil;
}

- (BOOL)isSuccesful {
    return self.Result != nil;
}

@end
