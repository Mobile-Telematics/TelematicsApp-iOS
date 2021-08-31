//
//  TotalTripsCell.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 13.04.20.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "TotalTripsCell.h"
#import "UIImageView+WebCache.h"

@interface TotalTripsCell ()

@property (nonatomic) NSTimer *timerTotalTrips;
@property float valueTotalTrips;
@property float valueMaximum;

@end

@implementation TotalTripsCell

@synthesize progressBarTotalTrips = _progressBarTotalTrips;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _progressBarTotalTrips.barFillColor = [Color officialMainAppColor];
    [_progressBarTotalTrips setBarBackgroundColor:[Color lightSeparatorColor]];
}


#pragma mark - Progress Bars Timers

- (void)configTotalTrips:(float)value usersNumber:(float)userValue {
    _valueTotalTrips = userValue - value;
    _valueMaximum = userValue;
    
    int rateProg = [@(_progressBarTotalTrips.progress*_valueMaximum) intValue];
    if (_valueTotalTrips == rateProg) {
        return;
    } else {
        _timerTotalTrips = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(incrementProgressTotalTrips:) userInfo:nil repeats:YES];
    }
}

- (void)incrementProgressTotalTrips:(NSTimer *)timer {
    int rate = _valueTotalTrips;
    int rateFixMax = _valueMaximum - 1;
    int rateProg = [@(_progressBarTotalTrips.progress*rateFixMax) intValue];
    
    if (rate == rateProg) {
        [_timerTotalTrips invalidate];
        _timerTotalTrips = nil;
    } else {
        _progressBarTotalTrips.progress = _progressBarTotalTrips.progress + 0.01f;
    }
}


#pragma mark - Progress Bars init

- (ProgressBarView *)progressBarTotalTrips {
    if (!_progressBarTotalTrips) {
        _progressBarTotalTrips = [[ProgressBarView alloc] initWithFrame:CGRectZero];
        _progressBarTotalTrips.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _progressBarTotalTrips;
}

@end
