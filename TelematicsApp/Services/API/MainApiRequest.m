//
//  MainApiRequest.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 20.01.19.
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
#import "EcoResponse.h"
#import "EcoIndividualResponse.h"
#import "DrivingDetailsResponse.h"
#import "LeaderboardResponse.h"
#import "GeneralService.h"
#import "Helpers.h"
#import "AFNetworking.h"
#import "ProfileResponse.h"
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

+ (NSString *)userServiceRootURL {
    return [Configurator sharedInstance].userServiceRootURL;
}

+ (NSString *)userServiceRootURLv2 {
    return [Configurator sharedInstance].userServiceRootURLv2;
}

+ (NSString *)statisticServiceURL {
    return [Configurator sharedInstance].statisticServiceURL;
}

+ (NSString *)leaderboardServiceURL {
    return [Configurator sharedInstance].leaderboardServiceURL;
}

+ (NSString *)carServiceURL {
    return [Configurator sharedInstance].carServiceURL;
}

+ (NSString *)instanceId {
    return [Configurator sharedInstance].instanceId;
}

+ (NSString *)instanceKey {
    return [Configurator sharedInstance].instanceKey;
}

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


#pragma mark RefreshToken

- (void)refreshJWToken:(RefreshTokenRequestData*)refreshData {
    NSDictionary* params = [refreshData paramsDictionary];
    [self performRequestWithPathBodyObject:@"Auth/RefreshToken" responseClass:[LoginResponse class] parameters:nil bodyObject:params method:POST];
}


#pragma mark Phone/Email change

- (void)checkEmailConfirmationCode:(CheckUserRequestData *)emailData {
    NSDictionary* params = [emailData paramsDictionary];
    NSString *fullPath = [NSString stringWithFormat:@"Management/users/CheckEmailConfirmationCode"];
    [self performRequestWithPath:fullPath responseClass:[CheckResponse class] parameters:params method:POST];
}

- (void)checkPhoneConfirmationCode:(CheckUserRequestData *)phoneData {
    NSDictionary* params = [phoneData paramsDictionary];
    NSString *fullPath = [NSString stringWithFormat:@"Management/users/CheckPhoneConfirmationCode"];
    [self performRequestWithPath:fullPath responseClass:[CheckResponse class] parameters:params method:POST];
}


#pragma mark Dashboard Statistics & Scorings
    
- (void)getLatestDayStatisticsScoring {
    [self performRequestStatisticService:@"Statistics/individual/latestDates" responseClass:[LatestDayScoringResponse class] parameters:nil method:GET];
}

- (void)getStatisticsIndividualAllTime:(NSString *)startDate endDate:(NSString*)endDate {
    NSDictionary *params = @{@"StartDate": startDate, @"EndDate": endDate};
    [self performRequestStatisticService:@"Statistics/individual" responseClass:[DashboardResponse class] parameters:params method:GET];
}

- (void)getScoringsIndividualCurrentDay:(NSString *)startDate endDate:(NSString*)endDate {
    NSDictionary *params = @{@"StartDate": startDate, @"EndDate": endDate};
    [self performRequestStatisticService:@"Scorings/individual" responseClass:[DashboardResponse class] parameters:params method:GET];
}

- (void)getScoringsIndividual14daysDaily:(NSString *)startDate endDate:(NSString*)endDate {
    NSDictionary *params = @{@"StartDate": startDate, @"EndDate": endDate};
    [self performRequestStatisticService:@"Scorings/individual/daily" responseClass:[DrivingDetailsResponse class] parameters:params method:GET];
}


#pragma mark Scorings

- (void)getEcoDataAllTime {
    [self performRequestStatisticService:@"Scorings/individual/eco" responseClass:[EcoIndividualResponse class] parameters:nil method:GET];
}

- (void)getEcoStatisticForPeriod:(NSString *)startDate endDate:(NSString*)endDate {
    NSDictionary *params = @{@"StartDate": startDate, @"EndDate": endDate};
    [self performRequestStatisticService:@"Statistics/individual" responseClass:[EcoResponse class] parameters:params method:GET];
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



#pragma mark DeleteTrack Status

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


#pragma mark Cornering

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


#pragma mark URLHelpers

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
