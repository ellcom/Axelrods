//
//  MStrategy.h
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 13/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MRule;

@interface MStrategy : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *rules;
@end

@interface MStrategy (CoreDataGeneratedAccessors)

- (void)addRulesObject:(MRule *)value;
- (void)removeRulesObject:(MRule *)value;
- (void)addRules:(NSSet *)values;
- (void)removeRules:(NSSet *)values;

@end
