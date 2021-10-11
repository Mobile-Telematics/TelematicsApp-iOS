//
//  PhoneLoginViewCtrl.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 22.01.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^NextPageBlock)(NSUInteger offset, void(^)(NSArray* result));
typedef void(^PageLoadedBlock)(NSArray* result);
typedef BOOL(^FilterBlock)(id evaluatedObject, NSDictionary *bindings);


@interface PaginationDataSource : NSObject

@property (nonatomic, strong) NextPageBlock                     nextPageBlock;
@property (nonatomic, strong) FilterBlock                       filterBlock;

@property (nonatomic, assign) BOOL                              onePage;

@property (nonatomic, strong, readonly) NSMutableArray*         data;
@property (nonatomic, assign, readonly) BOOL                    isLoading;
@property (nonatomic, assign, readonly) BOOL                    endOfData;


- (void)loadNextPage:(void(^)(NSArray* loadedItems))completion;

- (void)setNextPageBlock:(void(^)(NSUInteger offset, PageLoadedBlock pageLoaded))nextPageBlock;

- (void)reload:(void(^)(void))completion;

- (void)setFilterBlock:(BOOL(^)(id evaluatedObject, NSDictionary *bindings))filterBlock;

- (void)setStaticData:(NSArray*)data;

@end
