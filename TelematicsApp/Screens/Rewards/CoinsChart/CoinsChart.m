//
//  CoinsChart.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 17.08.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CoinsChart.h"
#import "UIColor+FSPalette.h"

@interface CoinsChart ()

@property (nonatomic, strong) NSMutableArray*   data;
@property (nonatomic, strong) NSMutableArray*   layers;

@property (nonatomic) CGFloat                   min;
@property (nonatomic) CGFloat                   max;
@property (nonatomic) CGMutablePathRef          initialPath;
@property (nonatomic) CGMutablePathRef          newPath;

@end

@implementation CoinsChart

#pragma mark - Initialisation

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit
{
    _layers = [NSMutableArray array];
    self.backgroundColor = [Color officialWhiteColor];
    [self setDefaultParameters];
}

- (void)setDefaultParameters
{
    _color = [UIColor fsLightBlue];
    _fillColor = [_color colorWithAlphaComponent:0.25];
    _verticalGridStep = 3;
    _horizontalGridStep = 3;
    _margin = 5.0f;
    _axisWidth = self.frame.size.width - 2 * _margin;
    _axisHeight = self.frame.size.height - 2 * _margin;
    _axisColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    _innerGridColor = [UIColor clearColor];// [UIColor colorWithWhite:0.9 alpha:1.0];
    _drawInnerGrid = YES;
    _bezierSmoothing = YES;
    _bezierSmoothingTension = 0.5;
    _lineWidth = 1;
    _innerGridLineWidth = 0.5;
    _axisLineWidth = 1;
    _animationDuration = 0.5;
    _displayDataPoint = NO;
    _dataPointRadius = 1;
    _dataPointColor = _color;
    _dataPointBackgroundColor = _color;
    
    _indexLabelBackgroundColor = [UIColor clearColor];
    _indexLabelTextColor = [UIColor grayColor];
    _indexLabelFont = [Font light10Helvetica];
    
    _valueLabelBackgroundColor = [UIColor colorWithWhite:1 alpha:0.0];
    _valueLabelTextColor = [UIColor grayColor];
    _valueLabelFont = [Font light10Helvetica];
    _valueLabelPosition = ValueLabelRight;
}

- (void)layoutSubviews
{
    _axisWidth = self.frame.size.width - 2 * _margin;
    _axisHeight = self.frame.size.height - 2 * _margin;
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    [self.layers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CALayer* layer = (CALayer*)obj;
        [layer removeFromSuperlayer];
    }];
    
    [self layoutChart];
    [super layoutSubviews];
}

- (void)layoutChart
{
    if (_data == nil) {
        return;
    }
    
    [self computeBounds];
    
    if (isnan(_max)) {
        _max = 1;
    }
    
    [self strokeChart];
    
    if (_displayDataPoint) {
        [self strokeDataPoints];
    }
    
    if (_labelForValue) {
        for (int i=0; i<_verticalGridStep; i++) {
            UILabel* label = [self createLabelForValue:i];
            
            if (label) {
                [self addSubview:label];
            }
        }
    }
    
    if (_labelForIndex) {
        for (int i=0; i<_horizontalGridStep + 1; i++) {
            UILabel* label = [self createLabelForIndex:i];
            
            if (label) {
                [self addSubview:label];
            }
        }
    }
    
    [self setNeedsDisplay];
}

- (void)setChartData:(NSArray *)chartData
{
    if (chartData == nil || chartData.count == 0) {
        return;
    }
    
    _data = [NSMutableArray arrayWithArray:chartData];
    
    for (int i = 0; i < _data.count; i++) {
        NSNumber *min = [_data objectAtIndex:i];
        
        if (min.intValue < 0) {
            min = @1;
        }
        
        if (min.intValue > 20) {
            NSNumber *minX = @([min intValue] - 1);
            [_data replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:minX.floatValue]];
        } else {
            [_data replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:min.floatValue]];
        }
    }
    [self layoutChart];
}


#pragma mark - Labels creation

