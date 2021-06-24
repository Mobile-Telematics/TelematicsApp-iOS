//
//  ZenAppModel+CoreDataProperties.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 28.10.18.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ZenAppModel+CoreDataProperties.h"

@implementation ZenAppModel (CoreDataProperties)

@dynamic current_user;

@dynamic userFirebaseId;
@dynamic userEmail;
@dynamic userFullName;
@dynamic userFirstName;
@dynamic userLastName;
@dynamic userPhone;
@dynamic userBirthday;
@dynamic userAddress;
@dynamic userClientId;
@dynamic userGender;
@dynamic userMaritalStatus;
@dynamic userChildrenCount;
@dynamic userProfilePictureLink;
@dynamic userPhotoData;

@dynamic notFirstRunApp;

@dynamic statRating;
@dynamic statPreviousRating;
@dynamic statSpeedLevel;
@dynamic statDrivingLevel;
@dynamic statPhoneLevel;
@dynamic statTimeOfDayScore;
@dynamic statTrackCount;
@dynamic statSummaryDuration;
@dynamic statSummaryDistance;
@dynamic statDistanceForScoring;

@dynamic statWeeklyMaxSpeed;
@dynamic statWeeklyAverageSpeed;
@dynamic statWeeklyTotalKm;
@dynamic statMonthlyMaxSpeed;
@dynamic statMonthlyAverageSpeed;
@dynamic statMonthlyTotalKm;
@dynamic statYearlyMaxSpeed;
@dynamic statYearlyAverageSpeed;
@dynamic statYearlyTotalKm;

@dynamic statEco;
@dynamic statPreviousEcoScoring;
@dynamic statEcoScoringFuel;
@dynamic statEcoScoringTyres;
@dynamic statEcoScoringBrakes;
@dynamic statEcoScoringDepreciation;

@dynamic detailsAllDrivingScores;

@dynamic detailsScoreOverall;
@dynamic detailsScoreAcceleration;
@dynamic detailsScoreDeceleration;
@dynamic detailsScorePhoneUsage;
@dynamic detailsScoreSpeeding;
@dynamic detailsScoreTurn;

@dynamic vehicleShortData;
@dynamic vehicleCarYear;

@end
