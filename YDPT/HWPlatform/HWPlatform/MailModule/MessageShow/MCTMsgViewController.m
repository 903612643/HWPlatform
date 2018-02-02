//
//  MCTMsgViewController.m
//  HWMail
//
//  Created by hanwei on 15/10/29.
//  Copyright © 2015年 HanWei. All rights reserved.
//

#import "MCTMsgViewController.h"
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>
#import <CoreData/CoreData.h>
#import "MailBoxDataManager.h"


#import <MobileCoreServices/MobileCoreServices.h>

#import "ComposerViewController.h"
#import "AuthManager.h"
#import "MBProgressHUD.h"
//#import "UIPopoverController+FlatUI.h"
//#import "UIColor+FlatUI.h"
//#import "UTIFunctions.h"

@interface MCTMsgViewController ()
{

}
@end

@implementation MCTMsgViewController

- (void)viewDidLoad {
    if (!self.messageIndex){
        return;
    }
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.18 green:0.54 blue:1 alpha:1]];
    
    //Remove all the underlying subviews;
//    [[self.view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.view.backgroundColor = [UIColor whiteColor];
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
//    self.navigationItem.backBarButtonItem = item;
//    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    //创建滚动视图
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64/*顶部导航工具栏和系统状态栏*/ - 44/*底部工具栏*/)];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.scrollEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = YES;
    _scrollView.showsVerticalScrollIndicator = YES;
    _scrollView.directionalLockEnabled = YES;
    _scrollView.backgroundColor = [UIColor whiteColor];
    
    //转圈圈等待下载完成
    [self showSpinner];
    
    if([_existbody isEqualToString:@"false"])
    {
        MCOPOPFetchMessageOperation * messageOperation=[[[AuthManager sharedManager] getPopSession]fetchMessageOperationWithIndex: [self.messageIndex intValue]];
        
        //完成百分比Block，未知原因不执行
        messageOperation.progress = ^(unsigned int current, unsigned int maximum){
            NSLog(@"当前下载的邮件index是：%d, 下载总大小是：%d, 当前下载进度是：%d", [self.messageIndex intValue], maximum, current);
        };
//        [messageOperation setProgress:^(unsigned int current, unsigned int maximum) {
//            NSLog(@"当前下载的邮件index是：%d, 下载总大小是：%d, 当前下载进度是：%d", [self.messageIndex intValue], maximum, current);
//        }];
        
        //开启异步请求, messageData为邮件内容
        [messageOperation start:^(NSError * error, NSData *messageData) {
            
            // messageData is the RFC 822 formatted message data.
            if (!error) {
                NSManagedObjectContext *context = [MailBoxDataManager sharedInstance].managedObjectContext;
                NSEntityDescription *MessageCoreData = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
                NSFetchRequest *request = [NSFetchRequest new];
                [request setEntity:MessageCoreData];          //构造查询条件，相当于where子句
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid=%@",_uid];
                [request setPredicate:predicate];
                NSArray *FetchAry = [context executeFetchRequest:request error:nil];
                if (FetchAry.count > 0)
                {
                    NSManagedObject *obj = FetchAry[0];
                    [obj setValue:messageData  forKey:@"messagebody"];
                    [obj setValue:@"true"  forKey:@"existbody"];
                    [context save:nil];
                }
                else
                {
                    //查询失败
                }
                //由data转换为MCOMessageParser
                MCOMessageParser * msgPaser =[MCOMessageParser messageParserWithData:messageData];
                _messagePOP = msgPaser;
                [self LoadMailBody];
            }
        }];
    }
    else
    {
        //由data转换为MCOMessageParser
        MCOMessageParser * msgPaser =[MCOMessageParser messageParserWithData:_BodyData];
        _messagePOP = msgPaser;
        [self LoadMailBody];
    }
}

- (void)LoadMailBody
{
    //邮件体中包含的附件
    NSMutableArray * attachments = [[NSMutableArray alloc] initWithArray:_messagePOP.attachments];
    //初始化邮件信息头
    _headerView = [[HeaderView alloc] initWithFrame:_scrollView.bounds message:_messagePOP Attachments:attachments];
    _headerView.delegate = self;
    [_scrollView addSubview:_headerView];
    
    //初始化邮件内容视图
    _messageContentsView = [[UIView alloc] initWithFrame:CGRectMake(0, _headerView.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height-_headerView.frame.size.height)];
    _messageContentsView.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:_messageContentsView];
    
    //邮件体试图
    _messageView = [[MCOMessageView alloc] initWithFrame:CGRectMake(0, _headerView.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height-_headerView.frame.size.height)];
    [_messageView setMessage:_messagePOP];
    [_messageView setDelegate:self];
    [_messageContentsView addSubview:_messageView];
    
    [self.view addSubview:_scrollView];
    
    //    if (_message){
    //        [self showSpinner];
    //    }
    //if (_messagePOP){
    //    [self showSpinner];
    //}
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(didLongPressOnMessageContentsView:)];
    [longPress setDelegate:self];
    [longPress setMinimumPressDuration:0.8f];
    
    [_messageContentsView addGestureRecognizer:longPress];
}

