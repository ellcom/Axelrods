//
//  MStrategy+Category.h
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 14/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import "MStrategy.h"
#import "MRule+Category.h"

@interface MStrategy (Category)

+ (BOOL) strategyWithNameExists:(NSString*)name;
+(MStrategy*) strategyForName:(NSString*)name;

- (void) changeNameTo:(NSString*)newName withError:(NSError **)error;
- (MRule*) ruleExistsAtPosition:(int) pos;
- (NSArray*) ruleBoiler;

@end
