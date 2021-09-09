//
//  EcoIndividualResultResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 03.11.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ResponseObject.h"

@interface EcoIndividualResultResponse: ResponseObject

@property (nonatomic, strong) NSNumber<Optional>* EcoScoreFuel;
@property (nonatomic, strong) NSNumber<Optional>* EcoScoreTyres;
@property (nonatomic, strong) NSNumber<Optional>* EcoScoreBrakes;
@property (nonatomic, strong) NSNumber<Optional>* EcoScoreDepreciation;
@property (nonatomic, strong) NSNumber<Optional>* EcoScore;

@end
