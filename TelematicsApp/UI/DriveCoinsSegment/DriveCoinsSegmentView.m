//
//  DriveCoinsSegmentView.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 17.08.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "DriveCoinsSegmentView.h"
#import <QuartzCore/QuartzCore.h>

#define DCS_SEG_BTN_TAG 120
#define DCS_SEG_LINE_TAG 130

@interface DriveCoinsSegmentView() {
    UIScrollView *_scrollView;
    UIColor *_selectColor;
    UIColor *_normalColor;
    UILabel *_line;
    NSInteger _selectIndex;
    UIButton *_originSelectedBtn;
}
@end


@implementation DriveCoinsSegmentView

- (instancetype)initWithItems:(NSArray *)items andNormalFontColor:(UIColor *)normalColor andSelectedColor:(UIColor *)selectedColor andLineColor:(UIColor *)lineColor andFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_scrollView];

        _selectColor = selectedColor == nil ? [UIColor redColor]:selectedColor;
        _normalColor = normalColor == nil ? UIColorFromHex(0x333333):normalColor;
        _selectIndex = 0;
        
        CGFloat width = frame.size.width / items.count;
        if (items.count >3) {
            _scrollView.contentSize = CGSizeMake(width*items.count, _scrollView.bounds.size.height);
        }
        
        UILabel *bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 0.5, frame.size.width, 0.5)];
        bottomLine.backgroundColor = UIColorFromHex(0x939d9e);
        [_scrollView addSubview:bottomLine];
        
        _line = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 3, width, 3)];
        _line.backgroundColor = lineColor == nil ? [UIColor redColor] : lineColor;
        [_scrollView addSubview:_line];
        
        for (int i = 0 ; i < items.count; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            if (IS_IPHONE_5 || IS_IPHONE) {
                btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
            } else {
                btn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
            }
            btn.tag = DCS_SEG_BTN_TAG + i;
            //btn.frame = CGRectMake(i *width, 1, width, frame.size.height - 2);
            btn.frame = CGRectMake(i *width, -5, width, frame.size.height - 2);
            
            if (i == _selectIndex) {
                [btn setAttributedTitle:[[NSAttributedString alloc] initWithString:items[i] attributes:@{NSForegroundColorAttributeName:_selectColor}] forState:UIControlStateNormal];
                CGRect lineFrame=_line.frame;
                lineFrame.origin.x = btn.center.x-(_line.width/2);
                _line.frame = lineFrame;
                _originSelectedBtn = btn;
            } else {
                [btn setAttributedTitle:[[NSAttributedString alloc] initWithString:items[i] attributes:@{NSForegroundColorAttributeName:_normalColor}] forState:UIControlStateNormal];
            }
            
            [btn addTarget:self action:@selector(chooseIndex:) forControlEvents:UIControlEventTouchUpInside];
            [_scrollView addSubview:btn];
        }
    }
    return self;
}


- (instancetype)initWithItemsAndImages:(NSArray *)items andNormalFontColor:(UIColor *)normalColor andSelectedColor:(UIColor *)selectedColor andLineColor:(UIColor *)lineColor andFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_scrollView];
        
        _selectColor = selectedColor == nil ? [UIColor redColor]:selectedColor;
        _normalColor = normalColor == nil ? UIColorFromHex(0x333333):normalColor;
        _selectIndex = 0;
        
        CGFloat width = frame.size.width / items.count;
        if (items.count >3) {
            _scrollView.contentSize = CGSizeMake(width*items.count, _scrollView.bounds.size.height);
        }
        
        UILabel *bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 0.5, frame.size.width, 0.5)];
        bottomLine.backgroundColor = UIColorFromHex(0x939d9e);
        [_scrollView addSubview:bottomLine];
        
        _line = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 3, width, 3)];
        _line.backgroundColor = lineColor == nil ? [UIColor redColor] : lineColor;
        [_scrollView addSubview:_line];
        
        for (int i = 0 ; i < items.count; i++) {
            
            if (i == 0) {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.titleLabel.font = [UIFont boldSystemFontOfSize:10];
                btn.tag = DCS_SEG_BTN_TAG + i;
                btn.frame = CGRectMake(i *width, 1, width, frame.size.height - 2);
                
                if (i == _selectIndex) {
                    [btn setAttributedTitle:[[NSAttributedString alloc] initWithString:items[i] attributes:@{NSForegroundColorAttributeName:_selectColor}] forState:UIControlStateNormal];
                    CGRect lineFrame=_line.frame;
                    lineFrame.origin.x = btn.center.x-(_line.width/2);
                    _line.frame = lineFrame;
                    _originSelectedBtn = btn;
                    
                } else {
                    [btn setAttributedTitle:[[NSAttributedString alloc] initWithString:items[i] attributes:@{NSForegroundColorAttributeName:_normalColor}] forState:UIControlStateNormal];
                }
                
                [btn addTarget:self action:@selector(chooseIndexWithImages:) forControlEvents:UIControlEventTouchUpInside];
                [_scrollView addSubview:btn];
                
            } else {
                
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.titleLabel.font = [UIFont boldSystemFontOfSize:10];
                btn.tag = DCS_SEG_BTN_TAG + i;
                btn.frame = CGRectMake(i *width, 1, width, frame.size.height - 2);
                
                if (i == _selectIndex) {
                    [btn setAttributedTitle:[[NSAttributedString alloc] initWithString:items[i] attributes:@{NSForegroundColorAttributeName:_selectColor}] forState:UIControlStateNormal];
                    CGRect lineFrame=_line.frame;
                    lineFrame.origin.x = btn.center.x-(_line.width/2);
                    _line.frame = lineFrame;
                    _originSelectedBtn = btn;
                    
                } else {
                    [[btn imageView] setContentMode: UIViewContentModeScaleAspectFit];
                    [btn setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 0)];
                    [btn setImage:[UIImage imageNamed:items[i]] forState:UIControlStateNormal];
                }
                
                [btn addTarget:self action:@selector(chooseIndexWithImages:) forControlEvents:UIControlEventTouchUpInside];
                [_scrollView addSubview:btn];
            }
        }
    }
    return self;
}


