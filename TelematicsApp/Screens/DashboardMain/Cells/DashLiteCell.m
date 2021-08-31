//
//  DashLiteCell.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 23.05.20.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "DashLiteCell.h"

@implementation DashLiteCell {
    CGFloat timeDelta;
    CGFloat velocity;
    NSInteger acceleration;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)loadGauge:(NSNumber*)value curveName:(NSString*)curveName {
    
    self.curveCountLbl.hidden = NO;
    self.curveCountPlaceholder.hidden = YES;
    self.curveCountPlaceholder.text = localizeString(@"Start Driving to Reveal Your Score!");
    
    self.curveCountLbl.format = @"%d";
    self.curveCountLbl.method = UILabelCountingMethodEaseIn;
    self.curveCountLbl.animationDuration = 1;
    self.curveCountLbl.text = value.stringValue;
    
    if (([value intValue] == 0)) {
        self.curveCountLbl.hidden = YES;
        self.curveCountPlaceholder.hidden = NO;
    }
    
    self.curveNameLbl.text = curveName;
    
    self.gaugeView.minValue = 0;
    self.gaugeView.maxValue = 100;
    self.gaugeView.limitValue40 = 40;
    self.gaugeView.limitValue50 = 50;
    self.gaugeView.limitValue60 = 60;
    self.gaugeView.limitValue70 = 70;
    self.gaugeView.limitValue80 = 80;
    self.gaugeView.limitValue90 = 90;
    
    velocity = [value doubleValue];
    acceleration = 0;
    timeDelta = 1.0/6;
    
    [NSTimer scheduledTimerWithTimeInterval:timeDelta
                                     target:self
                                   selector:@selector(updateGaugeTimer:)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)loadDemoGauge:(NSNumber*)value curveName:(NSString*)curveName {
    
    self.curveCountLbl.hidden = NO;
    self.curveCountPlaceholder.hidden = YES;
    self.curveCountPlaceholder.text = nil;
    
    self.curveCountLbl.format = @"%d";
    self.curveCountLbl.method = UILabelCountingMethodEaseIn;
    self.curveCountLbl.animationDuration = 1;
    self.curveCountLbl.text = @"?";
    self.curveCountLbl.font = [Font heavy54];
    
    self.curveNameLbl.text = curveName;
    
    self.gaugeView.minValue = 0;
    self.gaugeView.maxValue = 100;
    self.gaugeView.limitValue40 = 40;
    self.gaugeView.limitValue50 = 50;
    self.gaugeView.limitValue60 = 60;
    self.gaugeView.limitValue70 = 70;
    self.gaugeView.limitValue80 = 80;
    self.gaugeView.limitValue90 = 90;
    
    velocity = [value doubleValue];
    acceleration = 0;
    timeDelta = 1.0/6;
    
    [NSTimer scheduledTimerWithTimeInterval:timeDelta
                                     target:self
                                   selector:@selector(updateGaugeTimer:)
                                   userInfo:nil
                                    repeats:YES];
}

- (UIColor *)gaugeView:(DashLiteGaugeView *)gaugeView ringStokeColorForValue:(CGFloat)value
{
    if (value >= self.gaugeView.limitValue90) {
        [self.faceImg setImage:[UIImage imageNamed:@"greatScore"]];
        return [Color curveGreenColor];
    }
    
    if (value >= self.gaugeView.limitValue80) {
        [self.faceImg setImage:[UIImage imageNamed:@"goodScore"]];
        return [Color curveYellowColor];
    }
    
    if (value >= self.gaugeView.limitValue70) {
        [self.faceImg setImage:[UIImage imageNamed:@"okScore"]];
        return [Color curveOrangeColor];
    }
    
    if (value >= self.gaugeView.limitValue60) {
        //[self.faceImg setImage:[UIImage imageNamed:@"okScore"]];
        [self.faceImg setImage:[UIImage imageNamed:@"badScore"]];
        return [Color curveOrangeFantaColor];
    }
    
    if (value >= self.gaugeView.limitValue50) {
        [self.faceImg setImage:[UIImage imageNamed:@"badScore"]];
        return [Color curveRedColor];
    }
    
    if (value >= self.gaugeView.limitValue40) {
        [self.faceImg setImage:[UIImage imageNamed:@"badScore"]];
        return [Color curveRedBordoColor];
    }
    
    [self.faceImg setImage:[UIImage imageNamed:@"badScore"]];
    return [Color curveRedColor];
}

- (void)updateGaugeTimer:(NSTimer *)timer
{
    velocity += timeDelta * acceleration;
    self.gaugeView.value = velocity;
}

@end
