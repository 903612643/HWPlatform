//
//  InboxViewController.m
//  TEST
//
//  Created by Hanwei-MacMini on 15/10/31.
//  Copyright © 2015年 Hanwei-MacMini. All rights reserved.
//

#import "InboxViewController.h"
#import <MailCore/MailCore.h>
#import "MCTMsgViewController.h"
#import <QuartzCore/QuartzCore.h>
//回复邮件
//#import "ComposerViewController.h"
#import "AuthManager.h"
//#import "AppDelegate.h"
#import "MessageCell.h"
//数据库入库操作
#import "MailBoxDataManager.h"
#import "FooterView.h"
#import "HWPlatformTest-Swift.h"


@interface InboxViewController ()

@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, strong) NSArray *POPmessagesHeaders;
@property (nonatomic, strong) NSArray *POPmessagesInfo;
@property (nonatomic, strong) MCOPOPOperation * popCheckOp;
@property (nonatomic, strong) MCOPOPFetchMessagesOperation * popMessagesFetchOp;
@property (nonatomic, strong) MCOPOPFetchHeaderOperation * popHeaderFetchOp;

@end

@implementation InboxViewController

UserDataManager * userDataManagerInbox;
int loadMailCount;

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置NavigationBar颜色为蓝色
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.18 green:0.54 blue:1 alpha:1]];
    
//    self.cache = [[NSMutableDictionary alloc] init];
//    [self.navigationController.navigationBar configureFlatNavigationBarWithColor:[UIColor cloudsColor]];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor blackColor];
    [refreshControl addTarget:self action:@selector(loadEmails:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    userDataManagerInbox = [[UserDataManager alloc] init];
    NSString * SLoadMailCount = [userDataManagerInbox.userData objectForKey:@"LoadMailCount"];
    loadMailCount = SLoadMailCount.intValue;
    
    //注册观察者
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadEmails:) name:@"RequesetLoadMail" object:nil];
    
//    self.detailViewController = (MessageDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
  
    
//    for (UIBarButtonItem *bb in @[self.navigationItem.rightBarButtonItem, self.navigationItem.leftBarButtonItem]){
//        NSShadow * shadow = [[NSShadow alloc] init];
//        shadow.shadowColor = [UIColor clearColor];
//        
//        [bb setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"HelveticaNeue" size:16.0], NSFontAttributeName, [UIColor peterRiverColor], NSForegroundColorAttributeName, shadow, NSShadowAttributeName, nil] forState:UIControlStateNormal];
//        [bb setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"HelveticaNeue" size:16.0], NSFontAttributeName, [UIColor belizeHoleColor], NSForegroundColorAttributeName, nil] forState:UIControlStateHighlighted];
//    }
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedAuth) name:@"Finished_OAuth" object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedFirstAuth) name:@"Finished_FirstOAuth" object:nil];
    
    //CoreData 缓存 colin added
    self.managedObjectContext = [MailBoxDataManager sharedInstance].managedObjectContext;
    
    [self finishedAuth];
    [self.refreshControl beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)RturnButtonOn:(id)sender {
    //返回按钮被点中，返回主界面
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void) finishedAuth {
    [self loadAccount];
}

- (void) finishedFirstAuth {
    //For the first time you're here, we add a fake email to your account
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //要做的事情
    });
}

- (void)loadAccount
{
    InboxViewController * __weak weakSelf = self;
    NSLog(@"checking account");
    //  POP3 Server !!!!
    self.popCheckOp = [[[AuthManager sharedManager] getPopSession] checkAccountOperation];
    [self.popCheckOp start:^(NSError *error) {
        InboxViewController *strongSelf = weakSelf;
        NSLog(@"finished checking account.");
        if (error == nil) {
            [strongSelf loadEmailsWithCache:NO];
        } else {
            NSLog(@"error loading account: %@", error);
            [[AuthManager sharedManager] logout];
        }
    }];
}

