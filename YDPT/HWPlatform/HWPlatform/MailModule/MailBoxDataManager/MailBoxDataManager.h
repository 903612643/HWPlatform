//
//  MailBoxDataManager.h
//  ThatInbox
//
//  Created by hanwei on 15/10/20.
//  Copyright © 2015年 com.inkmobility. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@interface MailBoxDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (MailBoxDataManager *)sharedInstance;
- (void)saveContext;

@end
