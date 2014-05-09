//
//  EditRulesView.m
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 07/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import "EditRuleView.h"

#define P(x,y) CGPointMake(x, y)

@implementation EditRuleView{
    NSArray* rule;
    NSArray* ruleInitals;
    int response;
    
    UIImage * alreadyDrawn;
    
}
static const uint colors[9][4] = {{83,217,106,10},{253,49,89,10},{254,150,38,10},{0,0,0,5},{0,100,255,5}};

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]){
        ruleInitals = @[@"C",@"D",@"R", @"", ];
    }
    return self;
}

- (void) updateViewWithRule:(NSArray*) ru andResponse:(int) re
{
    rule = ru;
    response = re;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if(alreadyDrawn == nil){
        
        [@"Signature Pattern" drawAtPoint:CGPointMake(50, 80)
                           withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:22], NSForegroundColorAttributeName : [UIColor blackColor]}];
        
        [@"(Work from Right to Left)" drawAtPoint:CGPointMake(170, 250)
                           withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:18], NSForegroundColorAttributeName : [UIColor grayColor]}];
        
        [@"Signature Outcome" drawAtPoint:CGPointMake(50, 300)
                           withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:22], NSForegroundColorAttributeName : [UIColor blackColor]}];
        
        // A loop would be overkill.
        [@"C : Cooperate" drawAtPoint:CGPointMake(50, 470)
                       withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Bold" size:22], NSForegroundColorAttributeName : [UIColor colorWithRed:colors[0][0]/255.0 green:colors[0][1]/255.0 blue:colors[0][2]/255.0 alpha:1]}];
        
        [@"D : Defect" drawAtPoint:CGPointMake(50, 540)
                    withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Bold" size:22], NSForegroundColorAttributeName : [UIColor colorWithRed:colors[1][0]/255.0 green:colors[1][1]/255.0 blue:colors[1][2]/255.0 alpha:1]}];
        
        [@"R : Random" drawAtPoint:CGPointMake(350, 470)
                    withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Bold" size:22], NSForegroundColorAttributeName : [UIColor colorWithRed:colors[2][0]/255.0 green:colors[2][1]/255.0 blue:colors[2][2]/255.0 alpha:1]}];
        
        CGContextSetRGBFillColor(context,0.5,0.5,0.5,0.5);
        CGContextFillRect(context, CGRectMake(0, 440, rect.size.width, 2));
        
        alreadyDrawn = UIGraphicsGetImageFromCurrentImageContext();
        
    }else{
        [alreadyDrawn drawInRect:rect];
        
    }
    
    /*BOOL arrowDrawn = NO;*/
    
    for (int i=5; i>=0; i--) {
        
        /*if(!arrowDrawn && [[rule objectAtIndex:i] intValue] == 3){
            UIBezierPath *arrow = [UIBezierPath new];
            int mid_x = 115+i*60;
            // Pipe
            [arrow moveToPoint:P(mid_x, 140)];
            [arrow addLineToPoint:P(mid_x,170)];
            // right wing
            [arrow addLineToPoint:P(mid_x+10,160)];
            // left wing
            [arrow moveToPoint:P(mid_x,170)];
            [arrow addLineToPoint:P(mid_x-10,160)];
            [[UIColor grayColor] setStroke];
            [arrow stroke];
            arrowDrawn = YES;
        }*/
        
        CGContextSetRGBFillColor(context,
                                 colors[[[rule objectAtIndex:i] intValue]][0]/255.0,
                                 colors[[[rule objectAtIndex:i] intValue]][1]/255.0,
                                 colors[[[rule objectAtIndex:i] intValue]][2]/255.0,
                                 colors[[[rule objectAtIndex:i] intValue]][3]/10.0);
        
        CGContextFillEllipseInRect(context, CGRectMake(90+i*60, 180, 50, 50));
        NSString *text = [ruleInitals objectAtIndex:[[rule objectAtIndex:i] intValue]];
        
        [text drawAtPoint:CGPointMake(107+i*60, 191)
           withAttributes:@{NSFontAttributeName             : [UIFont fontWithName:@"HelveticaNeue" size:22],
                            NSForegroundColorAttributeName  : [UIColor whiteColor]}
         ];
    }
    
    CGContextSetRGBFillColor(context,
                             colors[response][0]/255.0,
                             colors[response][1]/255.0,
                             colors[response][2]/255.0,
                             colors[response][3]/10.0);
    CGContextFillEllipseInRect(context, CGRectMake(250, 350, 50, 50));

    [[ruleInitals objectAtIndex:response] drawAtPoint:CGPointMake(267, 362)
       withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:22], NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
}




@end
