//
//  MapPopTip+Exit.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 04.09.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "MapPopTip+Exit.h"

@implementation MapPopTip (Exit)

- (void)performExitAnimation:(void (^)(void))completion {
    switch (self.exitAnimation) {
        case MapPopTipExitAnimationScale: {
            [self exitScale:completion];
            break;
        }
        case MapPopTipExitAnimationFadeOut: {
            [self exitFadeOut:completion];
            break;
        }
        case MapPopTipExitAnimationCustom: {
            [self.containerView addSubview:self];
            if (self.exitAnimationHandler) {
                self.exitAnimationHandler(^{
                    if (completion) {
                        completion();
                    }
                });
            }
            break;
        }
        case MapPopTipExitAnimationNone: {
            [self.containerView addSubview:self];
            if (completion) {
                completion();
            }
            break;
        }
        default: {
            [self.containerView addSubview:self];
            if (completion) {
                completion();
            }
            break;
        }
    }
}

- (void)exitScale:(void (^)(void))completion {
    self.transform = CGAffineTransformIdentity;
    
    [UIView animateWithDuration:self.animationOut delay:self.delayOut options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.transform = CGAffineTransformMakeScale(0.000001, 0.000001);
        self.backgroundMask.alpha = 0;
    } completion:^(BOOL completed){
        if (completed && completion) {
            completion();
        }
    }];
}

- (void)exitFadeOut:(void (^)(void))completion {
    self.alpha = 1.0;
    [UIView animateWithDuration:self.animationOut delay:self.delayOut options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.alpha = 0.0;
        self.backgroundMask.alpha = 0;
    } completion:^(BOOL completed){
        if (completed && completion) {
            completion();
        }
    }];
}

@end
