//
//  UIView+parentViewController.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 12.12.18.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "UIView+parentViewController.h"

@implementation UIView (parentViewController)

- (UIViewController *)parentViewController
{
    UIResponder *parentResponder = self;
    while (parentResponder) {
        parentResponder = [parentResponder nextResponder];
        if ([parentResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)parentResponder;
        }
    }
    return nil;
}

@end
