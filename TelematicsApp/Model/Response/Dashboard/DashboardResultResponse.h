//
//  DashboardResultResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 28.01.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ResponseObject.h"

@interface DashboardResultResponse: ResponseObject

@property (nonatomic, strong) NSNumber<Optional>* EcoScoringFuel;
@property (nonatomic, strong) NSNumber<Optional>* EcoScoringTyres;
@property (nonatomic, strong) NSNumber<Optional>* EcoScoringBrakes;
@property (nonatomic, strong) NSNumber<Optional>* EcoScoringDepreciation;
@property (nonatomic, strong) NSNumber<Optional>* EcoScoring;
@property (nonatomic, strong) NSNumber<Optional>* PreviousEcoScoring;

@property (nonatomic, strong) NSNumber<Optional>* TrackCount;
@property (nonatomic, strong) NSNumber<Optional>* SummaryDuration;
@property (nonatomic, strong) NSNumber<Optional>* SummaryDistance;

@property (nonatomic, strong) NSNumber<Optional>* WeeklyMaxSpeed;
@property (nonatomic, strong) NSNumber<Optional>* WeeklyAverageSpeed;
@property (nonatomic, strong) NSNumber<Optional>* WeeklyTotalKm;
@property (nonatomic, strong) NSNumber<Optional>* MonthlyMaxSpeed;
@property (nonatomic, strong) NSNumber<Optional>* MonthlyAverageSpeed;
@property (nonatomic, strong) NSNumber<Optional>* MonthlyTotalKm;
@property (nonatomic, strong) NSNumber<Optional>* YearlyMaxSpeed;
@property (nonatomic, strong) NSNumber<Optional>* YearlyAverageSpeed;
@property (nonatomic, strong) NSNumber<Optional>* YearlyTotalKm;

@property (nonatomic, strong) NSNumber<Optional>* TripsCount;
@property (nonatomic, strong) NSNumber<Optional>* MileageKm;
@property (nonatomic, strong) NSNumber<Optional>* DrivingTime;

@property (nonatomic, strong) NSNumber<Optional>* SafetyScore;
@property (nonatomic, strong) NSNumber<Optional>* AccelerationScore;
@property (nonatomic, strong) NSNumber<Optional>* BrakingScore;
@property (nonatomic, strong) NSNumber<Optional>* SpeedingScore;
@property (nonatomic, strong) NSNumber<Optional>* PhoneUsageScore;
@property (nonatomic, strong) NSNumber<Optional>* CorneringScore;

@end
