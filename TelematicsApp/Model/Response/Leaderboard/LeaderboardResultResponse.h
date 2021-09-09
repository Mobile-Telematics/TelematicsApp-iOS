//
//  LeaderboardResultResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 06.02.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ResponseObject.h"
#import "LeaderboardObject.h"

@interface LeaderboardResultResponse: ResponseObject

@property (nonatomic, strong) NSMutableArray<LeaderboardObject, Optional> *Users;

@property (nonatomic, strong) NSString<Optional> *AccelerationPerc;
@property (nonatomic, strong) NSNumber<Optional> *AccelerationPlace;
@property (nonatomic, strong) NSString<Optional> *AccelerationScore;
@property (nonatomic, strong) NSString<Optional> *DecelerationPerc;
@property (nonatomic, strong) NSNumber<Optional> *DecelerationPlace;
@property (nonatomic, strong) NSNumber<Optional> *DecelerationScore;
@property (nonatomic, strong) NSString<Optional> *DeviceToken;
@property (nonatomic, strong) NSString<Optional> *Distance;
@property (nonatomic, strong) NSNumber<Optional> *DistancePlace;
@property (nonatomic, strong) NSString<Optional> *DistractionPerc;
@property (nonatomic, strong) NSNumber<Optional> *DistractionPlace;
@property (nonatomic, strong) NSNumber<Optional> *DistractionScore;
@property (nonatomic, strong) NSString<Optional> *Duration;
@property (nonatomic, strong) NSNumber<Optional> *DurationPlace;
@property (nonatomic, strong) NSString<Optional> *FirstName;
@property (nonatomic, strong) NSString<Optional> *Image;
@property (nonatomic, strong) NSString<Optional> *LastName;
@property (nonatomic, strong) NSString<Optional> *Nickname;
@property (nonatomic, strong) NSString<Optional> *Perc;
@property (nonatomic, strong) NSNumber<Optional> *Place;
@property (nonatomic, strong) NSString<Optional> *Score;
@property (nonatomic, strong) NSString<Optional> *SpeedingPerc;
@property (nonatomic, strong) NSNumber<Optional> *SpeedingPlace;
@property (nonatomic, strong) NSString<Optional> *SpeedingScore;
@property (nonatomic, strong) NSNumber<Optional> *Trips;
@property (nonatomic, strong) NSNumber<Optional> *TripsPlace;
@property (nonatomic, strong) NSString<Optional> *TurnPerc;
@property (nonatomic, strong) NSNumber<Optional> *TurnPlace;
@property (nonatomic, strong) NSNumber<Optional> *TurnScore;
@property (nonatomic, strong) NSNumber<Optional> *UsersNumber;

@end
