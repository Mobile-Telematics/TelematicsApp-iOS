//
//  MapPopTip.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 04.09.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MapPopTipDirection) {
    MapPopTipDirectionUp,
    MapPopTipDirectionDown,
    MapPopTipDirectionLeft,
    MapPopTipDirectionRight,
    MapPopTipDirectionNone
};

typedef NS_ENUM(NSInteger, MapPopTipEntranceAnimation) {
    MapPopTipEntranceAnimationScale,
    MapPopTipEntranceAnimationTransition,
    MapPopTipEntranceAnimationFadeIn,
    MapPopTipEntranceAnimationNone,
    MapPopTipEntranceAnimationCustom
};


typedef NS_ENUM(NSInteger, MapPopTipExitAnimation) {
    MapPopTipExitAnimationScale,
    MapPopTipExitAnimationFadeOut,
    MapPopTipExitAnimationNone,
    MapPopTipExitAnimationCustom
};


typedef NS_ENUM(NSInteger, MapPopTipActionAnimation) {
    MapPopTipActionAnimationBounce,
    MapPopTipActionAnimationFloat,
    MapPopTipActionAnimationPulse,
    MapPopTipActionAnimationNone
};


@interface MapPopTip : UIView

+ (nonnull instancetype)popTip;
- (void)showText:(nonnull NSString *)text direction:(MapPopTipDirection)direction maxWidth:(CGFloat)maxWidth inView:(nonnull UIView *)view fromFrame:(CGRect)frame;
- (void)showAttributedText:(nonnull NSAttributedString *)text direction:(MapPopTipDirection)direction maxWidth:(CGFloat)maxWidth inView:(nonnull UIView *)view fromFrame:(CGRect)frame;
- (void)showCustomView:(nonnull UIView *)customView direction:(MapPopTipDirection)direction inView:(nonnull UIView *)view fromFrame:(CGRect)frame;
- (void)showText:(nonnull NSString *)text direction:(MapPopTipDirection)direction maxWidth:(CGFloat)maxWidth inView:(nonnull UIView *)view fromFrame:(CGRect)frame duration:(NSTimeInterval)interval;
- (void)showAttributedText:(nonnull NSAttributedString *)text direction:(MapPopTipDirection)direction maxWidth:(CGFloat)maxWidth inView:(nonnull UIView *)view fromFrame:(CGRect)frame duration:(NSTimeInterval)interval;
- (void)showCustomView:(nonnull UIView *)customView direction:(MapPopTipDirection)direction inView:(nonnull UIView *)view fromFrame:(CGRect)frame duration:(NSTimeInterval)interval;
- (void)hide;
- (void)hideForced:(BOOL)forced;
- (void)updateText:(nonnull NSString *)text;
- (void)updateAttributedText:(nonnull NSAttributedString *)text;
- (void)updateCustomView:(nonnull UIView *)view;
- (void)startActionAnimation;
- (void)stopActionAnimation;


NS_ASSUME_NONNULL_BEGIN
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) NSTextAlignment textAlignment UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *popoverColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *borderColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat borderWidth UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat radius UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign, getter=isRounded) BOOL rounded UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat offset UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat padding UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) UIEdgeInsets edgeInsets UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGSize arrowSize UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) NSTimeInterval animationIn UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) NSTimeInterval animationOut UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) NSTimeInterval delayIn UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) NSTimeInterval delayOut UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) MapPopTipEntranceAnimation entranceAnimation UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) MapPopTipExitAnimation exitAnimation UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) MapPopTipActionAnimation actionAnimation UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat actionFloatOffset UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat actionBounceOffset UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat actionPulseOffset UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) NSTimeInterval actionAnimationIn UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) NSTimeInterval actionAnimationOut UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) NSTimeInterval actionDelayIn UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) NSTimeInterval actionDelayOut UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat edgeMargin UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat bubbleOffset UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *maskColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) BOOL shouldShowMask UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGRect fromFrame;
@property (nonatomic, assign, readonly) BOOL isVisible;
@property (nonatomic, assign, readonly) BOOL isAnimating;
@property (nonatomic, assign) BOOL shouldDismissOnTap;
@property (nonatomic, assign) BOOL shouldDismissOnTapOutside;
@property (nonatomic, assign) BOOL shouldDismissOnSwipeOutside;
@property (nonatomic, assign) UISwipeGestureRecognizerDirection swipeRemoveGestureDirection;
NS_ASSUME_NONNULL_END


@property (nonatomic, copy) void (^_Nullable wrongEventTapHandler)(void);

@property (nonatomic, copy) void (^_Nullable tapHandler)(void);
@property (nonatomic, copy) void (^_Nullable appearHandler)(void);
@property (nonatomic, copy) void (^_Nullable dismissHandler)(void);
@property (nonatomic, copy) void (^_Nullable entranceAnimationHandler)(void (^_Nonnull completion)(void));
@property (nonatomic, copy) void (^_Nullable exitAnimationHandler)(void (^_Nonnull completion)(void));
@property (nonatomic, readonly) CGPoint arrowPosition;
@property (nonatomic, weak, readonly) UIView *_Nullable containerView;
@property (nonatomic, assign, readonly) MapPopTipDirection direction;
@property (nullable, nonatomic, strong, readonly) UIView *backgroundMask;

@end
