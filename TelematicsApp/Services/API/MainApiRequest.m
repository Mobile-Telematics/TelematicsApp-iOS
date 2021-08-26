//
//  MainApiRequest.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 20.01.20.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "MainApiRequest.h"
#import "CheckUserRequestData.h"
#import "RefreshTokenRequestData.h"
#import "LatestDayScoringResponse.h"
#import "CheckResponse.h"
#import "RegResponse.h"
#import "LoginResponse.h"
#import "DashboardResponse.h"
#import "CoinsResponse.h"
#import "CoinsDetailsResponse.h"
#import "StreaksResponse.h"
#import "EcoResponse.h"
#import "EcoIndividualResponse.h"
#import "DrivingDetailsResponse.h"
#import "IndicatorsResponse.h"
#import "LeaderboardResponse.h"
#import "GeneralService.h"
#import "Helpers.h"
#import "AFNetworking.h"
#import "ProfileResponse.h"
#import "VehicleRequestData.h"
#import "VehicleResponse.h"
#import "VehiclesDictionaryResponse.h"
#import "ClaimsTokenRequestData.h"
#import "ClaimsTokenResponse.h"
#import "ClaimsUserResponse.h"
#import "ClaimsAccidentResponse.h"
@import MobileCoreServices;


@implementation MainApiRequest

#pragma mark Override

+ (instancetype)requestWithCompletion:(APIRequestCompletionBlock)completion {
    MainApiRequest* req = [[self alloc] init];
    [req setCompletionBlock:^(id response, NSError *error) {
        if (completion) {
            completion(response, error);
        }
    }];
    return req;
}

+ (NSString *)userServiceRootURL {
    return [Configurator sharedInstance].userServiceRootURL;
}

+ (NSString *)indicatorsServiceURL {
    return [Configurator sharedInstance].indicatorsServiceURL;
}

+ (NSString *)driveCoinsServiceURL {
    return [Configurator sharedInstance].driveCoinsServiceURL;
}

+ (NSString *)leaderboardServiceURL {
    return [Configurator sharedInstance].leaderboardServiceURL;
}

+ (NSString *)carServiceURL {
    return [Configurator sharedInstance].carServiceURL;
}

+ (NSString *)claimsServiceURL {
    return [Configurator sharedInstance].claimsServiceURL;
}

//YOUR OWN INSTANCE KEYS
+ (NSString *)instanceId {
    return [Configurator sharedInstance].instanceId;
}

+ (NSString *)instanceKey {
    return [Configurator sharedInstance].instanceKey;
}


//BASIC HEADER
+ (NSDictionary *)customRequestHeaders {
    NSMutableDictionary* headers = [[super customRequestHeaders] mutableCopy];
    if ([GeneralService sharedService].jwt_token_number) {
        NSString *authToken = [NSString stringWithFormat:@"Bearer %@", [GeneralService sharedService].jwt_token_number]; //'Bearer ' IS REQUIRED
        headers[@"Authorization"] = authToken;
    }
    
    headers[@"InstanceId"] = [self instanceId];
    headers[@"InstanceKey"] = [self instanceKey];
    headers[@"appversion"] = APP_VERSION;
    headers[@"DeviceToken"] = [GeneralService sharedService].device_token_number;
    
    NSLog(@"%@", headers);
    return headers;
}


#pragma mark RefreshToken Main Operation for JWToken if 401 UNAUTHORIZED

- (void)refreshJWToken:(RefreshTokenRequestData*)refreshData {
    NSDictionary* params = [refreshData paramsDictionary];
    [self performRequestWithPathBodyObject:@"Auth/RefreshToken" responseClass:[LoginResponse class] parameters:nil bodyObject:params method:POST];
}


#pragma mark Indicators Service Statistics & Scorings
    
- (void)getLatestDayStatisticsScoringForUser {
    [self performRequestIndicatorsService:@"Statistics/latestDates" responseClass:[LatestDayScoringResponse class] parameters:nil method:GET];
}

