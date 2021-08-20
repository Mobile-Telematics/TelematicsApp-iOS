//
//  DrivingDetailsObject.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 14.08.20.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ResponseObject.h"

@protocol DrivingDetailsObject;

@interface DrivingDetailsObject: NSDictionary

@property (nonatomic, strong) NSNumber<Optional>* OverallScore;
@property (nonatomic, strong) NSNumber<Optional>* AccelerationScore;
@property (nonatomic, strong) NSNumber<Optional>* BrakingScore;
@property (nonatomic, strong) NSNumber<Optional>* SpeedingScore;
@property (nonatomic, strong) NSNumber<Optional>* DistractedScore;
@property (nonatomic, strong) NSNumber<Optional>* CorneringScore;
@property (nonatomic, strong) NSString<Optional>* CalcDate;

@end
