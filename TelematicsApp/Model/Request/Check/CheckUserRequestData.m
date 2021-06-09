//
//  CheckUserRequestData.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 24.01.18.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "CheckUserRequestData.h"
#import "Helpers.h"

@implementation CheckUserRequestData

- (NSArray<NSString *> *)validateCheckEmail {
    NSMutableArray* errors = [NSMutableArray array];
    
    if (!self.Email.length) {
        [errors addObject:localizeString(@"validation_enter_email")];
    } else if (!NSStringIsValidEmail(self.Email)) {
        [errors addObject:localizeString(@"validation_invalid_email")];
    }
    
    return errors.count ? errors : [super validateCheckEmail];
}

- (NSArray<NSString *> *)validateCheckPhone {
    NSMutableArray* errors = [NSMutableArray array];
    
    if (!self.Phone.length) {
        [errors addObject:localizeString(@"validation_enter_phone")];
    } else if (!NSStringIsValidPhone(self.Phone)) {
        [errors addObject:localizeString(@"validation_invalid_phone")];
    }
    
    return errors.count ? errors : [super validateCheckPhone];
}

@end
