//
//  PhoneLoginViewCtrl.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 22.01.20.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "PaginationDataSource.h"

@interface PaginationDataSource ()

@property (nonatomic, assign) NSUInteger        offset;
@property (nonatomic, assign) BOOL              shouldReload;

@property (nonatomic, strong) NSMutableArray    *data;
@property (nonatomic, assign) BOOL              isLoading;
@property (nonatomic, assign) BOOL              endOfData;

@property (nonatomic, strong) NSMutableArray    *unfilteredData;


@end

@implementation PaginationDataSource

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.data = [NSMutableArray array];
        self.unfilteredData = [NSMutableArray array];
    }
    return self;
}

- (void)loadNextPage:(void (^)(NSArray* loadedItems))completion {
    if (self.isLoading) {
        NSLog(@"%s: already loading", __func__);
        return;
    }
    if (self.endOfData) {
        if (completion) {
            completion(@[]);
        }
        return;
    }
    self.isLoading = YES;
    __weak typeof(self) weakSelf = self;
    self.nextPageBlock(self.offset, ^(NSArray* result) {
        __typeof__(self) strongSelf = weakSelf;
        if (strongSelf.shouldReload) {
            strongSelf.shouldReload = NO;
            strongSelf.data = [NSMutableArray array];
            strongSelf.unfilteredData = [NSMutableArray array];
        }
        if (result.count) {
            [strongSelf.unfilteredData addObjectsFromArray:result];
        }
        if (strongSelf.filterBlock) {
            NSPredicate* predicate = [NSPredicate predicateWithBlock:strongSelf.filterBlock];
            result = [result filteredArrayUsingPredicate:predicate];
        }
        if (result.count) {
            NSMutableArray* mutableData = [strongSelf mutableArrayValueForKeyPath:@"data"];
            [mutableData addObjectsFromArray:result];
            strongSelf.offset = strongSelf.unfilteredData.count / 10;
            if (strongSelf.onePage) {
                strongSelf.endOfData = YES;
            }
        } else {
            strongSelf.endOfData = YES;
        }
        strongSelf.isLoading = NO;
        if (completion) {
            completion(result);
        }
    });
}

- (void)reload:(void(^)(void))completion {
    self.shouldReload = YES;
    self.isLoading = NO;
    self.endOfData = NO;
    self.offset = 0;
    [self loadNextPage:^(NSArray *loadedItems) {
        if (completion) {
            completion();
        }
    }];
}

- (void)setStaticData:(NSArray*)data {
    self.data = [NSMutableArray arrayWithArray:data];
    self.endOfData = YES;
}

@end