- (UILabel*)createLabelForValue:(NSUInteger)index
{
    CGFloat minBound = [self minVerticalBound];
    CGFloat maxBound = [self maxVerticalBound];
    
    CGPoint p = CGPointMake(_margin + (_valueLabelPosition == ValueLabelRight ? _axisWidth : 0), _axisHeight + _margin - (index + 1) * _axisHeight / _verticalGridStep);
    
    NSString* text = _labelForValue(minBound + (maxBound - minBound) / _verticalGridStep * (index + 1));
    
    if (!text) {
        return nil;
    }
    
    CGRect rect = CGRectMake(_margin, p.y + 2, self.frame.size.width - _margin * 2 - 4.0f, 14);
    
    float width = [text boundingRectWithSize:rect.size
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{ NSFontAttributeName:_valueLabelFont }
                                     context:nil].size.width;
    
    CGFloat xPadding = 6;
    CGFloat xOffset = width + xPadding;
    
    if (_valueLabelPosition == ValueLabelLeftMirrored) {
        xOffset = -xPadding;
    }
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(p.x - xOffset, p.y + 2, width + 2, 14)];
    label.text = text;
    label.font = _valueLabelFont;
    label.textColor = _valueLabelTextColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = _valueLabelBackgroundColor;
    
    return label;
}

- (UILabel*)createLabelForIndex:(NSUInteger)index
{
    CGFloat scale = [self horizontalScale];
    if (_horizontalGridStep == 0) {
        return nil;
    }
    
    NSInteger q = (int)_data.count / _horizontalGridStep;
    NSInteger itemIndex = q * index;
    
    if (itemIndex >= _data.count)
    {
        itemIndex = _data.count - 1;
    }
    
    NSString* text = _labelForIndex(itemIndex);
    
    if (!text)
    {
        return nil;
    }
    
    CGPoint p = CGPointMake(_margin + index * (_axisWidth / _horizontalGridStep) * scale, _axisHeight + _margin);
    
    CGRect rect = CGRectMake(_margin, p.y + 2, self.frame.size.width - _margin * 2 - 4.0f, 14);
    
    float width = [text boundingRectWithSize:rect.size
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{ NSFontAttributeName:_indexLabelFont }
                                     context:nil].size.width;
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(p.x - 4.0f, p.y + 2, width + 2, 14)];
    label.text = text;
    label.font = _indexLabelFont;
    label.textColor = _indexLabelTextColor;
    label.backgroundColor = _indexLabelBackgroundColor;
    
    return label;
}


#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    if (_data.count > 0) {
        [self drawGrid];
    }
}

- (void)drawGrid
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(ctx);
    CGContextSetLineWidth(ctx, _axisLineWidth);
    CGContextSetStrokeColorWithColor(ctx, [_axisColor CGColor]);
    
    CGContextMoveToPoint(ctx, _margin, _margin);
    CGContextAddLineToPoint(ctx, _margin, _axisHeight + _margin + 3);
    CGContextStrokePath(ctx);
    
    CGFloat scale = [self horizontalScale];
    CGFloat minBound = [self minVerticalBound];
    CGFloat maxBound = [self maxVerticalBound];
    
    if (_drawInnerGrid) {
        for (int i=0; i<_horizontalGridStep; i++) {
            CGContextSetStrokeColorWithColor(ctx, [_innerGridColor CGColor]);
            CGContextSetLineWidth(ctx, _innerGridLineWidth);
            
            CGPoint point = CGPointMake((1 + i) * _axisWidth / _horizontalGridStep * scale + _margin, _margin);
            
            CGContextMoveToPoint(ctx, point.x, point.y);
            CGContextAddLineToPoint(ctx, point.x, _axisHeight + _margin);
            CGContextStrokePath(ctx);
            
            CGContextSetStrokeColorWithColor(ctx, [_axisColor CGColor]);
            CGContextSetLineWidth(ctx, _axisLineWidth);
            CGContextMoveToPoint(ctx, point.x - 0.5f, _axisHeight + _margin);
            CGContextAddLineToPoint(ctx, point.x - 0.5f, _axisHeight + _margin + 3);
            CGContextStrokePath(ctx);
        }
        
        for (int i=0; i<_verticalGridStep + 1; i++) {
            
            CGFloat v = maxBound - (maxBound - minBound) / _verticalGridStep * i;
            
            if (v == 0) {
                CGContextSetLineWidth(ctx, _axisLineWidth);
                CGContextSetStrokeColorWithColor(ctx, [_axisColor CGColor]);
            } else {
                CGContextSetStrokeColorWithColor(ctx, [_innerGridColor CGColor]);
                CGContextSetLineWidth(ctx, _innerGridLineWidth);
            }
            
            CGPoint point = CGPointMake(_margin, (i) * _axisHeight / _verticalGridStep + _margin);
            
            CGContextMoveToPoint(ctx, point.x, point.y);
            CGContextAddLineToPoint(ctx, _axisWidth + _margin, point.y);
            CGContextStrokePath(ctx);
        }
    }
    
    UIGraphicsPopContext();
}

