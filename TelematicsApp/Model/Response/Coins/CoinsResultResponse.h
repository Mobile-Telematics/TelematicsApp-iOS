//
//  CoinsResultResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 10.08.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ResponseObject.h"

@interface CoinsResultResponse: ResponseObject

@property (nonatomic, strong) NSNumber<Optional>* DailyLimit;
@property (nonatomic, strong) NSString<Optional>* TotalEarnedCoins;
@property (nonatomic, strong) NSString<Optional>* AcquiredCoins;

@end
