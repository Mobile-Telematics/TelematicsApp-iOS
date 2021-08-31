//
//  LeaderboardObject.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 06.02.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ResponseObject.h"

@protocol LeaderboardObject;

@interface LeaderboardObject: ResponseObject

@property (nonatomic, strong) NSString<Optional>* Nickname;
@property (nonatomic, strong) NSString<Optional>* FirstName;
@property (nonatomic, strong) NSString<Optional>* LastName;
@property (nonatomic, strong) NSNumber<Optional>* Value;
@property (nonatomic, strong) NSNumber<Optional>* ValuePerc;
@property (nonatomic, strong) NSNumber<Optional>* Place;
@property (nonatomic, strong) NSNumber<Optional>* Distance;
@property (nonatomic, strong) NSNumber<Optional>* Duration;
@property (nonatomic, strong) NSNumber<Optional>* Trips;
@property (nonatomic, strong) NSString<Optional>* DeviceToken;
@property (nonatomic, strong) NSString<Optional>* Image;
@property (nonatomic, strong) NSNumber<Optional>* IsCurrentUser;

@end
