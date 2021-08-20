//
//  ZRTextFieldFloat.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 25.01.20.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//


#import "TelematicsAppTextFieldFloat.h"

@implementation TelematicsAppTextFieldFloat


#pragma mark - Drawing Methods

- (void)drawRect:(CGRect)rect {
    [self updateTextField:CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(rect), CGRectGetHeight(rect))];
}


#pragma mark - Initialization Methods

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialization];
}

- (instancetype)init {
    if (self) {
        self = [super init];
        [self initialization];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self) {
        self = [super initWithFrame:frame];
        [self initialization];
    }
    return self;
}


#pragma mark - Drawing Text Rect

- (CGRect)textRectForBounds:(CGRect)bounds {
    float xpos = 4.0;
    if (self.leftimage != nil)
    {
        xpos = 35;
    }
    return CGRectMake(xpos, 4, bounds.size.width, bounds.size.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    
    float xpos = 4.0;
    if (self.leftimage != nil)
    {
        xpos = 35;
    }
    
    return CGRectMake(xpos, 4, bounds.size.width, bounds.size.height);
}

- (void)setText:(NSString *)text {
    [super setText:text];
    if (text) {
        [self floatTheLabel];
    }
    if (showingError) {
        [self hideErrorPlaceHolder];
    }
}

- (void)setPlaceholder:(NSString *)placeholder {
    [super setPlaceholder:placeholder];
    if (![placeholder isEqualToString:@""]) {
        self.labelPlaceholder.text = placeholder;
    }
    
}

- (void)setErrorText:(NSString *)errorText {
    _errorText = errorText;
    self.labelErrorPlaceholder.text = errorText;
}


- (void)initialization {
    
    self.clipsToBounds = true;
    
    if (_placeHolderColor == nil) {
        _placeHolderColor = [UIColor lightGrayColor];
    }
    
    if (_selectedPlaceHolderColor == nil) {
        _selectedPlaceHolderColor = [UIColor colorWithRed:19/256.0 green:141/256.0 blue:117/256.0 alpha:1.0];
    }
    
    if (_lineColor == nil) {
        _lineColor = [UIColor colorWithRed:154/256.0 green:154/256.0 blue:154/256.0 alpha:1.0];
    }
    
    if (_selectedLineColor == nil) {
        _selectedLineColor = [UIColor colorWithRed:154/256.0 green:154/256.0 blue:154/256.0 alpha:1.0];
    }
    
    if (_errorLineColor == nil) {
        _errorLineColor = [UIColor redColor];
    }
    
    if (_errorTextColor == nil) {
        _errorTextColor = [UIColor redColor];
    }
    
    [self addBottomLineView];
    
    [self addPlaceholderLabel];
    
    [self setValue:self.placeHolderColor forKeyPath:@"_placeholderLabel.textColor"];
    
    if (![self.text isEqualToString:@""]) {
        [self floatTheLabel];
    }
    
    if (self.leftimage != nil)
    {
        [self addleftImage];
    }
}

- (void)addleftImage {
    
    self.leftViewMode = UITextFieldViewModeAlways;
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, 30, 25)];
    UIImageView *theImg = [[UIImageView alloc] initWithImage:_leftimage];
    theImg.frame = CGRectMake(0, 1, 21, 21);
    theImg.contentMode = UIViewContentModeScaleAspectFit;
    [paddingView addSubview:theImg];
    self.leftView = paddingView;
    
}

- (void)addBottomLineView {
    
    [bottomLineView removeFromSuperview];
    bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame)-1, CGRectGetWidth(self.frame), 2)];
    bottomLineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    bottomLineView.backgroundColor = _lineColor;
    [self addSubview:bottomLineView];
    
}

- (void)addPlaceholderLabel {
    
    [_labelPlaceholder removeFromSuperview];
    
    if (![self.placeholder isEqualToString:@""] && self.placeholder != nil) {
        _labelPlaceholder.text = self.placeholder;
    }
    
    NSString *placeHolderText = _labelPlaceholder.text;
    
    float xpos = 5.0;
    if (self.leftimage != nil)
    {
        xpos = 35;
    }
    
    _labelPlaceholder = [[UILabel alloc] initWithFrame:CGRectMake(xpos, 8, self.frame.size.width-xpos, CGRectGetHeight(self.frame))];
    _labelPlaceholder.text = placeHolderText;
    _labelPlaceholder.textAlignment = self.textAlignment;
    _labelPlaceholder.textColor = [UIColor redColor];
    _labelPlaceholder.font = self.font;;
    _labelPlaceholder.hidden = YES;
    [self addSubview:_labelPlaceholder];
    
}


