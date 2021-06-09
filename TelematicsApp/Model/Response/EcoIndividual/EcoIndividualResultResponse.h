//
//  EcoIndividualResultResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 03.11.20.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ResponseObject.h"

@interface EcoIndividualResultResponse: ResponseObject

@property (nonatomic, strong) NSNumber<Optional>* EcoScoringFuel;
@property (nonatomic, strong) NSNumber<Optional>* EcoScoringTyres;
@property (nonatomic, strong) NSNumber<Optional>* EcoScoringBrakes;
@property (nonatomic, strong) NSNumber<Optional>* EcoScoringDepreciation;
@property (nonatomic, strong) NSNumber<Optional>* EcoScoring;

@end