- (void)getStatisticsIndividualAllTime:(NSString *)startDate endDate:(NSString*)endDate {
    NSDictionary *params = @{@"StartDate": startDate, @"EndDate": endDate};
    [self performRequestIndicatorsService:@"Statistics" responseClass:[DashboardResponse class] parameters:params method:GET];
}

- (void)getScoringsIndividualCurrentDay:(NSString *)startDate endDate:(NSString*)endDate {
    NSDictionary *params = @{@"StartDate": startDate, @"EndDate": endDate};
    [self performRequestIndicatorsService:@"Scores/safety" responseClass:[DashboardResponse class] parameters:params method:GET];
}

- (void)getScoringsIndividual14daysDaily:(NSString *)startDate endDate:(NSString*)endDate {
    NSDictionary *params = @{@"StartDate": startDate, @"EndDate": endDate};
    [self performRequestIndicatorsService:@"Scores/safety/daily" responseClass:[DrivingDetailsResponse class] parameters:params method:GET];
}


#pragma mark Indicators Eco For Dashboard

- (void)getEcoScoresForTimePeriod:(NSString *)startDate endDate:(NSString*)endDate {
    NSDictionary *params = @{@"StartDate": startDate, @"EndDate": endDate};
    [self performRequestIndicatorsService:@"Scores/eco" responseClass:[EcoIndividualResponse class] parameters:params method:GET];
}


#pragma mark Indicators For Coins For Dashboard Preloader

- (void)getCoinsStatisticsIndividualForPeriod:(NSString *)startDate endDate:(NSString*)endDate {
    NSDictionary *params = @{@"StartDate": startDate, @"EndDate": endDate};
    [self performRequestIndicatorsService:@"Statistics" responseClass:[IndicatorsResponse class] parameters:params method:GET];
}


#pragma mark Indicators For Coins For Eco Percents

- (void)getIndicatorsIndividualForPeriod:(NSString *)startDate endDate:(NSString*)endDate {
    NSDictionary *params = @{@"StartDate": startDate, @"EndDate": endDate};
    [self performRequestIndicatorsService:@"Scores/eco" responseClass:[EcoIndividualResponse class] parameters:params method:GET];
}


#pragma mark Indicators Streaks

- (void)getIndicatorsStreaks {
    [self performRequestIndicatorsService:@"Streaks" responseClass:[StreaksResponse class] parameters:nil method:GET];
}


#pragma mark My Rewards - Coins

- (void)getCoinsDailyLimit {
    [self performRequestCoinsService:@"DriveCoins/dailylimit" responseClass:[CoinsResponse class] parameters:nil method:GET];
}

- (void)getCoinsTotal:(NSString *)startDate endDate:(NSString*)endDate {
    NSDictionary *params = @{@"StartDate": startDate, @"EndDate": endDate};
    [self performRequestCoinsService:@"DriveCoins/total" responseClass:[CoinsResponse class] parameters:params method:GET];
}

- (void)getCoinsDaily:(NSString *)startDate endDate:(NSString*)endDate {
    NSDictionary *params = @{@"StartDate": startDate, @"EndDate": endDate};
    [self performRequestCoinsService:@"DriveCoins/daily" responseClass:[CoinsDetailsResponse class] parameters:params method:GET];
}

- (void)getCoinsDetailed:(NSString *)startDate endDate:(NSString*)endDate {
    NSDictionary *params = @{@"StartDate": startDate, @"EndDate": endDate};
    [self performRequestCoinsService:@"DriveCoins/detailed" responseClass:[CoinsDetailsResponse class] parameters:params method:GET];
}


#pragma mark Leaderboard
//Acceleration = 1
//Deceleration = 2
//Distraction = 3
//Speeding = 4
//Turn = 5
//RateOverall = 6,
//Distance = 7
//Trips = 8
//Duration = 9

