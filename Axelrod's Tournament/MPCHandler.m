//
//  MCPHandler.m
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 21/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import "MPCHandler.h"

#import "MStrategy.h"
#import "MStrategy+Category.h"
#import "MRule.h"

// May need to change this if the peer networking changes
#define ServiceTypeIdentifier @"Axelrods1"

NSString * const kRecievedStrategyNotification = @"kRecievedStrategyNotification";

@interface MPCHandler()

@property (nonatomic, strong) MCPeerID *myPeerID;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCNearbyServiceBrowser *browser;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;

// data we send to other iPads
@property(strong,nonatomic)NSDictionary *strategyToSend;

@end

@implementation MPCHandler

- (instancetype)initWithStrategy:(MStrategy*)strategy
{
    if(self=[super init]){
        // Broadcast name
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        BOOL useCustom = [defaults boolForKey:@"use_custom"];
        // if the user wants to change their broadcast name, they do this is the user defaults
        if(useCustom){
            if([[defaults objectForKey:@"broadcast_name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length <1){
                [defaults setObject: NO forKey: @"use_custom"];
                [defaults setObject:@"" forKey:@"broadcast_name"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                self.myPeerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
            }else {
                self.myPeerID = [[MCPeerID alloc] initWithDisplayName:[defaults objectForKey:@"broadcast_name"]];
            }
        }else{
            self.myPeerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
        }
        // Send this stuff to everyone
        NSMutableArray *rules = [NSMutableArray new];
        for(MRule *rule in strategy.rules){
            [rules addObject:@{@"position":rule.position, @"response":rule.response}];
        }
        self.strategyToSend = @{@"device_name" : self.myPeerID.displayName,
                                @"boiled_rule" : [strategy ruleBoiler],
                                @"strategy_name" : strategy.name,
                                @"ruleset" : [rules copy]};
        // set up the networking services
        [self setupSession];
        [self setupBrowser];
        [self advertiseSelf:YES];
    }
    return self;
}
- (void)stop
{
    // kill everything
    [self.browser stopBrowsingForPeers];
    self.browser = nil;
    [self.session disconnect];
    self.session = nil;
    [self advertiseSelf:NO];
    
}

@synthesize recieved = _recieved;
- (NSMutableDictionary*)recieved
{
    if(_recieved == nil)
        _recieved = [NSMutableDictionary new];
    return _recieved;
}

- (void)setupSession
{
    self.session = [[MCSession alloc] initWithPeer:self.myPeerID];
    self.session.delegate = self;
}

- (void)setupBrowser {
    self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.myPeerID serviceType:ServiceTypeIdentifier];
    self.browser.delegate = self;
    [self.browser startBrowsingForPeers];
}

- (void)advertiseSelf:(BOOL)advertise
{
    if (advertise) {
        self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.myPeerID discoveryInfo:nil serviceType:ServiceTypeIdentifier];
        //self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithServiceType:ServiceTypeIdentifier discoveryInfo:nil session:self.session];
        self.advertiser.delegate = self;
        [self.advertiser startAdvertisingPeer];
        
    } else {
        [self.advertiser stopAdvertisingPeer];
        self.advertiser = nil;
    }
}

#pragma mark - MCSessionDelegate

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    //NSDictionary *userInfo = @{ @"peerID": peerID,
    //                            @"state" : @(state) };
    
    //dispatch_async(dispatch_get_main_queue(), ^{
    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"MPC_DidChangeStateNotification"
    //                                                       object:nil
    //                                                      userInfo:userInfo];
    //});
    //NSLog(@"User Info: %@",userInfo);
    //NSLog(@"Conntected Peers:: %@", self.session.connectedPeers);
    if(state==MCSessionStateConnected){
        NSError *error = nil;
        // Send the data over.
        [self.session sendData:[NSKeyedArchiver archivedDataWithRootObject:self.strategyToSend]
                       toPeers:@[peerID]
                      withMode:MCSessionSendDataReliable error:&error];
        
        if(error){
            NSLog(@"Error Sending Data to %@",peerID.displayName);
        }else if([self.recieved objectForKey:peerID.displayName]){
            // So we have just sent out some data, now we need to cancel the connection.
            NSLog(@"Sent Data to %@, closing connection",peerID.displayName);
            [self.session cancelConnectPeer:peerID];
        }else{
            NSLog(@"Sent Data to %@, connection left open",peerID.displayName);
        }
        // completeness
    }else if(state==MCSessionStateNotConnected){
        if([self.recieved objectForKey:peerID.displayName]){
            NSLog(@"Peer dissconnected: %@, data sent and received",peerID.displayName);
        }else{
            NSLog(@"Peer dissconnected: %@, data not recieved",peerID.displayName);
        }
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSLog(@"Recieved data from %@", peerID.displayName);
    // Okay that data useful
    NSDictionary *dict = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if(dict.count){
        
        
        [self.recieved setObject:dict forKey:peerID.displayName];
        // Push a notification when we receive data.
        [[NSNotificationCenter defaultCenter] postNotificationName:kRecievedStrategyNotification
                                                                object:nil
                                                            userInfo:dict];
    }else{
        // It looked better than it tasted.
        NSLog(@"Recieved bad data from %@",peerID.displayName);
    }
    
}
// completeness
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    NSLog(@"Did start revceiving data from %@",peerID.displayName);
}
// completeness
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    NSLog(@"Did finish revceiving data from %@",peerID.displayName);
}
// completeness
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    NSLog(@"Did revceive stream data from %@",peerID.displayName);
}

#pragma mark - MCNearbyServiceBrowserDelegate

- (void) browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    // if we find a peer then we invite them if we dont already have their data
    if(![self.recieved objectForKey:peerID.displayName]){
        NSLog(@"Peer ID Found: %@, sending out an invite",[peerID displayName]);
        [browser invitePeer:peerID toSession:self.session withContext:nil timeout:20];
    }
}
// completeness
- (void) browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    NSLog(@"Lost Peer: %@", peerID.displayName);
}
// completeness
-(void) browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    NSLog(@"ERROR didNotStartBrowsingForPeers: %@",error);
}

#pragma mark - MCNearbyServiceAdvertiserDelegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)theAdvertiser didReceiveInvitationFromPeer:(MCPeerID *)directorPeerId
       withContext:(NSData *)invitationData invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler
{
    // accpet the invite and then wait for them to send their data
    NSLog(@"Accepted an invite from %@",directorPeerId.displayName);
    if([self.recieved objectForKey:directorPeerId.displayName]){
        [self.recieved removeObjectForKey:directorPeerId.displayName];
    }
    invitationHandler(YES, self.session);
}
// completeness
-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    NSLog(@"ERROR didNotStartAdvertisingPeer: %@",error);
}

#pragma mark - MPC iOS7 BUG FIX

- (void) session:(MCSession*)session didReceiveCertificate:(NSArray*)certificate fromPeer:(MCPeerID*)peerID certificateHandler:(void (^)(BOOL accept))certificateHandler
{
    certificateHandler(YES);
}

@end
