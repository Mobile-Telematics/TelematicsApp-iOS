//
//  ZenLeaderboardModel+CoreDataProperties.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 09.07.19.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ZenLeaderboardModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZenLeaderboardModel (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *leaderboard_user;

@property (nullable, nonatomic, retain) NSArray *leaderboardGlobal;
@property (nullable, nonatomic, retain) NSArray *leaderboardAcceleration;
@property (nullable, nonatomic, retain) NSArray *leaderboardDeceleration;
@property (nullable, nonatomic, retain) NSArray *leaderboardDistraction;
@property (nullable, nonatomic, retain) NSArray *leaderboardSpeeding;
@property (nullable, nonatomic, retain) NSArray *leaderboardTurn;
@property (nullable, nonatomic, retain) NSArray *leaderboardRate;
@property (nullable, nonatomic, retain) NSArray *leaderboardDistance;
@property (nullable, nonatomic, retain) NSArray *leaderboardTrips;
@property (nullable, nonatomic, retain) NSArray *leaderboardDuration;

@end

NS_ASSUME_NONNULL_END
