//
//  TelematicsAppCollapsibleConstraints.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 06.06.20.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;


@interface UIView (TelematicsAppCollapsibleConstraints)

@property (nonatomic, assign) BOOL fd_collapsed;
@property (nonatomic, copy) IBOutletCollection(NSLayoutConstraint) NSArray *fd_collapsibleConstraints;

@end


@interface UIView (FDAutomaticallyCollapseByIntrinsicContentSize)

@property (nonatomic, assign) BOOL fd_autoCollapse;
@property (nonatomic, assign, getter=fd_autoCollapse) IBInspectable BOOL autoCollapse;

@end
