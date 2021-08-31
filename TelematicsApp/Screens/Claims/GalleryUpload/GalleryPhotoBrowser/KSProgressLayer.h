//
//  KSProgressLayer.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 28.06.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSProgressLayer : CAShapeLayer

- (instancetype)initWithFrame:(CGRect)frame;
- (void)startSpin; 
- (void)stopSpin;

@end

NS_ASSUME_NONNULL_END
