//
//  DriveCoinsSegmentView.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 17.08.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;
#import "UIView+Extension.h"

@protocol DriveCoinsSegmentViewDelegate <NSObject>

- (void)segmentDriveCoinsChose:(NSInteger)index;

@end

@interface DriveCoinsSegmentView : UIView

@property (nonatomic,weak) id<DriveCoinsSegmentViewDelegate> delegate;

- (instancetype)initWithItems:(NSArray *)items andNormalFontColor:(UIColor *)normalColor andSelectedColor:(UIColor *)selectedColor andLineColor:(UIColor *)lineColor andFrame:(CGRect)frame;
- (instancetype)initWithItemsAndImages:(NSArray *)items andNormalFontColor:(UIColor *)normalColor andSelectedColor:(UIColor *)selectedColor andLineColor:(UIColor *)lineColor andFrame:(CGRect)frame;
- (void)setSelectedIndex:(NSInteger)index;

@end
