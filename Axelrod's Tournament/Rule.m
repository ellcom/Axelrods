//
//  Rule.m
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 12/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import "Rule.h"

@interface Rule()

@property(nonatomic, readwrite)NSUInteger position;
@property(nonatomic, readwrite)NSUInteger response;

@end

@implementation Rule

// used within the create signature before we turn a rule into a managed object

-(instancetype) init
{
    if(self = [super init]){
        self.response = 0;
        self.position = 0;
    }
    return self;
}

-(instancetype) initWithPosition:(NSUInteger)pos andResponse:(NSUInteger)res
{
    if(self = [super init]){
        
        [self setResponse:res];
        [self setPosition:pos];
    }
    return self;
}
// bit array of CCCCCCC or DDDDDD etc
+(NSUInteger) rulePositionFromBitArray:(NSArray*) array
{
    if([array  count] != 6) return 0;
    
    NSUInteger rulePosition = 0;
    for(int i=0; i<6; i++){
        int valueOfRule = [[array objectAtIndex:5-i] intValue];
        
        if(valueOfRule == 3)
            break;
        
        rulePosition += 1 << i;
        
        if(valueOfRule == 1)
            rulePosition += 1 << i;
        
    }
    return rulePosition;
}
// cardinality, |CCCC| = 4
+(NSUInteger) lengthFromPosition:(NSUInteger) pos
{
    for(int i=0; i<6; i++){
        if(pos > (2 << i)-2 && pos < (4 << i)-1){
            return i+1;
        }
    }
    return 0;
}

// turn CCC into 7
+(NSArray*) bitArrayFromPosition:(NSUInteger) pos
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:@[@3,@3,@3,@3,@3,@3]];
    
    int len = (int)[Rule lengthFromPosition:pos];
    int start = ((int)pos+1) - (1 << len);
    for(int i=0; i<len; i++){
        
        if(1 << i & start){
            array[5-i] = @1;
        }else
             array[5-i] = @0;
    }
    return array;
}
// return the rule as a dictionary that can be easily converted into a managed object
// not used
+(NSDictionary*) getRuleAsDicionary:(NSArray*) array withResponse:(NSUInteger) res
{
    if(res > 2) res = 0;
    return @{@"rulePosition": @([Rule rulePositionFromBitArray:array]), @"response" : @(res)};
}
// setters
-(void) setRulePositionFromBitArray:(NSArray*) array
{
    self.position = [Rule rulePositionFromBitArray:array];
}

-(void) setRulePosition:(NSUInteger) pos
{
    self.position = pos;
}

-(void) setRuleResponse:(NSUInteger) res
{
    // Rule must be 0 for C, 1 for D and 2 for R
    if(res > 2) res = 0;
    self.response = res;
}
// get the current rule as a dictionary for easy conversion to a managed object
-(NSDictionary*) getRuleAsDicionary
{
    return @{@"rulePosition": @(self.position), @"response" : @(self.response)};
}

@end
