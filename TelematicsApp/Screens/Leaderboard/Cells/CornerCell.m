//
//  CornerCell.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 13.04.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "CornerCell.h"
#import "UIImageView+WebCache.h"

@interface CornerCell ()

@property (nonatomic) NSTimer *timerCorner;
@property float valueCorner;
@property float valueMaximum;

@end

@implementation CornerCell

@synthesize progressBarCorner = _progressBarCorner;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _progressBarCorner.barFillColor = [Color officialMainAppColor];
    [_progressBarCorner setBarBackgroundColor:[Color lightSeparatorColor]];
}


#pragma mark - Progress Bars Timers

- (void)configCorner:(float)value usersNumber:(float)userValue {
    _valueCorner = userValue - value;
    _valueMaximum = userValue;
    
    int rateProg = [@(_progressBarCorner.progress*_valueMaximum) intValue];
    if (_valueCorner == rateProg) {
        return;
    } else {
        _timerCorner = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(incrementProgressCorner:) userInfo:nil repeats:YES];
    }
}

- (void)incrementProgressCorner:(NSTimer *)timer {
    int rate = _valueCorner;
    int rateFixMax = _valueMaximum - 1;
    int rateProg = [@(_progressBarCorner.progress*rateFixMax) intValue];
    
    if (rate == rateProg) {
        [_timerCorner invalidate];
        _timerCorner = nil;
    } else {
        _progressBarCorner.progress = _progressBarCorner.progress + 0.01f;
    }
}


#pragma mark - Progress Bars init

- (ProgressBarView *)progressBarCorner {
    if (!_progressBarCorner) {
        _progressBarCorner = [[ProgressBarView alloc] initWithFrame:CGRectZero];
        _progressBarCorner.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _progressBarCorner;
}

@end
