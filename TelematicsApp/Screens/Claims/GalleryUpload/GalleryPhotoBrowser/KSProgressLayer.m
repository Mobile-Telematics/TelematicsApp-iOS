//
//  KSProgressLayer.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 28.06.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "KSProgressLayer.h"

@interface KSProgressLayer ()<CAAnimationDelegate>

@property (nonatomic, assign) BOOL isSpinning;

@end

@implementation KSProgressLayer

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        self.frame = frame;
        self.cornerRadius = 20;
        self.fillColor = [UIColor clearColor].CGColor;
        self.strokeColor = [Color officialWhiteColor].CGColor;
        self.lineWidth = 4;
        self.lineCap = kCALineCapRound;
        self.strokeStart = 0;
        self.strokeEnd = 0.01;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, 2, 2) cornerRadius:20-2];
        self.path = path.CGPath;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if (self.isSpinning) {
        [self startSpin];
    }
}

- (void)startSpin {
    self.isSpinning = YES;
    [self spinWithAngle:M_PI];
}

- (void)spinWithAngle:(CGFloat)angle {
    self.strokeEnd = 0.33;
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = @(M_PI-0.5);
    rotationAnimation.duration = 0.4;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE;
    [self addAnimation:rotationAnimation forKey:nil];
}

- (void)stopSpin {
    self.isSpinning = NO;
    [self removeAllAnimations];
}

@end
