//
//  SpecialActionSheet.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 24.05.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;

typedef NS_ENUM(NSInteger, SpecialActionSheetStyle) {
    SpecialActionSheetStyleLight,
    SpecialActionSheetStyleDark
};

typedef NS_ENUM(NSInteger, ZenActionSheetContentStyle) {
    ZenActionSheetContentStyleDefault,
    ZenActionSheetContentStyleLeft,
    ZenActionSheetContentStyleRight
};

@interface SpecialActionSheet : UIView


@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, assign) SpecialActionSheetStyle style UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) ZenActionSheetContentStyle contentstyle;
@property (nonatomic, assign) CGFloat dimmingViewAlpha UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat maximumCompactWidth;
@property (nonatomic, copy) NSString *cancelButtonTitle;
@property (nonatomic, copy) void (^actionSheetDismissedBlock)(void);
@property (nonatomic, copy) void (^cancelButtonTappedBlock)(void);
@property (nonatomic, strong) UIFont *buttonFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *cancelButtonFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *buttonBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *buttonTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *buttonTappedBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *buttonTappedTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *buttonSeparatorColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *cancelButtonBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *cancelButtonTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *cancelButtonTappedBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *cancelButtonTappedTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *destructiveButtonBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *destructiveButtonTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *destructiveButtonTappedBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *destructiveButtonTappedTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *headerBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *titleColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *titleFont UI_APPEARANCE_SELECTOR;

- (instancetype)initWithStyle:(SpecialActionSheetStyle)style;
- (instancetype)initWithTitle:(NSString *)title;
- (instancetype)initWithHeaderView:(UIView *)headerView;

- (void)addButtonWithTitle:(NSString *)title icon:(UIImage *)icon tappedBlock:(void (^)(void))tappedBlock;
- (void)addButtonWithTitle:(NSString *)title tappedBlock:(void (^)(void))tappedBlock;
- (void)addButtonWithTitle:(NSString *)title atIndex:(NSInteger)index tappedBlock:(void (^)(void))tappedBlock;
- (void)removeButtonAtIndex:(NSInteger)index;

- (void)addDestructiveButtonWithTitle:(NSString *)title tappedBlock:(void (^)(void))tappedBlock;
- (void)addDestructiveButtonWithTitle:(NSString *)title icon:(UIImage *)icon tappedBlock:(void (^)(void))tappedBlock;
- (void)removeDestructiveButton;

- (void)showFromRect:(CGRect)rect inView:(UIView *)view;
- (void)showFromView:(UIView *)fromView inView:(UIView *)view;
- (void)showFromBarButtonItem:(UIBarButtonItem *)barButtonItem inView:(UIView *)view;

@end
