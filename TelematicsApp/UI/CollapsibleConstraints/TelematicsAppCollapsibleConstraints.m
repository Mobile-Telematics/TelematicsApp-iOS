//
//  TelematicsAppCollapsibleConstraints.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 06.06.20.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "TelematicsAppCollapsibleConstraints.h"
#import <objc/runtime.h>

@implementation NSLayoutConstraint (_FDOriginalConstantStorage)

- (void)setFd_originalConstant:(CGFloat)originalConstant
{
    objc_setAssociatedObject(self, @selector(fd_originalConstant), @(originalConstant), OBJC_ASSOCIATION_RETAIN);
}

- (CGFloat)fd_originalConstant
{
#if CGFLOAT_IS_DOUBLE
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
#else
    return [objc_getAssociatedObject(self, _cmd) floatValue];
#endif
}

@end

@implementation UIView (TelematicsAppCollapsibleConstraints)


#pragma mark - Load

+ (void)load
{
    SEL originalSelector = @selector(setValue:forKey:);
    SEL swizzledSelector = @selector(fd_setValue:forKey:);

    Class class = UIView.class;
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (void)fd_setValue:(id)value forKey:(NSString *)key
{
    NSString *injectedKey = [NSString stringWithUTF8String:sel_getName(@selector(fd_collapsibleConstraints))];
    if ([key isEqualToString:injectedKey]) {
        self.fd_collapsibleConstraints = value;
    } else {
        [self fd_setValue:value forKey:key];
    }
}


#pragma mark - Dynamic Properties

- (void)setFd_collapsed:(BOOL)collapsed
{
    [self.fd_collapsibleConstraints enumerateObjectsUsingBlock:
     ^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop) {
         if (collapsed) {
             constraint.constant = 0;
         } else {
             constraint.constant = constraint.fd_originalConstant;
         } 
     }];

    objc_setAssociatedObject(self, @selector(fd_collapsed), @(collapsed), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)fd_collapsed
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (NSMutableArray *)fd_collapsibleConstraints
{
    NSMutableArray *constraints = objc_getAssociatedObject(self, _cmd);
    if (!constraints) {
        constraints = @[].mutableCopy;
        objc_setAssociatedObject(self, _cmd, constraints, OBJC_ASSOCIATION_RETAIN);
    }
    return constraints;
}

- (void)setFd_collapsibleConstraints:(NSArray *)fd_collapsibleConstraints
{
    NSMutableArray *constraints = (NSMutableArray *)self.fd_collapsibleConstraints;
    
    [fd_collapsibleConstraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop) {
        constraint.fd_originalConstant = constraint.constant;
        [constraints addObject:constraint];
    }];
}

@end

@implementation UIView (FDAutomaticallyCollapseByIntrinsicContentSize)


#pragma mark - Constraints

+ (void)load
{
    SEL originalSelector = @selector(updateConstraints);
    SEL swizzledSelector = @selector(fd_updateConstraints);
    
    Class class = UIView.class;
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (void)fd_updateConstraints
{
    [self fd_updateConstraints];
 
    if (self.fd_autoCollapse && self.fd_collapsibleConstraints.count > 0) {
        
        const CGSize absentIntrinsicContentSize = CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
        const CGSize contentSize = [self intrinsicContentSize];
        
        if (CGSizeEqualToSize(contentSize, absentIntrinsicContentSize) ||
            CGSizeEqualToSize(contentSize, CGSizeZero)) {
            self.fd_collapsed = YES;
        } else {
            self.fd_collapsed = NO;
        }
    }
}


#pragma mark - Dynamic Properties

- (BOOL)fd_autoCollapse
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setFd_autoCollapse:(BOOL)autoCollapse
{
    objc_setAssociatedObject(self, @selector(fd_autoCollapse), @(autoCollapse), OBJC_ASSOCIATION_RETAIN);
}

- (void)setAutoCollapse:(BOOL)collapse
{
    self.fd_autoCollapse = collapse;
}

@end
