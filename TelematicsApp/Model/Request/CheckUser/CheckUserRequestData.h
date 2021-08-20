//
//  CheckUserRequestData.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 24.08.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "RequestData.h"

@interface CheckUserRequestData: RequestData

@property (nonatomic, copy) NSString<Optional>* Email;
@property (nonatomic, copy) NSString<Optional>* Password;
@property (nonatomic, copy) NSString<Optional>* Phone;
@property (nonatomic, copy) NSString<Optional>* ClientId;
@property (nonatomic, copy) NSString<Optional>* NeedConfirm;
@property (nonatomic, copy) NSString<Optional>* ConfirmationCode;
@property (nonatomic, copy) NSString<Optional>* ResetTypeDataContract;
@property (nonatomic, copy) NSString<Optional>* ResetType;

@end
