//
//  MapPopTip+Entrance.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 04.09.20.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "MapPopTip+Entrance.h"

@implementation MapPopTip (Entrance)

- (void)performEntranceAnimation:(void (^)(void))completion {
    switch (self.entranceAnimation) {
        case MapPopTipEntranceAnimationScale: {
            [self entranceScale:completion];
            break;
        }
        case MapPopTipEntranceAnimationTransition: {
            [self entranceTransition:completion];
            break;
        }
        case MapPopTipEntranceAnimationFadeIn: {
            [self entranceFadeIn:completion];
            break;
        }
        case MapPopTipEntranceAnimationCustom: {
            [self.containerView addSubview:self.backgroundMask];
            [self.containerView addSubview:self];
            if (self.entranceAnimationHandler) {
                self.entranceAnimationHandler(^{
                    completion();
                });
            }
        }
        case MapPopTipEntranceAnimationNone: {
            [self.containerView addSubview:self.backgroundMask];
            [self.containerView addSubview:self];
            completion();
            break;
        }
        default: {
            [self.containerView addSubview:self.backgroundMask];
            [self.containerView addSubview:self];
            completion();
            break;
        }
    }
}

- (void)entranceTransition:(void (^)(void))completion {
    self.transform = CGAffineTransformMakeScale(0.6, 0.6);
    switch (self.direction) {
        case MapPopTipDirectionUp:
            self.transform = CGAffineTransformTranslate(self.transform, 0, -self.fromFrame.origin.y);
            break;
        case MapPopTipDirectionDown:
            self.transform = CGAffineTransformTranslate(self.transform, 0, (self.containerView.frame.size.height - self.fromFrame.origin.y));
            break;
        case MapPopTipDirectionLeft:
            self.transform = CGAffineTransformTranslate(self.transform, -self.fromFrame.origin.x, 0);
            break;
        case MapPopTipDirectionRight:
            self.transform = CGAffineTransformTranslate(self.transform, (self.containerView.frame.size.width - self.fromFrame.origin.x), 0);
            break;
        case MapPopTipDirectionNone:
            self.transform = CGAffineTransformTranslate(self.transform, 0, (self.containerView.frame.size.height - self.fromFrame.origin.y));
            break;

        default:
            break;
    }
    
    [self.containerView addSubview:self.backgroundMask];
    [self.containerView addSubview:self];

    [UIView animateWithDuration:self.animationIn delay:self.delayIn usingSpringWithDamping:0.6 initialSpringVelocity:1.5 options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.transform = CGAffineTransformIdentity;
        self.backgroundMask.alpha = 1.0;
    } completion:^(BOOL completed) {
        if (completed && completion) {
            completion();
        }
    }];
}

- (void)entranceScale:(void (^)(void))completion {
    self.transform = CGAffineTransformMakeScale(0, 0);
    [self.containerView addSubview:self.backgroundMask];
    [self.containerView addSubview:self];

    [UIView animateWithDuration:self.animationIn delay:self.delayIn usingSpringWithDamping:1.0 initialSpringVelocity:1.5 options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.transform = CGAffineTransformIdentity;
        self.backgroundMask.alpha = 1.0;
    } completion:^(BOOL completed) {
        if (completed && completion) {
            completion();
        }
    }];
}

- (void)entranceFadeIn:(void (^)(void))completion {
    [self.containerView addSubview:self.backgroundMask];
    [self.containerView addSubview:self];

    self.alpha = 0.0;
    [UIView animateWithDuration:self.animationIn delay:self.delayIn options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.alpha = 1.0;
        self.backgroundMask.alpha = 1.0;
    } completion:^(BOOL completed) {
        if (completed && completion) {
            completion();
        }
    }];
}

@end