- (void)clearChartData
{
    for (CAShapeLayer *layer in self.layers) {
        [layer removeFromSuperlayer];
    }
    [self.layers removeAllObjects];
}

- (void)strokeChart
{
    CGFloat minBound = [self minVerticalBound];
    CGFloat scale = [self verticalScale];
    
    UIBezierPath *noPath = [self getLinePath:0 withSmoothing:_bezierSmoothing close:NO];
    UIBezierPath *path = [self getLinePath:scale withSmoothing:_bezierSmoothing close:NO];
    
    UIBezierPath *noFill = [self getLinePath:0 withSmoothing:_bezierSmoothing close:YES];
    UIBezierPath *fill = [self getLinePath:scale withSmoothing:_bezierSmoothing close:YES];
    
    if (_fillColor) {
        CAShapeLayer* fillLayer = [CAShapeLayer layer];
        fillLayer.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y + minBound * scale, self.bounds.size.width, self.bounds.size.height);
        fillLayer.bounds = self.bounds;
        fillLayer.path = fill.CGPath;
        fillLayer.strokeColor = nil;
        fillLayer.fillColor = _fillColor.CGColor;
        fillLayer.lineWidth = 0;
        fillLayer.lineJoin = kCALineJoinRound;
        
        [self.layer addSublayer:fillLayer];
        [self.layers addObject:fillLayer];
        
        CABasicAnimation *fillAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        fillAnimation.duration = _animationDuration;
        fillAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        fillAnimation.fillMode = kCAFillModeForwards;
        fillAnimation.fromValue = (id)noFill.CGPath;
        fillAnimation.toValue = (id)fill.CGPath;
        [fillLayer addAnimation:fillAnimation forKey:@"path"];
    }
    
    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    pathLayer.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y + minBound * scale, self.bounds.size.width, self.bounds.size.height);
    pathLayer.bounds = self.bounds;
    pathLayer.path = path.CGPath;
    pathLayer.strokeColor = [_color CGColor];
    pathLayer.fillColor = nil;
    pathLayer.lineWidth = _lineWidth;
    pathLayer.lineJoin = kCALineJoinRound;
    
    [self.layer addSublayer:pathLayer];
    [self.layers addObject:pathLayer];
    
    if (_fillColor) {
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        pathAnimation.duration = _animationDuration;
        pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        pathAnimation.fromValue = (__bridge id)(noPath.CGPath);
        pathAnimation.toValue = (__bridge id)(path.CGPath);
        [pathLayer addAnimation:pathAnimation forKey:@"path"];
    } else {
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnimation.duration = _animationDuration;
        pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
        [pathLayer addAnimation:pathAnimation forKey:@"path"];
    }
    
}