- (void)getLeaderboardForUser {
    [self performRequestLeaderboardService:@"Leaderboard/user" responseClass:[LeaderboardResponse class] parameters:nil method:GET];
}

- (void)getLeaderboardScore:(NSUInteger)scoringRate {
    NSString *finalLeadersUrl = [NSString stringWithFormat:@"Leaderboard?usersCount=10&roundUsersCount=3&ScoringRate=%lu", (unsigned long)scoringRate];
    [self performRequestLeaderboardService:finalLeadersUrl responseClass:[LeaderboardResponse class] parameters:nil method:GET];
}


#pragma mark CarService

- (void)getAllCarsManufacturers {
    [self performRequestCarService:@"Directories/Manufacturers" responseClass:[VehiclesDictionaryResponse class] parameters:nil method:GET];
}

- (void)getAllBrandModels:(NSString*)brandId {
    NSString *fullPath = [NSString stringWithFormat:@"Directories/Models?manufacturerId=%@", brandId];
    [self performRequestCarService:fullPath responseClass:[VehiclesDictionaryResponse class] parameters:nil method:GET];
}

- (void)getUserAllVehicles {
    [self performRequestCarService:@"Vehicles" responseClass:[VehicleResponse class] parameters:nil method:GET];
}

- (void)updateVehicle:(VehicleRequestData *)vehicleData {
    [self performRequestCarService:@"Vehicles" responseClass:[ResponseObject class] parameters:[vehicleData paramsDictionary] method:POST];
}

- (void)putVehicle:(VehicleRequestData *)vehicleData vehicle:(NSString *)vehicleToken {
    NSString *tokenPath = [NSString stringWithFormat:@"Vehicles/%@", vehicleToken];
    [self performRequestCarService:tokenPath responseClass:[ResponseObject class] parameters:[vehicleData paramsDictionary] method:PUT];
}

- (void)deleteVehicle:(VehicleRequestData *)vehicleData vehicle:(NSString *)vehicleToken {
    NSString *tokenPath = [NSString stringWithFormat:@"Vehicles/%@", vehicleToken];
    [self performRequestCarService:tokenPath responseClass:[ResponseObject class] parameters:[vehicleData paramsDictionary] method:DELETE];
}



#pragma mark DeleteTrack From Feed Screen

- (void)deleteTrackSendStatusForBackEnd:(NSString *)trackToken {
    NSString *URLStr = [NSString stringWithFormat:@"https://mobilesdk.raxeltelematic.com/mobilesdk/stage/track/%@/setdeleted/v1", trackToken];
    NSError *error;
    NSMutableURLRequest *request = [self.sessionManager.requestSerializer requestWithMethod:POST URLString:URLStr parameters:nil error:&error];
    NSDictionary* customHeaders = [[self class] customRequestHeaders];
    for (NSString* key in customHeaders.allKeys) {
        [request setValue:customHeaders[key] forHTTPHeaderField:key];
    }
    [self performRequest:request withResponseClass:[ResponseObject class]];
}


#pragma mark Events Browse on Trip Details screen

- (void)trackBrowseStart:(NSString *)trackToken {
    NSString *URLStr = [NSString stringWithFormat:@"https://mobilesdk.raxeltelematic.com/mobilesdk/stage/track/browsestart/v1/%@", trackToken];
    NSError *error;
    NSMutableURLRequest *request = [self.sessionManager.requestSerializer requestWithMethod:POST URLString:URLStr parameters:nil error:&error];
    NSDictionary* customHeaders = [[self class] customRequestHeaders];
    for (NSString* key in customHeaders.allKeys) {
        [request setValue:customHeaders[key] forHTTPHeaderField:key];
    }
    [self performRequest:request withResponseClass:[ResponseObject class]];
}