-(void)didLongPressOnMessageContentsView:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer && recognizer.state == UIGestureRecognizerStateRecognized)
    {
        CGPoint point = [recognizer locationInView:_messageContentsView];
        [_messageView handleTapAtpoint:point];
    }
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    //Update the underlying webview with the new bounds
    //We don't know it yet for sure, but we can predict it
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
        _messageView.frame = CGRectMake(0, 0, 703, 724);
    } else {
        //You don't want to do this as it will flash the underlying content. Just wait it out.
        //_messageView.frame = CGRectMake(0, 0, 447, 980);
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    //Update the underlying webview with the new bounds;
    _messageView.frame = self.view.bounds;
    [_headerView render];
}


- (void) showSpinner {
    [MBProgressHUD showHUDAddedTo:[self view] animated:YES];
}

- (void) hideSpinner {
    [MBProgressHUD hideAllHUDsForView:[self view] animated:NO];
}

- (NSString *) msgContent {
    return [[[_messageView getMessage] mco_flattenHTML] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (IBAction)ReturnButtonOn:(UIButton *)sender {
    //返回按钮被点中，返回主界面
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return _messageView.gestureRecognizerEnabled;
}

#pragma mark - MCOMessageViewDelegate

- (NSString *) MCOMessageView_templateForAttachmentSeparator:(MCOMessageView *)view {
    return @"";
}

- (NSString *) MCOMessageView_templateForAttachment:(MCOMessageView *)view
{
    // No need for attachments to be displayed. Using Native HeaderView instead.
    return @"";    
}

- (NSString *) MCOMessageView_templateForMainHeader:(MCOMessageView *)view {
    // No need for main header. Using Native HeaderView instead.
    return @"";
}

- (NSString *) MCOMessageView_templateForImage:(MCOMessageView *)view {
    // Disable inline image attachments. Using Native HeaderView instead.
    return @"";
}

- (NSString *) MCOMessageView_templateForMessage:(MCOMessageView *)view
{
    return @"{{BODY}}";
}

- (BOOL) MCOMessageView:(MCOMessageView *)view canPreviewPart:(MCOAbstractPart *)part
{
    return NO;
}

- (NSData *) MCOMessageView:(MCOMessageView *)view dataForPartWithUniqueID:(NSString *)partUniqueID
{
    //NSData * data = [_storage objectForKey:partUniqueID];
    NSLog(@"in dataForPartWithUniqueID !!!!!!");
    NSData * data = nil;
    return data;
}

- (void) MCOMessageView:(MCOMessageView *)view fetchDataForPartWithUniqueID:(NSString *)partUniqueID
     downloadedFinished:(void (^)(NSError * error))downloadFinished
{
    // colin need modify it
    //    MCOIMAPFetchContentOperation * op = [self _fetchIMAPPartWithUniqueID:partUniqueID folder:_folder];
    //    [op setProgress:^(unsigned int current, unsigned int maximum) {
    //        MCLog("progress content: %u/%u", current, maximum);
    //    }];
    //    if (op != nil) {
    //        [_ops addObject:op];
    //    }
    //    if (downloadFinished != NULL) {
    //        NSMutableArray * blocks;
    //        blocks = [_callbacks objectForKey:partUniqueID];
    //        if (blocks == nil) {
    //            blocks = [NSMutableArray array];
    //            [_callbacks setObject:blocks forKey:partUniqueID];
    //        }
    //        [blocks addObject:[downloadFinished copy]];
    //    }
}

- (void) MCOMessageView:(MCOMessageView *)view handleMailtoUrlString:(NSString *)mailtoAddress
{
    ComposerViewController *vc = [[ComposerViewController alloc] initWithTo:@[mailtoAddress]
                                                                         CC:@[]
                                                                        BCC:@[]
                                                                    subject:@""
                                                                    message:@""
                                                                attachments:@[]
                                                         delayedAttachments:@[]];
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    nc.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:nc animated:YES completion:nil];
}


- (void) MCOMessageView:(MCOMessageView *)view
   didTappedInlineImage:(UIImage *)inlineImage
                atPoint:(CGPoint)point
              imageRect:(CGRect)rect
              imagePath:(NSString *)path
              imageName:(NSString *)imgName
          imageMimeType:(NSString *)mimeType
{
    /*
    if (!_actionPicker)
    {
        _actionPicker = [[ActionPickerViewController alloc] initWithStyle:UITableViewStylePlain];
        _actionPicker.delegate = self;
    }
    
    _actionPicker.image = inlineImage;
    _actionPicker.imagePath = path;
    _actionPicker.imageName = imgName;
    _actionPicker.imageMimeType = mimeType;
    
    if (!_actionPickerPopover)
    {
        _actionPickerPopover = [[UIPopoverController alloc] initWithContentViewController:_actionPicker];
        [_actionPickerPopover setDelegate:self];
        
        [_actionPickerPopover configureFlatPopoverWithBackgroundColor:[UIColor colorFromHexCode:@"f1f1f1"]
                                                         cornerRadius:5.f];
    }
    
    [_actionPickerPopover presentPopoverFromRect:rect
                                          inView:_messageContentsView
                        permittedArrowDirections:UIPopoverArrowDirectionAny
                                        animated:YES];
     */
}

- (NSData *) MCOMessageView:(MCOMessageView *)view previewForData:(NSData *)data isHTMLInlineImage:(BOOL)isHTMLInlineImage
{
    if (isHTMLInlineImage) {
        return data;
    }
    else {
        return [self _convertToJPEGData:data];
    }
}

#define IMAGE_PREVIEW_HEIGHT 300
#define IMAGE_PREVIEW_WIDTH 500

- (NSData *) _convertToJPEGData:(NSData *)data {
    CGImageSourceRef imageSource;
    CGImageRef thumbnail;
    NSMutableDictionary * info;
    int width;
    int height;
    float quality;

    width = IMAGE_PREVIEW_WIDTH;
    height = IMAGE_PREVIEW_HEIGHT;
    quality = 1.0;

    imageSource = CGImageSourceCreateWithData((__bridge CFDataRef) data, NULL);
    if (imageSource == NULL)
        return nil;

    info = [[NSMutableDictionary alloc] init];
    [info setObject:(id) kCFBooleanTrue forKey:(id) kCGImageSourceCreateThumbnailWithTransform];
    [info setObject:(id) kCFBooleanTrue forKey:(id) kCGImageSourceCreateThumbnailFromImageAlways];
    [info setObject:(id) [NSNumber numberWithFloat:(float) IMAGE_PREVIEW_WIDTH] forKey:(id) kCGImageSourceThumbnailMaxPixelSize];
    thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (__bridge CFDictionaryRef) info);

    CGImageDestinationRef destination;
    NSMutableData * destData = [NSMutableData data];

    destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef) destData,
                                                   (CFStringRef) @"public.jpeg",
                                                   1, NULL);
    
    CGImageDestinationAddImage(destination, thumbnail, NULL);
    CGImageDestinationFinalize(destination);

    CFRelease(destination);

    CFRelease(thumbnail);
    CFRelease(imageSource);

    return destData;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {

    [self hideSpinner];
    
    CGFloat contentHeight = webView.scrollView.contentSize.height;
    CGFloat contentWidth = webView.scrollView.contentSize.width;
    contentHeight = contentHeight > (self.view.bounds.size.height - _headerView.bounds.size.height) ? contentHeight : (self.view.bounds.size.height - _headerView.bounds.size.height);

    _messageContentsView.frame = CGRectMake(_messageContentsView.frame.origin.x, _messageContentsView.frame.origin.y, contentWidth, contentHeight);
    
    for (UIView *v in webView.scrollView.subviews){
        [_messageContentsView addSubview:v];
    }
    
    _scrollView.contentSize = CGSizeMake(_messageContentsView.bounds.size.width, _headerView.bounds.size.height + _messageContentsView.bounds.size.height);
}

