//
//  ProgressBarView.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 16.01.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;

@interface ProgressBarView: UIView

@property (nonatomic) CGFloat progress;
@property (nonatomic) CGFloat barBorderWidth UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *barBorderColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat barInnerBorderWidth UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *barInnerBorderColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat barInnerPadding UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *barFillColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *barBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) NSInteger usesRoundedCorners UI_APPEARANCE_SELECTOR;

+ (UIColor *)defaultBarColor;

@end
