//
//  FeedSlideMenuTableViewCell.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 11.09.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "FeedSlideMenuTableViewCell.h"
#import "UITableView+VisibleMenuCell.h"


typedef NS_ENUM(NSInteger, FeedSlideMenuUpdateAction) {
    FeedSlideMenuUpdateShowAction = 1,
    FeedSlideMenuUpdateHideAction = -1
};

typedef NS_ENUM(NSInteger, FeedSlideMenuState) {
    FeedSlideMenuStateHidden = 0,
    FeedSlideMenuStateShowing,
    FeedSlideMenuStateShown,
    FeedSlideMenuStateHiding
};

static CGFloat const kSpringAnimationDuration = .6;
static CGFloat const kAnimationDuration = .26;
static CGFloat const kHighlightAnimationDuration = 0.45;


@interface FeedSlideMenuTableViewCell ()

@property (nonatomic, assign) UITableView *parentTableView;

@property (nonatomic, assign) FeedSlideMenuState rightMenuState;
@property (nonatomic, assign) CGPoint lastGestureLocation;
@property (nonatomic, assign) CGPoint startGestureLocation;
@property (nonatomic, assign) CGFloat prevDistance;
@property (nonatomic, assign) BOOL ongoingSelection;

@end


@implementation FeedSlideMenuTableViewCell {
    CGRect _rightMenuViewInitialFrame;
    UIPanGestureRecognizer *_swipeGesture;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    UIView *view = self.superview;
    
    while (view && [view isKindOfClass:[UITableView class]] == NO) {
        view = view.superview;
    }
    
    self.parentTableView = (UITableView *)view;
}

- (void)willTransitionToState:(UITableViewCellStateMask)state {
    if (state == UITableViewCellStateShowingEditControlMask) {
        if (self.rightMenuState == FeedSlideMenuStateShown || self.rightMenuState == FeedSlideMenuStateShowing) {
            [self updateMenuView:FeedSlideMenuUpdateHideAction animated:YES];
        }
    }
    
    [super willTransitionToState:state];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    FeedSlideMenuTableViewCell *cell = nil;
    if (self.parentTableView.visibleMenuCell) {
        if (selected && (self.rightMenuState == FeedSlideMenuStateShowing || self.rightMenuState == FeedSlideMenuStateShown)) {
            cell = self;
        }
        else {
            cell = self.parentTableView.visibleMenuCell;
        }
        
        [cell updateMenuView:FeedSlideMenuUpdateHideAction animated:YES];
        self.parentTableView.visibleMenuCell = nil;
        
        return;
    }
    
    [super setSelected:selected animated:animated];
    
    if (!selected) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kHighlightAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.ongoingSelection = NO;
        });
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
    CGFloat gestureVelocity = [_swipeGesture velocityInView:self].x;
    if (gestureVelocity)
        return;
    
    if (self.parentTableView.visibleMenuCell)
        return;
    
    if (self.rightMenuState == FeedSlideMenuStateShowing || self.rightMenuState == FeedSlideMenuStateShown)
        return;
    
    if (highlighted)
        self.ongoingSelection = YES;
    
    [super setHighlighted:highlighted animated:animated];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self hideMenu];
    
    self.ongoingSelection = NO;
    self.rightMenuState = FeedSlideMenuStateHidden;
    self.prevDistance = .0;
    self.startGestureLocation = CGPointZero;
    
    [self resetLastGestureLocation];
}

- (void)layoutSubviews {
    if (self.rightMenuState == FeedSlideMenuStateHidden && _rightMenuView) {
        [self hideMenu];
    }
    
    [super layoutSubviews];
}

- (void)setRightMenuView:(UIView *)rightMenuView {
    if (_rightMenuView != rightMenuView) {
        
        [_rightMenuView removeFromSuperview];
        _rightMenuView = rightMenuView;
        _rightMenuViewInitialFrame = _rightMenuView.frame;
        
        [self hideMenu];
        [self.contentView addSubview:_rightMenuView];
    }
}

