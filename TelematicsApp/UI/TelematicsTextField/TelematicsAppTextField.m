//
//  TelematicsAppTextField.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 26.12.18.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "TelematicsAppTextField.h"

@interface TelematicsAppTextField () <UITextFieldDelegate>

@property (nonatomic, strong) UIButton *leftBtnView;
@property (nonatomic, strong) UIView *bottomLine;

@end

@implementation TelematicsAppTextField


- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit{
    
    self.leftViewMode = UITextFieldViewModeAlways;
    self.rightViewMode = UITextFieldViewModeAlways;
    self.returnKeyType = UIReturnKeyDone;
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.delegate = self;
    self.separateLineWith = 1.0;
    
}

- (UIView *)bottomLine {
    
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = _colorNormal;
        _bottomLine.frame = CGRectMake(0, CGRectGetHeight(self.bounds)-self.separateLineWith, CGRectGetWidth(self.bounds), self.separateLineWith);
        _bottomLine.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    }
    return _bottomLine;
}

- (UIButton *)leftBtnView {
    if (!_leftBtnView) {
        _leftBtnView = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftBtnView.showsTouchWhenHighlighted = NO;
    }
    return _leftBtnView;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (_showHighlightedEditing) {
        [self performSelector:@selector(changeEditStatus:) withObject:@(YES) afterDelay:0.1];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (_showHighlightedEditing) {
        [self performSelector:@selector(changeEditStatus:) withObject:@(NO) afterDelay:0.1];
    }
}

- (void)changeEditStatus:(id)obj{
    
    if ([obj boolValue]) {
        
        if (_leftBtnView) {
            _leftBtnView.selected = YES;
        }
        if (_bottomLine) {
            _bottomLine.backgroundColor = _colorHighlight;
        }
        if (_showBoundLine) {
            self.layer.borderColor = _colorHighlight.CGColor;
        }
        
    } else {
        
        if (_leftBtnView) {
            _leftBtnView.selected = NO;
        }
        if (_bottomLine) {
            _bottomLine.backgroundColor = _colorNormal;
        }
        if (_showBoundLine) {
            self.layer.borderColor = _colorNormal.CGColor;
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (self.shouldChangeBlock) {
        return self.shouldChangeBlock(textField, range, string);
    }
    return YES;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    if (self.rightView) {
        CGRect rightFrame = self.rightView.frame;
        return CGRectMake(bounds.size.width - rightFrame.size.width, 0, rightFrame.size.width, bounds.size.height);
    }
    return CGRectZero;
}


- (void)setLeftIconNormal:(UIImage *)leftIconNormal {
    _leftIconNormal = leftIconNormal;
    
    if (@available(iOS 13.0, *)) {
        UIView *iconView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
        [iconView setBackgroundColor:[UIColor clearColor]];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:leftIconNormal];
        [imageView setFrame:CGRectMake(0.f, 0.0f, 26.0f, 26.0f)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [iconView addSubview:imageView];
        
        self.leftView = iconView;
        
    } else {
        [self.leftBtnView setFrame:CGRectMake(0.f, 0.0f, 26.0f, 26.0f)];
        [self.leftBtnView setImage:leftIconNormal forState:UIControlStateNormal];
        
        self.leftView = self.leftBtnView;
    }
}

- (void)setLeftIconHighlight:(UIImage *)leftIconHighlight {
    _leftIconHighlight = leftIconHighlight;
    
    [self.leftBtnView setImage:_leftIconHighlight forState:UIControlStateSelected];
}

- (void)setLeftTitleNormal:(NSString *)leftTitleNormal {
    _leftTitleNormal = leftTitleNormal;
    [self.leftBtnView setTitle:leftTitleNormal forState:UIControlStateNormal];
    [self.leftBtnView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.leftBtnView sizeToFit];
    self.leftView = self.leftBtnView;
}


- (void)setLeftTitleHighlight:(NSString *)leftTitleHighlight {
    _leftTitleHighlight = leftTitleHighlight;
    [self.leftBtnView setTitle:leftTitleHighlight forState:UIControlStateSelected];
}


- (void)setFont:(UIFont *)font {
    [super setFont:font];
    self.leftBtnView.titleLabel.font = font;
}

- (void)setColorNormal:(UIColor *)colorNormal {
    _colorNormal = colorNormal;
    _bottomLine.backgroundColor = colorNormal;
}

- (void)setColorHighlight:(UIColor *)colorHighlight {
    _colorHighlight = colorHighlight;
    [self setTintColor:colorHighlight];
}

- (void)setShowBottomLine:(BOOL)showBottomLine {
    _showBottomLine = showBottomLine;
    if (_showBottomLine) {
        [self addSubview:self.bottomLine];
    }
}

- (void)setShowBoundLine:(BOOL)showBoundLine {
    _showBoundLine = showBoundLine;
    if (_showBoundLine) {
        self.layer.borderWidth = _separateLineWith;
        self.layer.masksToBounds = YES;
        self.layer.borderColor = _colorNormal.CGColor;
    }
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    
    CGRect rect = [super textRectForBounds:bounds];
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 10, 0, 0);
    return UIEdgeInsetsInsetRect(rect, insets);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    
    CGRect rect = [super textRectForBounds:bounds];
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 10, 0, 0);
    return UIEdgeInsetsInsetRect(rect, insets);
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    CGRect rect = [super leftViewRectForBounds:bounds];
    if (_showBoundLine) {
        UIEdgeInsets insets = UIEdgeInsetsMake(0, 10, 0, -10);
        return UIEdgeInsetsInsetRect(rect, insets);
    }
    return rect;
}

@end

