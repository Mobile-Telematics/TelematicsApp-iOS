//
//  BottomSheetPresenter.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 10.06.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BottomSheetPresenterDelegate <NSObject>

- (double)bounceHeight;
- (double)expandedHeight;
- (double)collapsedHeight;
- (void)animationFinished;

@end


@interface BottomSheetPresenter: NSObject

@property (nonatomic) UIView                            *superView;
@property (nonatomic) BOOL                              isBottomSheetHidden;
@property (nonatomic) RPTag*                            tags;

@property (nonatomic) id<BottomSheetPresenterDelegate>  delegate;

- (instancetype)initWith:(UIView *)superView andDelegate:(id<BottomSheetPresenterDelegate>)delegate;

- (void)setupBottomSheetViewWith:(UIView *)contentView;

- (void)updatePointsLabel:(NSString*)points;
- (void)updateKmLabel:(NSString*)km;
- (void)updateTimeLabel:(NSString*)time;

- (void)updateStartCityLabel:(NSString*)city;
- (void)updateEndCityLabel:(NSString*)city;

- (void)updateStartAddressLabel:(NSString*)address;
- (void)updateEndAddressLabel:(NSString*)address;

- (void)updateStartTimeLabel:(NSString*)time;
- (void)updateEndTimeLabel:(NSString*)time;

- (void)updateTrackOriginButton:(NSString*)origin;
- (void)updateTrackTagsButton:(NSArray*)tags;

- (void)updateAllScores:(float)acc brake:(float)brake phone:(float)phone speed:(float)speed corner:(float)corner;

@end

NS_ASSUME_NONNULL_END
