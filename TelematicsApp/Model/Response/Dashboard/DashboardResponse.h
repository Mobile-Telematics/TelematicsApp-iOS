//
//  DashboardResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 28.01.18.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "RootResponse.h"
#import "DashboardResultResponse.h"

@interface DashboardResponse: RootResponse

@property (nonatomic, strong) DashboardResultResponse<Optional>* Result;

@end
