//
//  LatestDayScoringResultResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 06.10.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ResponseObject.h"

@interface LatestDayScoringResultResponse : ResponseObject

@property (nonatomic, strong) NSString<Optional>* LatestTrackDate;
@property (nonatomic, strong) NSString<Optional>* LatestScoringDate;
@property (nonatomic, strong) NSString<Optional>* CompanyId;
@property (nonatomic, strong) NSString<Optional>* AppId;
@property (nonatomic, strong) NSString<Optional>* DeviceToken;
@property (nonatomic, strong) NSString<Optional>* InstanceId;

@end
