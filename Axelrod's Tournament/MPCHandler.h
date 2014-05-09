//
//  MCPHandler.h
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 21/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@class MStrategy;

extern NSString * const kRecievedStrategyNotification;

// not used yet
typedef NS_ENUM(NSInteger, Merp) {kReRecievedStrategyNotification,afasf,asfasf};

// define our self as a delegate for the MC classes
@interface MPCHandler : NSObject <MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate>

// data revieved from other ipads
@property(readonly,strong,nonatomic)NSMutableDictionary *recieved;

// init and stop
- (instancetype)initWithStrategy:(MStrategy*)strategy;
- (void)stop;

@end
