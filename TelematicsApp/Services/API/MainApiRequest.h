//
//  APIRequest.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 20.01.20.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "APIRequest.h"

@class CheckUserRequestData;
@class RefreshTokenRequestData;
@class ProfileRequestData;
@class VehicleRequestData;

@class ClaimsTokenRequestData;
@class CreateClaimRequestData;


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


#pragma mark DeleteTrack On Feed Screen

- (void)deleteTrackSendStatusForBackEnd:(NSString *)trackToken;


#pragma mark Browse Track Events On Trip Details Screen

- (void)trackBrowseStart:(NSString *)trackToken;
- (void)reportWrongEventNoEvent:(NSString *)trackToken lat:(NSString *)lat lon:(NSString *)lon eventType:(NSString *)eventType date:(NSString *)date;
- (void)reportWrongEventNewEvent:(NSString *)trackToken lat:(NSString *)lat lon:(NSString *)lon eventType:(NSString *)eventType newEventType:(NSString *)newEventType date:(NSString *)date;

#pragma mark My Rewards - Coins

- (void)getCoinsDailyLimit;
- (void)getCoinsTotal:(NSString *)startDate endDate:(NSString*)endDate;
- (void)getCoinsDetailed:(NSString *)startDate endDate:(NSString*)endDate;
- (void)getCoinsDaily:(NSString *)startDate endDate:(NSString*)endDate;

#pragma mark Indicators For My Rewards - Coins

- (void)getIndicatorsIndividualForPeriod:(NSString *)startDate endDate:(NSString*)endDate;
- (void)getIndicatorsStreaks;
- (void)getIndicatorsEcoWithPercentForPeriod:(NSString *)startDate endDate:(NSString*)endDate;

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


#pragma mark ClaimsService

- (void)getTokenForClaims:(ClaimsTokenRequestData*)claimsData;
- (void)getUserClaims;
- (void)getAccidentTypes;
- (void)deleteUserClaim:(NSString*)claimId;
- (void)createClaim:(CreateClaimRequestData*)createClaimData;


@end
