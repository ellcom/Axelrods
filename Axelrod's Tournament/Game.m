//
//  Game.m
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 05/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import "Game.h"

// alreay defined in header, here as a helper
/*
 // [me,them]
 payoff[0][0] = 3; // [C,C] = 3 Reward
 payoff[0][1] = 0; // [C,D] = 0 Sucker
 payoff[1][0] = 5; // [D,C] = 5 Tempration
 payoff[1][1] = 1; // [D,D] = 1 Punishment
*/

@interface Game()
// local strategies
@property(strong,nonatomic)NSArray* strategies;
// collection of the boiled rule sets
@property(strong,nonatomic)NSMutableDictionary* boiledRuleSet;
// collection of all the played games
@property(strong,nonatomic)NSMutableArray* games;

@end

@implementation Game

-(instancetype) init
{
    if(self = [super init]){


    }
    return self;
}

-(void) setStrategies:(NSArray *)strategies
{
    _strategies = strategies;
    for(MStrategy *s in strategies){
        [self.boiledRuleSet setObject:[s ruleBoiler] forKey:s.name];
    }
}

-(NSMutableDictionary*) boiledRuleSet
{
    if(_boiledRuleSet == nil){
        _boiledRuleSet = [[NSMutableDictionary alloc] init];
    }
    return _boiledRuleSet;
}

-(NSArray*) outcomeForStratagies:(NSArray *)strategies
{
    // ensure that everyone plays everyone
    [self setStrategies:strategies];
    int numberOfStrategies = (int)[strategies count];
    NSMutableArray *games = [NSMutableArray new];
    // 1 plays {2,3,4,5}, 2 plays {3,4,5}, 3 plays {4,5}, 4 plays {5}. everyone has played each other.
    for(int i=0; i<numberOfStrategies-1; i++){
        for(int k=i+1; k<numberOfStrategies; k++){
            [games addObject:[self play:strategies[i] against:strategies[k]]];
        }
    }
    return [games copy];
}

