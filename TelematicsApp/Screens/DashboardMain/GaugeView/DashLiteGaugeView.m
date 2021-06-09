//
//  DashLiteGaugeView.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 28.05.19.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "DashLiteGaugeView.h"

#define kDefaultStartAngle                      M_PI_4 * 3.40
#define kDefaultEndAngle                        M_PI_4 + 1.9 * M_PI
//#define kDefaultStartAngle                      M_PI_4 * 3
//#define kDefaultEndAngle                        M_PI_4 + 2 * M_PI
#define kDefaultMinValue                        0
#define kDefaultMaxValue                        100

#define kDefaultLimitValue40                    40
#define kDefaultLimitValue50                    50
#define kDefaultLimitValue60                    60
#define kDefaultLimitValue70                    70
#define kDefaultLimitValue80                    80
#define kDefaultLimitValue90                    90

#define kDefaultNumOfDivisions                  0
#define kDefaultNumOfSubDivisions               0

#define kDefaultRingThickness                   8 //12
#define kDefaultRingBackgroundColor             [UIColor colorWithRed:76.0/255 green:217.0/255 blue:100.0/255 alpha:0.2]
#define kDefaultRingColor                       [UIColor colorWithRed:76.0/255 green:217.0/255 blue:100.0/255 alpha:1]

#define kDefaultDivisionsRadius                 1.25
#define kDefaultDivisionsColor                  [UIColor colorWithWhite:0.5 alpha:1]
#define kDefaultDivisionsPadding                12

#define kDefaultSubDivisionsRadius              0.75
#define kDefaultSubDivisionsColor               [UIColor colorWithWhite:0.5 alpha:0.5]

#define kDefaultLimitDotRadius                  5
#define kDefaultLimitDotColor                   [UIColor redColor]

#define kDefaultValueFont                       [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:30]
#define kDefaultValueTextColor                  [UIColor colorWithWhite:0.1 alpha:1]
#define kDefaultMinMaxValueFont                 [UIFont fontWithName:@"HelveticaNeue" size:12]
#define kDefaultMinMaxValueTextColor            [UIColor colorWithWhite:0.3 alpha:1]

#define kDefaultUnitOfMeasurement               @"Safe Driving Score"
#define kDefaultUnitOfMeasurementFont           [UIFont fontWithName:@"HelveticaNeue" size:14]
#define kDefaultUnitOfMeasurementTextColor      [UIColor colorWithWhite:0.3 alpha:1]


@interface DashLiteGaugeView ()

@property (nonatomic, assign) CGFloat startAngle;
@property (nonatomic, assign) CGFloat endAngle;
@property (nonatomic, assign) CGFloat divisionUnitAngle;
@property (nonatomic, assign) CGFloat divisionUnitValue;

@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UILabel *unitOfMeasurementLabel;
@property (nonatomic, strong) UILabel *minValueLabel;
@property (nonatomic, strong) UILabel *maxValueLabel;

@end

@implementation DashLiteGaugeView

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    if (!self.backgroundColor) {
        self.backgroundColor = [UIColor clearColor];
    }
    
    _startAngle = kDefaultStartAngle;
    _endAngle = kDefaultEndAngle;
    
    _value = kDefaultMinValue;
    _minValue = kDefaultMinValue;
    _maxValue = kDefaultMaxValue;
    _limitValue40 = kDefaultLimitValue40;
    _limitValue50 = kDefaultLimitValue50;
    _limitValue60 = kDefaultLimitValue60;
    _limitValue70 = kDefaultLimitValue70;
    _limitValue80 = kDefaultLimitValue80;
    _limitValue90 = kDefaultLimitValue90;
    _numOfDivisions = kDefaultNumOfDivisions;
    _numOfSubDivisions = kDefaultNumOfSubDivisions;
    
    _ringThickness = kDefaultRingThickness;
    _ringBackgroundColor = kDefaultRingBackgroundColor;
    
    _divisionsRadius = kDefaultDivisionsRadius;
    _divisionsColor = kDefaultDivisionsColor;
    _divisionsPadding = kDefaultDivisionsPadding;
    
    _subDivisionsRadius = kDefaultSubDivisionsRadius;
    _subDivisionsColor = kDefaultSubDivisionsColor;
    
    _showLimitDot = NO;
    _limitDotRadius = kDefaultLimitDotRadius;
    _limitDotColor = kDefaultLimitDotColor;
    
    _valueFont = kDefaultValueFont;
    _valueTextColor = kDefaultValueTextColor;
    _showMinMaxValue = NO;
    _minMaxValueFont = kDefaultMinMaxValueFont;
    _minMaxValueTextColor = kDefaultMinMaxValueTextColor;
    
    _showUnitOfMeasurement = NO;
    _unitOfMeasurement = kDefaultUnitOfMeasurement;
    _unitOfMeasurementFont = kDefaultUnitOfMeasurementFont;
    _unitOfMeasurementTextColor = kDefaultUnitOfMeasurementTextColor;
}


