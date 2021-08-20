//
//  EcoResultResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 03.11.20.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ResponseObject.h"

@interface EcoResultResponse: ResponseObject

@property (nonatomic, strong) NSNumber<Optional>* AverageSpeedKmh;
@property (nonatomic, strong) NSNumber<Optional>* AverageSpeedMileh;
@property (nonatomic, strong) NSNumber<Optional>* MaxSpeedKmh;
@property (nonatomic, strong) NSNumber<Optional>* MaxSpeedMileh;
@property (nonatomic, strong) NSNumber<Optional>* MileageKm;
@property (nonatomic, strong) NSNumber<Optional>* MileageMile;
@property (nonatomic, strong) NSNumber<Optional>* TripsCount;

//ECO PERCENTS
@property (nonatomic, strong) NSNumber<Optional>* EcoScoreFuel;
@property (nonatomic, strong) NSNumber<Optional>* EcoScoreTyres;
@property (nonatomic, strong) NSNumber<Optional>* EcoScoreBrakes;
@property (nonatomic, strong) NSNumber<Optional>* EcoScoreDepreciation;
@property (nonatomic, strong) NSNumber<Optional>* EcoScore;

@end
