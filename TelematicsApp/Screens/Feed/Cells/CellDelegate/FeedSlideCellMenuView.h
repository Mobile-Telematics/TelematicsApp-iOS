//
//  FeedSlideCellMenuView.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 11.09.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;
#import "UIView+XIB.h"

@protocol FeedSlideCellMenuViewDelegate;

@interface FeedSlideCellMenuView : UIView

@property (nonatomic, assign) id<FeedSlideCellMenuViewDelegate> delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;

@end


@protocol FeedSlideCellMenuViewDelegate <NSObject>

@optional

- (void)cellMenuViewShareBtnTapped:(FeedSlideCellMenuView *)menuView;
- (void)cellMenuViewDeleteBtnTapped:(FeedSlideCellMenuView *)menuView;

- (void)cellMenuViewFlagBtnTapped:(FeedSlideCellMenuView *)menuView;

@end
