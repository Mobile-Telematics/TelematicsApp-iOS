//
//  MainApiRequest.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 20.01.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
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
#import "TagResponse.h"
#import "CoinsDetailsResponse.h"
#import "EcoResponse.h"
#import "EcoIndividualResponse.h"
#import "DrivingDetailsResponse.h"
#import "IndicatorsResponse.h"
#import "LeaderboardResponse.h"
#import "GeneralService.h"
#import "Helpers.h"
#import "AFNetworking.h"
#import "ProfileResponse.h"
#import "JoinCompanyResponse.h"
#import "VehicleRequestData.h"
#import "VehicleResponse.h"
#import "VehiclesDictionaryResponse.h"
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

//USERSERVICE URL FROM CONFIGURATION.PLIST
+ (NSString *)userServiceRootURL {
    return [Configurator sharedInstance].userServiceRootURL;
}

//INDICATORS SERVICE URL FROM CONFIGURATION.PLIST
+ (NSString *)indicatorsServiceURL {
    return [Configurator sharedInstance].indicatorsServiceURL;
}

//REWARDS DRIVECOINS URL FROM CONFIGURATION.PLIST
+ (NSString *)driveCoinsServiceURL {
    return [Configurator sharedInstance].driveCoinsServiceURL;
}

//LEADERBOARD URL FROM CONFIGURATION.PLIST
+ (NSString *)leaderboardServiceURL {
    return [Configurator sharedInstance].leaderboardServiceURL;
}

//CAR SERVICE URL FROM CONFIGURATION.PLIST
+ (NSString *)carServiceURL {
    return [Configurator sharedInstance].carServiceURL;
}

//YOUR OWN INSTANCE ID KEY
+ (NSString *)instanceId {
    return [Configurator sharedInstance].instanceId;
}

//YOUR OWN INSTANCE ID KEY
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
    [self performRequestIndicatorsService:@"Statistics/dates" responseClass:[LatestDayScoringResponse class] parameters:nil method:GET];
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

#pragma mark OnDemand Tags when "on duty trips" Dashboard statistics

- (void)getTagRiskScore:(NSString *)tagName startDate:(NSString*)startDate endDate:(NSString*)endDate {
    NSDictionary *params = @{@"Tag": tagName, @"StartDate": startDate, @"EndDate": endDate};
    [self performRequestIndicatorsService:@"Scorings/individual" responseClass:[TagResponse class] parameters:params method:GET];
}

- (void)getTagStatistic:(NSString *)tagName startDate:(NSString*)startDate endDate:(NSString*)endDate {
    NSDictionary *params = @{@"Tag": tagName, @"StartDate": startDate, @"EndDate": endDate};
    [self performRequestIndicatorsService:@"Statistics/individual" responseClass:[TagResponse class] parameters:params method:GET];
}


#pragma mark Leaderboard

- (void)getLeaderboardForUser {
    [self performRequestLeaderboardService:@"Leaderboard/user" responseClass:[LeaderboardResponse class] parameters:nil method:GET];
}

//SCORINGRATE
//Acceleration = 1
//Deceleration = 2
//Distraction = 3
//Speeding = 4
//Turn = 5
//RateOverall = 6,
//Distance = 7
//Trips = 8
//Duration = 9
- (void)getLeaderboardScore:(NSUInteger)scoringRate {
    NSString *finalLeadersUrl = [NSString stringWithFormat:@"Leaderboard?usersCount=10&roundUsersCount=3&ScoringRate=%lu", (unsigned long)scoringRate];
    [self performRequestLeaderboardService:finalLeadersUrl responseClass:[LeaderboardResponse class] parameters:nil method:GET];
}


#pragma mark CarService

- (void)getAllVehiclesManufacturers {
    [self performRequestCarService:@"Directories/Manufacturers" responseClass:[VehiclesDictionaryResponse class] parameters:nil method:GET];
}

- (void)getAllVehiclesBrandModels:(NSString*)brandId {
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


#pragma mark Delete Track From Feed Screen

- (void)deleteThisTripSendStatusForBackEnd:(NSString *)trackToken {
    NSString *URLStr = [NSString stringWithFormat:@"https://mobilesdk.telematicssdk.com/mobilesdk/stage/track/%@/setdeleted/v1", trackToken];
    NSError *error;
    NSMutableURLRequest *request = [self.sessionManager.requestSerializer requestWithMethod:POST URLString:URLStr parameters:nil error:&error];
    NSDictionary* customHeaders = [[self class] customRequestHeaders];
    for (NSString* key in customHeaders.allKeys) {
        [request setValue:customHeaders[key] forHTTPHeaderField:key];
    }
    [self performRequest:request withResponseClass:[ResponseObject class]];
}


#pragma mark Join a Company

- (void)joinCompanyIdRefresh:(NSString *)invitationCode {
    NSString *encodedСode = [invitationCode stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *URLStr = [NSString stringWithFormat:@"https://user.telematicssdk.com/v1/Management/users/instances/change/%@", encodedСode];
    NSError *error;
    NSMutableURLRequest *request = [self.sessionManager.requestSerializer requestWithMethod:POST URLString:URLStr parameters:nil error:&error];
    NSDictionary* customHeaders = [[self class] customRequestHeaders];
    for (NSString* key in customHeaders.allKeys) {
        [request setValue:customHeaders[key] forHTTPHeaderField:key];
    }
    [self performRequest:request withResponseClass:[JoinCompanyResponse class]];
}


#pragma mark Events Browse on Trip Details screen

- (void)trackEventsStartBrowse:(NSString *)trackToken {
    NSString *URLStr = [NSString stringWithFormat:@"https://mobilesdk.telematicssdk.com/mobilesdk/stage/track/browsestart/v1/%@", trackToken];
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
    
    NSString *URLStr = [NSString stringWithFormat:@"https://mobilesdk.telematicssdk.com/mobilesdk/stage/events/reportwrongevent/v1/%@", trackToken];
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
    
    NSString *URLStr = [NSString stringWithFormat:@"https://mobilesdk.telematicssdk.com/mobilesdk/stage/events/reportwrongeventtype/v1/%@", trackToken];
    NSError *error;
    NSMutableURLRequest *request = [self.sessionManager.requestSerializer requestWithMethod:POST URLString:URLStr parameters:params error:&error];
    NSDictionary* customHeaders = [[self class] customRequestHeaders];
    for (NSString* key in customHeaders.allKeys) {
        [request setValue:customHeaders[key] forHTTPHeaderField:key];
    }
    [self performRequest:request withResponseClass:[ResponseObject class]];
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

@end
