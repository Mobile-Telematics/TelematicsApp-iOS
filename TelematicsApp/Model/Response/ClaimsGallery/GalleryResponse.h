//
//  GalleryResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.04.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "RootResponse.h"
#import "GalleryResultResponse.h"

@interface GalleryResponse: RootResponse

@property (nonatomic, strong) GalleryResultResponse<Optional>* Result;

@end
