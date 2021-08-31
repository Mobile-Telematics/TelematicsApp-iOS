//
//  VehicleObject.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 24.01.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ResponseObject.h"

@protocol VehicleObject;

@interface VehicleObject: ResponseObject

@property (nonatomic, strong) NSString<Optional>* Token;
@property (nonatomic, strong) NSString<Optional>* Name;
@property (nonatomic, strong) NSString<Optional>* PlateNumber;
@property (nonatomic, strong) NSString<Optional>* Vin;
@property (nonatomic, strong) NSString<Optional>* Manufacturer;
@property (nonatomic, strong) NSString<Optional>* Model;
@property (nonatomic, strong) NSString<Optional>* Type;
@property (nonatomic, strong) NSString<Optional>* BodyType;
@property (nonatomic, strong) NSString<Optional>* CarYear;
@property (nonatomic, strong) NSString<Optional>* SpecialMarks;
@property (nonatomic, strong) NSString<Optional>* Nvic;
@property (nonatomic, strong) NSString<Optional>* InitialMilage;
@property (nonatomic, strong) NSString<Optional>* ColorType;
@property (nonatomic, strong) NSString<Optional>* VehicleId;
@property (nonatomic, strong) NSString<Optional>* LastKnownMileage;
@property (nonatomic, strong) NSString<Optional>* LastKnownMileageDate;

@end
