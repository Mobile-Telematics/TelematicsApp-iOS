//
//  APIRequest.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 20.01.19.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "APIRequest.h"

@class CheckUserRequestData;
@class RefreshTokenRequestData;
@class ForgotRequestData;
@class ProfileRequestData;
@class FeedRequestData;
@class ChangePasswordRequestData;
@class VehicleRequestData;

@interface MainApiRequest: APIRequest


#pragma mark RefreshToken

- (void)refreshJWToken:(RefreshTokenRequestData*)refreshData;


#pragma mark Dashboard Statistics & Scorings
    
- (void)getLatestDayStatisticsScoring;
- (void)getStatisticsIndividualAllTime:(NSString *)startDate endDate:(NSString*)endDate;
- (void)getScoringsIndividualCurrentDay:(NSString *)startDate endDate:(NSString*)endDate;
- (void)getScoringsIndividual14daysDaily:(NSString *)startDate endDate:(NSString*)endDate;


#pragma mark EcoScorings

- (void)getEcoDataAllTime;
- (void)getEcoStatisticForPeriod:(NSString *)startDate endDate:(NSString*)endDate;


#pragma mark Feed

- (void)getAllEvents:(FeedRequestData*)eventData;
- (void)getTypeEvents:(FeedRequestData*)eventData;


#pragma mark DeleteTrack Status

- (void)deleteTrackSendStatusForBackEnd:(NSString *)trackToken;


#pragma mark Browse Track Events

- (void)trackBrowseStart:(NSString *)trackToken;
- (void)reportWrongEventNoEvent:(NSString *)trackToken lat:(NSString *)lat lon:(NSString *)lon eventType:(NSString *)eventType date:(NSString *)date;
- (void)reportWrongEventNewEvent:(NSString *)trackToken lat:(NSString *)lat lon:(NSString *)lon eventType:(NSString *)eventType newEventType:(NSString *)newEventType date:(NSString *)date;


#pragma mark Leaderboard

- (void)getLeaderboardForUser;
- (void)getLeaderboardScore:(NSUInteger)scoringRate;


#pragma mark CarService

- (void)getAllCarsManufacturers;
- (void)getAllBrandModels:(NSString*)brandId;
- (void)getUserAllVehicles;
- (void)updateVehicle:(VehicleRequestData *)vehicleData;
- (void)putVehicle:(VehicleRequestData *)vehicleData vehicle:(NSString *)vehicleToken;
- (void)deleteVehicle:(VehicleRequestData *)vehicleData vehicle:(NSString *)vehicleToken;


@end
