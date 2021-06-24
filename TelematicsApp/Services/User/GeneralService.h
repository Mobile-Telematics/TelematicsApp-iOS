//
//  GeneralService.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 20.01.18.
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

@property (nonatomic, copy, readwrite) NSString *device_token_number;
@property (nonatomic, copy, readwrite) NSString *jwt_token_number;
@property (nonatomic, copy, readwrite) NSString *refresh_token_number;
@property (nonatomic, copy, readwrite) NSString *firebase_user_id;

@property (nonatomic, copy, readwrite) NSString *stored_userEmail;
@property (nonatomic, copy, readwrite) NSString *stored_userPhone;
@property (nonatomic, copy, readwrite) NSString *stored_firstName;
@property (nonatomic, copy, readwrite) NSString *stored_lastName;
@property (nonatomic, copy, readwrite) NSString *stored_birthday;
@property (nonatomic, copy, readwrite) NSString *stored_address;
@property (nonatomic, copy, readwrite) NSString *stored_clientId;
@property (nonatomic, copy, readwrite) NSString *stored_gender;
@property (nonatomic, copy, readwrite) NSString *stored_maritalStatus;
@property (nonatomic, copy, readwrite) NSString *stored_childrenCount;
@property (nonatomic, copy, readwrite) NSString *stored_profilePictureLink;

@property (nonatomic, strong) NSString* claimsToken;

- (void)enterUserInAppWith:(NSString*)deviceToken jwToken:(NSString*)jwToken refreshToken:(NSString*)refreshToken;
- (void)refreshJWToken:(RegResponse*)login;

- (void)loadProfile;
- (void)loadUserVehicles;

- (void)logout;

+ (void)alert:(NSString *)getMessage title:(NSString *)getTitle;

+ (instancetype)sharedService;

@end
