//
//  GeneralService.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 20.01.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import Foundation;
@import UIKit;
@import Firebase;
#import "LoginResponse.h"
#import "RegResponse.h"

@interface GeneralService: NSObject

@property FIRUser *user_FIR;
@property(strong, nonatomic) FIRDatabaseReference *realtimeDatabase;

@property (nonatomic, assign, readonly) BOOL isLoggedOn;

@property (nonatomic, copy, readwrite) NSString *device_token_number; //DEVICETOKEN
@property (nonatomic, copy, readwrite) NSString *jwt_token_number; //JWTOKEN
@property (nonatomic, copy, readwrite) NSString *refresh_token_number; //REFRESH TOKEN FOR JWTOKEN
@property (nonatomic, copy, readwrite) NSString *firebase_user_id; //FIREBASE USERID REQUIRED

@property (nonatomic, copy, readwrite) NSString *stored_userEmail;
@property (nonatomic, copy, readwrite) NSString *stored_userPhone;
@property (nonatomic, copy, readwrite) NSString *stored_firstName;
@property (nonatomic, copy, readwrite) NSString *stored_lastName;
@property (nonatomic, copy, readwrite) NSString *stored_birthday;
@property (nonatomic, copy, readwrite) NSString *stored_address;
@property (nonatomic, copy, readwrite) NSString *stored_clientId;
@property (nonatomic, copy, readwrite) NSString *stored_gender;
@property (nonatomic, copy, readwrite) NSString *stored_maritalStatus;
@property (nonatomic, copy, readwrite) NSNumber *stored_childrenCount;
@property (nonatomic, copy, readwrite) NSString *stored_profilePictureLink;

@property (nonatomic, strong) NSString* claimsToken; //TOKEN FOR CLAIMS


//ENTER USER IN APP
- (void)enterUserInAppWith:(NSString*)deviceToken jwToken:(NSString*)jwToken refreshToken:(NSString*)refreshToken;

//REFRESH JWToken EVERY TIME 401 UNAUTHORIZED!
- (void)refreshJWToken:(RegResponse*)login;

//LOAD USER PROFILE
- (void)loadProfile;

//LOAD ALL USER VEHICLES
- (void)loadUserVehicles;

//LOGOUT
- (void)logout;

//HELPFUL
+ (void)alert:(NSString *)getMessage title:(NSString *)getTitle;

//OUR SHARED SERVICE
+ (instancetype)sharedService;

@end
