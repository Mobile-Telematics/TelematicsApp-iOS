//
//  CoinsDetailsObject.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 10.08.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ResponseObject.h"

@protocol CoinsDetailsObject;

@interface CoinsDetailsObject: ResponseObject

@property (nonatomic, strong) NSNumber<Optional>* TotalEarnedCoins;
@property (nonatomic, strong) NSNumber<Optional>* AcquiredCoins;
@property (nonatomic, strong) NSNumber<Optional>* LimitReached;
@property (nonatomic, strong) NSString<Optional>* Date;
@property (nonatomic, strong) NSString<Optional>* DateUpdated;

@property (nonatomic, strong) NSString<Optional>* CoinCategoryName;
@property (nonatomic, strong) NSString<Optional>* CoinFactor;
@property (nonatomic, strong) NSString<Optional>* CoinsSum;

@end