- (void)strokeDataPoints
{
    CGFloat minBound = [self minVerticalBound];
    CGFloat scale = [self verticalScale];
    
    for (int i=0; i <_data.count; i++) {
        CGPoint p = [self getPointForIndex:i withScale:scale];
        p.y +=  minBound * scale;
        
        UIBezierPath* circle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(p.x - _dataPointRadius, p.y - _dataPointRadius, _dataPointRadius * 2, _dataPointRadius * 2)];
        
        CAShapeLayer *fillLayer = [CAShapeLayer layer];
        fillLayer.frame = CGRectMake(p.x, p.y, _dataPointRadius, _dataPointRadius);
        fillLayer.bounds = CGRectMake(p.x, p.y, _dataPointRadius, _dataPointRadius);
        fillLayer.path = circle.CGPath;
        fillLayer.strokeColor = _dataPointColor.CGColor;
        fillLayer.fillColor = _dataPointBackgroundColor.CGColor;
        fillLayer.lineWidth = 1;
        fillLayer.lineJoin = kCALineJoinRound;
        
        [self.layer addSublayer:fillLayer];
        [self.layers addObject:fillLayer];
    }
}


#pragma mark - Chart scale & boundaries

- (CGFloat)horizontalScale
{
    CGFloat scale = 1.0f;
    if (_horizontalGridStep == 0) {
        return 1;
    }
    
    NSInteger q = (int)_data.count / _horizontalGridStep;
    
    if (_data.count > 1) {
        scale = (CGFloat)(q * _horizontalGridStep) / (CGFloat)(_data.count - 1);
    }
    
    return scale;
}

- (CGFloat)verticalScale
{
    CGFloat minBound = [self minVerticalBound];
    CGFloat maxBound = [self maxVerticalBound];
    CGFloat spread = maxBound - minBound;
    CGFloat scale = 0;
    
    if (spread != 0) {
        scale = _axisHeight / spread;
    }

    return scale;
}

- (CGFloat)minVerticalBound
{
    return MIN(_min, 0);
}

- (CGFloat)maxVerticalBound
{
    return MAX(_max, 0);
}

- (void)computeBounds
{
    _min = MAXFLOAT;
    _max = -MAXFLOAT;
    
    for (int i=0; i<_data.count; i++) {
        NSNumber* number = _data[i];
        if ([number floatValue] < _min)
            _min = [number floatValue];
        
        if ([number floatValue] > _max)
            _max = [number floatValue];
    }
    
    if (_min < 0) {
        _min = 0;
    }
    
    _max = [self getUpperRoundNumber:_max forGridStep:_verticalGridStep];
    
    if (_min < 0) {
        
        float step;
        
        if (_verticalGridStep > 3) {
            step = fabs(_max - _min) / (float)(_verticalGridStep - 1);
        } else {
            step = MAX(fabs(_max - _min) / 2, MAX(fabs(_min), fabs(_max)));
        }
        
        step = [self getUpperRoundNumber:step forGridStep:_verticalGridStep];
        
        float newMin,newMax;
        
        if (fabs(_min) > fabs(_max)) {
            int m = ceilf(fabs(_min) / step);
            
            newMin = step * m * (_min > 0 ? 1 : -1);
            newMax = step * (_verticalGridStep - m) * (_max > 0 ? 1 : -1);
            
        } else {
            int m = ceilf(fabs(_max) / step);
            
            newMax = step * m * (_max > 0 ? 1 : -1);
            newMin = step * (_verticalGridStep - m) * (_min > 0 ? 1 : -1);
        }
        
        if (_min < newMin) {
            newMin -= step;
            newMax -=  step;
        }
        
        if (_max > newMax + step) {
            newMin += step;
            newMax +=  step;
        }
        
        _min = newMin;
        _max = newMax;
        
        if (_max < _min) {
            float tmp = _max;
            _max = _min;
            _min = tmp;
        }
    }
}


#pragma mark - Chart utils

