//
//  MapPopTip+Animation.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 04.09.20.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "MapPopTip+Animation.h"
#import <objc/runtime.h>

@implementation MapPopTip (Animation)

- (void)setShouldBounce:(BOOL)shouldBounce { objc_setAssociatedObject(self, @selector(shouldBounce), [NSNumber numberWithBool:shouldBounce], OBJC_ASSOCIATION_RETAIN);}
- (BOOL)shouldBounce { return [objc_getAssociatedObject(self, @selector(shouldBounce)) boolValue]; }

- (void)performActionAnimation {
    switch (self.actionAnimation) {
        case MapPopTipActionAnimationBounce:
            self.shouldBounce = YES;
            [self bounceAnimation];
            break;
        case MapPopTipActionAnimationFloat:
            [self floatAnimation];
            break;
        case MapPopTipActionAnimationPulse:
            [self pulseAnimation];
            break;
        case MapPopTipActionAnimationNone:
            return;
            break;
        default:
            break;
    }
}

- (void)floatAnimation {
    CGFloat xOffset = 0;
    CGFloat yOffset = 0;
    switch (self.direction) {
        case MapPopTipDirectionUp:
            yOffset = -self.actionFloatOffset;
            break;
        case MapPopTipDirectionDown:
            yOffset = self.actionFloatOffset;
            break;
        case MapPopTipDirectionLeft:
            xOffset = -self.actionFloatOffset;
            break;
        case MapPopTipDirectionRight:
            xOffset = self.actionFloatOffset;
            break;
        case MapPopTipDirectionNone:
            yOffset = -self.actionFloatOffset;
            break;
    }

    [UIView animateWithDuration:(self.actionAnimationIn / 2) delay:self.actionDelayIn options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionAllowUserInteraction) animations:^{
        self.transform = CGAffineTransformMakeTranslation(xOffset, yOffset);
    } completion:nil];
}

- (void)bounceAnimation {
    CGFloat xOffset = 0;
    CGFloat yOffset = 0;
    switch (self.direction) {
        case MapPopTipDirectionUp:
            yOffset = -self.actionBounceOffset;
            break;
        case MapPopTipDirectionDown:
            yOffset = self.actionBounceOffset;
            break;
        case MapPopTipDirectionLeft:
            xOffset = -self.actionBounceOffset;
            break;
        case MapPopTipDirectionRight:
            xOffset = self.actionBounceOffset;
            break;
        case MapPopTipDirectionNone:
            yOffset = -self.actionBounceOffset;
            break;
    }

    [UIView animateWithDuration:(self.actionAnimationIn / 10) delay:self.actionDelayIn options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction) animations:^{
        self.transform = CGAffineTransformMakeTranslation(xOffset, yOffset);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:(self.actionAnimationIn - self.actionAnimationIn / 10) delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:1 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:^(BOOL done) {
            if (self.shouldBounce && done) {
                [self bounceAnimation];
            }
        }];
    }];
}

- (void)pulseAnimation {
    [UIView animateWithDuration:(self.actionAnimationIn / 2) delay:self.actionDelayIn options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionAllowUserInteraction) animations:^{
        self.transform = CGAffineTransformMakeScale(self.actionPulseOffset, self.actionPulseOffset);
    } completion:nil];
}

- (void)dismissActionAnimation {
    self.shouldBounce = NO;
    [UIView animateWithDuration:(self.actionAnimationOut / 2) delay:self.actionDelayOut options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self.layer removeAllAnimations];
    }];
}

@end