- (void)loadEmailsWithCache:(BOOL)allowed {
    
    void(^completionWithLoad)(NSError*, NSArray*, MCOIndexSet*) =
    ^(NSError *error, NSArray *POPmessagesInfo, MCOIndexSet *vanishedMessages){
        [self.refreshControl endRefreshing];
    };
    
    NSString *folderName = @"";
    [self loadEmailsFromFolder:folderName WithCompletion:completionWithLoad];
    
}

- (void)loadEmails:(id)sender {
    [self loadEmailsWithCache:NO];
}

- (void)loadEmailsFromFolder:(NSString*)folderName WithCompletion:(void(^)(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages))block {
    
    //请求文件头信息
    self.popMessagesFetchOp = [[[AuthManager sharedManager] getPopSession] fetchMessagesOperation];
    [self.popMessagesFetchOp start:^(NSError *error, NSArray *messages ) {
        if (error) {
            NSLog(@"请求失败");
        }else{
            NSLog(@"所有邮件数量：%ld", messages.count);
            
            //邮件信息倒叙排序，新邮件在前
            NSSortDescriptor *sortMessageInfo = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:NO];
            messages = [messages sortedArrayUsingDescriptors:@[sortMessageInfo]];
            //查询服务器最新邮件UID
            MCOPOPMessageInfo *theLasetmessageInfo = messages[0];
            NSString * theLastMessageUID = theLasetmessageInfo.uid;
            NSLog(@"Server UID = %@", theLastMessageUID);
            
            //查询缓存中存邮件的个数
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Message"];
            fetchRequest.resultType = NSCountResultType;
            NSError *fetchError = nil;
            NSUInteger itemsCount = [self.managedObjectContext countForFetchRequest:fetchRequest error:&fetchError];
            if (itemsCount == NSNotFound) {
                NSLog(@"Fetch error: %@", fetchError);
            }
            NSLog(@"数据库中存有%lu个数据", (unsigned long)itemsCount);

            if (itemsCount > 0)
            {
                //返回全部
                NSUInteger fetchNum = 0;
                //顺序排序
                BOOL SortType = NO;
                //排序字段
                NSString * OrderType = @"messagedate";
                //查询CoreData
                NSArray *resultValue = [self GetSortMessageInfo:OrderType sorttype:SortType limit:fetchNum];
                NSManagedObject *object = resultValue[0];
                NSString * messageIndex = [object valueForKey:@"uid"];
                NSLog(@"Store UID = %@", messageIndex);
                
                //缓存中的邮件与服务器上的邮件同步,更新index 或删除缓存中的邮件
                NSMutableArray * MutableMessagesServer = [[NSMutableArray alloc] initWithArray:messages];
                NSMutableArray * MutableMessagesStore = [[NSMutableArray alloc] initWithArray:resultValue];
                
                BOOL isFindStoreMailInServer = false;
                
                for(int i = 0; i < MutableMessagesStore.count; i++){
                    isFindStoreMailInServer = false;
                    MCOPOPMessageInfo *messageinfoStore = MutableMessagesStore[i];
                    for(id objServer in MutableMessagesServer){
                        MCOPOPMessageInfo *messagesinfoServer = objServer;
                        if ([messageinfoStore.uid isEqualToString:messagesinfoServer.uid]) {
                            isFindStoreMailInServer = true;
                            //判断同一封邮件在缓存中的index与服务器端的index是否相同
                            if (messageinfoStore.index != messagesinfoServer.index)
                            {
                                //index不相同，同步服务器端的index到缓存中
                                NSManagedObjectContext *context = self.managedObjectContext;
                                NSEntityDescription *MessageCoreData = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
                                NSFetchRequest *request = [NSFetchRequest new];
                                [request setEntity:MessageCoreData];          //构造查询条件，相当于where子句
                                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid=%@",messageinfoStore.uid];
                                [request setPredicate:predicate];
                                NSArray *FetchAry = [context executeFetchRequest:request error:nil];
                                if (FetchAry.count > 0)
                                {
                                    NSManagedObject *obj = FetchAry[0];
                                    [obj setValue:[NSNumber numberWithInt:messagesinfoServer.index]  forKey:@"index"];
                                    [context save:nil];
                                }
                                else
                                {
                                    //查询失败
                                    break;
                                }
                            }
                        }
                    }
                    //在服务上未匹配到此邮件
                    if (!isFindStoreMailInServer)
                    {
                        //缓存中删除当前邮件
                        NSManagedObjectContext *context = self.managedObjectContext;
                        NSEntityDescription *MessageCoreData = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
                        NSFetchRequest *request = [NSFetchRequest new];
                        [request setEntity:MessageCoreData];          //构造查询条件，相当于where子句
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid=%@",messageinfoStore.uid];
                        [request setPredicate:predicate];
                        NSManagedObject *obj = [[context executeFetchRequest:request error:nil] lastObject];
                        if (obj) {
                            [context deleteObject:obj];
                            [context save:nil];
                        }
                        //数组中删除当前邮件
                        [MutableMessagesStore removeObjectAtIndex:i];
                    }

                }
                
                //存在新邮件，下载新邮件
                if (![messageIndex isEqualToString:theLastMessageUID])
                {
                    NSLog(@"加载新邮件!!");
                    for (int i = 0; i <= messages.count -1 ; i++) {
                        MCOPOPMessageInfo *messageInfo = messages[i];
                        NSUInteger messageSize = messageInfo.size;
                        BOOL messageBodyUsed = false;
                        if ((messageSize/1024) < 512) messageBodyUsed = true;
                        //异步接收邮件
                        NSEntityDescription *MessageCoreData = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:self.managedObjectContext];
                        NSFetchRequest *request = [NSFetchRequest new];
                        [request setEntity:MessageCoreData];          //构造查询条件，相当于where子句
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid=%@",messageInfo.uid];
                        [request setPredicate:predicate];
                        NSArray *FetchAry = [self.managedObjectContext executeFetchRequest:request error:nil];
                        if (FetchAry.count == 0)
                        {
                            //异步接收邮件
                            self.popHeaderFetchOp = [[[AuthManager sharedManager] getPopSession] fetchHeaderOperationWithIndex:messageInfo.index];
                            [self.popHeaderFetchOp start:^(NSError * error, MCOMessageHeader * header) {
                                if(messageBodyUsed)
                                {
                                    //邮件体收取
                                    MCOPOPFetchMessageOperation * messageOperation=[[[AuthManager sharedManager] getPopSession] fetchMessageOperationWithIndex: messageInfo.index];
                                    
                                    //开启异步请求, messageData为邮件内容
                                    [messageOperation start:^(NSError * error, NSData *messageData) {
                                        //接收邮件体成功
                                        if (!error) {
                                            //插入CoreData数据库
                                            [self inserCoreData:messageInfo messageHeaderStore:header messageBodyStore:messageData useMessageBody:@"true"];
                                        }else{
                                            NSLog(@"存在新邮件，获取邮件消息失败");
                                        }
                                    }];
                                }
                                else
                                {
                                    [self inserCoreData:messageInfo messageHeaderStore:header messageBodyStore:nil useMessageBody:@"false"];
                                }
                            }];
                        }
                        else
                        {
                            //查找到第一条缓存中已经存在的邮件，判断加载新邮件结束
                            break;
                        }
                    }
                }
            }
            else
            {   //没有缓存,加载邮件， 默认加载指定封邮件
                for (int i = 0; i < loadMailCount; i++)
                {
                    MCOPOPMessageInfo *messageInfo = messages[i];
                    NSUInteger messageSize = messageInfo.size;
                    BOOL messageBodyUsed = false;
                    if ((messageSize/1024) < 512) messageBodyUsed = true;
                    //异步接收邮件
                    self.popHeaderFetchOp = [[[AuthManager sharedManager] getPopSession] fetchHeaderOperationWithIndex:messageInfo.index];
                    [self.popHeaderFetchOp start:^(NSError * error, MCOMessageHeader * header) {
                        //辞职或许需要被删除
                        //[POPHeaderDatas addObject:header];
                        if(messageBodyUsed)
                        {
                            //邮件体收取
                            MCOPOPFetchMessageOperation * messageOperation=[[[AuthManager sharedManager] getPopSession] fetchMessageOperationWithIndex: messageInfo.index];
                            
                            //开启异步请求, messageData为邮件内容
                            [messageOperation start:^(NSError * error, NSData *messageData) {
                                //接收邮件体成功
                                if (!error) {
                                    //插入CoreData数据库
                                    [self inserCoreData:messageInfo messageHeaderStore:header messageBodyStore:messageData useMessageBody:@"true"];
                                }else{
                                    NSLog(@"没有新邮件，获取邮件消息失败");
                                }
                                
                                //接收到 全部邮件开始操作
                                if (i == loadMailCount -1) {
                                    //收件完成加载显示
                                    block(error, self.POPmessagesInfo, nil);
                                }
                            }];
                        }
                        else
                        {
                            [self inserCoreData:messageInfo messageHeaderStore:header messageBodyStore:nil useMessageBody:@"false"];
                        }

                    }];
                }
            }
        }
    }];
    [self.refreshControl endRefreshing];
    [[AuthManager sharedManager] logout];
}

