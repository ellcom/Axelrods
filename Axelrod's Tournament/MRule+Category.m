//
//  MRule+Category.m
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 15/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import "MRule+Category.h"

@implementation MRule (Category)

-(id)initWithPosition:(NSNumber*)pos response:(NSNumber*)res statergy:(MStrategy*)strat insertIntoManagedObjectContext:(NSManagedObjectContext *)context{
    
    if(self == [MRule alloc]){
        self = [NSEntityDescription insertNewObjectForEntityForName:@"MRule" inManagedObjectContext:context];
        self.position = pos;
        self.response = res;
        self.strategy = strat;
    }
    return self;
}
// convert to a bit array used on a signature view
-(NSArray*) bitArray
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:@[@3,@3,@3,@3,@3,@3]];
    
    int len = (int)[self length];
    int start = ([self.position intValue]+1) - (1 << len);
    for(int i=0; i<len; i++){
        
        if(1 << i & start){
            array[5-i] = @1;
        }else
            array[5-i] = @0;
    }
    return array;
}

-(NSUInteger) bitAtPosition:(int) pos
{
    // Super Lazy.
    return [[[self bitArray] objectAtIndex:pos] integerValue];
}
// a signauture is of length 0 to 6 i,e, |CCCCCC| = 6 and |CD| = 2
-(NSUInteger) length
{
    for(int i=0; i<6; i++){
        if([self.position intValue] > (2 << i)-2 && [self.position intValue] < (4 << i)-1){
            return i+1;
        }
    }
    return 0;
    
    //return (int) log2(self.length+1);
}

@end