#pragma mark - Animation

- (void)strokeGauge
{
    CGFloat progress = self.maxValue ? (self.value - self.minValue)/(self.maxValue - self.minValue) : 0;
    self.progressLayer.strokeEnd = progress;
    
    UIColor *ringColor = kDefaultRingColor;
    if (self.delegate && [self.delegate respondsToSelector:@selector(gaugeView:ringStokeColorForValue:)]) {
        ringColor = [self.delegate gaugeView:self ringStokeColorForValue:self.value];
    }
    self.progressLayer.strokeColor = ringColor.CGColor;
}


#pragma mark - Custom Drawing

- (void)drawRect:(CGRect)rect
{
    self.divisionUnitValue = self.numOfDivisions ? (self.maxValue - self.minValue)/self.numOfDivisions : 0;
    self.divisionUnitAngle = self.numOfDivisions ? ABS(self.endAngle - self.startAngle)/self.numOfDivisions : 0;
    
    CGPoint center = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
    CGFloat ringRadius = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))/2 - self.ringThickness/2;
    CGFloat dotRadius = ringRadius - self.ringThickness/2 - self.divisionsPadding - self.divisionsRadius/2;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    CGContextSetLineWidth(context, self.ringThickness);
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, ringRadius, 0, M_PI * 2, 0);
    CGContextSetStrokeColorWithColor(context, [self.ringBackgroundColor colorWithAlphaComponent:0.0].CGColor);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextStrokePath(context);

    
    //0%-60% SCALE
    CGContextSetLineWidth(context, self.ringThickness);
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, ringRadius, self.startAngle, M_PI_4 + 1.382 * M_PI, 0);
    CGContextSetStrokeColorWithColor(context, [Color curveRedBordoColorAlpha].CGColor);
    CGContextStrokePath(context);

    CGContextSetLineWidth(context, self.ringThickness);
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, ringRadius, M_PI_4 + 1.382 * M_PI, M_PI_4 + 1.387 * M_PI, 0);
    CGContextSetStrokeColorWithColor(context, [Color officialWhiteColor].CGColor);
    CGContextStrokePath(context);


    //60%-70% SCALE
    CGContextSetLineWidth(context, self.ringThickness);
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, ringRadius, M_PI_4 + 1.387 * M_PI, M_PI_4 + 1.519 * M_PI, 0);
    CGContextSetStrokeColorWithColor(context, [Color curveOrangeFantaColorAlpha].CGColor);
    CGContextStrokePath(context);

    CGContextSetLineWidth(context, self.ringThickness);
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, ringRadius, M_PI_4 + 1.519 * M_PI, M_PI_4 + 1.524 * M_PI, 0);
    CGContextSetStrokeColorWithColor(context, [Color officialWhiteColor].CGColor);
    CGContextStrokePath(context);


    //70%-80% SCALE
    CGContextSetLineWidth(context, self.ringThickness);
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, ringRadius, M_PI_4 + 1.524 * M_PI, M_PI_4 + 1.647 * M_PI, 0);
    CGContextSetStrokeColorWithColor(context, [Color curveOrangeColorAlpha].CGColor);
    CGContextStrokePath(context);

    CGContextSetLineWidth(context, self.ringThickness);
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, ringRadius, M_PI_4 + 1.647 * M_PI, M_PI_4 + 1.652 * M_PI, 0);
    CGContextSetStrokeColorWithColor(context, [Color officialWhiteColor].CGColor);
    CGContextStrokePath(context);


    //80%-90% SCALE
    CGContextSetLineWidth(context, self.ringThickness);
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, ringRadius, M_PI_4 + 1.652 * M_PI, M_PI_4 + 1.779 * M_PI, 0);
    CGContextSetStrokeColorWithColor(context, [Color curveYellowColorAlpha].CGColor);
    CGContextStrokePath(context);

    CGContextSetLineWidth(context, self.ringThickness);
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, ringRadius, M_PI_4 + 1.779  * M_PI, M_PI_4 + 1.784 * M_PI, 0);
    CGContextSetStrokeColorWithColor(context, [Color officialWhiteColor].CGColor);
    CGContextStrokePath(context);


    //90%-100% SCALE
    CGContextSetLineWidth(context, self.ringThickness);
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, ringRadius, M_PI_4 + 1.784 * M_PI, self.endAngle, 0);
    CGContextSetStrokeColorWithColor(context, self.ringBackgroundColor.CGColor);
    CGContextStrokePath(context);
    
    
    for (int i = 0; i <= self.numOfDivisions && self.numOfDivisions != 0; i++)
    {
        if (i != self.numOfDivisions)
        {
            for (int j = 0; j <= self.numOfSubDivisions && self.numOfSubDivisions != 0; j++)
            {
                CGFloat value = i * self.divisionUnitValue + j * self.divisionUnitValue/self.numOfSubDivisions + self.minValue;
                CGFloat angle = [self angleFromValue:value];
                CGPoint dotCenter = CGPointMake(dotRadius * cos(angle) + center.x, dotRadius * sin(angle) + center.y);
                [self drawDotAtContext:context
                                center:dotCenter
                                radius:self.subDivisionsRadius
                             fillColor:self.subDivisionsColor.CGColor];
            }
        }
        
        CGFloat value = i * self.divisionUnitValue + self.minValue;
        CGFloat angle = [self angleFromValue:value];
        CGPoint dotCenter = CGPointMake(dotRadius * cos(angle) + center.x, dotRadius * sin(angle) + center.y);
        [self drawDotAtContext:context
                        center:dotCenter
                        radius:self.divisionsRadius
                     fillColor:self.divisionsColor.CGColor];
    }
    
    
    if (self.showLimitDot && self.numOfDivisions != 0)
    {
        CGFloat angle = [self angleFromValue:self.limitValue60];
        CGPoint dotCenter = CGPointMake(dotRadius * cos(angle) + center.x, dotRadius * sin(angle) + center.y);
        [self drawDotAtContext:context
                        center:dotCenter
                        radius:self.limitDotRadius
                     fillColor:self.limitDotColor.CGColor];
    }
    
    
    if (!self.progressLayer)
    {
        self.progressLayer = [CAShapeLayer layer];
        self.progressLayer.contentsScale = [[UIScreen mainScreen] scale];
        self.progressLayer.fillColor = [UIColor clearColor].CGColor;
        self.progressLayer.lineCap = kCALineJoinRound;
        self.progressLayer.lineJoin = kCALineJoinRound;
        [self.layer addSublayer:self.progressLayer];
        self.progressLayer.strokeEnd = 0;
    }
    
    self.progressLayer.frame = CGRectMake(center.x - ringRadius - self.ringThickness/2,
                                          center.y - ringRadius - self.ringThickness/2,
                                          (ringRadius + self.ringThickness/2) * 2,
                                          (ringRadius + self.ringThickness/2) * 2);
    self.progressLayer.bounds = self.progressLayer.frame;
    
    UIBezierPath *smoothedPath = [UIBezierPath bezierPathWithArcCenter:self.progressLayer.position
                                                                radius:ringRadius
                                                            startAngle:self.startAngle
                                                              endAngle:self.endAngle
                                                             clockwise:YES];
    
    
    self.progressLayer.path = smoothedPath.CGPath;
    self.progressLayer.lineWidth = self.ringThickness;
    
    if (!self.valueLabel)
    {
        self.valueLabel = [[UILabel alloc] init];
        self.valueLabel.backgroundColor = [UIColor clearColor];
        self.valueLabel.textAlignment = NSTextAlignmentCenter;
        self.valueLabel.text = [NSString stringWithFormat:@"%0.f", self.value];
        self.valueLabel.font = self.valueFont;
        self.valueLabel.adjustsFontSizeToFitWidth = YES;
        self.valueLabel.minimumScaleFactor = 10/self.valueLabel.font.pointSize;
        self.valueLabel.textColor = self.valueTextColor;
        
        self.valueLabel.hidden = YES;
        [self addSubview:self.valueLabel];
    }
    
    CGFloat insetX = self.ringThickness + self.divisionsPadding * 2 + self.divisionsRadius;
    self.valueLabel.frame = CGRectInset(self.progressLayer.frame, insetX, insetX);
    self.valueLabel.frame = CGRectOffset(self.valueLabel.frame, 0, self.showUnitOfMeasurement ? -self.divisionsPadding/2 : 0);
    
    
    if (!self.minValueLabel)
    {
        self.minValueLabel = [[UILabel alloc] init];
        self.minValueLabel.backgroundColor = [UIColor clearColor];
        self.minValueLabel.textAlignment = NSTextAlignmentLeft;
        self.minValueLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.minValueLabel];
    }
    self.minValueLabel.text = [NSString stringWithFormat:@"%0.f", self.minValue];
    self.minValueLabel.font = self.minMaxValueFont;
    self.minValueLabel.minimumScaleFactor = 10/self.minValueLabel.font.pointSize;
    self.minValueLabel.textColor = self.minMaxValueTextColor;
    self.minValueLabel.hidden = !self.showMinMaxValue;
    CGPoint minDotCenter = CGPointMake(dotRadius * cos(self.startAngle) + center.x, dotRadius * sin(self.startAngle) + center.y);
    self.minValueLabel.frame = CGRectMake(minDotCenter.x + 8, minDotCenter.y - 20, 40, 20);
    
    if (!self.maxValueLabel)
    {
        self.maxValueLabel = [[UILabel alloc] init];
        self.maxValueLabel.backgroundColor = [UIColor clearColor];
        self.maxValueLabel.textAlignment = NSTextAlignmentRight;
        self.maxValueLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.maxValueLabel];
    }
    self.maxValueLabel.text = [NSString stringWithFormat:@"%0.f", self.maxValue];
    self.maxValueLabel.font = self.minMaxValueFont;
    self.maxValueLabel.minimumScaleFactor = 10/self.maxValueLabel.font.pointSize;
    self.maxValueLabel.textColor = self.minMaxValueTextColor;
    self.maxValueLabel.hidden = !self.showMinMaxValue;
    CGPoint maxDotCenter = CGPointMake(dotRadius * cos(self.endAngle) + center.x, dotRadius * sin(self.endAngle) + center.y);
    self.maxValueLabel.frame = CGRectMake(maxDotCenter.x - 8 - 40, maxDotCenter.y - 20, 40, 20);
    
    
    if (!self.unitOfMeasurementLabel)
    {
        self.unitOfMeasurementLabel = [[UILabel alloc] init];
        self.unitOfMeasurementLabel.backgroundColor = [UIColor clearColor];
        self.unitOfMeasurementLabel.textAlignment = NSTextAlignmentCenter;
        self.unitOfMeasurementLabel.text = self.unitOfMeasurement;
        self.unitOfMeasurementLabel.font = self.unitOfMeasurementFont;
        self.unitOfMeasurementLabel.adjustsFontSizeToFitWidth = YES;
        self.unitOfMeasurementLabel.minimumScaleFactor = 10/self.unitOfMeasurementLabel.font.pointSize;
        self.unitOfMeasurementLabel.textColor = self.unitOfMeasurementTextColor;
        [self addSubview:self.unitOfMeasurementLabel];
        self.unitOfMeasurementLabel.hidden = !self.showUnitOfMeasurement;
    }
    
    self.unitOfMeasurementLabel.frame = CGRectMake(self.valueLabel.frame.origin.x,
                                                   self.valueLabel.frame.origin.y + CGRectGetHeight(self.valueLabel.frame) - 10,
                                                   CGRectGetWidth(self.valueLabel.frame),
                                                   20);
}