- (void)inserCoreData:(MCOPOPMessageInfo*)messageInfo messageHeaderStore:(MCOMessageHeader*)header messageBodyStore:(NSData *)messageBody useMessageBody:(NSString*) existBody
{
    //写入本地缓存
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    NSString * fromText = header.from.displayName ? header.from.displayName : header.from.mailbox;
    NSString *subjectText = @"";
    if (nil == [header subject] || YES == [[header subject] isEqual:@""]) {
        subjectText = @"No Title";
    } else {
        subjectText = [header subject];
    }
    NSString *MessageID = [header messageID];
    NSDate * MessageDate = [header date];
    //发件人
    [newManagedObject setValue:fromText forKey:@"fromtext"];
    //主题
    [newManagedObject setValue:subjectText forKey:@"subjecttext"];
    //邮件索引序列号
    [newManagedObject setValue:[NSNumber numberWithInt:messageInfo.index] forKey:@"index"];
    //邮件唯一标识
    [newManagedObject setValue:messageInfo.uid forKey:@"uid"];
    //邮件ID
    [newManagedObject setValue:MessageID forKey:@"messageid"];
    //邮件大小
    [newManagedObject setValue:[NSNumber numberWithInt:messageInfo.size] forKey:@"messagesize"];
    //邮件接收时间
    [newManagedObject setValue:MessageDate forKey:@"messagedate"];
    //已读读标记
    [newManagedObject setValue:@"false" forKey:@"readsign"];
    
    if ([existBody isEqualToString:@"true"])
    {
        //存储邮件体
        [newManagedObject setValue:messageBody forKey:@"messagebody"];
    }
    //是否存在邮件体标记
    [newManagedObject setValue:existBody forKey:@"existbody"];

    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

}