- (BOOL)showingRightMenu {
    return  self.rightMenuState != FeedSlideMenuStateHidden;
}


#pragma mark UIGestureRecognizerDelegate Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    //return NO;
    if (gestureRecognizer == _swipeGesture) {
        CGPoint velocity = [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:self];
        
        if (self.ongoingSelection)
            return NO;
        
        if (self.editing)
            return NO;
        
        if (self.parentTableView.visibleMenuCell) {
            [self.parentTableView.visibleMenuCell updateMenuView:FeedSlideMenuUpdateHideAction animated:YES];
            self.parentTableView.visibleMenuCell = nil;
            
            if (velocity.x < 0)
                return NO;
        }
        
        BOOL shouldBegin = fabs(velocity.x) > fabs(velocity.y);
        
        return shouldBegin;
    }
    
    return YES;
}


#pragma mark Actions

- (void)handleSwipeGesture:(UIPanGestureRecognizer *)gesture {
    CGFloat initialWidth = CGRectGetWidth(_rightMenuViewInitialFrame);
    FeedSlideMenuUpdateAction direction = [self actionForGesture:gesture];
    CGPoint gestureLocation = [gesture locationInView:self];
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            
            self.prevDistance = .0;
            self.startGestureLocation = [gesture locationInView:self];
            [self resetLastGestureLocation];
            
            direction = [self actionForGesture:gesture];
            
            if (direction == FeedSlideMenuUpdateShowAction) {
                self.rightMenuState = FeedSlideMenuStateShowing;
            }
            else {
                self.rightMenuState = FeedSlideMenuStateHiding;
            }
            
            break;
        }
        case UIGestureRecognizerStateChanged: {
            
            CGFloat totalDistance = self.startGestureLocation.x - gestureLocation.x;
            
            if (totalDistance <= .0) {
                if (direction == FeedSlideMenuUpdateHideAction && self.rightMenuState == FeedSlideMenuStateHidden)
                    totalDistance = .0;
                
                self.startGestureLocation = [gesture locationInView:self];
            }
            
            [self updateMenuView:direction delta:fabs(totalDistance - self.prevDistance) animated:NO completion:nil];
                
            self.prevDistance = totalDistance;
            
            break;
        }
        case UIGestureRecognizerStateCancelled: {
            break;
        }
        case UIGestureRecognizerStateEnded: {
            
            CGFloat deltaX = .0;
            switch (self.rightMenuState) {
                case FeedSlideMenuStateShowing: {
                    deltaX = (direction == FeedSlideMenuUpdateShowAction? initialWidth : 0) - self.prevDistance;
                    break;
                }
                case FeedSlideMenuStateHiding: {
                    deltaX = (direction == FeedSlideMenuUpdateShowAction? 0 : initialWidth) - self.prevDistance;
                    break;
                }
                case FeedSlideMenuStateShown:
                case FeedSlideMenuStateHidden:
                    break;
                    
                default:
                    break;
            }
            
            [self updateMenuView:direction delta:fabs(deltaX) animated:YES completion:nil];
            
            if (direction == FeedSlideMenuUpdateShowAction) {
                self.rightMenuState = FeedSlideMenuStateShown;
                self.parentTableView.visibleMenuCell = self;
            }
            else {
                self.rightMenuState = FeedSlideMenuStateHidden;
            }
            
            break;
        }
            
        default:
            break;
    }
    
    self.lastGestureLocation = gestureLocation;
}


#pragma mark Private Methods

- (void)commonInit {
    self.ongoingSelection = NO;
    self.rightMenuState = FeedSlideMenuStateHidden;
    self.prevDistance = .0;
    self.startGestureLocation = CGPointZero;
    
    [self resetLastGestureLocation];
    
    _swipeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    _swipeGesture.delegate = self;
    [self addGestureRecognizer:_swipeGesture];
}