#pragma mark - Adding Error Label

- (void)addErrorPlaceholderLabel {
    
    [self.labelErrorPlaceholder removeFromSuperview];
    
    self.labelErrorPlaceholder = [[UILabel alloc] init];
    self.labelErrorPlaceholder.text = self.errorText;
    self.labelErrorPlaceholder.textAlignment = self.textAlignment;
    self.labelErrorPlaceholder.textColor = self.errorTextColor;
    self.labelErrorPlaceholder.font = [UIFont fontWithName:self.font.fontName size:9];
    [self.labelErrorPlaceholder sizeToFit];
    self.labelErrorPlaceholder.hidden = YES;
    [self addSubview:self.labelErrorPlaceholder];
    
    CGRect frameError = self.labelErrorPlaceholder.frame;
    frameError.origin.x = CGRectGetMaxX(self.bounds) - CGRectGetWidth(self.labelErrorPlaceholder.frame);
    self.labelErrorPlaceholder.frame = frameError;
}

- (void)showErrorPlaceHolder {
    
    CGRect bottmLineFrame = bottomLineView.frame;
    bottmLineFrame.origin.y = self.frame.size.height-2;
    
    if (self.errorText != nil && ![self.errorText isEqualToString:@""]) {
        
        [self addErrorPlaceholderLabel];
        self.labelErrorPlaceholder.hidden = NO;
        
        CGRect frame = self.labelErrorPlaceholder.frame;
        frame.origin.y -= (frame.size.height);
        self.labelErrorPlaceholder.frame = frame;
        
        [UIView animateWithDuration:0.2 animations:^{
            self->bottomLineView.frame  =  bottmLineFrame;
            self->bottomLineView.backgroundColor = self->_errorLineColor;
            CGRect labelFrame = self.labelErrorPlaceholder.frame;
            labelFrame.origin.y = 0;
            self.labelErrorPlaceholder.frame = labelFrame;
        }];
        
    } else {
        
        [UIView animateWithDuration:0.2 animations:^{
            self->bottomLineView.frame  =  bottmLineFrame;
            self->bottomLineView.backgroundColor = self->_errorLineColor;
        }];
        
    }
    if (!self.disableShakeWithError) {
        [self shakeView:bottomLineView];
    }
}


- (void)hideErrorPlaceHolder {
    showingError = NO;
    
    if (self.errorText == nil || [self.errorText isEqualToString:@""]) {
        return;
    }
    
    CGRect labelErrorFrame = _labelErrorPlaceholder.frame;
    labelErrorFrame.origin.y -= (labelErrorFrame.size.height);
    
    [UIView animateWithDuration:0.2 animations:^{
        self.
        labelErrorPlaceholder.frame = labelErrorFrame;
    } completion:^(BOOL finished) {
        [self.labelErrorPlaceholder removeFromSuperview];
    }];
}


- (void)updateTextField:(CGRect )frame {
    self.frame = frame;
    [self initialization];
}


- (void)floatPlaceHolder:(BOOL)selected {
    
    self.labelPlaceholder.hidden = NO;
    CGRect bottmLineFrame = bottomLineView.frame;
    
    if (selected) {
        bottomLineView.backgroundColor = self.selectedLineColor;
        self.labelPlaceholder.textColor = self.selectedPlaceHolderColor;
        bottmLineFrame.origin.y = CGRectGetHeight(self.frame)-1;
        [self setValue:self.selectedPlaceHolderColor forKeyPath:@"_placeholderLabel.textColor"];
        
    } else {
        
        bottomLineView.backgroundColor = self.lineColor;
        self.labelPlaceholder.textColor = self.placeHolderColor;
        bottmLineFrame.origin.y = CGRectGetHeight(self.frame)-1;
        [self setValue:self.placeHolderColor forKeyPath:@"_placeholderLabel.textColor"];
    }
    
    if (self.disableFloatingLabel) {
        
        _labelPlaceholder.hidden = YES;
        [UIView animateWithDuration:0.2 animations:^{
            self->bottomLineView.frame  =  bottmLineFrame;
        }];
        
        return;
    }
    
    CGRect frame = self.labelPlaceholder.frame;
    frame.size.height = 12;
    
    [UIView animateWithDuration:0.2 animations:^{
        self->_labelPlaceholder.frame = frame;
        self->_labelPlaceholder.font = [UIFont fontWithName:self.font.fontName size:9];
        self->bottomLineView.frame  =  bottmLineFrame;
        
    }];
}

