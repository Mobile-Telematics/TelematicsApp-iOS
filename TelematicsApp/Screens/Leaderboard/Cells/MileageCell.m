//
//  MileageCell.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 13.04.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "MileageCell.h"
#import "UIImageView+WebCache.h"

@interface MileageCell ()

@property (nonatomic) NSTimer *timerMileage;
@property float valueMileage;
@property float valueMaximum;

@end

@implementation MileageCell

@synthesize progressBarMileage = _progressBarMileage;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _progressBarMileage.barFillColor = [Color officialMainAppColor];
    [_progressBarMileage setBarBackgroundColor:[Color lightSeparatorColor]];
}


#pragma mark - Progress Bars Timers

- (void)configMileage:(float)value usersNumber:(float)userValue {
    _valueMileage = userValue - value;
    _valueMaximum = userValue;
    
    int rateProg = [@(_progressBarMileage.progress*_valueMaximum) intValue];
    if (_valueMileage == rateProg) {
        return;
    } else {
        _timerMileage = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(incrementProgressMileage:) userInfo:nil repeats:YES];
    }
}

- (void)incrementProgressMileage:(NSTimer *)timer {
    int rate = _valueMileage;
    int rateFixMax = _valueMaximum - 1;
    int rateProg = [@(_progressBarMileage.progress*rateFixMax) intValue];
    
    if (rate == rateProg) {
        [_timerMileage invalidate];
        _timerMileage = nil;
    } else {
        _progressBarMileage.progress = _progressBarMileage.progress + 0.01f;
    }
}


#pragma mark - Progress Bars init

- (ProgressBarView *)progressBarMileage {
    if (!_progressBarMileage) {
        _progressBarMileage = [[ProgressBarView alloc] initWithFrame:CGRectZero];
        _progressBarMileage.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _progressBarMileage;
}

@end
