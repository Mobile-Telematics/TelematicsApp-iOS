//
//  StreaksResultResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 05.08.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ResponseObject.h"

@interface StreaksResultResponse: ResponseObject

@property (nonatomic, strong) NSNumber<Optional>* StreakCorneringBest; //": 671,
@property (nonatomic, strong) NSNumber<Optional>* StreakCorneringBestDurationSec; //": 647462,
@property (nonatomic, strong) NSNumber<Optional>* StreakCorneringBestDistanceKm; //": 5110.190999999993,
@property (nonatomic, strong) NSString<Optional>* StreakCorneringBestFromDate; //": "2021-02-28T00:00:00",
@property (nonatomic, strong) NSString<Optional>* StreakCorneringBestToDate; //": "2021-04-04T00:00:00",
@property (nonatomic, strong) NSNumber<Optional>* StreakCorneringCurrentStreak; //": 1,
@property (nonatomic, strong) NSNumber<Optional>* StreakCorneringCurrentDurationSec; //": 2601,
@property (nonatomic, strong) NSNumber<Optional>* StreakCorneringCurrentDistanceKm; //": 18.225,
@property (nonatomic, strong) NSString<Optional>* StreakCorneringCurrentFromDate; //": "2021-07-23T00:00:00",
@property (nonatomic, strong) NSString<Optional>* StreakCorneringCurrentToDate; //": "2021-07-23T00:00:00",
@property (nonatomic, strong) NSNumber<Optional>* StreakCorneringIsActive; //": false,

@property (nonatomic, strong) NSNumber<Optional>* StreakBrakingBest; //": 11,
@property (nonatomic, strong) NSNumber<Optional>* StreakBrakingBestDurationSec; //": 14490,
@property (nonatomic, strong) NSNumber<Optional>* StreakBrakingBestDistanceKm; //": 53.814,
@property (nonatomic, strong) NSString<Optional>* StreakBrakingBestFromDate; //": "2021-12-06T00:00:00",
@property (nonatomic, strong) NSString<Optional>* StreakBrakingBestToDate; //": "2021-12-06T00:00:00",
@property (nonatomic, strong) NSNumber<Optional>* StreakBrakingCurrentStreak; //": 1,
@property (nonatomic, strong) NSNumber<Optional>* StreakBrakingCurrentDurationSec; //": 915,
@property (nonatomic, strong) NSNumber<Optional>* StreakBrakingCurrentDistanceKm; //": 10.818,
@property (nonatomic, strong) NSString<Optional>* StreakBrakingCurrentFromDate; //": "2021-04-24T00:00:00",
@property (nonatomic, strong) NSString<Optional>* StreakBrakingCurrentToDate; //": "2021-04-24T00:00:00",
@property (nonatomic, strong) NSNumber<Optional>* StreakBrakingIsActive; //": false,

@property (nonatomic, strong) NSNumber<Optional>* StreakAccelerationBest; //": 20,
@property (nonatomic, strong) NSNumber<Optional>* StreakAccelerationBestDurationSec; //": 9332,
@property (nonatomic, strong) NSNumber<Optional>* StreakAccelerationBestDistanceKm; //": 55.681,
@property (nonatomic, strong) NSString<Optional>* StreakAccelerationBestFromDate; //": "2020-02-01T00:00:00",
@property (nonatomic, strong) NSString<Optional>* StreakAccelerationBestToDate; //": "2020-02-13T00:00:00",
@property (nonatomic, strong) NSNumber<Optional>* StreakAccelerationCurrentStreak; //": 4,
@property (nonatomic, strong) NSNumber<Optional>* StreakAccelerationCurrentDurationSec; //": 2150,
@property (nonatomic, strong) NSNumber<Optional>* StreakAccelerationCurrentDistanceKm; //": 23.079000000000004,
@property (nonatomic, strong) NSString<Optional>* StreakAccelerationCurrentFromDate; //": "2021-04-22T00:00:00",
@property (nonatomic, strong) NSString<Optional>* StreakAccelerationCurrentToDate; //": "2021-04-24T00:00:00",
@property (nonatomic, strong) NSNumber<Optional>* StreakAccelerationIsActive; //": true,

@property (nonatomic, strong) NSNumber<Optional>* StreakOverSpeedBest; //": 12,
@property (nonatomic, strong) NSNumber<Optional>* StreakOverSpeedBestDurationSec; //": 4637,
@property (nonatomic, strong) NSNumber<Optional>* StreakOverSpeedBestDistanceKm; //": 39.06300000000001,
@property (nonatomic, strong) NSString<Optional>* StreakOverSpeedBestFromDate; //": "2021-12-01T00:00:00",
@property (nonatomic, strong) NSString<Optional>* StreakOverSpeedBestToDate; //": "2021-12-01T00:00:00",
@property (nonatomic, strong) NSNumber<Optional>* StreakOverSpeedCurrentStreak; //": 1,
@property (nonatomic, strong) NSNumber<Optional>* StreakOverSpeedCurrentDurationSec; //": 369,
@property (nonatomic, strong) NSNumber<Optional>* StreakOverSpeedCurrentDistanceKm; //": 2.571,
@property (nonatomic, strong) NSString<Optional>* StreakOverSpeedCurrentFromDate; //": "2021-04-24T00:00:00",
@property (nonatomic, strong) NSString<Optional>* StreakOverSpeedCurrentToDate; //": "2021-04-24T00:00:00",
@property (nonatomic, strong) NSNumber<Optional>* StreakOverSpeedIsActive; //": false,

@property (nonatomic, strong) NSNumber<Optional>* StreakPhoneUsageBest; //": 38,
@property (nonatomic, strong) NSNumber<Optional>* StreakPhoneUsageBestDurationSec; //": 31720,
@property (nonatomic, strong) NSNumber<Optional>* StreakPhoneUsageBestDistanceKm; //": 199.79200000000003,
@property (nonatomic, strong) NSString<Optional>* StreakPhoneUsageBestFromDate; //": "2020-02-17T00:00:00",
@property (nonatomic, strong) NSString<Optional>* StreakPhoneUsageBestToDate; //": "2020-03-07T00:00:00",
@property (nonatomic, strong) NSNumber<Optional>* StreakPhoneUsageCurrentStreak; //": 3,
@property (nonatomic, strong) NSNumber<Optional>* StreakPhoneUsageCurrentDurationSec; //": 1309,
@property (nonatomic, strong) NSNumber<Optional>* StreakPhoneUsageCurrentDistanceKm; //": 11.196000000000002,
@property (nonatomic, strong) NSString<Optional>* StreakPhoneUsageCurrentFromDate; //": "2021-04-22T00:00:00",
@property (nonatomic, strong) NSString<Optional>* StreakPhoneUsageCurrentToDate; //": "2021-04-22T00:00:00",
@property (nonatomic, strong) NSNumber<Optional>* StreakPhoneUsageIsActive; //": true,


@end
