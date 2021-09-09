//
//  LeaderboardResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 06.02.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "RootResponse.h"
#import "LeaderboardResultResponse.h"

@interface LeaderboardResponse: RootResponse

@property (nonatomic, strong) LeaderboardResultResponse<Optional>* Result;

@end