-(NSDictionary*) play:(MStrategy*)s1 against:(MStrategy*)s2
{
    // scores for each of the give games
    NSMutableArray *score1 = [NSMutableArray arrayWithArray:@[@0,@0,@0,@0,@0,@0]];
    NSMutableArray *score2 = [NSMutableArray arrayWithArray:@[@0,@0,@0,@0,@0,@0]];

    
    // the game results to return
    NSMutableDictionary *game = [NSMutableDictionary dictionaryWithDictionary:@{@"strategy_1":s1.name,@"strategy_2":s2.name, @"rounds":[NSMutableArray new]}];
    
    // five rounds
    for(int i=0; i<5; i++){

        // winnings from each round, listing cooperate defects suckers and tempted in that order
        NSMutableArray *roundPayoff = [NSMutableArray arrayWithArray:@[[NSMutableArray arrayWithArray:@[@0,@0,@0,@0]],[NSMutableArray arrayWithArray:@[@0,@0,@0,@0]]]];
        // signatures
        NSMutableArray *s1History = [NSMutableArray arrayWithArray:@[@3,@3,@3,@3,@3,@3]];
        NSMutableArray *s2History = [NSMutableArray arrayWithArray:@[@3,@3,@3,@3,@3,@3]];
        // move history of very play off and points earned or not
        NSArray *moveHistory = @[[NSMutableArray new],[NSMutableArray new]];
        // 100 iterations
        for(int k=0; k<100; k++){
            // find the responses to the history
            int s1Move = -3;
            int s2Move = -3;
            
            if(k==0){
                s1Move = [[[self.boiledRuleSet objectForKey:s1.name] objectAtIndex:0] intValue];
                s2Move = [[[self.boiledRuleSet objectForKey:s2.name] objectAtIndex:0] intValue];
            }else{
                
                s1Move = [[[self.boiledRuleSet objectForKey:s1.name] objectAtIndex:[Rule rulePositionFromBitArray:[s2History copy]]] intValue];
                s2Move = [[[self.boiledRuleSet objectForKey:s2.name] objectAtIndex:[Rule rulePositionFromBitArray:[s1History copy]]] intValue];
                //NSLog(@"%d is %@ with response from s1 of %d",[Rule rulePositionFromBitArray:[s2History copy]], s2History, s1Move);
            }
            // turn random into a cooperate or defect
            if(s1Move == 2){
                s1Move = arc4random_uniform(101)%2;}
            if(s2Move == 2){
                s2Move = arc4random_uniform(202)%2;}
            // shuffle the signatures
            for(int j=0; j<5;j++){
                s1History[j] = s1History[j+1];
                s2History[j] = s2History[j+1];
            }
            s1History[5] = @(s1Move);
            s2History[5] = @(s2Move);
            [moveHistory[0] addObject:@(s1Move)];
            [moveHistory[1] addObject:@(s2Move)];
            // add the score for this round
            score1[i] = @([score1[i] intValue] + payoff[s1Move][s2Move]);
            score2[i] = @([score2[i] intValue] + payoff[s2Move][s1Move]);
            // update the cooperate defect sucker tempted database
            switch (payoff[s1Move][s2Move]) {
                case 3:
                    roundPayoff[0][0] = @([roundPayoff[0][0] intValue] + 1);
                    roundPayoff[1][0] = @([roundPayoff[1][0] intValue] + 1);
                    break;
                case 0:
                    roundPayoff[0][1] = @([roundPayoff[0][1] intValue] + 1);
                    roundPayoff[1][2] = @([roundPayoff[1][2] intValue] + 1);
                    break;
                case 5:
                    roundPayoff[0][2] = @([roundPayoff[0][2] intValue] + 1);
                    roundPayoff[1][1] = @([roundPayoff[1][1] intValue] + 1);
                    break;
                case 1:
                    roundPayoff[0][3] = @([roundPayoff[0][3] intValue] + 1);
                    roundPayoff[1][3] = @([roundPayoff[1][3] intValue] + 1);
                    break;
            }
        }
        // add an outcome string to the game, not used
        NSString* outcome = ([score1[i] intValue] == [score2[i] intValue]) ? @"Draw" : [NSString stringWithFormat:@"%@ wins",([score1[i] intValue] > [score2[i] intValue])? s1.name : s2.name];
        // add the data gained from the iterations into an the rounds arrays
        [[game objectForKey:@"rounds"] addObject:@{@"outcome": outcome, @"payoffs": roundPayoff, @"p1score" : score1[i], @"p2score" : score2[i], @"history" : [moveHistory copy]}];
    }
    // at the end determin the overall scores
    NSUInteger score1TOTAL = 0;
    for(NSNumber *i in score1)
        score1TOTAL = score1TOTAL + i.intValue;
    NSUInteger score2TOTAL = 0;
    for(NSNumber *i in score2)
        score2TOTAL = score2TOTAL + i.intValue;
    [game setObject:@((score1TOTAL==score2TOTAL)?GameResultStateDraw:(score1TOTAL>score2TOTAL)?GameResultStatePlayerOneWinner:GameResultStatePlayerTwoWinner) forKey:@"result"];
    [game setObject:@(score1TOTAL) forKey:@"s1score"];
    [game setObject:@(score2TOTAL) forKey:@"s2score"];
    [game setObject:@(score1TOTAL+score2TOTAL) forKey:@"overallScore"];
    return [game copy];
}

