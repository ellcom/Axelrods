//
//  Prisoner.m
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 05/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//


//
////
////
////
////
////
////
////
////
////
////
////
////
////
////
////
////
////
////
////
////
////
////
////
////
////
////
//
// NOT USED
//
////
////
////
////
////
////
////
////
////
////
////
////
////
////
////
////
////
////
////
////
////
////
//

#import "Prisoner.h"

@implementation Prisoner{

    NSArray *stratergy;
}

-(id)initWithStratergy:(NSArray*) strat
{
    if(self=[super init]){
        NSMutableArray *rStrat = [NSMutableArray arrayWithArray:strat];
        
        for(int i = (int)[strat count]; i<STRATERGY_LENGTH; i++){
            [rStrat addObject:[[strat objectAtIndex:0] stringValue]];
        }
        stratergy = [NSArray arrayWithArray:rStrat];
        rStrat = nil;
    }
    return self;
}

-(id)initWithRandomStratergy
{
    if(self=[super init]){
        NSMutableArray *rStrat = [NSMutableArray new];
        for(int i=0; i<STRATERGY_LENGTH; i++)
            [rStrat addObject:[NSString stringWithFormat:@"%d",arc4random_uniform(2)]];
        
        stratergy = [NSArray arrayWithArray:rStrat];
        rStrat = nil;
    }
    return self;
}

-(BOOL) responseToHistory: (NSArray*) history
{
    uint round = (int)[history count];
    if(round == 0)
        return [[stratergy objectAtIndex:0] boolValue];
    else if(round == 1){
        return [[stratergy objectAtIndex:1+[[history objectAtIndex:0] intValue]] boolValue];
    }else if(round == 2){
        uint x = 3;
        x += 2*([[history objectAtIndex:0] intValue]); // defect or cooperate zone
        x += [[history objectAtIndex:1] intValue]; // defect or cooperate position
        
        return [[stratergy objectAtIndex:x] boolValue];
    }else{
        uint x = 7;
        x += 4*([[history objectAtIndex:round-3] intValue]);
        x += 2*([[history objectAtIndex:round-2] intValue]);
        x += [[history objectAtIndex:round-1] intValue];
        
        return [[stratergy objectAtIndex:x] boolValue];
    }
    
    return 0;
}

-(void) nslogStratergy
{
    NSLog(@"Default Rule: %@", ([[stratergy objectAtIndex:0] boolValue])?@"C":@"D");
    for(int i=1; i< STRATERGY_LENGTH; i++){
        NSMutableString *signat = [NSMutableString stringWithFormat:@"%@: %@", (i%2)?@"D":@"C",[[stratergy objectAtIndex:i] boolValue]?@"C":@"D"];
        for(int parent = (i-1)/2; parent>0; parent = (parent-1)/2){
            signat = [NSMutableString stringWithFormat:@"%@%@",(parent%2)?@"D":@"C",signat];
        }
        NSLog(@"%@",signat);
    }
}

@end
