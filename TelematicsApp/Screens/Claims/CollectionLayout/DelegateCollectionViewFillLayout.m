//
//  DelegateCollectionViewFillLayout.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.04.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "DelegateCollectionViewFillLayout.h"

@interface DelegateCollectionViewFillLayout ()

@property (readonly, nonatomic) NSInteger numberOfItemsInCollectionView;
@property (assign, nonatomic) CGSize contentSize;
@property (copy, nonatomic) NSIndexSet *extraIndexes;
@property (copy, nonatomic) NSArray *itemAttributes;
@property (readonly, weak, nonatomic) NSNotificationCenter *notificationCenter;

- (void)setup;
- (void)setupDefaults;
- (void)prepareVerticalLayout;
- (void)prepareHorizontalLayout;

@end

@implementation DelegateCollectionViewFillLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - Setup

- (void)setup
{
    [self setupDefaults];
    [self listenForOrientationChanges];
}

- (void)setupDefaults
{
    self.numberOfItemsInSide = 1;
    self.itemSpacing = 2.0f;
    self.direction = DelegateCollectionViewFillLayoutVertical;
    self.stretchesLastItems = YES;
}

#pragma mark - Orientation

- (void)listenForOrientationChanges
{
    [self.notificationCenter addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)orientationDidChange:(NSNotification *)note
{
    [self invalidateLayout];
}

- (void)dealloc
{
    [self.notificationCenter removeObserver:self];
}

- (NSNotificationCenter *)notificationCenter
{
    return [NSNotificationCenter defaultCenter];
}

#pragma mark - Overrides

- (void)prepareLayout
{
    [super prepareLayout];
  
    if ([_delegate respondsToSelector:@selector(numberOfItemsInSide)])
    {
        _numberOfItemsInSide = [_delegate numberOfItemsInSide];
    }
    if ([_delegate respondsToSelector:@selector(itemLength)])
        NSAssert(_numberOfItemsInSide > 0, @"Collection view must have at least one item in row. Set 'numberOfItemsInSide'.");
  
    if ([_delegate respondsToSelector:@selector(itemLength)])
    {
        _itemLength = [_delegate itemLength];
    }
    if ([_delegate respondsToSelector:@selector(itemSpacing)])
    {
        _itemSpacing = [_delegate itemSpacing];
    }
  
    _itemAttributes = nil;
    _extraIndexes = nil;
    _contentSize = CGSizeZero;
  
    NSInteger numberOfItems = self.numberOfItemsInCollectionView;
    NSInteger extraItems = numberOfItems % _numberOfItemsInSide;
  
    if (extraItems > 0)
    {
        NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
        for (int i=0; i<extraItems; i++)
        {
            NSInteger idx = (numberOfItems - 1) - i;
            [indexes addIndex:idx];
        }
        _extraIndexes = indexes;
    }
  
    if (_direction == DelegateCollectionViewFillLayoutVertical) {
        [self prepareVerticalLayout];
    }
    else {
        [self prepareHorizontalLayout];
    }
}

- (void)prepareVerticalLayout
{
    CGFloat xOffset = _itemSpacing;
    CGFloat yOffset = _itemSpacing;
    CGFloat rowHeight = 0.0f;
    CGFloat contentWidth = 0.0f;
    CGFloat contentHeight = 0.0f;
    NSUInteger column = 0;
    NSInteger numberOfItems = self.numberOfItemsInCollectionView;
    NSMutableArray *layoutAttributes = [[NSMutableArray alloc] init];
  
    for (int i = 0; i < numberOfItems; i++)
    {
        CGFloat itemWidth = 0.0f;
    
        if (_stretchesLastItems && _extraIndexes.count && [_extraIndexes containsIndex:i])
        {
            CGFloat availableSpaceForItems = self.collectionView.bounds.size.width - (2 * _itemSpacing) - ((_extraIndexes.count - 1) * _itemSpacing);
            itemWidth = availableSpaceForItems / _extraIndexes.count;
        }
        else
        {
            CGFloat availableSpaceForItems = self.collectionView.bounds.size.width - (2 * _itemSpacing) - ((_numberOfItemsInSide - 1) * _itemSpacing);
            itemWidth = availableSpaceForItems / _numberOfItemsInSide;
        }
    
        if (!_itemLength) {
            _itemLength = itemWidth;
        }
        CGSize itemSize = CGSizeMake(itemWidth, _itemLength);
    
        if (itemSize.height > rowHeight) {
            rowHeight = itemSize.height;
        }
    
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.frame = CGRectIntegral(CGRectMake(xOffset, yOffset, itemSize.width, itemSize.height));
        [layoutAttributes addObject:attributes];
    
        xOffset = xOffset + itemSize.width + _itemSpacing;
        column++;
    
        if ((numberOfItems < _numberOfItemsInSide && column == numberOfItems) ||
            (column == _numberOfItemsInSide))
        {
            if (xOffset > contentWidth) {
                contentWidth = xOffset;
            }
      
            column = 0;
            xOffset = _itemSpacing;
            yOffset += rowHeight + _itemSpacing;
        }
    
        UICollectionViewLayoutAttributes *lastAttributes = layoutAttributes.lastObject;
        contentHeight = lastAttributes.frame.origin.y + lastAttributes.frame.size.height;
        _contentSize = CGSizeMake(contentWidth, contentHeight + _itemSpacing);
        _itemAttributes = [NSArray arrayWithArray:layoutAttributes];
    }
}

- (void)prepareHorizontalLayout
{
    CGFloat xOffset = _itemSpacing;
    CGFloat yOffset = _itemSpacing;
    CGFloat columnWidth = 0.0f;
    CGFloat contentWidth = 0.0f;
    CGFloat contentHeight = 0.0f;
    NSUInteger row = 0;
    NSInteger numberOfItems = self.numberOfItemsInCollectionView;
    NSMutableArray *layoutAttributes = [[NSMutableArray alloc] init];
  
    for (int i = 0; i < numberOfItems; i++)
    {
        CGFloat itemHeight = 0.0f;
    
        if (_stretchesLastItems && _extraIndexes.count && [_extraIndexes containsIndex:i])
        {
            CGFloat availableSpaceForItems = self.collectionView.bounds.size.height - (2 * _itemSpacing) - ((_extraIndexes.count - 1) * _itemSpacing);
            itemHeight = availableSpaceForItems / _extraIndexes.count;
        }
        else
        {
            CGFloat availableSpaceForItems = self.collectionView.bounds.size.height - (2 * _itemSpacing) - ((_numberOfItemsInSide - 1) * _itemSpacing);
            itemHeight = availableSpaceForItems / _numberOfItemsInSide;
        }
    
        if (!_itemLength) {
            _itemLength = itemHeight;
        }
        CGSize itemSize = CGSizeMake(_itemLength, itemHeight);
    
        if (itemSize.width > columnWidth) {
            columnWidth = itemSize.width;
        }
    
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.frame = CGRectIntegral(CGRectMake(xOffset, yOffset, itemSize.width, itemSize.height));
        [layoutAttributes addObject:attributes];
    
        yOffset = yOffset + itemSize.height + _itemSpacing;
        row++;
    
        if ((numberOfItems < _numberOfItemsInSide && row == numberOfItems) ||
            (row == _numberOfItemsInSide))
        {
            if (xOffset > contentWidth) {
                contentWidth = xOffset;
            }
      
            row = 0;
            yOffset = _itemSpacing;
            xOffset += columnWidth + _itemSpacing;
        }
    
        UICollectionViewLayoutAttributes *lastAttributes = layoutAttributes.lastObject;
        contentWidth = lastAttributes.frame.origin.x + lastAttributes.frame.size.width;
        _contentSize = CGSizeMake(contentWidth + _itemSpacing, contentHeight);
        _itemAttributes = [NSArray arrayWithArray:layoutAttributes];
    }
}

#pragma mark - Property getters

- (NSInteger)numberOfItemsInCollectionView
{
    return [self.collectionView numberOfItemsInSection:0];
}

- (CGSize)collectionViewContentSize
{
    return _contentSize;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return _itemAttributes[indexPath.row];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
  NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *evaluatedObject, NSDictionary *bindings)
                                {
                                    return CGRectIntersectsRect(rect, evaluatedObject.frame);
                                }];
    return [_itemAttributes filteredArrayUsingPredicate:predicate];
}

#pragma mark - Property setters

- (void)setNumberOfItemsInSide:(NSInteger)numberOfItemsInSide
{
    if (_numberOfItemsInSide != numberOfItemsInSide)
    {
        _numberOfItemsInSide = numberOfItemsInSide;
        [self invalidateLayout];
    }
}

- (void)setItemLength:(CGFloat)itemLength
{
    if (_itemLength != itemLength)
    {
        _itemLength = itemLength;
        [self invalidateLayout];
    }
}

- (void)setItemSpacing:(CGFloat)itemSpacing
{
    if (_itemSpacing != itemSpacing)
    {
        _itemSpacing = itemSpacing;
        [self invalidateLayout];
    }
}

- (void)setDirection:(DelegateCollectionViewFillLayoutDirection)direction
{
    if (_direction != direction)
    {
        _direction = direction;
        [self invalidateLayout];
    }
}

@end
