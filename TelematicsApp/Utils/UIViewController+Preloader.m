//
//  UIViewController+Preloader.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 09.01.18.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "UIViewController+Preloader.h"
#import <objc/runtime.h>

#define kPreloaderKey @"preloaderKey"
#define kActivityKey @"activityKey"

#define kKbIsShownKey @"kbIsShownKey"
#define kDontHideKbKey @"dontHideKbKey"

#define kShiftHeightKey @"shiftHeightKey"

#define kLocationViewKey @"locationViewKey"


@implementation UIViewController (Preloader)
@dynamic preloader;
@dynamic activity;
@dynamic kbIsShown;
@dynamic dontHideKb;
@dynamic shiftHeight;

- (void)showPreloader {
    if (self.navigationController) {
        [self.navigationController showPreloader];
        return;
    }
    
    if (!self.preloader) {
        if (self.navigationController) {
            self.preloader = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
        } else {
            self.preloader = [[UIView alloc] initWithFrame:self.view.bounds];
        }
        self.preloader.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7];
        self.preloader.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 56, 56)];
        self.activity.transform = CGAffineTransformMakeScale(1.25f, 1.25f);
        self.activity.color = [Color whiteSpinnerColor];
        self.activity.center = CGPointMake(self.preloader.frame.size.width/2, self.preloader.frame.size.height/2);
        self.activity.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    }
    
    if (self.navigationController) {
        self.preloader.frame = self.navigationController.view.bounds;
    } else {
        self.preloader.frame = self.view.bounds;
    }
    
    self.activity.center = self.preloader.center;
    [self.preloader addSubview:self.activity];
    [self.activity startAnimating];
    [self.view addSubview:self.preloader];
}

- (void)hidePreloader {
    if (self.navigationController) {
        [self.navigationController hidePreloader];
        return;
    }
    [self.activity stopAnimating];
    [self.activity removeFromSuperview];
    [self.preloader removeFromSuperview];
}

- (void)setPreloader:(UIView *)preloader {
	objc_setAssociatedObject(self, kPreloaderKey, preloader, OBJC_ASSOCIATION_RETAIN);
}

- (UIView *)preloader {
	return objc_getAssociatedObject(self, kPreloaderKey);
}

- (void)setActivity:(UIActivityIndicatorView *)activity {
	objc_setAssociatedObject(self, kActivityKey, activity, OBJC_ASSOCIATION_RETAIN);
}

- (UIActivityIndicatorView *)activity {
    return objc_getAssociatedObject(self, kActivityKey);
}

- (BOOL)kbIsShown {
    return [objc_getAssociatedObject(self, kKbIsShownKey) boolValue];
}

- (BOOL)dontHideKb {
    return [objc_getAssociatedObject(self, kDontHideKbKey) boolValue];
}

- (void)setKbIsShown:(BOOL)kbIsShown {
    objc_setAssociatedObject(self, kKbIsShownKey, [NSNumber numberWithBool:kbIsShown], OBJC_ASSOCIATION_RETAIN);
}

- (void)setDontHideKb:(BOOL)dontHideKb {
    objc_setAssociatedObject(self, kDontHideKbKey, [NSNumber numberWithBool:dontHideKb], OBJC_ASSOCIATION_RETAIN);
}

- (int)shiftHeight {
    return [objc_getAssociatedObject(self, kShiftHeightKey) intValue];
}

- (void)setShiftHeight:(int)shiftHeight {
    objc_setAssociatedObject(self, kShiftHeightKey, [NSNumber numberWithInt:shiftHeight], OBJC_ASSOCIATION_RETAIN);
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    if (self.shiftHeight == -1) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textfieldBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textviewBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
    }
}

- (void)textfieldBeginEditing:(NSNotification*)aNotification {
    [self updatePosition];
}

- (void)textviewBeginEditing:(NSNotification*)aNotification {
    [self updatePosition];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    if (!self.kbIsShown) {
        return;
    }
    if (!self.dontHideKb) {
        NSDictionary *keyboardAnimationDetail = [aNotification userInfo];
        UIViewAnimationCurve animationCurve = [keyboardAnimationDetail[UIKeyboardAnimationCurveUserInfoKey] integerValue];
        [UIView animateWithDuration:self.dontHideKb ? 0 : kShiftAnimationDuration delay:0 options:(animationCurve << 16) animations:^{
            self.view.bounds = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        } completion:nil];
    }
    self.kbIsShown = NO;
}

- (UIView*)currentFirstResponder {
    return [self currentFirstResponderInView:self.view];
}

- (UIView*)currentFirstResponderInView:(UIView*)v {
    for (UIView *view in v.subviews) {
        if (view.isFirstResponder) {
            return view;
        } else {
            UIView* inner = [self currentFirstResponderInView:view];
            if (inner) {
                return inner;
            } 
        }
    }
    return nil;
}

static int lastHeight;
static int kbHeight;

- (void)updatePosition {
    if (self.shiftHeight == -1) {
        int height = 0;
        UIView* responder = [self currentFirstResponder];
        if (responder) {
            CGRect responderRect = [self.view convertRect:responder.frame fromView:responder.superview];
            height = (responderRect.origin.y + responderRect.size.height)- (self.view.frame.size.height - kbHeight)  ;
            height = MAX(0, height);
        } else {
            height = self.shiftHeight;
        }
        [UIView animateWithDuration:kShiftAnimationDuration animations:^{
            self.view.bounds = CGRectMake(0, height, self.view.bounds.size.width, self.view.bounds.size.height);
        }];
    }
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
    int height = self.shiftHeight;
    if (self.shiftHeight == -1) {
        NSDictionary* d = [aNotification userInfo];
        CGRect r = [d[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        r = [self.view convertRect:r fromView:nil];
        kbHeight = r.size.height;
        
        UIView* responder = [self currentFirstResponder];
        if (responder) {
            CGRect responderRect = [self.view convertRect:responder.frame fromView:responder.superview];
            height = (responderRect.origin.y + responderRect.size.height)- (self.view.frame.size.height - r.size.height)  ;
            height = MAX(0, height);
        } else {
            height = self.shiftHeight;
        }
    }
    
    if (self.kbIsShown && lastHeight == height) {
        lastHeight = height;
        return;
    }
    NSDictionary *keyboardAnimationDetail = [aNotification userInfo];
    UIViewAnimationCurve animationCurve = [keyboardAnimationDetail[UIKeyboardAnimationCurveUserInfoKey] integerValue];

    if (!self.dontHideKb) {
        [UIView animateWithDuration:kShiftAnimationDuration delay:0 options:(animationCurve << 16) animations:^{
            self.view.bounds = CGRectMake(0, height, self.view.bounds.size.width, self.view.bounds.size.height);
        } completion:nil];
    }
    lastHeight = height;
    self.dontHideKb = NO;
    self.kbIsShown = YES;
}

@end
