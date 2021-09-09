//
//  TelematicsAppContactsAccessor.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 04.12.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "TelematicsAppContactsAccessor.h"
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
#import <Contacts/Contacts.h>
#endif
@implementation TelematicsAppContactsAccessor
+ (TelematicsAppAuthorizationStatus)authorizationStatus {
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    switch (status) {
        case CNAuthorizationStatusNotDetermined:
            return TelematicsAppAuthorizationStatusNotDetermined;
        case CNAuthorizationStatusRestricted:
            return TelematicsAppAuthorizationStatusRestricted;
        case CNAuthorizationStatusDenied:
            return TelematicsAppAuthorizationStatusDenied;
        case CNAuthorizationStatusAuthorized:
            return TelematicsAppAuthorizationStatusAuthorized;
    }
}


- (void)requestAuthorization:(TelematicsAppRequestAuthorizationHandler)handler {
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            TelematicsAppAuthorizationStatus status = [TelematicsAppContactsAccessor authorizationStatus];
            handler(status);
        });
    }];
}

@end
