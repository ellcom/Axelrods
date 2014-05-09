//
//  MRule+Category.h
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 15/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import "MRule.h"

@interface MRule (Category)

-(id)initWithPosition:(NSNumber*)pos response:(NSNumber*)res statergy:(MStrategy*)strat insertIntoManagedObjectContext:(NSManagedObjectContext *)context;
-(NSArray*) bitArray;
-(NSUInteger) bitAtPosition:(int) pos;
-(NSUInteger) length;

@end
