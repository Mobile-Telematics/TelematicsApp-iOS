//
//  AccCell.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 13.04.20.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "AccCell.h"
#import "UIImageView+WebCache.h"

@interface AccCell ()

@property (nonatomic) NSTimer *timerAcc;
@property float valueAcc;
@property float valueMaximum;

@end

@implementation AccCell

@synthesize progressBarAcc = _progressBarAcc;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _progressBarAcc.barFillColor = [Color officialMainAppColor];
    [_progressBarAcc setBarBackgroundColor:[Color lightSeparatorColor]];
}


#pragma mark - Progress Bars Timers

- (void)configAcc:(float)value usersNumber:(float)userValue {
    _valueAcc = userValue - value;
    _valueMaximum = userValue;
    
    int rateProg = [@(_progressBarAcc.progress*_valueMaximum) intValue];
    if (_valueAcc == rateProg) {
        return;
    } else {
        _timerAcc = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(incrementProgressAcc:) userInfo:nil repeats:YES];
    }
}

- (void)incrementProgressAcc:(NSTimer *)timer {
    int rate = _valueAcc;
    int rateFixMax = _valueMaximum - 1;
    int rateProg = [@(_progressBarAcc.progress*rateFixMax) intValue];
    
    if (rate == rateProg) {
        [_timerAcc invalidate];
        _timerAcc = nil;
    } else {
        _progressBarAcc.progress = _progressBarAcc.progress + 0.01f;
    }
}


#pragma mark - Progress Bars init

- (ProgressBarView *)progressBarAcc {
    if (!_progressBarAcc) {
        _progressBarAcc = [[ProgressBarView alloc] initWithFrame:CGRectZero];
        _progressBarAcc.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _progressBarAcc;
}

@end
