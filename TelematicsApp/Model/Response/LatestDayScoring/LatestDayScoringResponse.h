//
//  LatestDayScoringResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 06.10.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "RootResponse.h"
#import "LatestDayScoringResultResponse.h"

@interface LatestDayScoringResponse : RootResponse

@property (nonatomic, strong) LatestDayScoringResultResponse<Optional>* Result;

@end
