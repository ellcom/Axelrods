//
//  MRule.h
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 13/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MStrategy;

@interface MRule : NSManagedObject

@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSNumber * response;
@property (nonatomic, retain) MStrategy *strategy;

@end
