//
//  Game.h
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 05/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MStrategy+Category.h"
#import "Rule.h"
// winner enums
typedef NS_ENUM(NSInteger, GameResultState) {
    GameResultStateDraw,
    GameResultStatePlayerOneWinner,
    GameResultStatePlayerTwoWinner
};
// payoff matrix
static const uint payoff[2][2] = {{3,0},{5,1}};

@interface Game : NSObject
// local tournament
-(NSArray*) outcomeForStratagies:(NSArray *)strategies;
// network tournament
+(NSMutableDictionary*) remotePlay:(NSDictionary*)s1 against:(NSDictionary*)s2;
+(NSArray*) play:(NSDictionary*)s1 againstArray:(NSArray*)others;

@end
