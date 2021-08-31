//
//  UITableView+VisibleMenuCell.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 11.09.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "UITableView+VisibleMenuCell.h"
#import <objc/runtime.h>

@implementation UITableView (VisibleMenuCell)

@dynamic visibleMenuCell;

- (void)setVisibleMenuCell:(FeedSlideMenuTableViewCell *)visibleMenuCell {
    objc_setAssociatedObject(self, @selector(visibleMenuCell), visibleMenuCell, OBJC_ASSOCIATION_ASSIGN);
}

- (FeedSlideMenuTableViewCell *)visibleMenuCell {
    return objc_getAssociatedObject(self, @selector(visibleMenuCell));
}

@end
