//
//  Prisoner.h
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 05/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Prisoner : NSObject

-(id)initWithStratergy:(NSArray*) strat;
-(id)initWithRandomStratergy;

-(BOOL) responseToHistory: (NSArray*) history;
-(void) nslogStratergy;
@end
