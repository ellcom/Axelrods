//
//  MultiPlayerViewController.h
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 24/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MStrategy;

@interface MultiPlayerViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)MStrategy* myStrategy;

@property (weak, nonatomic) IBOutlet UITableView *remotePlayersTableView;
@property (weak, nonatomic) IBOutlet UITableView *gamePlayTableView;
@end