#pragma mark - Table View
/*---------------------------------------
 cell高度默认为60
 --------------------------------------- */
-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    FooterView *footer = [FooterView footerView];
    footer.delegate = self;
    self.tableView.tableFooterView = footer;
}

/*
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //邮件列表被选中
    [self selectRowAtIndexPath:indexPath];
 }
 
- (void)selectRowAtIndexPath:(NSIndexPath*)indexPath {
    
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSNumber * messageIndex = [object valueForKey:@"index"];
    NSString * uid = [object valueForKey:@"uid"];
    NSData * BodyData = [object valueForKey:@"messagebody"];
    NSString * existbody = [object valueForKey:@"existbody"];
    NSString * fromtext = [object valueForKey:@"fromtext"];
    NSString * subjecttext = [object valueForKey:@"subjecttext"];
    NSString * readsign = [object valueForKey:@"readsign"];
    //获取邮件预览界面
    UIStoryboard * board = [UIStoryboard storyboardWithName:@"MailModule" bundle:nil];
    MCTMsgViewController * next = [board instantiateViewControllerWithIdentifier:@"MsgBodyView"];
    
    next.messageIndex = messageIndex;
    next.uid = uid;
    next.BodyData = BodyData;
    next.existbody = existbody;
    next.fromtext = fromtext;
    next.subjecttext = subjecttext;
    next.readsign = readsign;
    next.sessionPOP = [[AuthManager sharedManager] getPopSession];
    //next.delegate = self;
    
    //将此邮件设置为已读
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *MessageCoreData = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
    NSFetchRequest *request = [NSFetchRequest new];
    [request setEntity:MessageCoreData];          //构造查询条件，相当于where子句
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid=%@",uid];
    [request setPredicate:predicate];
    NSArray *FetchAry = [context executeFetchRequest:request error:nil];
    if (FetchAry.count > 0)
    {
        NSManagedObject *obj = FetchAry[0];
        [obj setValue:@"true"  forKey:@"readsign"];
        [context save:nil];
    }

    [self.navigationController pushViewController:next animated:YES];
}
 */

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"ShowMailView"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        NSNumber * messageIndex = [object valueForKey:@"index"];
        NSString * uid = [object valueForKey:@"uid"];
        NSData * BodyData = [object valueForKey:@"messagebody"];
        NSString * existbody = [object valueForKey:@"existbody"];
        NSString * fromtext = [object valueForKey:@"fromtext"];
        NSString * subjecttext = [object valueForKey:@"subjecttext"];
        NSString * readsign = [object valueForKey:@"readsign"];
        
        MCTMsgViewController *next = (MCTMsgViewController *)[[segue destinationViewController] topViewController];
        next.messageIndex = messageIndex;
        next.uid = uid;
        next.BodyData = BodyData;
        next.existbody = existbody;
        next.fromtext = fromtext;
        next.subjecttext = subjecttext;
        next.readsign = readsign;
        next.sessionPOP = [[AuthManager sharedManager] getPopSession];
        next.navigationItem.title = @"邮件";
        //next.delegate = self;
        
        //将此邮件设置为已读
        NSManagedObjectContext *context = self.managedObjectContext;
        NSEntityDescription *MessageCoreData = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
        NSFetchRequest *request = [NSFetchRequest new];
        [request setEntity:MessageCoreData];          //构造查询条件，相当于where子句
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid=%@",uid];
        [request setPredicate:predicate];
        NSArray *FetchAry = [context executeFetchRequest:request error:nil];
        if (FetchAry.count > 0)
        {
            NSManagedObject *obj = FetchAry[0];
            [obj setValue:@"true"  forKey:@"readsign"];
            [context save:nil];
        }
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
    //return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
    //    return self.messages.count;
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
    NSString * fromText = [object valueForKey:@"fromtext"];
    NSString * subjectText = [object valueForKey:@"subjecttext"];
    NSString * readsign = [object valueForKey:@"readsign"];
    
    //NSDate转换NSString
    NSDate * messagedate = [object valueForKey:@"messagedate"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:messagedate];
    //写入数据字典用来传递参数
    NSMutableDictionary * MessageHeader = [[NSMutableDictionary alloc] init];
    [MessageHeader setObject:fromText forKey:@"fromtext"];
    [MessageHeader setObject:subjectText forKey:@"subjecttext"];
    [MessageHeader setObject:strDate forKey:@"maildate"];
    [MessageHeader setObject:readsign forKey:@"readsign"];
    
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messagedate" ascending:NO];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
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

