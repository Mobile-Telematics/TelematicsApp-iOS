//
//  GearLoadingView.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 12.06.20.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "GearLoadingView.h"

@interface GearLoadingView ()

@property (nonatomic, strong) UIImageView *imgGear1;
@property (nonatomic, strong) UIImageView *imgGear2;
@property (nonatomic, strong) UIImageView *imgGear3;
@property (nonatomic) BOOL removeFromSuperViewOnHide;

@end

@implementation GearLoadingView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initItem];
    }
    return self;
}

- (void)initItem
{
    self.imgGear1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gears_1"]];
    [self.imgGear1 setContentMode:UIViewContentModeCenter];
    [self.imgGear1 setCenter:CGPointMake(CGRectGetWidth(self.frame)/2 - 50, CGRectGetHeight(self.frame)/2+20)];
    //self.imgGear1.alpha = 0.8;
    [self addSubview:self.imgGear1];
    
    self.imgGear2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gears_2"]];
    [self.imgGear2 setCenter:CGPointMake(CGRectGetWidth(self.frame)/2 - 9, CGRectGetHeight(self.frame)/2-45)];
    [self.imgGear2 setContentMode:UIViewContentModeCenter];
    //self.imgGear2.alpha = 0.8;
    [self addSubview:self.imgGear2];
    
    self.imgGear3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gears_3"]];
    [self.imgGear3 setCenter:CGPointMake(CGRectGetWidth(self.frame)/2 + 48, CGRectGetHeight(self.frame)/2-20)];
    [self.imgGear3 setContentMode:UIViewContentModeCenter];
    //self.imgGear3.alpha = 0.8;
    [self addSubview:self.imgGear3];
    
//    UIImageView *imgBgView = [[UIImageView alloc] initWithFrame:self.frame];
//    [imgBgView setImage:[UIImage imageNamed:@"background.png"]];
//    [self addSubview:imgBgView];
//    imgBgView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    
    [self runSpinAnimationWithDuration:8 withView:self.imgGear1 withValue:10];
    [self runSpinAnimationWithDuration:8 withView:self.imgGear2 withValue:-18];
    [self runSpinAnimationWithDuration:8 withView:self.imgGear3 withValue:15];
}

- (void)runSpinAnimationWithDuration:(CGFloat) duration withView:(UIView *)view withValue:(float)value;
{
    [CATransaction begin];
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.byValue = [NSNumber numberWithFloat:value];
    rotationAnimation.duration = duration;
    rotationAnimation.fromValue = 0;
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI*2];
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fillMode = kCAFillModeForwards;
    rotationAnimation.autoreverses = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    [CATransaction commit];
}

- (id)initWithView:(UIView *)view {
    //return [self initWithFrame:view.bounds]; //original full screen disabled
    return [self initWithFrame:CGRectMake(0, view.frame.size.height/4, view.frame.size.width, view.frame.size.height/2)];
}

+ (instancetype)showGearLoadingForView:(UIView *)view {
    GearLoadingView *gear = [[self alloc] initWithView:view];
    [gear setAlpha:0];
    //gear.backgroundColor = [UIColor redColor]; //test
    [view addSubview:gear];
    [gear showViewWithAnimate:YES];
    return nil;
}

+ (BOOL)hideGearLoadingForView:(UIView *)view {
    GearLoadingView *gearLoading = [self gearLoadingForView:view];
    if (gearLoading != nil) {
        [gearLoading hideViewWithAnimate:YES];
        gearLoading = nil;
        gearLoading.imgGear1 = nil;
        gearLoading.imgGear2 = nil;
        gearLoading.imgGear3 = nil;
        return YES;
    }
    return NO;
}

+ (instancetype)gearLoadingForView:(UIView *)view {
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:self]) {
            return (GearLoadingView *)subview;
        }
    }
    return nil;
}

- (void)showViewWithAnimate:(BOOL)animate
{
    [UIView animateWithDuration:0.3 animations:^{
        [self setAlpha:1];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideViewWithAnimate:(BOOL)animate
{
    [UIView animateWithDuration:0.3 animations:^{
        [self setAlpha:0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
