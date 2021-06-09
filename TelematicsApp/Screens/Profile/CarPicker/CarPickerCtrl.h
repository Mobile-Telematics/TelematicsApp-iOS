//
//  CarPickerCtrl.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 26.11.20.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PickType) {
    PickBrand,
    PickModel
};

@protocol CarPickerDelegate

- (void)carPickerDidPick:(NSString *)stringDict;
- (void)carPickerDidCancel;

@end

@interface CarPickerCtrl : UIViewController

@property (nonatomic) PickType                          pickType;
@property (nonatomic, weak) id<CarPickerDelegate>       delegate;
@property (nonatomic) NSArray<NSString *>               *brands;
@property (nonatomic) NSArray<NSString *>               *brandsFiltered;
@property (nonatomic) NSArray<NSString *>               *models;
@property (nonatomic) NSArray<NSString *>               *modelsFiltered;

@end
