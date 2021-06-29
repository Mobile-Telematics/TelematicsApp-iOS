//
//  ClaimsUserObject.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 14.03.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ResponseObject.h"

@protocol ClaimsUserObject;

@interface ClaimsUserObject: ResponseObject

@property (nonatomic, strong) NSNumber<Optional>* Id;
@property (nonatomic, strong) NSArray<Optional>* AccidentTypes;
@property (nonatomic, strong) NSNumber<Optional>* AccidentTypeKey;
@property (nonatomic, strong) NSNumber<Optional>* AccidentTypeLabel;
@property (nonatomic, strong) NSString<Optional>* CarDrivable;
@property (nonatomic, strong) NSString<Optional>* CarToken;
@property (nonatomic, strong) NSString<Optional>* CarTowing;
@property (nonatomic, strong) NSString<Optional>* ClaimDateTime;
@property (nonatomic, strong) NSString<Optional>* CreatedAt;
@property (nonatomic, strong) NSString<Optional>* DriverFirstName;
@property (nonatomic, strong) NSString<Optional>* DriverLastName;
@property (nonatomic, strong) NSString<Optional>* DriverName;
@property (nonatomic, strong) NSString<Optional>* DriverPhone;
@property (nonatomic, strong) NSString<Optional>* InvolvedFirstName;
@property (nonatomic, strong) NSString<Optional>* InvolvedLastName;
@property (nonatomic, strong) NSString<Optional>* InvolvedLicenseNo;
@property (nonatomic, strong) NSString<Optional>* InvolvedVehicleLicenseplateno;
@property (nonatomic, strong) NSString<Optional>* Lat;
@property (nonatomic, strong) NSString<Optional>* Lng;
@property (nonatomic, strong) NSString<Optional>* Paint;
@property (nonatomic, strong) NSArray<Optional>* Quotes;
@property (nonatomic, strong) NSArray<Optional>* Screens;
@property (nonatomic, strong) NSString<Optional>* UpdatedAt;
@property (nonatomic, strong) NSString<Optional>* VehicleLicenseplateno;
@property (nonatomic, strong) NSString<Optional>* VehicleMake;
@property (nonatomic, strong) NSString<Optional>* VehicleModel;


@end
