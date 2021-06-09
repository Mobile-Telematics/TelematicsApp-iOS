//
//  TelematicsAppAddressBookAccessor.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 04.12.18.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "TelematicsAppAddressBookAccessor.h"
#import "TelematicsAppContactsAccessor.h"
#import <AddressBook/AddressBook.h>


@implementation TelematicsAppAddressBookAccessor
+ (TelematicsAppAuthorizationStatus)authorizationStatus {
    return [TelematicsAppContactsAccessor authorizationStatus];
}
- (void)requestAuthorization:(TelematicsAppRequestAuthorizationHandler)handler {
    TelematicsAppContactsAccessor *contactsAccessor = [[TelematicsAppContactsAccessor alloc] init];
    [contactsAccessor requestAuthorization:handler];
}
@end
