//
//  ClaimsService.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 14.06.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ClaimsService.h"
#import "AppDelegate.h"


@interface ClaimsService ()
@end

@implementation ClaimsService

+ (instancetype)sharedService {
    static ClaimsService *_sharedService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedService = [[ClaimsService alloc] init];
    });
    return _sharedService;
}

- (void)destroyClaimsService {
    
    self.AccidentTypeKey = nil;
    self.AccidentTypeLabel = nil;
    
    self.ClaimDateTime = nil;
    self.ClaimTime = nil;
    self.Lat = nil;
    self.Lng = nil;
    self.PlaceCreateLat = nil;
    self.PlaceCreateLng = nil;
    self.LocationStr = nil;
    self.DriverFirstName = nil;
    self.DriverLastName = nil;
    self.DriverLicenseNo = nil;
    self.DriverPhone = nil;
    self.DriverComments = nil;
    self.InvolvedFirstName = nil;
    self.InvolvedLastName = nil;
    self.InvolvedLicenseNo = nil;
    self.InvolvedVehicleLicenseplateno = nil;
    self.InvolvedComments = nil;
    self.VehicleMake = nil;
    self.VehicleModel = nil;
    self.VehicleLicenseplateno = nil;
    self.CarToken = nil;
    self.CarMake = nil;
    self.CarModel = nil;
    self.CarType = nil;
    self.CarYear = nil;
    self.CarVin = nil;
    self.CarPainting = nil;
    self.CarLicensePlate = nil;
    self.CarTowing = nil;
    self.CarDrivable = nil;
    self.CreatedAt = nil;
    self.UpdatedAt = nil;
    self.Screens = nil;
    
    self.Photo_Left_Wide = nil;
    self.Photo_Left_Front_Wing = nil;
    self.Photo_Left_Front_Door = nil;
    self.Photo_Left_Rear_Door = nil;
    self.Photo_Left_Rear_Wing = nil;

    self.Photo_Right_Wide = nil;
    self.Photo_Right_Front_Wing = nil;
    self.Photo_Right_Front_Door = nil;
    self.Photo_Right_Rear_Door = nil;
    self.Photo_Right_Rear_Wing = nil;

    self.Photo_Front_Left_Diagonal = nil;
    self.Photo_Front_Right_Diagonal = nil;
    self.Photo_Rear_Left_Diagonal = nil;
    self.Photo_Rear_Right_Diagonal = nil;

    self.Photo_Front_Wide = nil;
    self.Photo_Rear_Wide = nil;
    self.Photo_Windshield_Wide = nil;
    self.Photo_Dashboard_Wide = nil;
    
}

- (void)destroyPhotosForClaimsService {
    
    self.Photo_Left_Wide = nil;
    self.Photo_Left_Front_Wing = nil;
    self.Photo_Left_Front_Door = nil;
    self.Photo_Left_Rear_Door = nil;
    self.Photo_Left_Rear_Wing = nil;

    self.Photo_Right_Wide = nil;
    self.Photo_Right_Front_Wing = nil;
    self.Photo_Right_Front_Door = nil;
    self.Photo_Right_Rear_Door = nil;
    self.Photo_Right_Rear_Wing = nil;

    self.Photo_Front_Left_Diagonal = nil;
    self.Photo_Front_Right_Diagonal = nil;
    self.Photo_Rear_Left_Diagonal = nil;
    self.Photo_Rear_Right_Diagonal = nil;

    self.Photo_Front_Wide = nil;
    self.Photo_Rear_Wide = nil;
    self.Photo_Windshield_Wide = nil;
    self.Photo_Dashboard_Wide = nil;
    
}

@end
