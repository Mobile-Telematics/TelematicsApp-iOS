//
//  UITextField+Form.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 14.01.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "UITextField+Form.h"

@implementation UITextField (Form)

- (void)makeFormFieldZero {
    UIView* left = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 10)];
    self.leftView = left;
    self.leftViewMode = UITextFieldViewModeAlways;
}

- (void)makeFormFieldShift20 {
    UIView* left = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 10)];
    self.leftView = left;
    self.leftViewMode = UITextFieldViewModeAlways;
}

- (void)makeFormFieldShift40 {
    UIView* left = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 10)];
    self.leftView = left;
    self.leftViewMode = UITextFieldViewModeAlways;
}

@end
