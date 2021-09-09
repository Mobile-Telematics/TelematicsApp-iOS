//
//  DecCell.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 13.04.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "DecCell.h"
#import "UIImageView+WebCache.h"

@interface DecCell ()

@property (nonatomic) NSTimer *timerDec;
@property float valueDec;
@property float valueMaximum;

@end

@implementation DecCell

@synthesize progressBarDec = _progressBarDec;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _progressBarDec.barFillColor = [Color officialMainAppColor];
    [_progressBarDec setBarBackgroundColor:[Color lightSeparatorColor]];
}


#pragma mark - Progress Bars Timers

- (void)configDec:(float)value usersNumber:(float)userValue {
    _valueDec = userValue - value;
    _valueMaximum = userValue;
    
    int rateProg = [@(_progressBarDec.progress*_valueMaximum) intValue];
    if (_valueDec == rateProg) {
        return;
    } else {
        _timerDec = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(incrementProgressDec:) userInfo:nil repeats:YES];
    }
}

- (void)incrementProgressDec:(NSTimer *)timer {
    int rate = _valueDec;
    int rateFixMax = _valueMaximum - 1;
    int rateProg = [@(_progressBarDec.progress*rateFixMax) intValue];
    
    if (rate == rateProg) {
        [_timerDec invalidate];
        _timerDec = nil;
    } else {
        _progressBarDec.progress = _progressBarDec.progress + 0.01f;
    }
}


#pragma mark - Progress Bars init

- (ProgressBarView *)progressBarDec {
    if (!_progressBarDec) {
        _progressBarDec = [[ProgressBarView alloc] initWithFrame:CGRectZero];
        _progressBarDec.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _progressBarDec;
}

@end
