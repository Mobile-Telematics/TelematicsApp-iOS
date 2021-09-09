//
//  OverallCell.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 07.04.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "OverallCell.h"
#import "UIImageView+WebCache.h"

@interface OverallCell ()

@property (nonatomic) NSTimer *timerOverall;
@property float valueOverall;
@property float valueMaximum;

@end

@implementation OverallCell

@synthesize progressBarOverall = _progressBarOverall;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _progressBarOverall.barFillColor = [Color officialMainAppColor];
    [_progressBarOverall setBarBackgroundColor:[Color lightSeparatorColor]];
}


#pragma mark - Progress Bars Timers

- (void)configOverall:(float)value usersNumber:(float)userValue {
    _valueOverall = userValue - value;
    _valueMaximum = userValue;
    
    int rateProg = [@(_progressBarOverall.progress*_valueMaximum) intValue];
    if (_valueOverall == rateProg) {
        return;
    } else {
        _timerOverall = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(incrementProgressOverall:) userInfo:nil repeats:YES];
    }
}

- (void)incrementProgressOverall:(NSTimer *)timer {
    int rate = _valueOverall;
    int rateFixMax = _valueMaximum - 1;
    int rateProg = [@(_progressBarOverall.progress*rateFixMax) intValue];
    
    if (rate == rateProg) {
        [_timerOverall invalidate];
        _timerOverall = nil;
    } else {
        _progressBarOverall.progress = _progressBarOverall.progress + 0.01f;
    }
}


#pragma mark - Progress Bars init

- (ProgressBarView *)progressBarOverall {
    if (!_progressBarOverall) {
        _progressBarOverall = [[ProgressBarView alloc] initWithFrame:CGRectZero];
        _progressBarOverall.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _progressBarOverall;
}

@end