/*
- (IBAction)ReplyMailButtonOn:(id)sender {
    //答复按钮被点中
    NSLog(@"答复按钮被点中");
    ComposerViewController *vc = [[ComposerViewController alloc] initWithTo:@[]
    CC:@[]
    BCC:@[]
    subject:@""
    message:@""
    attachments:@[]
    delayedAttachments:@[]];
     
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    nc.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:nc animated:YES completion:nil];
}
 */

- (IBAction)DeleteButtonOn:(id)sender {
    //删除按钮被点中
    NSLog(@"删除按钮被点中");
    //删除服务器端邮件
    if (_messageIndex)
    {
        MCOIndexSet * indexes = [MCOIndexSet indexSet];
        [indexes addIndex:[self.messageIndex intValue]];
        MCOPOPOperation * messageOperation=[[[AuthManager sharedManager] getPopSession] deleteMessagesOperationWithIndexes:indexes];
        //开启异步请求, messageData为邮件内容
        [messageOperation start:^(NSError * error) {
            
            // messageData is the RFC 822 formatted message data.
            if (!error) {
                //由data转换为MCOMessageParser
                //删除本地缓存邮件
                NSManagedObjectContext *context = [MailBoxDataManager sharedInstance].managedObjectContext;
                NSEntityDescription *MessageCoreData = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
                NSFetchRequest *request = [NSFetchRequest new];
                [request setEntity:MessageCoreData];          //构造查询条件，相当于where子句
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid=%@",_uid];
                [request setPredicate:predicate];
                NSManagedObject *obj = [[context executeFetchRequest:request error:nil] lastObject];
                if (obj) {
                    [context deleteObject:obj];
                    [context save:nil];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"RequesetLoadMail"
                                                                        object:nil];
                    
                    //页面返回
                    [self dismissViewControllerAnimated:YES completion:NULL];
                }
            }
        }];
        
        [[AuthManager sharedManager] logout];
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    //邮件答复
    if ([[segue identifier] isEqualToString:@"replayMail"])
    {
        ComposerViewController *controller = (ComposerViewController *)[[segue destinationViewController] topViewController];
        
        NSArray *recipients = @[];
        NSArray *cc = @[];
        NSArray *bcc = @[];
        NSString *subject = [[[self messagePOP] header] subject];
  
        subject = [[[[self messagePOP] header] replyHeaderWithExcludedRecipients:@[]] subject];
        recipients = @[[[[[[self messagePOP] header] replyHeaderWithExcludedRecipients:@[]] to] mco_nonEncodedRFC822StringForAddresses]];

        NSString *body = @"";
        if ([self msgContent]){
            NSString *date = [NSDateFormatter localizedStringFromDate:[[[self messagePOP] header] date]
                                                            dateStyle:NSDateFormatterMediumStyle
                                                            timeStyle:NSDateFormatterMediumStyle];
            
            NSString *replyLine = [NSString stringWithFormat:@"On %@, %@ wrote:", date, [[[[self messagePOP] header] from]nonEncodedRFC822String] ];
            body = [NSString stringWithFormat:@"\n\n\n%@\n> %@", replyLine, [[self msgContent] stringByReplacingOccurrencesOfString:@"\n" withString:@"\n> "]];
        }

        if ([body length] > 0){
            controller.bodyString = body;
        } else {
            controller.bodyString = @"";
        }
//        _attachmentsArray = [NSMutableArray arrayWithArray:attachments];//attachments;
//        _delayedAttachmentsArray = delayedAttachments;

        controller.toString = [controller emailStringFromArray:recipients];
        controller.ccString = [controller emailStringFromArray:cc];
        controller.bccString = [controller emailStringFromArray:bcc];
        controller.subjectString = subject;
//        controller.writeDate = strDate;
        controller.navigationItem.title = @"回复";
    }
    
    //邮件转发
    if ([[segue identifier] isEqualToString:@"ReplayAll"])
    {
        ComposerViewController *controller = (ComposerViewController *)[[segue destinationViewController] topViewController];
        
        NSArray *recipients = @[];
        NSString *subject = [[[self messagePOP] header] subject];
        
        subject = [[[[self messagePOP] header] replyHeaderWithExcludedRecipients:@[]] subject];
        recipients = @[[[[[[self messagePOP] header] replyHeaderWithExcludedRecipients:@[]] to] mco_nonEncodedRFC822StringForAddresses]];
        //答复全部
        //        if ( [@[@"Reply All"] containsObject:type]){
        //            cc = @[[[[[msg header] replyAllHeaderWithExcludedRecipients:@[]] cc] mco_nonEncodedRFC822StringForAddresses]];
        //        }
        
        NSString *body = @"";
        if ([self msgContent]){
            body = [NSString stringWithFormat:@"%@", [self msgContent]];
        }
        
        if ([body length] > 0){
            controller.bodyString = body;
        } else {
            controller.bodyString = @"";
        }
        
        //邮件体中包含的附件
        NSMutableArray * attachments = [[NSMutableArray alloc] initWithArray:_messagePOP.attachments];
        controller.attachmentsArray = attachments;
        controller.toString = @"";
        controller.ccString = @"";
        controller.bccString = @"";
        controller.subjectString = subject;
        controller.navigationItem.title = @"转发";
    }
}

@end
