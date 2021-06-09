//
//  FeedSlideCellMenuView.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 11.09.18.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
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

- (IBAction)shareBtnPressed:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(cellMenuViewShareBtnTapped:)])
        [_delegate cellMenuViewShareBtnTapped:self];
}

- (IBAction)deleteBtnPressed:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(cellMenuViewDeleteBtnTapped:)])
        [_delegate cellMenuViewDeleteBtnTapped:self];
}

- (IBAction)flagBtnPressed:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(cellMenuViewFlagBtnTapped:)])
        [_delegate cellMenuViewFlagBtnTapped:self];
}

@end
