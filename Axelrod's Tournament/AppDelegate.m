//
//  AppDelegate.m
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 05/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import "AppDelegate.h"

#import "MRule.h"
#import "MStrategy.h"

@interface AppDelegate()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Check to see if we need to reset the application
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL reset = [defaults boolForKey:@"reset"];
    // Get the url for the bdatabase document
    NSURL *url = [self urlForDatabase];
    
    // Delete the database if the reset button in user prefs is ticked.
    if(reset){
        [[NSFileManager defaultManager] removeItemAtPath:[url path] error:nil];
        [defaults setObject: NO forKey: @"reset"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    // set the database document
    self.document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    
    // Check if a document exists, if so open it, if else create a new file at the url location with default strategies
    if([[NSFileManager defaultManager] fileExistsAtPath:[self.document.fileURL path]]){
        [self.document openWithCompletionHandler:^(BOOL success){
            if(success){ NSLog(@"Opened an existing database"); [self documentIsReady]; }
            if(!success){ NSLog(@"Could not open document at path %@", url); }
        }];
    } else {
        [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
            // Do whatever you want after the database is created
            if(success){
                NSLog(@"Created a new database");
                // Tit-4-Tat Strategy
                MStrategy *strategy = [NSEntityDescription insertNewObjectForEntityForName:@"MStrategy" inManagedObjectContext:self.document.managedObjectContext];
                strategy.name = @"Tit-4-Tat";
                MRule* rule = [[MRule alloc] initWithPosition:@0 response:@0 statergy:strategy insertIntoManagedObjectContext:self.document.managedObjectContext];
                rule = [[MRule alloc] initWithPosition:@1 response:@0 statergy:strategy insertIntoManagedObjectContext:self.document.managedObjectContext];
                rule = [[MRule alloc] initWithPosition:@2 response:@1 statergy:strategy insertIntoManagedObjectContext:self.document.managedObjectContext];
                
                
                // Random Strategy
                strategy = [NSEntityDescription insertNewObjectForEntityForName:@"MStrategy" inManagedObjectContext:self.document.managedObjectContext];
                strategy.name = @"Random";
                rule = [[MRule alloc] initWithPosition:@0 response:@2 statergy:strategy insertIntoManagedObjectContext:self.document.managedObjectContext];
                rule = [[MRule alloc] initWithPosition:@1 response:@2 statergy:strategy insertIntoManagedObjectContext:self.document.managedObjectContext];
                rule = [[MRule alloc] initWithPosition:@2 response:@2 statergy:strategy insertIntoManagedObjectContext:self.document.managedObjectContext];
                
                [self documentIsReady];
            }
            if(!success) NSLog(@"Could not create document at path %@", url);
        }];
    }
    
    
    // Override point for customization after application launch.
    
    return YES;
}

-(void)documentIsReady
{
    // Tell the world that the database docuement is ready for use
    if(self.document.documentState == UIDocumentStateNormal){
        [[NSNotificationCenter defaultCenter] postNotificationName:kUIDOCUMENTREADYNOTIFICATION object:self.document.managedObjectContext];
    }
}

- (NSURL*) urlForDatabase
{
    // The location of where the database is stored
    return [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject] URLByAppendingPathComponent:@"Strategydb"];
}


@end
