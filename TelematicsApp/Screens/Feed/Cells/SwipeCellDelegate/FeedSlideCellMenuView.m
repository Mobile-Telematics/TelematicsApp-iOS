//
//  FeedSlideCellMenuView.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 11.09.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "FeedSlideCellMenuView.h"

@implementation FeedSlideCellMenuView {
    IBOutlet UIButton *deleteButton;
    IBOutlet UIButton *flagButton;
    IBOutlet UIButton *moreButton;
}

- (void)awakeFromNib {    
    [super awakeFromNib];
}


#pragma mark Actions

- (IBAction)hideBtnPressed:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(cellMenuViewHideTripBtnTapped:)])
        [_delegate cellMenuViewHideTripBtnTapped:self];
}

- (IBAction)deleteBtnPressed:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(cellMenuViewDeleteBtnTapped:)])
        [_delegate cellMenuViewDeleteBtnTapped:self];
}

- (IBAction)shareBtnPressed:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(cellMenuViewShareBtnTapped:)])
        [_delegate cellMenuViewShareBtnTapped:self];
}

@end
