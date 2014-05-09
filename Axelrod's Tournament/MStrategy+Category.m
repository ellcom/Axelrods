//
//  MStrategy+Category.m
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 14/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import "MStrategy+Category.h"

@implementation MStrategy (Category)
// change a strategies name to something else, but pass back an error if we cannot do it
- (void)changeNameTo:(NSString*)newName withError:(NSError **)error
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"MStrategy" inManagedObjectContext:self.managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"name == %@",newName]];
    
    NSError *insideError = nil;
    NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&insideError];
    
    if(insideError){
        *error = insideError;
        return;
    }
    
    if([array count] > 0){
        *error = [NSError errorWithDomain:@"MStrategy" code:-1 userInfo:@{}];
    }else{
        self.name = newName;
    }
}
// ensure we dont create two strategies with the same name
+ (BOOL) strategyWithNameExists:(NSString*)name
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"MStrategy" inManagedObjectContext:appD.document.managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"name == %@",name]];
    
    NSError *error = nil;
    return [[appD.document.managedObjectContext executeFetchRequest:request error:&error] count];
}
// find a strategy with a given name
+(MStrategy*) strategyForName:(NSString*)name
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"MStrategy" inManagedObjectContext:appD.document.managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"name == %@",name]];
    
    NSError *error = nil;
    NSArray *items = [appD.document.managedObjectContext executeFetchRequest:request error:&error];
    
    if(!items || items.count<1 || error ) return nil;
                
    return (MStrategy*)[items objectAtIndex:0];
}
// see if a rule exists at a given position
-(MRule*) ruleExistsAtPosition:(int) pos
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"MRule" inManagedObjectContext:self.managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"(strategy == %@) && (position == %d)",self,pos]];
    
    NSError *error = nil;
    MRule* rule = [[self.managedObjectContext executeFetchRequest:request error:&error] firstObject];
    
    if (!error) {
        return rule;
    } else {
        return nil;
    }
}
// convert a collection of rules into a string array of responses
-(NSArray*) ruleBoiler
{
    NSMutableArray *boiledStrategy = [NSMutableArray new];
    for(int i=0; i<127; i++)
        [boiledStrategy addObject:@-1];
    for(MRule *rule in self.rules)
        [boiledStrategy replaceObjectAtIndex:[rule.position integerValue] withObject:@([rule.response integerValue])];
    /*            if([[boiledStrategy objectAtIndex:(bits-1)+i] intValue] == -1){
     
     }*/
    for(int i=2; i<7; i++){
        int bits = 1 << i;
        for(int k=0;k<bits; k++){
            //NSLog(@"v[%d] = v[%d]",bits+k-1,((bits >> 1)-1)+k%(bits >> 1));
            if([[boiledStrategy objectAtIndex:bits+k-1] intValue] == -1){
                [boiledStrategy replaceObjectAtIndex:bits+k-1 withObject:@([[boiledStrategy objectAtIndex:((bits >> 1)-1)+k%(bits >> 1)] integerValue])];
            }
        }
    }
   return [boiledStrategy copy];
}


@end
