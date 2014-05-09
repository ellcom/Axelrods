//
//  EditRuleViewController.m
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 07/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import "EditRuleViewController.h"
#import "Rule.h"
#import "UIView+DrawRectBlock.h"


@interface EditRuleViewController (){
    int response;
    NSMutableArray *rule;
}

@property(nonatomic)UIView* arrowView;
@end

@implementation EditRuleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]){
        response = 0;
        rule = [NSMutableArray arrayWithArray:@[@3,@3,@3,@3,@3,@3]];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [(EditRuleView*)self.view updateViewWithRule:[rule copy] andResponse:response];
    [self.view addSubview:self.arrowView];
}

#pragma mark - Drawing Arrow
-(UIView*) arrowView
{
    if(!_arrowView){
        _arrowView = [UIView viewWithFrame:CGRectMake(0, 0, 20, 30)drawRectBlock:^(UIView *drawRectView, CGRect rect) {
            UIBezierPath *arrow = [UIBezierPath new];
            [arrow moveToPoint:CGPointMake(10, 0)];
            [arrow addLineToPoint:CGPointMake(10,30)];
            // right wing
            [arrow addLineToPoint:CGPointMake(20,20)];
            // left wing
            [arrow moveToPoint:CGPointMake(10,30)];
            [arrow addLineToPoint:CGPointMake(0,20)];
            [[UIColor grayColor] setStroke];
            [arrow stroke];
            
        }];
     _arrowView.backgroundColor = [UIColor clearColor];
     _arrowView.center = [self drawArrowAtCenterPoint];
    }
    
    return _arrowView;
}

- (CGPoint) drawArrowAtCenterPoint
{
    int x = -10;
    for(int k=5; k>=0;k--){
        if([rule[k] intValue] == 3){
            x = 115+(k*60);
            break;
        }
    }
    return CGPointMake(x, 145);
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
    /*CGRect frame;
    frame.origin = CGPointZero;
    frame.size = CGSizeMake(50, 50);
    
    UIView *mehView = [[UIView alloc] initWithFrame:frame];
    mehView.layer.cornerRadius = 25;
    mehView.backgroundColor = [UIColor blueColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    label.text = @"A";
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:22];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [mehView addSubview:label];
    [self.view addSubview:mehView];*/

    uint x = [[touches anyObject] locationInView:self.view].x;
    uint y = [[touches anyObject] locationInView:self.view].y;
    
    if(x>90 && y>180 && y<230 && x<440){
        for(int i=0; i<6;i++){
            if(x>= 90+i*60 && x<= 140+i*60 ){
                [self iterateValueAt:i];
                //[self setNeedsDisplay];
                [(EditRuleView*)self.view updateViewWithRule:[rule copy] andResponse:response];
                break;
            }
        }
    }else if(x>250 && x<300 && y>350 && y<400){
        if(response == 2) response = 0; else response ++;
        [(EditRuleView*)self.view updateViewWithRule:[rule copy] andResponse:response];
        //[self setNeedsDisplay];
    }else if (y>500){
        [self returnRule];
    }
    
    //[self setNeedsDisplay];
    [(EditRuleView*)self.view updateViewWithRule:[rule copy] andResponse:response];
}



- (void) iterateValueAt:(int) i
{
    for(int k=i+1; k<6; k++)
        if([[rule objectAtIndex:k] intValue] == 3) return;
    
    int value = [[rule objectAtIndex:i] intValue];
    if(value == 3){
        [rule replaceObjectAtIndex:i withObject:@0];
    }else if(value == 1){
        [rule replaceObjectAtIndex:i withObject:@3];
        for(int k=0; k<i; k++){
            if([[rule objectAtIndex:k] intValue] != 3){
                [rule replaceObjectAtIndex:i withObject:@0];
                return;
            }
        }
    }else{
        [rule replaceObjectAtIndex:i withObject:@(value+1)];
    }
    
    [UIView animateWithDuration:.2 animations:^{self.arrowView.center = [self drawArrowAtCenterPoint];}completion:^(BOOL finished) {}];
    
}

- (void) setRule:(NSDictionary*)ru
{
    rule = [NSMutableArray arrayWithArray:[Rule bitArrayFromPosition:[[ru objectForKey:@"rulePosition"] intValue]]];
    response = [[ru objectForKey:@"response"] intValue];
}

- (NSDictionary*) returnRule
{
    return [Rule getRuleAsDicionary:[rule copy] withResponse:response];
}


@end