- (void)reportWrongEventNoEvent:(NSString *)trackToken lat:(NSString *)lat lon:(NSString *)lon eventType:(NSString *)eventType date:(NSString *)date {
    NSDictionary *params = @{@"PointDate": date,
                             @"Latitude": lat,
                             @"Longitude": lon,
                             @"EventType": eventType
                             };
    
    NSString *URLStr = [NSString stringWithFormat:@"https://mobilesdk.raxeltelematic.com/mobilesdk/stage/events/reportwrongevent/v1/%@", trackToken];
    NSError *error;
    NSMutableURLRequest *request = [self.sessionManager.requestSerializer requestWithMethod:POST URLString:URLStr parameters:params error:&error];
    NSDictionary* customHeaders = [[self class] customRequestHeaders];
    for (NSString* key in customHeaders.allKeys) {
        [request setValue:customHeaders[key] forHTTPHeaderField:key];
    }
    [self performRequest:request withResponseClass:[ResponseObject class]];
}

- (void)reportWrongEventNewEvent:(NSString *)trackToken lat:(NSString *)lat lon:(NSString *)lon eventType:(NSString *)eventType newEventType:(NSString *)newEventType date:(NSString *)date {
    NSDictionary *params = @{@"PointDate": date,
                             @"Latitude": lat,
                             @"Longitude": lon,
                             @"EventType": eventType,
                             @"ChangeTypeTo": newEventType
                             };
    
    NSString *URLStr = [NSString stringWithFormat:@"https://mobilesdk.raxeltelematic.com/mobilesdk/stage/events/reportwrongeventtype/v1/%@", trackToken];
    NSError *error;
    NSMutableURLRequest *request = [self.sessionManager.requestSerializer requestWithMethod:POST URLString:URLStr parameters:params error:&error];
    NSDictionary* customHeaders = [[self class] customRequestHeaders];
    for (NSString* key in customHeaders.allKeys) {
        [request setValue:customHeaders[key] forHTTPHeaderField:key];
    }
    [self performRequest:request withResponseClass:[ResponseObject class]];
}


#pragma mark Claims Service Implementation Crash Request

- (void)getTokenForClaims:(ClaimsTokenRequestData*)claimsData {
    NSDictionary* params = [claimsData paramsDictionary];
    [self performRequestClaimsService:@"profiles/login" responseClass:[ClaimsTokenResponse class] parameters:params method:POST];
}

- (void)getUserClaims {
    [self performRequestClaimsService:@"claims" responseClass:[ClaimsUserResponse class] parameters:nil method:GET];
}

- (void)getAccidentTypes {
    [self performRequestClaimsService:@"claims/accident_types" responseClass:[ClaimsAccidentResponse class] parameters:nil method:GET];
}

- (void)deleteUserClaim:(NSString*)claimId {
    NSString *ids = [NSString stringWithFormat:@"claims/%@", claimId];
    [self performRequestClaimsService:ids responseClass:[RootResponse class] parameters:nil method:DELETE];
}

