//
//  SentItemsViewController.h
//  JHMail
//
//  Created by hanwei on 15/11/26.
//  Copyright © 2015年 HanWei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "FooterView.h"
#import "ComposerViewController.h"
#import "MessageCell.h"
#import "MailBoxDataManager.h"

@interface SentItemsViewController : UITableViewController<NSFetchedResultsControllerDelegate, FooterViewDelegate>

@property (strong, nonatomic) ComposerViewController * composerViewController;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
