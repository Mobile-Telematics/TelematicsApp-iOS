//
//  EcoResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 03.11.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "RootResponse.h"
#import "EcoResultResponse.h"

@interface EcoResponse: RootResponse

@property (nonatomic, strong) EcoResultResponse<Optional>* Result;

@end
