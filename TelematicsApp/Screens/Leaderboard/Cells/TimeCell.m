//
//  TimeCell.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 13.04.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "TimeCell.h"
#import "UIImageView+WebCache.h"

@interface TimeCell ()

@property (nonatomic) NSTimer *timerTime;
@property float valueTime;
@property float valueMaximum;

@end

@implementation TimeCell

@synthesize progressBarTime = _progressBarTime;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _progressBarTime.barFillColor = [Color officialMainAppColor];
    [_progressBarTime setBarBackgroundColor:[Color lightSeparatorColor]];
}


#pragma mark - Progress Bars Timers

- (void)configTime:(float)value usersNumber:(float)userValue {
    _valueTime = userValue - value;
    _valueMaximum = userValue;
    
    int rateProg = [@(_progressBarTime.progress*_valueMaximum) intValue];
    if (_valueTime == rateProg) {
        return;
    } else {
        _timerTime = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(incrementProgressTime:) userInfo:nil repeats:YES];
    }
}

- (void)incrementProgressTime:(NSTimer *)timer {
    int rate = _valueTime;
    int rateFixMax = _valueMaximum - 1;
    int rateProg = [@(_progressBarTime.progress*rateFixMax) intValue];
    
    if (rate == rateProg) {
        [_timerTime invalidate];
        _timerTime = nil;
    } else {
        _progressBarTime.progress = _progressBarTime.progress + 0.01f;
    }
}


#pragma mark - Progress Bars init

- (ProgressBarView *)progressBarTime {
    if (!_progressBarTime) {
        _progressBarTime = [[ProgressBarView alloc] initWithFrame:CGRectZero];
        _progressBarTime.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _progressBarTime;
}

@end
