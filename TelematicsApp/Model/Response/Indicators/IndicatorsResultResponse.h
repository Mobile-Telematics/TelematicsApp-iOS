//
//  IndicatorsResultResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 20.08.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ResponseObject.h"

@interface IndicatorsResultResponse: ResponseObject

@property (nonatomic, strong) NSNumber<Optional>* MileageKm;
@property (nonatomic, strong) NSNumber<Optional>* MileageMile;
@property (nonatomic, strong) NSNumber<Optional>* TripsCount;
@property (nonatomic, strong) NSNumber<Optional>* DriverTripsCount;
@property (nonatomic, strong) NSNumber<Optional>* OtherTripsCount;
@property (nonatomic, strong) NSNumber<Optional>* MaxSpeedKmh;
@property (nonatomic, strong) NSNumber<Optional>* MaxSpeedMileh;
@property (nonatomic, strong) NSNumber<Optional>* AverageSpeedKmh;
@property (nonatomic, strong) NSNumber<Optional>* AverageSpeedMileh;
@property (nonatomic, strong) NSNumber<Optional>* TotalSpeedingKm;
@property (nonatomic, strong) NSNumber<Optional>* TotalSpeedingMile;
@property (nonatomic, strong) NSNumber<Optional>* AccelerationCount;
@property (nonatomic, strong) NSNumber<Optional>* BrakingCount;
@property (nonatomic, strong) NSNumber<Optional>* CorneringCount;
@property (nonatomic, strong) NSNumber<Optional>* PhoneUsageDurationMin;

@property (nonatomic, strong) NSNumber<Optional>* PhoneUsageMileageKm;
@property (nonatomic, strong) NSNumber<Optional>* PhoneUsageMileageMile;
@property (nonatomic, strong) NSNumber<Optional>* PhoneUsageSpeedingDurationMin;
@property (nonatomic, strong) NSNumber<Optional>* PhoneUsageSpeedingMileageKm;
@property (nonatomic, strong) NSNumber<Optional>* PhoneUsageSpeedingMileageMile;

@property (nonatomic, strong) NSNumber<Optional>* DrivingTime;
@property (nonatomic, strong) NSNumber<Optional>* NightDrivingTime;
@property (nonatomic, strong) NSNumber<Optional>* DayDrivingTime;
@property (nonatomic, strong) NSNumber<Optional>* RushHoursDrivingTime;

@end
