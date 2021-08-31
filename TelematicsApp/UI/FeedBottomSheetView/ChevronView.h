//
//  ChevronView.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 10.06.20.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ChevronViewState) {
    ChevronViewStateUp = -1,
    ChevronViewStateFlat = 0,
    ChevronViewStateDown = 1
};

@interface ChevronView: UIView

@property (nonatomic, assign) ChevronViewState state;
@property (nonatomic, strong, null_resettable) UIColor *color;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) NSTimeInterval animationDuration;

- (void)setState:(ChevronViewState)state animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
