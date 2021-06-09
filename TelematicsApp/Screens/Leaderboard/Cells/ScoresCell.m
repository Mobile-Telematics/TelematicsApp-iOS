//
//  ScoresCell.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 07.04.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ScoresCell.h"
#import "UIImageView+WebCache.h"

@interface ScoresCell ()

@property (nonatomic) NSTimer *timerAccel;
@property (nonatomic) NSTimer *timerDecel;
@property (nonatomic) NSTimer *timerSpeed;
@property (nonatomic) NSTimer *timerPhone;
@property (nonatomic) NSTimer *timerCorner;
@property (nonatomic) NSTimer *timerTrips;
@property (nonatomic) NSTimer *timerMileage;
@property (nonatomic) NSTimer *timerTime;

@property float valueAccel;
@property float valueDecel;
@property float valueSpeed;
@property float valuePhone;
@property float valueCorner;
@property float valueTrips;
@property float valueMileage;
@property float valueTime;

@property float valueAccelMax;
@property float valueDecelMax;
@property float valueSpeedMax;
@property float valuePhoneMax;
@property float valueCornerMax;
@property float valueTripsMax;
@property float valueMileageMax;
@property float valueTimeMax;

@end

@implementation ScoresCell

@synthesize progressBarOBDView = _progressBarOBDView;

- (void)awakeFromNib {
    [super awakeFromNib];
    _progressBarOBDView.barFillColor = [Color officialGreenColor];
    [_progressBarOBDView setBarBackgroundColor:[Color lightSeparatorColor]];
}

- (void)setLeaderScore:(LeaderboardResultResponse *)leaderScore {
    _valueAccel = leaderScore.UsersNumber.floatValue - leaderScore.AccelerationPlace.floatValue;
    _valueAccelMax = leaderScore.UsersNumber.floatValue;
    
    int rateProg = [@(_progressBarOBDView.progress*_valueAccelMax) intValue];
    if (_valueAccel == rateProg) {
        [_positionLbl countFrom:leaderScore.AccelerationPlace.floatValue to:leaderScore.AccelerationPlace.floatValue];
        [_timerAccel invalidate];
        _timerAccel = nil;
        //_timerAccel = [NSTimer scheduledTimerWithTimeInterval:11.02 target:self selector:@selector(incrementProgressAccel:) userInfo:nil repeats:YES];
        return;
    } else {
        [_positionLbl countFrom:0 to:leaderScore.AccelerationPlace.floatValue];
        if (_timerAccel == nil) {
            _timerAccel = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(incrementProgressAccel:) userInfo:nil repeats:YES];
            _timerAccel.tolerance = 0.1;
        }
    }
}


#pragma mark - Progress Bars Timers

- (void)configAccel:(float)value usersNumber:(float)userValue {
    _valueAccel = userValue - value;
    _valueAccelMax = userValue;
    
    //[_positionLbl countFrom:0 to:value];
    
    int rateProg = [@(_progressBarOBDView.progress*_valueAccelMax) intValue];
    if (_valueAccel == rateProg) {
        [_positionLbl countFrom:value to:value];
        [_timerAccel invalidate];
        _timerAccel = nil;
        //_timerAccel = [NSTimer scheduledTimerWithTimeInterval:11.02 target:self selector:@selector(incrementProgressAccel:) userInfo:nil repeats:YES];
        return;
    } else {
        [_positionLbl countFrom:0 to:value];
        if (_timerAccel == nil) {
            _timerAccel = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(incrementProgressAccel:) userInfo:nil repeats:YES];
        }
    }
}

- (void)configDecel:(float)value usersNumber:(float)userValue {
    _valueDecel = userValue - value;
    _valueDecelMax = userValue;
    
    int rateProg = [@(_progressBarOBDView.progress*_valueDecelMax) intValue];
    if (_valueDecel == rateProg) {
        [_timerDecel invalidate];
        _timerDecel = nil;
        return;
    } else {
        _timerDecel = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(incrementProgressDecel:) userInfo:nil repeats:YES];
    }
}

- (void)configSpeed:(float)value usersNumber:(float)userValue {
    _valueSpeed = userValue - value;
    _valueSpeedMax = userValue;
    
    int rateProg = [@(_progressBarOBDView.progress*_valueSpeedMax) intValue];
    if (_valueSpeed == rateProg) {
        [_timerSpeed invalidate];
        _timerSpeed = nil;
        return;
    } else {
        _timerSpeed = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(incrementProgressSpeed:) userInfo:nil repeats:YES];
    }
}

- (void)configPhone:(float)value usersNumber:(float)userValue {
    _valuePhone = userValue - value;
    _valuePhoneMax = userValue;
    
    int rateProg = [@(_progressBarOBDView.progress*_valuePhoneMax) intValue];
    if (_valuePhone == rateProg) {
        [_timerPhone invalidate];
        _timerPhone = nil;
        return;
    } else {
        _timerPhone = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(incrementProgressPhone:) userInfo:nil repeats:YES];
    }
}