- (void)resetLastGestureLocation {
    if (self.rightMenuState == FeedSlideMenuStateShown) {
        self.lastGestureLocation = CGPointZero;
    }
    else if (self.rightMenuState == FeedSlideMenuStateHidden) {
        self.lastGestureLocation = CGPointMake(CGRectGetWidth(self.frame), .0);
    }
}

- (void)updateMenuView:(FeedSlideMenuUpdateAction)action animated:(BOOL)animated {
    CGFloat initialWidth = CGRectGetWidth(_rightMenuViewInitialFrame);
    
    if (action == FeedSlideMenuUpdateShowAction) {
        self.rightMenuState = FeedSlideMenuStateShowing;
    }
    else {
        self.rightMenuState = FeedSlideMenuStateHiding;
    }
    
    [self updateMenuView:action delta:initialWidth animated:animated completion:^{
        
        if (action == FeedSlideMenuUpdateShowAction) {
            self.rightMenuState = FeedSlideMenuStateShown;
        }
        else {
            self.rightMenuState = FeedSlideMenuStateHidden;
        }
    }];
}

- (FeedSlideMenuUpdateAction)actionForGesture:(UIPanGestureRecognizer *)gesture {
    static FeedSlideMenuUpdateAction direction = 0;
    CGPoint gestureLocation = [gesture locationInView:self];
    
    if (gestureLocation.x == self.lastGestureLocation.x) {
        
    }
    else if (gestureLocation.x < self.lastGestureLocation.x) {
        direction = FeedSlideMenuUpdateShowAction;
    }
    else {
        direction = FeedSlideMenuUpdateHideAction;
    }
    
    return direction;
}

- (void)updateMenuView:(FeedSlideMenuUpdateAction)action delta:(CGFloat)deltaX animated:(BOOL)animated completion: (void (^)(void))completionHandler {
    CGFloat initialWidth = CGRectGetWidth(_rightMenuViewInitialFrame);
    
    CGFloat newWidth = CGRectGetWidth(_rightMenuView.frame) + action*deltaX;
    CGFloat deltaOffset = initialWidth - newWidth;
    
    [self setNeedsUpdateConstraints];
    [self.parentTableView setNeedsUpdateConstraints];
    
    if (newWidth < 0) {
        deltaX += newWidth;
    }
    else if (deltaOffset < 0) {
        deltaX += deltaOffset;
    }
    
    CGRect menuNewFrame = CGRectMake(CGRectGetMinX(_rightMenuView.frame) - action*deltaX, .0,
                                     CGRectGetWidth(_rightMenuView.frame) + action*deltaX, CGRectGetHeight(self.contentView.frame));
    
    NSMutableArray *subviews = [NSMutableArray array];
    for (UIView *subview in self.contentView.subviews) {
        if (subview == _rightMenuView)
            continue;

        [subviews addObject:subview];
    }
    
    [self layoutIfNeeded];
    
    [UIView animateWithDuration:(animated? kAnimationDuration : .0)
                     animations:^{
                         self->_rightMenuView.frame = menuNewFrame;
                         [self layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         if (completionHandler) {
                             completionHandler();
                         }
                     }];
    
    
    [UIView animateWithDuration:(animated? kSpringAnimationDuration : .0)
                     delay:.0
    usingSpringWithDamping:(action > 0) ? kSpringAnimationDuration : 1.0
     initialSpringVelocity:(action > 0) ? 1.0 : .0
                   options:0
                animations:^{
                    for (UIView *subview in subviews) {
                        subview.frame = CGRectMake(CGRectGetMinX(subview.frame) - action*deltaX, CGRectGetMinY(subview.frame),
                                                   CGRectGetWidth(subview.frame), CGRectGetHeight(subview.frame));
                    }
                }
                completion:^(BOOL finished) {
                    if (completionHandler) {
                        completionHandler();
                    }
                }];
}

- (void)hideMenu {
    _rightMenuView.frame = CGRectMake(CGRectGetWidth(self.contentView.frame), .0, .0, CGRectGetHeight(self.contentView.frame));
}

@end
