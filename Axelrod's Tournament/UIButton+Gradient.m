//
//  UIButton+Gradient.m
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 25/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import "UIButton+Gradient.h"

@implementation UIButton (Gradient)


-(void)applyGradient
{
    [self applyGradientWithStart:[UIColor colorWithRed:0.1 green:0.84 blue:0.99 alpha:1] end:[UIColor colorWithRed:0.11 green:0.38 blue:0.94 alpha:1]];
    
}

-(void)applyRedGradient
{
    [self applyGradientWithStart:[UIColor colorWithRed:1 green:0.4 blue:0 alpha:1] end:[UIColor colorWithRed:1 green:0 blue:0 alpha:1]];
}

-(void)applyGradientWithStart:(UIColor*)start end:(UIColor*)end
{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.layer.bounds;
    
    gradientLayer.colors = @[(id)start.CGColor,(id)end.CGColor];
    
    gradientLayer.locations = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0f],
                               [NSNumber numberWithFloat:1.0f],
                               nil];
    
    self.layer.cornerRadius = 5;
    gradientLayer.cornerRadius = self.layer.cornerRadius;
    //gradientLayer.masksToBounds = YES;
    [self.layer addSublayer:gradientLayer];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
}

@end
