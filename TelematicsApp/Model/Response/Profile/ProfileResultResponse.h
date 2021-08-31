//
//  ProfileResultResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 16.01.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ResponseObject.h"
#import "UserProfileObject.h"

@interface ProfileResultResponse: ResponseObject

@property (nonatomic, strong) UserProfileObject<Optional>* UserProfile;
@property (nonatomic, strong) NSArray<Optional>* UserFields;
@property (nonatomic, strong) NSString<Optional>* Name;
@property (nonatomic, strong) NSString<Optional>* FamilyName;
@property (nonatomic, strong) NSString<Optional>* Nickname;
@property (nonatomic, strong) NSString<Optional>* Email;
@property (nonatomic, strong) NSString<Optional>* Phone;
@property (nonatomic, strong) NSString<Optional>* MobileUid;
@property (nonatomic, strong) NSString<Optional>* MobileName;
@property (nonatomic, strong) NSString<Optional>* MobileOsType;
@property (nonatomic, strong) NSString<Optional>* MobileOsVersion;
@property (nonatomic, strong) NSString<Optional>* SdkVersion;
@property (nonatomic, strong) NSString<Optional>* AppVersion;
@property (nonatomic, strong) NSString<Optional>* Language;
@property (nonatomic, strong) NSString<Optional>* Image;
@property (nonatomic, strong) NSString<Optional>* Gender;
@property (nonatomic, strong) NSString<Optional>* Birthday;
@property (nonatomic, strong) NSString<Optional>* ReferralLink;
@property (nonatomic, strong) NSNumber<Optional>* ViewProfileIsComplete;
@property (nonatomic, strong) NSNumber<Optional>* AccountIsComplete;
@property (nonatomic, strong) NSString<Optional>* Address;
@property (nonatomic, strong) NSString<Optional>* Marital;
@property (nonatomic, strong) NSString<Optional>* ChildrenCount;

@end
