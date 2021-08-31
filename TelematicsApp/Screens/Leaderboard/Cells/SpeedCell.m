//
//  SpeedCell.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 13.04.20.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "SpeedCell.h"
#import "UIImageView+WebCache.h"

@interface SpeedCell ()

@property (nonatomic) NSTimer *timerSpeed;
@property float valueSpeed;
@property float valueMaximum;

@end

@implementation SpeedCell

@synthesize progressBarSpeed = _progressBarSpeed;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _progressBarSpeed.barFillColor = [Color officialMainAppColor];
    [_progressBarSpeed setBarBackgroundColor:[Color lightSeparatorColor]];
}


#pragma mark - Progress Bars Timers

- (void)configSpeed:(float)value usersNumber:(float)userValue {
    _valueSpeed = userValue - value;
    _valueMaximum = userValue;
    
    int rateProg = [@(_progressBarSpeed.progress*_valueMaximum) intValue];
    if (_valueSpeed == rateProg) {
        return;
    } else {
        _timerSpeed = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(incrementProgressSpeed:) userInfo:nil repeats:YES];
    }
}

- (void)incrementProgressSpeed:(NSTimer *)timer {
    int rate = _valueSpeed;
    int rateFixMax = _valueMaximum - 1;
    int rateProg = [@(_progressBarSpeed.progress*rateFixMax) intValue];
    
    if (rate == rateProg) {
        [_timerSpeed invalidate];
        _timerSpeed = nil;
    } else {
        _progressBarSpeed.progress = _progressBarSpeed.progress + 0.01f;
    }
}


#pragma mark - Progress Bars init

- (ProgressBarView *)progressBarSpeed {
    if (!_progressBarSpeed) {
        _progressBarSpeed = [[ProgressBarView alloc] initWithFrame:CGRectZero];
        _progressBarSpeed.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _progressBarSpeed;
}

@end