#pragma mark - Support

- (CGFloat)angleFromValue:(CGFloat)value
{
    CGFloat level = self.divisionUnitValue ? (value - self.minValue)/self.divisionUnitValue : 0;
    CGFloat angle = level * self.divisionUnitAngle + self.startAngle;
    return angle;
}

- (void)drawDotAtContext:(CGContextRef)context
                  center:(CGPoint)center
                  radius:(CGFloat)radius
               fillColor:(CGColorRef)fillColor
{
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, radius, 0, M_PI * 2, 0);
    CGContextSetFillColorWithColor(context, fillColor);
    CGContextFillPath(context);
}


#pragma mark - Properties

- (void)setValue:(CGFloat)value
{
    _value = MIN(value, _maxValue);
    _value = MAX(_value, _minValue);
    
    self.valueLabel.text = [NSString stringWithFormat:@"%0.f", _value];
    
    [self strokeGauge];
}

- (void)setMinValue:(CGFloat)minValue
{
    if (_minValue != minValue && minValue < _maxValue) {
        _minValue = minValue;
        [self setNeedsDisplay];
    }
}

- (void)setMaxValue:(CGFloat)maxValue
{
    if (_maxValue != maxValue && maxValue > _minValue) {
        _maxValue = maxValue;
        [self setNeedsDisplay];
    }
}