#pragma mark - FooterView controller Delegate
- (void)FooterViewClickedloadMoreData
{
    //返回个数
    NSUInteger fetchNum = 0;
    //顺序排序
    BOOL SortType = YES;
    //排序字段
    NSString * OrderType = @"messagedate";
    //查询CoreData
    NSArray *resultValue = [self GetSortMessageInfo:OrderType sorttype:SortType limit:fetchNum];
    
    //查询服务器最新邮件信息
    self.popMessagesFetchOp = [[[AuthManager sharedManager] getPopSession] fetchMessagesOperation];
    [self.popMessagesFetchOp start:^(NSError *error, NSArray *messages ) {
        //邮件信息倒叙排序，新邮件在前
        NSSortDescriptor *sortMessageInfo = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:NO];
        messages = [messages sortedArrayUsingDescriptors:@[sortMessageInfo]];
        
        NSMutableArray * MutableMessagesServer = [[NSMutableArray alloc] initWithArray:messages];
        NSMutableArray * MutableMessagesStore = [[NSMutableArray alloc] initWithArray:resultValue];
        BOOL isFindTheOldMessageInStore = false;
        MCOPOPMessageInfo * MessageinfoInServer;
        for(id objStore in MutableMessagesStore){
            MCOPOPMessageInfo *messageinfoStore = objStore;
            for(id objServer in MutableMessagesServer){
                MCOPOPMessageInfo *messagesinfoServer = objServer;
                if ([messageinfoStore.uid isEqualToString:messagesinfoServer.uid]) {
                    isFindTheOldMessageInStore = YES;
                    //将找到的MessageInfo传递出循环
                    MessageinfoInServer = messagesinfoServer;
                }
            }
            if (isFindTheOldMessageInStore)
            {
                //只要匹配到一次就结束循环
                break;
            }
        }
        
        //邮件信息倒叙排序，旧邮件在前
        sortMessageInfo = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
        messages = [messages sortedArrayUsingDescriptors:@[sortMessageInfo]];
        //找到数据库中要接收的第一封邮箱的index
        int ServerIndex;
        if (!isFindTheOldMessageInStore)
        {
            //数据库中的所有邮件在服务上都未找到,
            MessageinfoInServer = messages[0];
            ServerIndex = MessageinfoInServer.index;
            isFindTheOldMessageInStore = YES;
        }
        else
        {
            //将ServerIndex指向下一封邮件， 因为数组索引从0 开始，说以减去2
            ServerIndex = (MessageinfoInServer.index) - 2;
        }

        int MessageCountCanReceive;
        if (ServerIndex < loadMailCount)
        {
            MessageCountCanReceive = ServerIndex;
        }
        else
        {
            MessageCountCanReceive = loadMailCount;
        }
        if (ServerIndex >= 0) {
            //服务器端有可收取的邮件
            for (int i = MessageCountCanReceive; i >= 0; i--)
            {
                MCOPOPMessageInfo *messageInfo = messages[ServerIndex];
                NSUInteger messageSize = messageInfo.size;
                BOOL messageBodyUsed = false;
                if ((messageSize/1024) < 512) messageBodyUsed = true;
                if (MessageCountCanReceive >= 0) {
                    //异步接收邮件
                    self.popHeaderFetchOp = [[[AuthManager sharedManager] getPopSession] fetchHeaderOperationWithIndex:messageInfo.index];
                    [self.popHeaderFetchOp start:^(NSError * error, MCOMessageHeader * header) {
                        if(messageBodyUsed)
                        {
                            //邮件体收取
                            MCOPOPFetchMessageOperation * messageOperation=[[[AuthManager sharedManager] getPopSession] fetchMessageOperationWithIndex: messageInfo.index];
                            
                            //开启异步请求, messageData为邮件内容
                            [messageOperation start:^(NSError * error, NSData *messageData) {
                                //接收邮件体成功
                                if (!error) {
                                    //插入CoreData数据库
                                    [self inserCoreData:messageInfo messageHeaderStore:header messageBodyStore:messageData useMessageBody:@"true"];
                                    if (i == 0)
                                    {
                                        //发送消息，给FooterView，停止转圈圈
                                    }
                                }else{
                                    NSLog(@"加载更多，获取邮件消息失败");
                                }
                            }];
                        }
                        else
                        {
                            [self inserCoreData:messageInfo messageHeaderStore:header messageBodyStore:nil useMessageBody:@"false"];
                        }
                    }];
                }
                else
                {
                    //跳出循环
                    break;
                }
                
                MessageCountCanReceive --;
                ServerIndex --;
            }
        }
    }];
    [[AuthManager sharedManager] logout];
}

- (NSArray *)GetSortMessageInfo:(NSString*) OrderType sorttype:(BOOL)Bsort limit:(NSUInteger)LimitNum
{
    //缓存中存储最旧一封邮件的UID，及时间
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:OrderType ascending:Bsort];
    NSEntityDescription * emEty = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:emEty];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    if(LimitNum != 0)
        [request setFetchLimit:LimitNum];
    NSArray *objs =[self.managedObjectContext executeFetchRequest:request error:nil];
    
    return objs;
}

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