- (void)configCorner:(float)value usersNumber:(float)userValue {
    _valueCorner = userValue - value;
    _valueCornerMax = userValue;
    
    int rateProg = [@(_progressBarOBDView.progress*_valueCornerMax) intValue];
    if (_valueCorner == rateProg) {
        [_timerCorner invalidate];
        _timerCorner = nil;
        return;
    } else {
        _timerCorner = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(incrementProgressCorner:) userInfo:nil repeats:YES];
    }
}

- (void)configTrips:(float)value usersNumber:(float)userValue {
    _valueTrips = userValue - value;
    _valueTripsMax = userValue;
    
    int rateProg = [@(_progressBarOBDView.progress*_valueTripsMax) intValue];
    if (_valueTrips == rateProg) {
        [_timerTrips invalidate];
        _timerTrips = nil;
        return;
    } else {
        _timerTrips = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(incrementProgressTrips:) userInfo:nil repeats:YES];
    }
}

- (void)configMileage:(float)value usersNumber:(float)userValue {
    _valueMileage = userValue - value;
    _valueMileageMax = userValue;
    
    int rateProg = [@(_progressBarOBDView.progress*_valueMileageMax) intValue];
    if (_valueMileage == rateProg) {
        [_timerMileage invalidate];
        _timerMileage = nil;
        return;
    } else {
        _timerMileage = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(incrementProgressMileage:) userInfo:nil repeats:YES];
    }
}

- (void)configTime:(float)value usersNumber:(float)userValue {
    _valueTime = userValue - value;
    _valueTimeMax = userValue;
    
    int rateProg = [@(_progressBarOBDView.progress*_valueTimeMax) intValue];
    if (_valueTime == rateProg) {
        [_timerTime invalidate];
        _timerTime = nil;
        return;
    } else {
        _timerTime = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(incrementProgressTime:) userInfo:nil repeats:YES];
    }
}


#pragma mark - Increment Timers

- (void)incrementProgressAccel:(NSTimer *)timer {
    int rate = _valueAccel;
    int rateProg = [@(_progressBarOBDView.progress*_valueAccelMax) intValue];
    if (rate == rateProg) {
        [_timerAccel invalidate];
        _timerAccel = nil;
    } else {
        _progressBarOBDView.progress = _progressBarOBDView.progress + 0.01f;
    }
}

- (void)incrementProgressDecel:(NSTimer *)timer {
    int rate = _valueDecel;
    int rateProg = [@(_progressBarOBDView.progress*_valueDecelMax) intValue];
    if (rate == rateProg) {
        [_timerDecel invalidate];
        _timerDecel = nil;
    } else {
        _progressBarOBDView.progress = _progressBarOBDView.progress + 0.01f;
    }
}

- (void)incrementProgressSpeed:(NSTimer *)timer {
    int rate = _valueSpeed;
    int rateProg = [@(_progressBarOBDView.progress*_valueSpeedMax) intValue];
    if (rate == rateProg) {
        [_timerSpeed invalidate];
        _timerSpeed = nil;
    } else {
        _progressBarOBDView.progress = _progressBarOBDView.progress + 0.01f;
    }
}

- (void)incrementProgressPhone:(NSTimer *)timer {
    int rate = _valuePhone;
    int rateProg = [@(_progressBarOBDView.progress*_valuePhoneMax) intValue];
    if (rate == rateProg) {
        [_timerPhone invalidate];
        _timerPhone = nil;
    } else {
        _progressBarOBDView.progress = _progressBarOBDView.progress + 0.01f;
    }
}

- (void)incrementProgressCorner:(NSTimer *)timer {
    int rate = _valueCorner;
    int rateProg = [@(_progressBarOBDView.progress*_valueCornerMax) intValue];
    if (rate == rateProg) {
        [_timerCorner invalidate];
        _timerCorner = nil;
    } else {
        _progressBarOBDView.progress = _progressBarOBDView.progress + 0.01f;
    }
}

- (void)incrementProgressTrips:(NSTimer *)timer {
    int rate = _valueTrips;
    int rateProg = [@(_progressBarOBDView.progress*_valueTripsMax) intValue];
    if (rate == rateProg) {
        [_timerTrips invalidate];
        _timerTrips = nil;
    } else {
        _progressBarOBDView.progress = _progressBarOBDView.progress + 0.01f;
    }
}

- (void)incrementProgressMileage:(NSTimer *)timer {
    int rate = _valueMileage;
    int rateProg = [@(_progressBarOBDView.progress*_valueMileageMax) intValue];
    if (rate == rateProg) {
        [_timerMileage invalidate];
        _timerMileage = nil;
    } else {
        _progressBarOBDView.progress = _progressBarOBDView.progress + 0.01f;
    }
}

- (void)incrementProgressTime:(NSTimer *)timer {
    int rate = _valueTime;
    int rateProg = [@(_progressBarOBDView.progress*_valueTimeMax) intValue];
    if (rate == rateProg) {
        [_timerTime invalidate];
        _timerTime = nil;
    } else {
        _progressBarOBDView.progress = _progressBarOBDView.progress + 0.01f;
    }
}


#pragma mark - Progress Bars init

- (ProgressBarView *)_progressBarOBDView {
    if (!_progressBarOBDView) {
        _progressBarOBDView = [[ProgressBarView alloc] initWithFrame:CGRectZero];
        _progressBarOBDView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _progressBarOBDView;
}

@end