- (void)createClaim:(CreateClaimRequestData*)createClaimData {
    
    NSDictionary* URLParams = @{
        @"claim[source]": @"mobile_app",
        @"claim[accident_type]": [ClaimsService sharedService].AccidentTypeKey ? [ClaimsService sharedService].AccidentTypeKey : @"",
        @"claim[paint]": [ClaimsService sharedService].CarPainting.lowercaseString ? [ClaimsService sharedService].CarPainting.lowercaseString : @"solid",
        @"claim[claim_date_time]": [ClaimsService sharedService].ClaimDateTime ? [ClaimsService sharedService].ClaimDateTime : @"",
        @"claim[lat]": [ClaimsService sharedService].Lat ? [ClaimsService sharedService].Lat : @"0.0",
        @"claim[lng]": [ClaimsService sharedService].Lng ? [ClaimsService sharedService].Lng : @"0.0",
        @"claim[created_lat]": [ClaimsService sharedService].PlaceCreateLat ? [ClaimsService sharedService].PlaceCreateLat : @"0.0",
        @"claim[created_lng]": [ClaimsService sharedService].PlaceCreateLng ? [ClaimsService sharedService].PlaceCreateLng : @"0.0",
        @"claim[locations]": [ClaimsService sharedService].LocationStr ? [ClaimsService sharedService].LocationStr : @"",
        @"claim[driver_first_name]": [ClaimsService sharedService].DriverFirstName ? [ClaimsService sharedService].DriverFirstName : @"",
        @"claim[driver_last_name]": [ClaimsService sharedService].DriverLastName ? [ClaimsService sharedService].DriverLastName : @"",
        @"claim[driver_phone]": [ClaimsService sharedService].DriverPhone ? [ClaimsService sharedService].DriverPhone : @"",
        @"claim[description]": [ClaimsService sharedService].DriverComments ? [ClaimsService sharedService].DriverComments : @"",
        @"claim[involved_first_name]": [ClaimsService sharedService].InvolvedFirstName ? [ClaimsService sharedService].InvolvedFirstName : @"",
        @"claim[involved_last_name]": [ClaimsService sharedService].InvolvedLastName ? [ClaimsService sharedService].InvolvedLastName : @"",
        @"claim[involved_license_no]": [ClaimsService sharedService].InvolvedLicenseNo ? [ClaimsService sharedService].InvolvedLicenseNo : @"",
        @"claim[involved_vehicle_licenseplateno]": [ClaimsService sharedService].InvolvedVehicleLicenseplateno ? [ClaimsService sharedService].InvolvedVehicleLicenseplateno : @"",
        @"claim[involved_comments]": [ClaimsService sharedService].InvolvedComments ? [ClaimsService sharedService].InvolvedComments : @"",
        @"claim[vehicle_make]": [ClaimsService sharedService].CarMake ? [ClaimsService sharedService].CarMake : @"",
        @"claim[vehicle_model]": [ClaimsService sharedService].CarModel ? [ClaimsService sharedService].CarModel : @"",
        @"claim[vehicle_licenseplateno]": [ClaimsService sharedService].CarLicensePlate ? [ClaimsService sharedService].CarLicensePlate : @"",
        @"claim[car_token]": [ClaimsService sharedService].CarToken ? [ClaimsService sharedService].CarToken : @"",
        @"claim[car_towing]": [ClaimsService sharedService].CarTowing ? [ClaimsService sharedService].CarTowing : @"",
        @"claim[car_drivable]": [ClaimsService sharedService].CarDrivable ? [ClaimsService sharedService].CarDrivable : @"",
    };
    
    NSString *boundary = [self generateBoundaryString];
    
    NSString *finalUrl = [NSString stringWithFormat:@"%@%@", [Configurator sharedInstance].claimsServiceURL, @"/claims"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:finalUrl]];
    
    [request setTimeoutInterval:120.0];
    [request setHTTPMethod:@"POST"];
    [request addValue:[GeneralService sharedService].claimsToken forHTTPHeaderField:@"Authorization"];
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *filePath_LEFT0 = @"";
    if (![[ClaimsService sharedService].Photo_Left_Wide isEqualToString:@""] && [ClaimsService sharedService].Photo_Left_Wide != nil && ![[ClaimsService sharedService].Photo_Left_Wide isEqualToString:@"(null)"]) {
        filePath_LEFT0 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoLEFT0.png"];
    }
    NSString *filePath_LEFT1 = @"";
    if (![[ClaimsService sharedService].Photo_Left_Front_Wing isEqualToString:@""] && [ClaimsService sharedService].Photo_Left_Front_Wing != nil && ![[ClaimsService sharedService].Photo_Left_Front_Wing isEqualToString:@"(null)"]) {
        filePath_LEFT1 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoLEFT1.png"];
    }
    NSString *filePath_LEFT2 = @"";
    if (![[ClaimsService sharedService].Photo_Left_Front_Door isEqualToString:@""] && [ClaimsService sharedService].Photo_Left_Front_Door != nil && ![[ClaimsService sharedService].Photo_Left_Front_Door isEqualToString:@"(null)"]) {
        filePath_LEFT2 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoLEFT2.png"];
    }
    NSString *filePath_LEFT3 = @"";
    if (![[ClaimsService sharedService].Photo_Left_Rear_Door isEqualToString:@""] && [ClaimsService sharedService].Photo_Left_Rear_Door != nil && ![[ClaimsService sharedService].Photo_Left_Rear_Door isEqualToString:@"(null)"]) {
        filePath_LEFT3 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoLEFT3.png"];
    }
    NSString *filePath_LEFT4 = @"";
    if (![[ClaimsService sharedService].Photo_Left_Rear_Wing isEqualToString:@""] && [ClaimsService sharedService].Photo_Left_Rear_Wing != nil && ![[ClaimsService sharedService].Photo_Left_Rear_Wing isEqualToString:@"(null)"]) {
        filePath_LEFT4 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoLEFT4.png"];
    }
    NSString *filePath_RIGHT0 = @"";
    if (![[ClaimsService sharedService].Photo_Right_Wide isEqualToString:@""] && [ClaimsService sharedService].Photo_Right_Wide != nil && ![[ClaimsService sharedService].Photo_Right_Wide isEqualToString:@"(null)"]) {
        filePath_RIGHT0 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoRIGHT0.png"];
    }
    NSString *filePath_RIGHT1 = @"";
    if (![[ClaimsService sharedService].Photo_Right_Front_Wing isEqualToString:@""] && [ClaimsService sharedService].Photo_Right_Front_Wing != nil && ![[ClaimsService sharedService].Photo_Right_Front_Wing isEqualToString:@"(null)"]) {
        filePath_RIGHT1 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoRIGHT1.png"];
    }
    NSString *filePath_RIGHT2 = @"";
    if (![[ClaimsService sharedService].Photo_Right_Front_Door isEqualToString:@""] && [ClaimsService sharedService].Photo_Right_Front_Door != nil && ![[ClaimsService sharedService].Photo_Right_Front_Door isEqualToString:@"(null)"]) {
        filePath_RIGHT2 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoRIGHT2.png"];
    }
    NSString *filePath_RIGHT3 = @"";
    if (![[ClaimsService sharedService].Photo_Right_Rear_Door isEqualToString:@""] && [ClaimsService sharedService].Photo_Right_Rear_Door != nil && ![[ClaimsService sharedService].Photo_Right_Rear_Door isEqualToString:@"(null)"]) {
        filePath_RIGHT3 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoRIGHT3.png"];
    }
    NSString *filePath_RIGHT4 = @"";
    if (![[ClaimsService sharedService].Photo_Right_Rear_Wing isEqualToString:@""] && [ClaimsService sharedService].Photo_Right_Rear_Wing != nil && ![[ClaimsService sharedService].Photo_Right_Rear_Wing isEqualToString:@"(null)"]) {
        filePath_RIGHT4 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoRIGHT4.png"];
    }
    NSString *filePath_REAR0 = @"";
    if (![[ClaimsService sharedService].Photo_Rear_Left_Diagonal isEqualToString:@""] && [ClaimsService sharedService].Photo_Rear_Left_Diagonal != nil && ![[ClaimsService sharedService].Photo_Rear_Left_Diagonal isEqualToString:@"(null)"]) {
        filePath_REAR0 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoREAR0.png"];
    }
    NSString *filePath_REAR1 = @"";
    if (![[ClaimsService sharedService].Photo_Rear_Wide isEqualToString:@""] && [ClaimsService sharedService].Photo_Rear_Wide != nil && ![[ClaimsService sharedService].Photo_Rear_Wide isEqualToString:@"(null)"]) {
        filePath_REAR1 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoREAR1.png"];
    }
    NSString *filePath_REAR2 = @"";
    if (![[ClaimsService sharedService].Photo_Rear_Right_Diagonal isEqualToString:@""] && [ClaimsService sharedService].Photo_Rear_Right_Diagonal != nil && ![[ClaimsService sharedService].Photo_Rear_Right_Diagonal isEqualToString:@"(null)"]) {
        filePath_REAR2 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoREAR2.png"];
    }
    NSString *filePath_FRONT0 = @"";
    if (![[ClaimsService sharedService].Photo_Front_Right_Diagonal isEqualToString:@""] && [ClaimsService sharedService].Photo_Front_Right_Diagonal != nil && ![[ClaimsService sharedService].Photo_Front_Right_Diagonal isEqualToString:@"(null)"]) {
        filePath_FRONT0 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoFRONT0.png"];
    }
    NSString *filePath_FRONT1 = @"";
    if (![[ClaimsService sharedService].Photo_Front_Wide isEqualToString:@""] && [ClaimsService sharedService].Photo_Front_Wide != nil && ![[ClaimsService sharedService].Photo_Front_Wide isEqualToString:@"(null)"]) {
        filePath_FRONT1 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoFRONT1.png"];
    }
    NSString *filePath_FRONT2 = @"";
    if (![[ClaimsService sharedService].Photo_Front_Left_Diagonal isEqualToString:@""] && [ClaimsService sharedService].Photo_Front_Left_Diagonal != nil && ![[ClaimsService sharedService].Photo_Front_Left_Diagonal isEqualToString:@"(null)"]) {
        filePath_FRONT2 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoFRONT2.png"];
    }
    NSString *filePath_WIND0 = @"";
    if (![[ClaimsService sharedService].Photo_Windshield_Wide isEqualToString:@""] && [ClaimsService sharedService].Photo_Windshield_Wide != nil && ![[ClaimsService sharedService].Photo_Rear_Wide isEqualToString:@"(null)"]) {
        filePath_WIND0 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoWIND0.png"];
    }
    NSString *filePath_DASH0 = @"";
    if (![[ClaimsService sharedService].Photo_Dashboard_Wide isEqualToString:@""] && [ClaimsService sharedService].Photo_Dashboard_Wide != nil && ![[ClaimsService sharedService].Photo_Dashboard_Wide isEqualToString:@"(null)"]) {
        filePath_DASH0 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"photoDASH0.png"];
    }
    
    NSData *httpBody = [self createBodyWithBoundary:boundary parameters:URLParams paths:@[filePath_LEFT0, filePath_LEFT1, filePath_LEFT2, filePath_LEFT3, filePath_LEFT4, filePath_RIGHT0, filePath_RIGHT1, filePath_RIGHT2, filePath_RIGHT3, filePath_RIGHT4, filePath_REAR0, filePath_REAR1, filePath_REAR2, filePath_FRONT0, filePath_FRONT1, filePath_FRONT2, filePath_WIND0, filePath_DASH0] fieldName:@"claim[screens_attributes][][left]"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session uploadTaskWithRequest:request fromData:httpBody completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error = %@", error);
            return;
        }
        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"result = %@", result);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"claimSuccessUpdate" object:self];
    }];
    [task resume];
}