- (void)resignPlaceholder {
    
    [self setValue:self.placeHolderColor forKeyPath:@"_placeholderLabel.textColor"];
    
    bottomLineView.backgroundColor = self.lineColor;
    
    CGRect bottmLineFrame = bottomLineView.frame;
    bottmLineFrame.origin.y = CGRectGetHeight(self.frame)-1;
    
    if (self.disableFloatingLabel) {
        
        self.labelPlaceholder.hidden = YES;
        self.labelPlaceholder.textColor = self.placeHolderColor;
        [UIView animateWithDuration:0.2 animations:^{
            self->bottomLineView.frame  =  bottmLineFrame;
        }];
        
        return;
        
    }
    
    float xpos = 5.0;
    if (self.leftimage != nil)
    {
        xpos = 35;
    }

    CGRect frame = CGRectMake(xpos, 8, self.frame.size.width-5, self.frame.size.height);
    
    [UIView animateWithDuration:0.3 animations:^{
        self->_labelPlaceholder.frame = frame;
        self->_labelPlaceholder.font = self.font;
        self->_labelPlaceholder.textColor = self->_placeHolderColor;
        self->bottomLineView.frame  =  bottmLineFrame;
    } completion:^(BOOL finished) {
        self.labelPlaceholder.hidden = YES;
        self.placeholder = self.labelPlaceholder.text;
    }];
    
}


#pragma mark - UITextField Begin Editing

- (void)textFieldDidBeginEditing {
    if (showingError) {
        [self hideErrorPlaceHolder];
    }
    if (!self.disableFloatingLabel) {
        self.placeholder = @"";
    }
    
    [self floatTheLabel];
    [self layoutSubviews];
}


#pragma mark - UITextField End Editing

- (void)textFieldDidEndEditing {
    [self floatTheLabel];
}

#pragma mark - Float & Resign

- (void)floatTheLabel{
    
    if ([self.text isEqualToString:@""] && self.isFirstResponder) {
        
        [self floatPlaceHolder:YES];
        
    }else if ([self.text isEqualToString:@""] && !self.isFirstResponder) {
        
        [self resignPlaceholder];
        
    }else if (![self.text isEqualToString:@""] && !self.isFirstResponder) {
        
        [self floatPlaceHolder:NO];
        
    }else if (![self.text isEqualToString:@""] && self.isFirstResponder) {
        
        [self floatPlaceHolder:YES];
    }
}


#pragma mark - Shake Animation

- (void)shakeView:(UIView*)view{
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = 0.6;
    animation.values = @[@(-20.0), @20.0, @(-20.0), @20.0, @(-10.0), @10.0, @(-5.0), @(5.0), @(0.0) ];
    [view.layer addAnimation:animation forKey:@"shake"];
    
}


#pragma mark - Set Placeholder Text On Error Labels

- (void)showError {
    showingError = YES;
    [self showErrorPlaceHolder];
}

- (void)showErrorWithText:(NSString *)errorText {
    _errorText = errorText;
    showingError = YES;
    [self showErrorPlaceHolder];
}


#pragma mark - UITextField Responder Overide

- (BOOL)becomeFirstResponder {
    
    BOOL result = [super becomeFirstResponder];
    [self textFieldDidBeginEditing];
    return result;
}

- (BOOL)resignFirstResponder {
    
    BOOL result = [super resignFirstResponder];
    [self textFieldDidEndEditing];
    return result;
}

@end


