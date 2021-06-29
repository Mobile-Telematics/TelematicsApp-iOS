//
//  ClaimsService.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 14.06.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import Foundation;

@interface ClaimsService: NSObject

@property (nonatomic, strong) NSArray<Optional>* AccidentTypes;
@property (nonatomic, strong) NSString<Optional>* AccidentTypeKey;
@property (nonatomic, strong) NSString<Optional>* AccidentTypeLabel;

@property (nonatomic, strong) NSString* ClaimDateTime;
@property (nonatomic, strong) NSString* ClaimTime;
@property (nonatomic, strong) NSString* Lat;
@property (nonatomic, strong) NSString* Lng;
@property (nonatomic, strong) NSString* PlaceCreateLat;
@property (nonatomic, strong) NSString* PlaceCreateLng;
@property (nonatomic, strong) NSString* LocationStr;
@property (nonatomic, strong) NSString* DriverFirstName;
@property (nonatomic, strong) NSString* DriverLastName;
@property (nonatomic, strong) NSString* DriverLicenseNo;
@property (nonatomic, strong) NSString* DriverPhone;
@property (nonatomic, strong) NSString* DriverComments;
@property (nonatomic, strong) NSString* InvolvedFirstName;
@property (nonatomic, strong) NSString* InvolvedLastName;
@property (nonatomic, strong) NSString* InvolvedLicenseNo;
@property (nonatomic, strong) NSString* InvolvedVehicleLicenseplateno;
@property (nonatomic, strong) NSString* InvolvedComments;
@property (nonatomic, strong) NSString* VehicleMake;
@property (nonatomic, strong) NSString* VehicleModel;
@property (nonatomic, strong) NSString* VehicleLicenseplateno;
@property (nonatomic, strong) NSString* CarToken;
@property (nonatomic, strong) NSString* CarMake;
@property (nonatomic, strong) NSString* CarModel;
@property (nonatomic, strong) NSString* CarType;
@property (nonatomic, strong) NSString* CarYear;
@property (nonatomic, strong) NSString* CarVin;
@property (nonatomic, strong) NSString* CarPainting;
@property (nonatomic, strong) NSString* CarLicensePlate;
@property (nonatomic, strong) NSString* CarTowing;
@property (nonatomic, strong) NSString* CarDrivable;
@property (nonatomic, strong) NSString* CreatedAt;
@property (nonatomic, strong) NSString* UpdatedAt;
@property (nonatomic, strong) NSArray* Screens;

@property (nonatomic, strong) NSString* Photo_Left_Wide;
@property (nonatomic, strong) NSString* Photo_Left_Front_Wing;
@property (nonatomic, strong) NSString* Photo_Left_Front_Door;
@property (nonatomic, strong) NSString* Photo_Left_Rear_Door;
@property (nonatomic, strong) NSString* Photo_Left_Rear_Wing;

@property (nonatomic, strong) NSString* Photo_Rear_Left_Diagonal;
@property (nonatomic, strong) NSString* Photo_Rear_Wide;
@property (nonatomic, strong) NSString* Photo_Rear_Right_Diagonal;

@property (nonatomic, strong) NSString* Photo_Right_Wide;
@property (nonatomic, strong) NSString* Photo_Right_Front_Wing;
@property (nonatomic, strong) NSString* Photo_Right_Front_Door;
@property (nonatomic, strong) NSString* Photo_Right_Rear_Door;
@property (nonatomic, strong) NSString* Photo_Right_Rear_Wing;

@property (nonatomic, strong) NSString* Photo_Front_Right_Diagonal;
@property (nonatomic, strong) NSString* Photo_Front_Wide;
@property (nonatomic, strong) NSString* Photo_Front_Left_Diagonal;

@property (nonatomic, strong) NSString* Photo_Windshield_Wide;
@property (nonatomic, strong) NSString* Photo_Dashboard_Wide;

- (void)destroyClaimsService;
- (void)destroyPhotosForClaimsService;

+ (instancetype)sharedService;

@end
