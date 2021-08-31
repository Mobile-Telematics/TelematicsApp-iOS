//
//  PhoneCell.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 13.04.20.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "PhoneCell.h"
#import "UIImageView+WebCache.h"

@interface PhoneCell ()

@property (nonatomic) NSTimer *timerPhone;
@property float valuePhone;
@property float valueMaximum;

@end

@implementation PhoneCell

@synthesize progressBarPhone = _progressBarPhone;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _progressBarPhone.barFillColor = [Color officialMainAppColor];
    [_progressBarPhone setBarBackgroundColor:[Color lightSeparatorColor]];
}


#pragma mark - Progress Bars Timers

- (void)configPhone:(float)value usersNumber:(float)userValue {
    _valuePhone = userValue - value;
    _valueMaximum = userValue;
    
    int rateProg = [@(_progressBarPhone.progress*_valueMaximum) intValue];
    if (_valuePhone == rateProg) {
        return;
    } else {
        _timerPhone = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(incrementProgressPhone:) userInfo:nil repeats:YES];
    }
}

- (void)incrementProgressPhone:(NSTimer *)timer {
    int rate = _valuePhone;
    int rateFixMax = _valueMaximum - 1;
    int rateProg = [@(_progressBarPhone.progress*rateFixMax) intValue];
    
    if (rate == rateProg) {
        [_timerPhone invalidate];
        _timerPhone = nil;
    } else {
        _progressBarPhone.progress = _progressBarPhone.progress + 0.01f;
    }
}


#pragma mark - Progress Bars init

- (ProgressBarView *)progressBarPhone {
    if (!_progressBarPhone) {
        _progressBarPhone = [[ProgressBarView alloc] initWithFrame:CGRectZero];
        _progressBarPhone.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _progressBarPhone;
}

@end