#pragma mark Claims Images Upload Helpers for Car seides

- (NSData *)createBodyWithBoundary:(NSString *)boundary
                        parameters:(NSDictionary *)parameters
                             paths:(NSArray *)paths
                         fieldName:(NSString *)fieldName {
    
    NSMutableData *httpBody = [NSMutableData data];
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];

    for (NSString *path in paths) {
        if (![path isEqualToString:@""]) {
            NSString *filename  = [path lastPathComponent];
            NSData   *data      = [NSData dataWithContentsOfFile:path];
            NSString *mimetype  = [self mimeTypeForPath:path];
            
            if (![filename isEqualToString:@""]) {
                NSString* correctString = filename.stringByRemovingPercentEncoding;
                if ([correctString isEqualToString:@"photoLEFT0.png"])
                    fieldName = @"claim[screens_attributes][][left]";
                else if ([correctString isEqualToString:@"photoLEFT1.png"])
                    fieldName = @"claim[screens_attributes][][left_front_wing]";
                else if ([correctString isEqualToString:@"photoLEFT2.png"])
                    fieldName = @"claim[screens_attributes][][left_front_door]";
                else if ([correctString isEqualToString:@"photoLEFT3.png"])
                    fieldName = @"claim[screens_attributes][][left_rear_door]";
                else if ([correctString isEqualToString:@"photoLEFT4.png"])
                    fieldName = @"claim[screens_attributes][][left_rear_wing]";

                else if ([correctString isEqualToString:@"photoRIGHT0.png"])
                    fieldName = @"claim[screens_attributes][][right]";
                else if ([correctString isEqualToString:@"photoRIGHT1.png"])
                    fieldName = @"claim[screens_attributes][][right_front_wing]";
                else if ([correctString isEqualToString:@"photoRIGHT2.png"])
                    fieldName = @"claim[screens_attributes][][right_front_door]";
                else if ([correctString isEqualToString:@"photoRIGHT3.png"])
                    fieldName = @"claim[screens_attributes][][right_rear_door]";
                else if ([correctString isEqualToString:@"photoRIGHT4.png"])
                    fieldName = @"claim[screens_attributes][][right_rear_wing]";

                else if ([correctString isEqualToString:@"photoREAR0.png"])
                    fieldName = @"claim[screens_attributes][][back_left_diagonal]";
                else if ([correctString isEqualToString:@"photoREAR1.png"])
                    fieldName = @"claim[screens_attributes][][back]";
                else if ([correctString isEqualToString:@"photoREAR2.png"])
                    fieldName = @"claim[screens_attributes][][back_right_diagonal]";
                
                else if ([correctString isEqualToString:@"photoFRONT0.png"])
                    fieldName = @"claim[screens_attributes][][front_right_diagonal]";
                else if ([correctString isEqualToString:@"photoFRONT1.png"])
                    fieldName = @"claim[screens_attributes][][front]";
                else if ([correctString isEqualToString:@"photoFRONT2.png"])
                    fieldName = @"claim[screens_attributes][][front_left_diagonal]";
                else if ([correctString isEqualToString:@"photoWIND0.png"])
                    fieldName = @"claim[screens_attributes][][windshield]";
                else if ([correctString isEqualToString:@"photoDASH0.png"])
                    fieldName = @"claim[screens_attributes][][dashboard]";
                
                [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, filename] dataUsingEncoding:NSUTF8StringEncoding]];
                [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
                [httpBody appendData:data];
                [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            }
        }
    }
    
    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    return httpBody;
}

- (NSString *)mimeTypeForPath:(NSString *)path {

    CFStringRef extension = (__bridge CFStringRef)[path pathExtension];
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extension, NULL);
    assert(UTI != NULL);

    NSString *mimetype = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType));
    assert(mimetype != NULL);

    CFRelease(UTI);

    return mimetype;
}

- (NSString *)generateBoundaryString {
    return [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];
}


#pragma mark URLHelpers for us

+ (NSString *)contentTypePathToJson {
    return @"application/json; charset=utf-8";
}

static NSString* NSStringFromQueryParameters(NSDictionary* queryParameters) {
    NSMutableArray* parts = [NSMutableArray array];
    [queryParameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        NSString *part = [NSString stringWithFormat: @"%@=%@",
                          [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]],
                          [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]
                          ];
        [parts addObject:part];
    }];
    return [parts componentsJoinedByString: @"&"];
}

static NSURL* NSURLByAppendingQueryParameters(NSURL* URL, NSDictionary* queryParameters) {
    NSString* URLString = [NSString stringWithFormat:@"%@?%@",
                           [URL absoluteString],
                           NSStringFromQueryParameters(queryParameters)];
    return [NSURL URLWithString:URLString];
}

@end