+(NSArray*) play:(NSDictionary*)s1 againstArray:(NSArray*)others
{
    // ensure that everyone plays s1
    NSMutableArray *games = [NSMutableArray new];
    
    for(NSDictionary* s2 in others){
        [games addObject:[self remotePlay:s1 against:s2]];
    }
    
    return [games copy];
}
// same as -(NSDictionary*) play:(MStrategy*)s1 against:(MStrategy*)s2
+(NSMutableDictionary*) remotePlay:(NSDictionary*)s1 against:(NSDictionary*)s2
{
    NSMutableDictionary *game = [NSMutableDictionary dictionaryWithDictionary:@{@"strategy_1":[s1 objectForKey:@"strategy_name"],@"strategy_2":[s2 objectForKey:@"strategy_name"],@"rounds":[NSMutableArray new]}];
    
    NSMutableArray *score1 = [NSMutableArray arrayWithArray:@[@0,@0,@0,@0,@0,@0]];
    NSMutableArray *score2 = [NSMutableArray arrayWithArray:@[@0,@0,@0,@0,@0,@0]];
    for(int i=0; i<5; i++){
        NSMutableArray *roundPayoff = [NSMutableArray arrayWithArray:@[[NSMutableArray arrayWithArray:@[@0,@0,@0,@0]],[NSMutableArray arrayWithArray:@[@0,@0,@0,@0]]]];
        NSMutableArray *s1History = [NSMutableArray arrayWithArray:@[@3,@3,@3,@3,@3,@3]];
        NSMutableArray *s2History = [NSMutableArray arrayWithArray:@[@3,@3,@3,@3,@3,@3]];
        NSArray *moveHistory = @[[NSMutableArray new],[NSMutableArray new]];
        for(int k=0; k<100; k++){
            int s1Move = -3;
            int s2Move = -3;
        
            if(k==0){
                s1Move = [[[s1 objectForKey:@"boiled_rule"] objectAtIndex:0] intValue];
                s2Move = [[[s2 objectForKey:@"boiled_rule"] objectAtIndex:0] intValue];
            }else{
            
                s1Move = [[[s1 objectForKey:@"boiled_rule"] objectAtIndex:[Rule rulePositionFromBitArray:[s2History copy]]] intValue];
                s2Move = [[[s2 objectForKey:@"boiled_rule"] objectAtIndex:[Rule rulePositionFromBitArray:[s1History copy]]] intValue];
            }
            if(s1Move == 2){
                s1Move = arc4random_uniform(101)%2;}
            if(s2Move == 2){
                s2Move = arc4random_uniform(202)%2;}
            for(int j=0; j<5;j++){
                s1History[j] = s1History[j+1];
                s2History[j] = s2History[j+1];
            }
            s1History[5] = @(s1Move);
            s2History[5] = @(s2Move);
            [moveHistory[0] addObject:@(s1Move)];
            [moveHistory[1] addObject:@(s2Move)];
        
            score1[i] = @([score1[i] intValue] + payoff[s1Move][s2Move]);
            score2[i] = @([score2[i] intValue] + payoff[s2Move][s1Move]);
            switch (payoff[s1Move][s2Move]) {
                case 3:
                    roundPayoff[0][0] = @([roundPayoff[0][0] intValue] + 1);
                    roundPayoff[1][0] = @([roundPayoff[1][0] intValue] + 1);
                    break;
                case 0:
                    roundPayoff[0][1] = @([roundPayoff[0][1] intValue] + 1);
                    roundPayoff[1][2] = @([roundPayoff[1][2] intValue] + 1);
                    break;
                case 5:
                    roundPayoff[0][2] = @([roundPayoff[0][2] intValue] + 1);
                    roundPayoff[1][1] = @([roundPayoff[1][1] intValue] + 1);
                    break;
                case 1:
                    roundPayoff[0][3] = @([roundPayoff[0][3] intValue] + 1);
                    roundPayoff[1][3] = @([roundPayoff[1][3] intValue] + 1);
                    break;
            }
        }

        NSString* outcome = ([score1[i] intValue] == [score2[i] intValue]) ? @"Draw" : [NSString stringWithFormat:@"%@ wins",([score1[i] intValue] > [score2[i] intValue])? [s1 objectForKey:@"strategy_name"] : [s2 objectForKey:@"strategy_name"]];
        [[game objectForKey:@"rounds"] addObject:@{@"outcome": outcome, @"payoffs": roundPayoff, @"p1score" : score1[i], @"p2score" : score2[i], @"history" : [moveHistory copy]}];
    }

    NSUInteger score1TOTAL = 0;
    for(NSNumber *i in score1)
        score1TOTAL = score1TOTAL + i.intValue;
    NSUInteger score2TOTAL = 0;
    for(NSNumber *i in score2)
        score2TOTAL = score2TOTAL + i.intValue;
    [game setObject:@((score1TOTAL==score2TOTAL)?GameResultStateDraw:(score1TOTAL>score2TOTAL)?GameResultStatePlayerOneWinner:GameResultStatePlayerTwoWinner) forKey:@"result"];
    [game setObject:@(score1TOTAL) forKey:@"s1score"];
    [game setObject:@(score2TOTAL) forKey:@"s2score"];
    [game setObject:@(score1TOTAL+score2TOTAL) forKey:@"overallScore"];

    return [game copy];
}

@end
