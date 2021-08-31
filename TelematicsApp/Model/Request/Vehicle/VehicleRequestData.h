//
//  VehicleRequestData.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 24.01.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "RequestData.h"

@interface VehicleRequestData: RequestData

@property (nonatomic, copy) NSString<Optional>* plateNumber;
@property (nonatomic, copy) NSString<Optional>* vin;
@property (nonatomic, copy) NSString<Optional>* manufacturerName;
@property (nonatomic, copy) NSString<Optional>* modelName;
@property (nonatomic, copy) NSString<Optional>* typeName;
@property (nonatomic, copy) NSString<Optional>* name;
@property (nonatomic, copy) NSString<Optional>* carYear;
@property (nonatomic, copy) NSString<Optional>* initialMilage;
@property (nonatomic, copy) NSNumber<Optional>* manufacturerId;
@property (nonatomic, copy) NSNumber<Optional>* modelId;
@property (nonatomic, copy) NSNumber<Optional>* typeId;
@property (nonatomic, copy) NSString<Optional>* specialMarks;
@property (nonatomic, copy) NSString<Optional>* nvic;
@property (nonatomic, copy) NSString<Optional>* vehicleId;
@property (nonatomic, copy) NSString<Optional>* colorType;
@property (nonatomic, copy) NSNumber<Optional>* entityStatus;
@property (nonatomic, copy) NSArray<Optional>* allowedDrivers;

@end
