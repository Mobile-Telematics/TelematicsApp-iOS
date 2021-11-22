//
//  ChevronView.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 21.11.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ChevronView.h"
#import "Color.h"

static const CGFloat ChevronDefaultWidth = 4.67;
static const CGFloat ChevronAngleCoefficient = 20.5714286;
static const NSTimeInterval ChevronDELAY_IMMEDIATELY_03_SEC = 0.3;

IB_DESIGNABLE
@interface ChevronView (Inspectable)

@property (nonatomic, assign) IBInspectable NSInteger chevronState;
@property (nonatomic, strong, null_resettable) IBInspectable UIColor * color;
@property (nonatomic, assign) IBInspectable CGFloat width;

@end

@interface ChevronView()

@property UIView * leftView;
@property UIView * rightView;
@property ChevronViewState pendingState;

@end

@implementation ChevronView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self commonInit];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self commonInit];
    return self;
}

- (void)commonInit
{
    self.color = [UIColor lightGrayColor];
    self.width = ChevronDefaultWidth;
    self.animationDuration = ChevronDELAY_IMMEDIATELY_03_SEC;
    
    self.userInteractionEnabled = NO;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.bounds.size.width == 0 || self.bounds.size.height == 0) {
        
        return;
    }
    
    if (self.leftView == nil) {
        
        self.leftView = [[UIView alloc] initWithFrame:CGRectZero];
        self.leftView.backgroundColor = self.color;
        self.rightView = [[UIView alloc] initWithFrame:CGRectZero];
        self.rightView.backgroundColor = self.color;
        
        [self addSubview:self.leftView];
        [self addSubview:self.rightView];
    }
    
    CGRect leftFrame, rightFrame;
    CGRectDivide(self.bounds, &leftFrame, &rightFrame, self.bounds.size.width * 0.5, CGRectMinXEdge);
    rightFrame.size.height = leftFrame.size.height = self.width;
    
    CGFloat angle = self.bounds.size.height / self.bounds.size.width * ChevronAngleCoefficient;
    CGFloat dx = leftFrame.size.width * (1 - cos(angle * M_PI / 180.0)) / 2.0;
    
    leftFrame = CGRectOffset(leftFrame, self.width / 2 + dx - 0.75, 0.0);
    rightFrame = CGRectOffset(rightFrame, -(self.width / 2) - dx + 0.75, 0.0);
    
    self.leftView.bounds = leftFrame;
    self.rightView.bounds = rightFrame;
    self.leftView.center = CGPointMake(CGRectGetMidX(leftFrame), CGRectGetMidY(self.bounds));
    self.rightView.center = CGPointMake(CGRectGetMidX(rightFrame), CGRectGetMidY(self.bounds));
    
    self.leftView.layer.cornerRadius = self.width / 2.0;
    self.rightView.layer.cornerRadius = self.width / 2.0;
    
    if (self.pendingState != ChevronViewStateFlat)
    {
        [self setState:self.pendingState];
        self.pendingState = ChevronViewStateFlat;
    }
}

- (void)setChevronState:(NSInteger)state
{
    [self setState:state];
}

- (void)setState:(ChevronViewState)state
{
    [self setState:state animated:NO];
}

- (void)setState:(ChevronViewState)state animated:(BOOL)animated
{
    if (state > ChevronViewStateDown) {
        state = ChevronViewStateDown;
    }
    
    if (state < ChevronViewStateUp) {
        state = ChevronViewStateUp;
    }
    
    if (state == _state) {
        return;
    }
    
    if (self.leftView == nil) {
        self.pendingState = state;
        return;
    }
    
    _state = state;
    
    CGFloat angle = self.bounds.size.height / self.bounds.size.width * ChevronAngleCoefficient;
    void (^transition)(void) = ^{
        self.leftView.transform = CGAffineTransformMakeRotation(-state * angle * M_PI / 180.0);
        self.rightView.transform = CGAffineTransformMakeRotation(state * angle * M_PI / 180.0);
    };
    
    if (animated == NO) {
        [UIView performWithoutAnimation:transition];
    } else {
        [UIView animateWithDuration:_animationDuration animations:transition];
    }
}

- (void)setColor:(UIColor *)color
{
    if (color == nil) {
        color = [UIColor lightGrayColor];
    }
    
    _color = color;
    
    self.leftView.backgroundColor = color;
    self.rightView.backgroundColor = color;
}

- (void)setWidth:(CGFloat)width
{
    _width = width;
    [self setNeedsLayout];
}

@end
