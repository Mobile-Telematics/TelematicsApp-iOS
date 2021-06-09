//
//  TelematicsAppLocationAccessor.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 04.12.18.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import Foundation;
#import "TelematicsAppPrivacyRequestManager.h"

@interface TelematicsAppLocationAccessor : NSObject
@end

@interface TelematicsAppLocationAlwaysAccessor : NSObject<TelematicsAppPrivacyAccessor>

@end

@interface TelematicsAppLocationWhenInUseAccessor : NSObject<TelematicsAppPrivacyAccessor>

@end
