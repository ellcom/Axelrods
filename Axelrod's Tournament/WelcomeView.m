//
//  WelcomeView.m
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 16/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import "WelcomeView.h"

@implementation WelcomeView


- (void)drawRect:(CGRect)rect
{
    // Drawing code
    //CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    [[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] setFill];
    // top box gray fill
	[[UIBezierPath bezierPathWithRoundedRect:CGRectMake(350, 20, 650, 190) cornerRadius:5] fill];
    // next box
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(350, 230, 650, 110) cornerRadius:5] fill];
    // next box
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(350, 360, 650, 180) cornerRadius:5] fill];
    // final box gray fill
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(350, 560, 650, 120) cornerRadius:5] fill];

}


@end
