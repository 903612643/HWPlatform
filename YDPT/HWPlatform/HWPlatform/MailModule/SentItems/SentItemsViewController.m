//
//  SentItemsViewController.m
//  JHMail
//
//  Created by hanwei on 15/11/26.
//  Copyright © 2015年 HanWei. All rights reserved.
//

#import "SentItemsViewController.h"

@implementation SentItemsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置NavigationBar颜色为蓝色

    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.18 green:0.54 blue:1 alpha:1]];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    //CoreData 缓存 colin added
    self.managedObjectContext = [MailBoxDataManager sharedInstance].managedObjectContext;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)RturnButtonOn:(id)sender {
    //返回按钮被点中，返回主界面
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Table View
/*---------------------------------------
 cell高度默认为60
 --------------------------------------- */
-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 80;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    //邮件列表被选中
//    [self selectRowAtIndexPath:indexPath];
//}

//- (void)selectRowAtIndexPath:(NSIndexPath*)indexPath {
//
//    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    NSString * toText = [object valueForKey:@"totext"];
//    NSString * CCText = [object valueForKey:@"cctext"];
//    NSString * BCCText = [object valueForKey:@"bcctext"];
//    NSString * subjectText = [object valueForKey:@"subjecttext"];
//    NSString * Messagebody = [object valueForKey:@"messagebody"];
//    //NSDate转换NSString
//    NSDate * messagedate = [object valueForKey:@"messagedate"];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSString *strDate = [dateFormatter stringFromDate:messagedate];
//
////storyboard 跳转传参的问题...
//}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowSentItems"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSString * toText = [object valueForKey:@"totext"];
        NSString * CCText = [object valueForKey:@"cctext"];
        NSString * BCCText = [object valueForKey:@"bcctext"];
        NSString * subjectText = [object valueForKey:@"subjecttext"];
        NSString * Messagebody = [object valueForKey:@"messagebody"];
        NSData * AttachmentData = [object valueForKey:@"attachment"];
        //NSDate转换NSString
        NSDate * messagedate = [object valueForKey:@"messagedate"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *strDate = [dateFormatter stringFromDate:messagedate];
        
        //附件数组
        NSMutableArray * AttachmetArray = [[NSMutableArray alloc] init];
        if (AttachmentData != nil)
        {
            //将NSData转换为附件
            NSMutableDictionary* Convertarray = [NSKeyedUnarchiver unarchiveObjectWithData:AttachmentData];
            
            //快速枚举遍历所有KEY的值
            NSEnumerator * enumeratorKey = [Convertarray keyEnumerator];
            for (NSString *object in enumeratorKey) {
                NSString * filename = object;
                NSData * fileData = [Convertarray objectForKey:filename];
                MCOAttachment * Attachmentfile = [MCOAttachment attachmentWithData:fileData filename:filename];
                [AttachmetArray addObject:Attachmentfile];
            }
        }
        
        ComposerViewController *controller = (ComposerViewController *)[[segue destinationViewController] topViewController];
        controller.toString = toText;
        controller.ccString = CCText;
        controller.bccString = BCCText;
        controller.subjectString = subjectText;
        controller.bodyString = Messagebody;
        controller.attachmentsArray = AttachmetArray;
        controller.writeDate = strDate;
        controller.navigationItem.title = @"已发送邮件";
        //        [controller setDetailItem:object];
        //        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        //        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MessageCell *cell = (MessageCell *)[tableView dequeueReusableCellWithIdentifier:@"MsgCell"];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Return NO if you do not want the specified item to be editable.
//    return YES;
//}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
//        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
//
//        NSError *error = nil;
//        if (![context save:&error]) {
//            // Replace this implementation with code to handle the error appropriately.
//            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        }
//    }
//}

- (void)configureCell:(MessageCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //获取数据库中的邮件信息
    NSString * toText = [object valueForKey:@"totext"];
    NSString * CCText = [object valueForKey:@"cctext"];
    NSString * subjectText = [object valueForKey:@"subjecttext"];
    NSString * Messagebody = [object valueForKey:@"messagebody"];
    //NSDate转换NSString
    NSDate * messagedate = [object valueForKey:@"messagedate"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:messagedate];
    //写入数据字典用来传递参数
    NSMutableDictionary * MessageHeader = [[NSMutableDictionary alloc] init];
    [MessageHeader setObject:toText forKey:@"fromtext"];
    [MessageHeader setObject:CCText forKey:@"cctext"];
    [MessageHeader setObject:subjectText forKey:@"subjecttext"];
    [MessageHeader setObject:Messagebody forKey:@"messagebody"];
    [MessageHeader setObject:strDate forKey:@"maildate"];
    
    [cell setMessageHeader : MessageHeader];
    
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SentItems" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messagedate" ascending:NO];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}


@end
