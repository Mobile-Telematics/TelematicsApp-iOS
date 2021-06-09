//
//  ZenAppModel+CoreDataProperties.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 28.10.18.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ZenAppModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZenAppModel (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *current_user;

@property (nullable, nonatomic, retain) NSString *userFirebaseId;
@property (nullable, nonatomic, retain) NSString *userEmail;
@property (nullable, nonatomic, retain) NSString *userFirstName;
@property (nullable, nonatomic, retain) NSString *userLastName;
@property (nullable, nonatomic, retain) NSString *userFullName;
@property (nullable, nonatomic, retain) NSString *userPhone;
@property (nullable, nonatomic, retain) NSString *userBirthday;
@property (nullable, nonatomic, retain) NSString *userAddress;
@property (nullable, nonatomic, retain) NSString *userGender;
@property (nullable, nonatomic, retain) NSString *userClientId;
@property (nullable, nonatomic, retain) NSString *userAvatarLink;
@property (nullable, nonatomic, retain) NSData *userPhotoData;

@property (nonatomic, assign) BOOL notFirstRunApp;

@property (nullable, nonatomic, retain) NSNumber *statRating;
@property (nullable, nonatomic, retain) NSNumber *statPreviousRating;
@property (nullable, nonatomic, retain) NSNumber *statSpeedLevel;
@property (nullable, nonatomic, retain) NSNumber *statDrivingLevel;
@property (nullable, nonatomic, retain) NSNumber *statPhoneLevel;
@property (nullable, nonatomic, retain) NSNumber *statTimeOfDayScore;
@property (nullable, nonatomic, retain) NSNumber *statTrackCount;
@property (nullable, nonatomic, retain) NSNumber *statSummaryDuration;
@property (nullable, nonatomic, retain) NSNumber *statSummaryDistance;
@property (nullable, nonatomic, retain) NSNumber *statDistanceForScoring;

@property (nullable, nonatomic, retain) NSNumber *statWeeklyMaxSpeed;
@property (nullable, nonatomic, retain) NSNumber *statWeeklyAverageSpeed;
@property (nullable, nonatomic, retain) NSNumber *statWeeklyTotalKm;
@property (nullable, nonatomic, retain) NSNumber *statMonthlyMaxSpeed;
@property (nullable, nonatomic, retain) NSNumber *statMonthlyAverageSpeed;
@property (nullable, nonatomic, retain) NSNumber *statMonthlyTotalKm;
@property (nullable, nonatomic, retain) NSNumber *statYearlyMaxSpeed;
@property (nullable, nonatomic, retain) NSNumber *statYearlyAverageSpeed;
@property (nullable, nonatomic, retain) NSNumber *statYearlyTotalKm;

@property (nullable, nonatomic, retain) NSNumber *statEco;
@property (nullable, nonatomic, retain) NSNumber *statPreviousEcoScoring;
@property (nullable, nonatomic, retain) NSNumber *statEcoScoringFuel;
@property (nullable, nonatomic, retain) NSNumber *statEcoScoringTyres;
@property (nullable, nonatomic, retain) NSNumber *statEcoScoringBrakes;
@property (nullable, nonatomic, retain) NSNumber *statEcoScoringDepreciation;

@property (nullable, nonatomic, retain) NSArray *detailsAllDrivingScores;

@property (nullable, nonatomic, retain) NSNumber *detailsScoreOverall;
@property (nullable, nonatomic, retain) NSNumber *detailsScoreAcceleration;
@property (nullable, nonatomic, retain) NSNumber *detailsScoreDeceleration;
@property (nullable, nonatomic, retain) NSNumber *detailsScorePhoneUsage;
@property (nullable, nonatomic, retain) NSNumber *detailsScoreSpeeding;
@property (nullable, nonatomic, retain) NSNumber *detailsScoreTurn;

@property (nullable, nonatomic, retain) NSMutableArray *vehicleShortData;
@property (nullable, nonatomic, retain) NSString *vehicleCarYear;

@end

NS_ASSUME_NONNULL_END
