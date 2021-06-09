//
//  EcoIndividualResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 03.11.20.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "RootResponse.h"
#import "EcoIndividualResultResponse.h"

@interface EcoIndividualResponse: RootResponse

@property (nonatomic, strong) EcoIndividualResultResponse<Optional>* Result;

@end
