//
//  InboxViewController.h
//  TEST
//
//  Created by Hanwei-MacMini on 15/10/31.
//  Copyright © 2015年 Hanwei-MacMini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MCTMsgViewController.h"
#import "FooterView.h"

@interface InboxViewController : UITableViewController<NSFetchedResultsControllerDelegate, FooterViewDelegate>
 
@property (strong, nonatomic) MCTMsgViewController *MsgViewController;

//colin added for CoreData
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
