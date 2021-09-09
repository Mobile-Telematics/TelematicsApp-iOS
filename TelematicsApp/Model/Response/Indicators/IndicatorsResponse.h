//
//  IndicatorsResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 20.08.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "RootResponse.h"
#import "IndicatorsResultResponse.h"

@interface IndicatorsResponse: RootResponse

@property (nonatomic, strong) IndicatorsResultResponse<Optional>* Result;

@end
