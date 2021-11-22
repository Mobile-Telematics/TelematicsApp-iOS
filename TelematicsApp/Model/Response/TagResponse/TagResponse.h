//
//  TagResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 22.11.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "RootResponse.h"
#import "TagResultResponse.h"

@interface TagResponse: RootResponse

@property (nonatomic, strong) TagResultResponse<Optional>* Result;

@end
