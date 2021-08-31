//
//  MapPopTip+Draw.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 04.09.20.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "MapPopTip.h"

@interface MapPopTip (Draw)

- (nonnull UIBezierPath *)pathWithRect:(CGRect)rect direction:(MapPopTipDirection)direction;

@end