- (CGFloat)getUpperRoundNumber:(CGFloat)value forGridStep:(int)gridStep
{
    if (value <= 0)
        return 0;
    
    CGFloat logValue = log10f(value);
    CGFloat scale = powf(10, floorf(logValue));
    CGFloat n = ceilf(value / scale * 4);
    
    int tmp = (int)(n) % gridStep;
    
    if (tmp != 0) {
        n += gridStep - tmp;
    }
    
    return n * scale / 4.0f;
}

- (void)setGridStep:(int)gridStep
{
    _verticalGridStep = gridStep;
    _horizontalGridStep = gridStep;
}

- (CGPoint)getPointForIndex:(NSUInteger)idx withScale:(CGFloat)scale
{
    if (idx >= _data.count) {
        return CGPointZero;
    }
    
    NSNumber* number = _data[idx];
    
    if (_data.count < 2) {
        return CGPointMake(_margin, _axisHeight + _margin - [number floatValue] * scale);
    } else {
        return CGPointMake(_margin + idx * (_axisWidth / (_data.count - 1)), _axisHeight + _margin - [number floatValue] * scale);
    }
}

- (UIBezierPath*)getLinePath:(float)scale withSmoothing:(BOOL)smoothed close:(BOOL)closed
{
    UIBezierPath* path = [UIBezierPath bezierPath];
    
    if (smoothed) {
        for(int i=0; i <_data.count - 1; i++) {
            CGPoint controlPoint[2];
            CGPoint p = [self getPointForIndex:i withScale:scale];
            
            if (i == 0)
                [path moveToPoint:p];
            
            CGPoint nextPoint, previousPoint, m;
            
            nextPoint = [self getPointForIndex:i + 1 withScale:scale];
            previousPoint = [self getPointForIndex:i - 1 withScale:scale];
            m = CGPointZero;
            
            if (i > 0) {
                m.x = (nextPoint.x - previousPoint.x) / 2;
                m.y = (nextPoint.y - previousPoint.y) / 2;
            } else {
                m.x = (nextPoint.x - p.x) / 2;
                m.y = (nextPoint.y - p.y) / 2;
            }
            
            controlPoint[0].x = p.x + m.x * _bezierSmoothingTension;
            controlPoint[0].y = p.y + m.y * _bezierSmoothingTension;
            
            nextPoint = [self getPointForIndex:i + 2 withScale:scale];
            previousPoint = [self getPointForIndex:i withScale:scale];
            p = [self getPointForIndex:i + 1 withScale:scale];
            m = CGPointZero;
            
            if (i < _data.count - 2) {
                m.x = (nextPoint.x - previousPoint.x) / 2;
                m.y = (nextPoint.y - previousPoint.y) / 2;
            } else {
                m.x = (p.x - previousPoint.x) / 2;
                m.y = (p.y - previousPoint.y) / 2;
            }
            
            //SPECIAL NOT VELOCITY ON GRAPH IF 3 RESULTS IN DATA
            if (_data.count == 3) {
                m.x = (nextPoint.x - previousPoint.x) / 14;
                m.y = (nextPoint.y - previousPoint.y) / 14;
            }
            
            controlPoint[1].x = p.x - m.x * _bezierSmoothingTension;
            controlPoint[1].y = p.y - m.y * _bezierSmoothingTension;
            
            [path addCurveToPoint:p controlPoint1:controlPoint[0] controlPoint2:controlPoint[1]];
        }
        
    } else {
        for (int i=0; i<_data.count; i++) {
            if (i > 0) {
                [path addLineToPoint:[self getPointForIndex:i withScale:scale]];
            } else {
                [path moveToPoint:[self getPointForIndex:i withScale:scale]];
            }
        }
    }
    
    if (closed) {
        [path addLineToPoint:[self getPointForIndex:_data.count - 1 withScale:scale]];
        [path addLineToPoint:[self getPointForIndex:_data.count - 1 withScale:0]];
        [path addLineToPoint:[self getPointForIndex:0 withScale:0]];
        [path addLineToPoint:[self getPointForIndex:0 withScale:scale]];
    }
    
    return path;
}


@end
