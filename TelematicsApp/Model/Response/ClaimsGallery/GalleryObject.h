//
//  GalleryObject.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.04.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ResponseObject.h"

@protocol GalleryObject;

@interface GalleryObject: ResponseObject

@property (nonatomic, strong) NSNumber<Optional>* Id;
@property (nonatomic, strong) NSString<Optional>* Url;
@property (nonatomic, strong) NSString<Optional>* DocumentType;

@end