#pragma mark - DriveCoins Segment

- (void)chooseIndex:(UIButton *)btn
{
    NSInteger index = btn.tag - DCS_SEG_BTN_TAG;
    if (index == _selectIndex) {
        return;
    }
    
    [btn setAttributedTitle:[[NSAttributedString alloc] initWithString:btn.titleLabel.text attributes:@{NSForegroundColorAttributeName:_selectColor}]  forState:UIControlStateNormal];
    [_originSelectedBtn setAttributedTitle:[[NSAttributedString alloc] initWithString:_originSelectedBtn.titleLabel.text attributes:@{NSForegroundColorAttributeName:_normalColor}]  forState:UIControlStateNormal];
    
    [UIView animateWithDuration:0.1 animations:^{
        self->_scrollView.userInteractionEnabled = NO;
        self->_originSelectedBtn = btn;
        CGRect lineFrame = self->_line.frame;
        lineFrame.origin.x = btn.center.x-(self->_line.width/2);
        self->_line.frame = lineFrame;
        
    } completion:^(BOOL finished){
        self->_scrollView.userInteractionEnabled = YES;
        self->_selectIndex = index;
    }];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(segmentDriveCoinsChose:)]) {
        [self.delegate segmentDriveCoinsChose:index];
    }
}


- (void)chooseIndexWithImages:(UIButton *)btn
{
    NSInteger index = btn.tag - DCS_SEG_BTN_TAG;
    if (index == _selectIndex) {
        return;
    }
    
    if (index == 0 && _selectIndex != 1 && _selectIndex != 2 && _selectIndex != 3) {
        [btn setAttributedTitle:[[NSAttributedString alloc] initWithString:btn.titleLabel.text attributes:@{NSForegroundColorAttributeName:_selectColor}]  forState:UIControlStateNormal];
        [_originSelectedBtn setAttributedTitle:[[NSAttributedString alloc] initWithString:_originSelectedBtn.titleLabel.text attributes:@{NSForegroundColorAttributeName:_normalColor}]  forState:UIControlStateNormal];
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        self->_scrollView.userInteractionEnabled = NO;
        self->_originSelectedBtn = btn;
        CGRect lineFrame = self->_line.frame;
        lineFrame.origin.x = btn.center.x-(self->_line.width/2);
        self->_line.frame = lineFrame;
        
    } completion:^(BOOL finished){
        self->_scrollView.userInteractionEnabled = YES;
        self->_selectIndex = index;
    }];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(segmentDriveCoinsChose:)]) {
        [self.delegate segmentDriveCoinsChose:index];
    }
}

- (void)setSelectedIndex:(NSInteger)index
{
    UIButton *btn=(UIButton *)[self viewWithTag:DCS_SEG_BTN_TAG+index];
    
    if (index>=5) {
        NSInteger num=index/5;
        
        _scrollView.contentOffset=CGPointMake(num*_scrollView.bounds.size.width, 0);
    } else {
        _scrollView.contentOffset=CGPointMake(0, 0);
    }
    
    [self chooseIndexWithImages:btn];
}

@end
