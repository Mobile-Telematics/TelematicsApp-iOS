//
//  DashLiteGaugeView.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 28.05.20.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DashLiteGaugeViewDelegate;

IB_DESIGNABLE
@interface DashLiteGaugeView : UIView

@property (nonatomic, assign) CGFloat value;
@property (nonatomic, assign) CGFloat minValue;
@property (nonatomic, assign) CGFloat maxValue;

@property (nonatomic, assign) CGFloat limitValue40;
@property (nonatomic, assign) CGFloat limitValue50;
@property (nonatomic, assign) CGFloat limitValue60;
@property (nonatomic, assign) CGFloat limitValue70;
@property (nonatomic, assign) CGFloat limitValue80;
@property (nonatomic, assign) CGFloat limitValue85;
@property (nonatomic, assign) CGFloat limitValue90;

@property (nonatomic, assign) IBInspectable NSUInteger numOfDivisions;
@property (nonatomic, assign) IBInspectable NSUInteger numOfSubDivisions;
@property (nonatomic, assign) IBInspectable CGFloat ringThickness;
@property (nonatomic, strong) IBInspectable UIColor *ringBackgroundColor;
@property (nonatomic, assign) IBInspectable CGFloat divisionsRadius;
@property (nonatomic, strong) IBInspectable UIColor *divisionsColor;
@property (nonatomic, assign) IBInspectable CGFloat divisionsPadding;
@property (nonatomic, assign) IBInspectable CGFloat subDivisionsRadius;
@property (nonatomic, strong) IBInspectable UIColor *subDivisionsColor;
@property (nonatomic, assign) IBInspectable BOOL showLimitDot;
@property (nonatomic, assign) IBInspectable CGFloat limitDotRadius;
@property (nonatomic, strong) IBInspectable UIColor *limitDotColor;
@property (nonatomic, strong) IBInspectable UIFont *valueFont;
@property (nonatomic, strong) IBInspectable UIColor *valueTextColor;
@property (nonatomic, assign) IBInspectable BOOL showMinMaxValue;
@property (nonatomic, strong) IBInspectable UIFont *minMaxValueFont;
@property (nonatomic, strong) IBInspectable UIColor *minMaxValueTextColor;
@property (nonatomic, assign) IBInspectable BOOL showUnitOfMeasurement;
@property (nonatomic, copy) IBInspectable NSString *unitOfMeasurement;
@property (nonatomic, strong) IBInspectable UIFont *unitOfMeasurementFont;
@property (nonatomic, strong) IBInspectable UIColor *unitOfMeasurementTextColor;

@property (nonatomic, weak) IBOutlet id<DashLiteGaugeViewDelegate> delegate;

- (void)strokeGauge;

@end


@protocol DashLiteGaugeViewDelegate <NSObject>

@optional

- (UIColor *)gaugeView:(DashLiteGaugeView *)gaugeView ringStokeColorForValue:(CGFloat)value;

@end
