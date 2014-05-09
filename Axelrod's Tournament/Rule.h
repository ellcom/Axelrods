//
//  Rule.h
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 12/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Rule : NSObject

@property(nonatomic,readonly,getter = getPosition)NSUInteger position;
@property(nonatomic,readonly,getter = getResponse)NSUInteger response;

+(NSUInteger) rulePositionFromBitArray:(NSArray*) array;
+(NSDictionary*) getRuleAsDicionary:(NSArray*) array withResponse:(NSUInteger) res;
+(NSArray*) bitArrayFromPosition:(NSUInteger) pos;

-(NSDictionary*) getRuleAsDicionary;
-(void) setRulePositionFromBitArray:(NSArray*) array;
-(void) setRulePosition:(NSUInteger) pos;
+(NSUInteger) lengthFromPosition:(NSUInteger) pos;

@end