- (void)setLimitValue40:(CGFloat)limitValue40
{
    if (_limitValue40 != limitValue40 && limitValue40 >= _minValue && limitValue40 <= _limitValue50) {
        _limitValue40 = limitValue40;
        [self setNeedsDisplay];
    }
}

- (void)setLimitValue50:(CGFloat)limitValue50
{
    if (_limitValue50 != limitValue50 && limitValue50 >= _minValue && limitValue50 <= _limitValue60) {
        _limitValue50 = limitValue50;
        [self setNeedsDisplay];
    }
}

- (void)setLimitValue60:(CGFloat)limitValue60
{
    if (_limitValue60 != limitValue60 && limitValue60 >= _minValue && limitValue60 <= _limitValue70) {
        _limitValue60 = limitValue60;
        [self setNeedsDisplay];
    }
}

- (void)setLimitValue70:(CGFloat)limitValue70
{
    if (_limitValue70 != limitValue70 && limitValue70 >= _limitValue60 && limitValue70 <= _limitValue80) {
        _limitValue70 = limitValue70;
        [self setNeedsDisplay];
    }
}

- (void)setLimitValue80:(CGFloat)limitValue80
{
    if (_limitValue80 != limitValue80 && limitValue80 >= _limitValue70 && limitValue80 <= _limitValue90) {
        _limitValue80 = limitValue80;
        [self setNeedsDisplay];
    }
}

