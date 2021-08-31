//
//  UITableView+Preloader.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 19.01.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "UITableView+Preloader.h"

static const CGFloat kTablePreloaderHeight = 50.0f;
static const CGFloat kTablePreloaderAnimationDuration = 0.25f;

@implementation UITableView (Preloader)

- (void)showPreloaderAtTop:(BOOL)top {
    UIView* preloader;
    if (top) {
        preloader = self.tableHeaderView;
    } else {
        preloader = self.tableFooterView;
    }
    if (!preloader) {
        preloader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, kTablePreloaderHeight)];
        preloader.backgroundColor = [UIColor clearColor];
        preloader.clipsToBounds = YES;
        preloader.translatesAutoresizingMaskIntoConstraints = YES;
        UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.center = preloader.center;
        indicator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        [preloader addSubview:indicator];
        [indicator startAnimating];
    }
    CGRect fr = preloader.frame;
    fr.size.height = kTablePreloaderHeight;
    preloader.frame = fr;
    if (top) {
        self.tableHeaderView = preloader;
    } else {
        self.tableFooterView = preloader;
    }
}

- (void)hidePreloaderAtTop:(BOOL)top {
    UIView* preloader;
    if (top) {
        preloader = self.tableHeaderView;
    } else {
        preloader = self.tableFooterView;
    }
    [UIView animateWithDuration:kTablePreloaderAnimationDuration animations:^{
        CGRect fr = preloader.frame;
        fr.size.height = 0;
        preloader.frame = fr;
        if (top) {
            self.tableHeaderView = preloader;
        } else {
            self.tableFooterView = preloader;
        }
    }];
}

@end
