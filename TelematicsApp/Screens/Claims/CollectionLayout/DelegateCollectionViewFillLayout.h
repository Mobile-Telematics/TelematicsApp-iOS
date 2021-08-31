//
//  DelegateCollectionViewFillLayout.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.04.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DelegateCollectionViewFillLayoutDirection)
{
    DelegateCollectionViewFillLayoutVertical,
    DelegateCollectionViewFillLayoutHorizontal
};

@protocol DelegateCollectionViewFillLayoutDelegate <NSObject>

@optional

- (NSInteger)numberOfItemsInSide;
- (CGFloat)itemLength;
- (CGFloat)itemSpacing;

@end

@interface DelegateCollectionViewFillLayout : UICollectionViewLayout

@property (assign, nonatomic) NSInteger numberOfItemsInSide;
@property (assign, nonatomic) CGFloat itemLength;
@property (assign, nonatomic) CGFloat itemSpacing;
@property (assign, nonatomic) DelegateCollectionViewFillLayoutDirection direction;
@property (assign, nonatomic) BOOL stretchesLastItems;
@property (nullable, weak, nonatomic) id<DelegateCollectionViewFillLayoutDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
