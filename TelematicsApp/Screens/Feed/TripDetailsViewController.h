//
//  TripDetailsViewController.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 10.06.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;
#import "NMAkit/NMAkit.h"

@class RPTrackProcessed;

@interface TripDetailsViewController: BaseViewController <NMAMapGestureDelegate>

@property (nonatomic) RPTrackProcessed *track;

@property (nonatomic) NSString *trackToken;
@property (nonatomic) NSInteger trackTag;

@property (nonatomic) NSString *trackDistanceSummary;
@property (nonatomic) NSString *trackPointsSummary;
@property (nonatomic) NSString *simpleStartTime;
@property (nonatomic) NSString *simpleEndTime;

@property (nonatomic) NSMutableArray *sortedOnlyTrips;

@end