- (void)setLimitValue90:(CGFloat)limitValue90
{
    if (_limitValue90 != limitValue90 && limitValue90 >= _limitValue80 && limitValue90 <= _maxValue) {
        _limitValue90 = limitValue90;
        [self setNeedsDisplay];
    }
}

- (void)setNumOfDivisions:(NSUInteger)numOfDivisions
{
    if (_numOfDivisions != numOfDivisions) {
        _numOfDivisions = numOfDivisions;
        [self setNeedsDisplay];
    }
}

- (void)setNumOfSubDivisions:(NSUInteger)numOfSubDivisions
{
    if (_numOfSubDivisions != numOfSubDivisions) {
        _numOfSubDivisions = numOfSubDivisions;
        [self setNeedsDisplay];
    }
}

- (void)setRingThickness:(CGFloat)ringThickness
{
    if (_ringThickness != ringThickness) {
        _ringThickness = ringThickness;
        [self setNeedsDisplay];
    }
}

- (void)setRingBackgroundColor:(UIColor *)ringBackgroundColor
{
    if (_ringBackgroundColor != ringBackgroundColor) {
        _ringBackgroundColor = ringBackgroundColor;
        [self setNeedsDisplay];
    }
}

- (void)setDivisionsRadius:(CGFloat)divisionsRadius
{
    if (_divisionsRadius != divisionsRadius) {
        _divisionsRadius = divisionsRadius;
        [self setNeedsDisplay];
    }
}

- (void)setDivisionsColor:(UIColor *)divisionsColor
{
    if (_divisionsColor != divisionsColor) {
        _divisionsColor = divisionsColor;
        [self setNeedsDisplay];
    }
}

- (void)setDivisionsPadding:(CGFloat)divisionsPadding
{
    if (_divisionsPadding != divisionsPadding) {
        _divisionsPadding = divisionsPadding;
        [self setNeedsDisplay];
    }
}

- (void)setSubDivisionsRadius:(CGFloat)subDivisionsRadius
{
    if (_subDivisionsRadius != subDivisionsRadius) {
        _subDivisionsRadius = subDivisionsRadius;
        [self setNeedsDisplay];
    }
}

- (void)setSubDivisionsColor:(UIColor *)subDivisionsColor
{
    if (_subDivisionsColor != subDivisionsColor) {
        _subDivisionsColor = subDivisionsColor;
        [self setNeedsDisplay];
    }
}

- (void)setShowLimitDot:(BOOL)showLimitDot
{
    if (_showLimitDot != showLimitDot) {
        _showLimitDot = showLimitDot;
        [self setNeedsDisplay];
    }
}

- (void)setLimitDotRadius:(CGFloat)limitDotRadius
{
    if (_limitDotRadius != limitDotRadius) {
        _limitDotRadius = limitDotRadius;
        [self setNeedsDisplay];
    }
}

- (void)setLimitDotColor:(UIColor *)limitDotColor
{
    if (_limitDotColor != limitDotColor) {
        _limitDotColor = limitDotColor;
        [self setNeedsDisplay];
    }
}

- (void)setValueFont:(UIFont *)valueFont
{
    if (_valueFont != valueFont) {
        _valueFont = valueFont;
        self.valueLabel.font = _valueFont;
        self.valueLabel.minimumScaleFactor = 10/_valueFont.pointSize;
    }
}

- (void)setValueTextColor:(UIColor *)valueTextColor
{
    if (_valueTextColor != valueTextColor) {
        _valueTextColor = valueTextColor;
        self.valueLabel.textColor = _valueTextColor;
    }
}

- (void)setShowMinMaxValue:(BOOL)showMinMaxValue
{
    if (_showMinMaxValue != showMinMaxValue) {
        _showMinMaxValue = showMinMaxValue;
        [self setNeedsDisplay];
    }
}

- (void)setMinMaxValueFont:(UIFont *)minMaxValueFont
{
    if (_minMaxValueFont != minMaxValueFont) {
        _minMaxValueFont = minMaxValueFont;
        [self setNeedsDisplay];
    }
}

- (void)setMinMaxValueTextColor:(UIColor *)minMaxValueTextColor
{
    if (_minMaxValueTextColor != minMaxValueTextColor) {
        _minMaxValueTextColor = minMaxValueTextColor;
        [self setNeedsDisplay];
    }
}

- (void)setShowUnitOfMeasurement:(BOOL)showUnitOfMeasurement
{
    if (_showUnitOfMeasurement != showUnitOfMeasurement) {
        _showUnitOfMeasurement = showUnitOfMeasurement;
        self.unitOfMeasurementLabel.hidden = !_showUnitOfMeasurement;
    }
}

- (void)setUnitOfMeasurement:(NSString *)unitOfMeasurement
{
    if (_unitOfMeasurement != unitOfMeasurement) {
        _unitOfMeasurement = unitOfMeasurement;
        self.unitOfMeasurementLabel.text = _unitOfMeasurement;
    }
}

- (void)setUnitOfMeasurementFont:(UIFont *)unitOfMeasurementFont
{
    if (_unitOfMeasurementFont != unitOfMeasurementFont) {
        _unitOfMeasurementFont = unitOfMeasurementFont;
        self.unitOfMeasurementLabel.font = _unitOfMeasurementFont;
        self.unitOfMeasurementLabel.minimumScaleFactor = 10/_unitOfMeasurementFont.pointSize;
    }
}

- (void)setUnitOfMeasurementTextColor:(UIColor *)unitOfMeasurementTextColor
{
    if (_unitOfMeasurementTextColor != unitOfMeasurementTextColor) {
        _unitOfMeasurementTextColor = unitOfMeasurementTextColor;
        self.unitOfMeasurementLabel.textColor = _unitOfMeasurementTextColor;
    }
}

@end
