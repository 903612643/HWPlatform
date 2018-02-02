//
//  ComposerViewController.m
//  ThatInbox
//
//  Created by Liyan David Chang on 7/31/13.
//  Copyright (c) 2013 Ink. All rights reserved.
//

#import "ComposerViewController.h"
//#import "FlatUIKit.h"
//#import "UIPopoverController+FlatUI.h"
#import "AuthManager.h"
//#import "TRAutocompleteView.h"
//#import "TRAddressBookSource.h"
//#import "TRAddressBookCellFactory.h"
#import "NSString+Email.h"
//#import "UIPopoverController+FlatUI.h"
//#import "FUIButton.h"
//#import "UTIFunctions.h"

#import "MCOMessageView.h"

//#import <FPPicker/FPPicker.h>
//#import "DelayedAttachment.h"
#import "FPMimetype.h"
#import "IQUIView+IQKeyboardToolbar.h"
#import "UIColor+ColorWithHex.h"
#import "UIActionSheet+Blocks.h"

typedef enum
{
    ToTextFieldTag,
    CcTextFieldTag,
    SubjectTextFieldTag
}TextFildTag;

@interface ComposerViewController ()
//@property (nonatomic, strong) UIPopoverController *filepickerPopover;
//@property (weak, nonatomic) IBOutlet UIView *attachmentSeparatorView;
//@property (weak, nonatomic) IBOutlet UILabel *attachmentsTitleLabel;

-(void)previousAction:(id)sender;
-(void)nextAction:(id)sender;
-(void)doneAction:(id)sender;

@end

@implementation ComposerViewController {

//    TRAutocompleteView *_autocompleteView;
//    TRAutocompleteView *_autocompleteViewCC;
    
    UIPopoverController *pop;
    
    BOOL keyboardState;
}

@synthesize toField, ccField, subjectField, messageBox;

- (id)initWithMessage:(MCOMessageParser *)msg
               ofType:(NSString*)type
              content:(NSString*)content
          attachments:(NSArray *)attachments
   delayedAttachments:(NSArray *)delayedAttachments
{
    self = [super init];
    
    NSArray *recipients = @[];
    NSArray *cc = @[];
    NSArray *bcc = @[];
    NSString *subject = [[msg header] subject];
    
    if ([type isEqual: @"Forward"]){
        //TODO: Will crash if subject is null
        if (subject){
            subject = [[[msg header] forwardHeader] subject];
        }
    }
    
    if ( [@[@"Reply", @"Reply All"] containsObject:type]){
        
        subject = [[[msg header] replyHeaderWithExcludedRecipients:@[]] subject];
        recipients = @[[[[[msg header] replyHeaderWithExcludedRecipients:@[]] to] mco_nonEncodedRFC822StringForAddresses]];
    }
    if ( [@[@"Reply All"] containsObject:type]){
        cc = @[[[[[msg header] replyAllHeaderWithExcludedRecipients:@[]] cc] mco_nonEncodedRFC822StringForAddresses]];
    }
    
    NSString *body = @"";
    if (content){
        NSString *date = [NSDateFormatter localizedStringFromDate:[[msg header] date]
                                                        dateStyle:NSDateFormatterMediumStyle
                                                        timeStyle:NSDateFormatterMediumStyle];
        
        NSString *replyLine = [NSString stringWithFormat:@"On %@, %@ wrote:", date, [[[msg header] from]nonEncodedRFC822String] ];
        body = [NSString stringWithFormat:@"\n\n\n%@\n> %@", replyLine, [content stringByReplacingOccurrencesOfString:@"\n" withString:@"\n> "]];
    }
    return [self initWithTo:recipients CC:cc BCC:bcc subject:subject message:body attachments:attachments delayedAttachments:delayedAttachments];
}

- (id)initWithTo:(NSArray *)to
              CC:(NSArray *)cc
             BCC:(NSArray *)bcc
         subject:(NSString *)subject
         message:(NSString *)message
     attachments:(NSArray *)attachments
delayedAttachments:(NSArray *)delayedAttachments
{
    self = [super init];
    
    _toString = [self emailStringFromArray:to];
    _ccString = [self emailStringFromArray:cc];
    _bccString = [self emailStringFromArray:bcc];
    _subjectString = subject;
    if ([message length] > 0){
        _bodyString = message;
    } else {
        _bodyString = @"";
    }
    _attachmentsArray = [NSMutableArray arrayWithArray:attachments];//attachments;
    _delayedAttachmentsArray = delayedAttachments;
    
    return self;
}

- (id)initWithToNoAttachments:(NSString *)to
              CC:(NSString *)cc
             BCC:(NSString *)bcc
         subject:(NSString *)subject
         message:(NSString *)message
        wirteDate:(NSString*)writedate
{
    self = [super init];
    
    _toString = to;
    _ccString = cc;
    _bccString = bcc;
    _subjectString = subject;
    //邮件编写时间
    _writeDate = writedate;
    if ([message length] > 0){
        _bodyString = message;
    } else {
        _bodyString = @"";
    }
//    _attachmentsArray = [NSMutableArray arrayWithArray:attachments];//attachments;
//    _delayedAttachmentsArray = delayedAttachments;
    
    return self;
}

//键盘上一下项
-(void)previousAction:(id)sender
{
    if ([messageBox isFirstResponder])
    {
        [subjectField becomeFirstResponder];
    }
    else if ([subjectField isFirstResponder])
    {
        [ccField becomeFirstResponder];
    }
    else if ([ccField isFirstResponder])
    {
        [toField becomeFirstResponder];
    }
}

//键盘下一项
-(void)nextAction:(id)sender
{
    if ([toField isFirstResponder])
    {
        [ccField becomeFirstResponder];
    }
    else if ([ccField isFirstResponder])
    {
        [subjectField becomeFirstResponder];
    }
    else if ([subjectField isFirstResponder])
    {
        [messageBox becomeFirstResponder];
    }
}

//键盘完成按键响应事件
-(void)doneAction:(id)sender
{
    [self.view endEditing:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    keyboardState = NO;
    
    //设置不被键盘遮挡
//    [toField addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousAction:) nextAction:@selector(nextAction:) doneAction:@selector(doneAction:)];
//    [toField setEnablePrevious:NO next:YES];
//    
//    [ccField addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousAction:) nextAction:@selector(nextAction:) doneAction:@selector(doneAction:)];
//    
//    [subjectField addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousAction:) nextAction:@selector(nextAction:) doneAction:@selector(doneAction:)];
//    
//    [messageBox addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousAction:) nextAction:@selector(nextAction:) doneAction:@selector(doneAction:)];
//    
//    [messageBox setEnablePrevious:YES next:NO];
    
    messageBox.textColor=[UIColor colorWithHexString:@"#999999" andAlpha:1.0];
    messageBox.delegate = self;
    //设置导航栏颜色
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.18 green:0.54 blue:1 alpha:1]];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    toField.text = _toString;
    ccField.text = _ccString;
    subjectField.text = _subjectString;
    if(!([_bodyString isEqualToString:@""]) && _bodyString != nil)
    {
        messageBox.text = _bodyString;
    }
    else
    {
        messageBox.text = @"邮件内容";
    }
    
    _AttachmentViewHeight.constant = 1;
    
    //CoreData 缓存 colin added
    self.managedObjectContext = [MailBoxDataManager sharedInstance].managedObjectContext;
    
//    TRAddressBookSource *source = [[TRAddressBookSource alloc] initWithMinimumCharactersToTrigger:2];
//    TRAddressBookCellFactory *cellFactory = [[TRAddressBookCellFactory alloc] initWithCellForegroundColor:[UIColor blackColor] fontSize:16];
//    _autocompleteView = [TRAutocompleteView autocompleteViewBindedTo:toField
//                                                         usingSource:source
//                                                         cellFactory:cellFactory
//                                                        presentingIn:self.navigationController];
//    
//    _autocompleteViewCC = [TRAutocompleteView autocompleteViewBindedTo:ccField
//                                                         usingSource:source
//                                                         cellFactory:cellFactory
//                                                        presentingIn:self.navigationController];
//
//    for (TRAutocompleteView *av in @[_autocompleteView, _autocompleteViewCC]){
//        av.separatorColor = [UIColor whiteColor];
//    }
    
    //self.navigationController.navigationBarHidden = NO;
    //[self.navigationController.navigationBar configureFlatNavigationBarWithColor:[UIColor cloudsColor]];
    
//    self.attachButton.buttonColor = [UIColor cloudsColor];
//    self.attachButton.shadowColor = [UIColor peterRiverColor];
    
//    self.navigationItem.leftBarButtonItem = backButton;
//    self.navigationItem.rightBarButtonItem = sendButton;
//    self.navigationItem.title = @"Compose";
    
    [self performSelector:@selector(configureViewForAttachments) withObject:nil/*可传任意类型参数*/ afterDelay:0.05];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWasShown:)
//                                                 name:UIKeyboardDidShowNotification
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillHide:)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:nil];
}

- (void)configureViewForAttachments
{
    if (([_attachmentsArray count] + [_delayedAttachmentsArray count]) > 0)
    {
        NSMutableArray *attachmentLabels = [[NSMutableArray alloc] init];
        
        int tag = 0;
        for (MCOAttachment* a in _attachmentsArray)
        {
            //创建一个附件视图
            UIView *contentView = [[UIView alloc]initWithFrame: CGRectMake(0,0,_AttachmentView.frame.size.width,40)];
            //创建附件图片视图
            UIImageView *AttachmentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 4, 32, 32)];
            NSString *pathToIcon = [FPMimetype iconPathForMimetype:[a mimeType] Filename:[a filename]];
            AttachmentImageView.image = [UIImage imageNamed:pathToIcon];
            AttachmentImageView.contentMode = UIViewContentModeScaleAspectFit;
            //创建附件名字Lable
            CGFloat LabelX = AttachmentImageView.frame.origin.x + AttachmentImageView.frame.size.width;
            CGFloat LabelY = AttachmentImageView.frame.origin.y;
            UILabel * AttachmentNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(LabelX, LabelY, _AttachmentView.frame.size.width - LabelX - AttachmentImageView.frame.size.width - 10, AttachmentImageView.frame.size.height)];
            AttachmentNameLabel.text = [a filename];
            //创建删除按钮
            UIButton *DeleteAttachmentButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            CGFloat ButtonX = AttachmentNameLabel.frame.origin.x + AttachmentNameLabel.frame.size.width;
            CGFloat ButtonY = AttachmentNameLabel.frame.origin.y;
            DeleteAttachmentButton.frame = CGRectMake(ButtonX, ButtonY, 32, 32);
            DeleteAttachmentButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//            label.contentEdgeInsets = UIEdgeInsetsMake(10, 50, 10, 0);
//            [label.titleLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
//            [label setTitle:[a filename] forState:UIControlStateNormal];
//            [label setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//            [label.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
            UIImageView *Buttonimage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
            Buttonimage.image = [UIImage imageNamed:@"DeleteAttachment"];
            Buttonimage.contentMode = UIViewContentModeScaleAspectFit;
            [DeleteAttachmentButton addSubview:Buttonimage];
            
            DeleteAttachmentButton.tag = tag;
            tag++;
            
            //删除附件的点击事件
            [DeleteAttachmentButton addTarget:self action:@selector(DeleteAttachmentTapped:) forControlEvents:UIControlEventTouchUpInside];
            

            [contentView addSubview:AttachmentImageView];
            [contentView addSubview:AttachmentNameLabel];
            [contentView addSubview:DeleteAttachmentButton];
            
            [attachmentLabels addObject:contentView];
        }
/*
        for (DelayedAttachment* da in _delayedAttachmentsArray)
        {
            UIButton *label = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            label.frame = CGRectMake(0, 0, 300, 60);
            label.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            label.contentEdgeInsets = UIEdgeInsetsMake(10, 50, 10, 0);
            [label.titleLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
            [label setTitle:[da filename] forState:UIControlStateNormal];
            [label setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [label.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
            label.tag = tag;
            tag++;
            
            [label addTarget:self action:@selector(attachmentTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(10, 13, 32, 32)];
            NSString *pathToIcon = [FPMimetype iconPathForMimetype:[da mimeType] Filename:[da filename]];
            imageview.image = [UIImage imageNamed:pathToIcon];
            imageview.contentMode = UIViewContentModeScaleAspectFit;
            [label addSubview:imageview];
            
            [self grabDataWithBlock:^NSData *{
                return [da getData];
            } completion:^(NSData *data) {
                if ([pathToIcon isEqualToString:@"page_white_picture.png"]){
                    imageview.image = [UIImage imageWithData:data];
                }
                
                MCOAttachment *attachment = [[MCOAttachment alloc] init];
                attachment.data = data;
                attachment.filename = da.filename;
                attachment.mimeType = da.mimeType;
                if (!_attachmentsArray)
                {
                    _attachmentsArray = [NSMutableArray new];
                }
                [_attachmentsArray addObject:attachment];
                
                @synchronized(self) {
                    NSMutableArray *delayedMut = [NSMutableArray arrayWithArray:_delayedAttachmentsArray];
                    [delayedMut removeObject:da];
                    _delayedAttachmentsArray = delayedMut;
                }
                [self updateSendButton];
            }];
            
            [attachmentLabels addObject:label];
        }
 */
        
        CGFloat startingHeight = _AttachmentView.frame.origin.x;
        for (UIButton *attachmentLabel in attachmentLabels)
        {
            _AttachmentViewHeight.constant += attachmentLabel.frame.size.height;
            
            NSLog(@"attachmentLabel.frame.size.height = %f", attachmentLabel.frame.size.height);
            attachmentLabel.frame = CGRectMake(0, startingHeight, _AttachmentView.frame.size.width, attachmentLabel.frame.size.height);
            
            [self.AttachmentView addSubview:attachmentLabel];
            startingHeight += attachmentLabel.frame.size.height;
        }
        
/*
        CGRect lastAttachRect = [[attachmentLabels lastObject] frame];

        [UIView animateWithDuration:0.5
                              delay:1.5
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{

                             self.attachButton.frame = CGRectMake(self.attachButton.frame.origin.x,
                                                                  lastAttachRect.origin.y + lastAttachRect.size.height,
                                                                  self.attachButton.frame.size.width,
                                                                  self.attachButton.frame.size.height);
                             
                             self.attachmentSeparatorView.frame = CGRectMake(self.attachmentSeparatorView.frame.origin.x,
                                                                             lastAttachRect.origin.y + lastAttachRect.size.height + self.attachButton.frame.size.height + 8,
                                                                             self.attachmentSeparatorView.frame.size.width,
                                                                             self.attachmentSeparatorView.frame.size.height);
                             
                             self.messageBox.frame = CGRectMake(self.messageBox.frame.origin.x,
                                                                self.attachmentSeparatorView.frame.origin.y + 9,
                                                                self.messageBox.frame.size.width,
                                                                self.messageBox.frame.size.height);
                             self.messageBox.hidden = true;
 
                         }
                         completion:^(BOOL finished) {
                            //[self updateSendButton];
                         }];
*/
 
    }
}


- (void) DeleteAttachmentTapped:(UIButton *)button {
    
    //删除所有附件
    NSMutableArray * ConverArray = [[NSMutableArray alloc] initWithArray:_attachmentsArray];
    [ConverArray removeObjectAtIndex:[button tag]];
    _attachmentsArray = ConverArray;
    
    //移除附件视图所有附件
    [_AttachmentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _AttachmentViewHeight.constant = 1;
    
    //重新绘制附件视图
    [self configureViewForAttachments];
}

- (void)grabDataWithBlock: (NSData* (^)(void))dataBlock completion:(void(^)(NSData *data))callback {
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
        NSData *data = dataBlock();
        callback(data);
    });
}

- (void)updateSendButton {
    if ([_delayedAttachmentsArray count] > 0)
    {
        self.navigationItem.rightBarButtonItem.title = @"Sending disabled while loading attachments";
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else
    {
        self.navigationItem.rightBarButtonItem.title = @"Send";
        self.navigationItem.rightBarButtonItem.enabled = [self isEmailTextFieldValid];//[toField.text isEmailValid];
    }
    
    [self.navigationController.navigationBar layoutSubviews];
}

- (BOOL)isEmailTextFieldValid
{
    NSString *emailTextFieldText = toField.text;
    
    if ([emailTextFieldText isEmailValid])
    {
        return YES;
    }
    
    NSArray *emails = [emailTextFieldText componentsSeparatedByString:@", "];
    
    if (emails.count == 0)
    {
        return NO;
    }
    else
    {
        __block BOOL isValid = NO;
        [emails enumerateObjectsUsingBlock:^(NSString *email, NSUInteger idx, BOOL *stop)
        {
            if (email.length != 0)
            {
                isValid = [email isEmailValid];
                if (!isValid)
                {
                    *stop = YES;
                }
            }
        }];
        
        return isValid;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIKeyboardDidShowNotification
     object:nil];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIKeyboardWillHideNotification
     object:nil];
}

- (IBAction)CCAndBCCTouchUp:(UIButton *)sender {
    //启动
    NSLog(@"收缩隐藏");
}

- (IBAction) closeWindow:(id)sender {
    BOOL hasToUser = ([[toField text] length] > 0);
    BOOL hasSubject = ([[subjectField text] length] > 0);
    BOOL hasBody = ([[messageBox text] length] > 0 && ![messageBox.text isEqualToString:@"邮件内容"]);
//    BOOL hasFiles = ([[_draft files] count] > 0);
    
//    if (hasSubject || hasBody || hasFiles) {
    if (hasToUser || hasSubject || hasBody) {
        [UIActionSheet showInView:self.view withTitle:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"忽略" otherButtonTitles:@[@"保存为草稿"] tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == [actionSheet cancelButtonIndex]) {
                return;
            } else if (buttonIndex == [actionSheet destructiveButtonIndex]) {
//                [_draft delete];
                NSLog(@"删除");
            } else {
//                [self applyChangesToDraft];
//                [_draft save];
                NSLog(@"保存");
                //插入新的草稿
                [self insertToSQLite:toField.text CCText:ccField.text MessageBody:messageBox.text SubjectText:subjectField.text Attachments:_attachmentsArray TableName:@"Draft"];
            }
            [self dismissViewControllerAnimated:YES completion:NULL];
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (IBAction) sendEmail:(id)sender {
    
    //Additional check
    if (![toField.text isEmailValid])
    {
//        FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"Invalid Email Address"
//                                                              message:@"Please enter a valid email address for a recipient"
//                                                             delegate:nil
//                                                    cancelButtonTitle:@"Dismiss"
//                                                    otherButtonTitles:nil,
//         nil];
//        
//        alertView.titleLabel.textColor = [UIColor blackColor];
//        alertView.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
//        alertView.messageLabel.textColor = [UIColor asbestosColor];
//        alertView.messageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
//        alertView.backgroundOverlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
//        alertView.alertContainer.backgroundColor = [UIColor cloudsColor];
//        alertView.defaultButtonColor = [UIColor cloudsColor];
//        alertView.defaultButtonShadowColor = [UIColor cloudsColor];
//        alertView.defaultButtonFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
//        alertView.defaultButtonTitleColor = [UIColor belizeHoleColor];
//        [alertView show];
        
        [self updateSendButton];
        return;
    }
    
    [self sendEmailto:[self emailArrayFromString:toField.text]
                   cc:[self emailArrayFromString:ccField.text]
                  bcc:@[]
          withSubject:subjectField.text
             withBody:[messageBox.text stringByReplacingOccurrencesOfString:@"\n" withString:@"<br />"]
      withAttachments:_attachmentsArray];
    
    [self insertToSQLite:toField.text CCText:ccField.text MessageBody:messageBox.text SubjectText:subjectField.text Attachments:_attachmentsArray TableName:@"SentItems"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - EMAIL HELPERS

- (NSString*) emailStringFromArray:(NSArray*) emails {
    return [emails componentsJoinedByString:@", "];
}

- (NSArray *) emailArrayFromString:(NSString*) emailstring {
    //Need to remove empty emails with trailing ,
    NSArray *emails = [emailstring componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
    NSPredicate *notBlank = [NSPredicate predicateWithFormat:@"length > 0 AND SELF != ' '"];
    
    return [emails filteredArrayUsingPredicate:notBlank];
}

- (void)sendEmailto:(NSArray*)to
                 cc:(NSArray*)cc
                bcc:(NSArray*)bcc
        withSubject:(NSString*)subject
           withBody:(NSString*)body
    withAttachments:(NSArray*)attachments
{
    MCOSMTPSession *smtpSession = [[AuthManager sharedManager] getSmtpSession];

    NSString *username = smtpSession.username;
    
    MCOMessageBuilder * builder = [[MCOMessageBuilder alloc] init];
    [[builder header] setFrom:[MCOAddress addressWithDisplayName:nil mailbox:username]];
    NSMutableArray *toma = [[NSMutableArray alloc] init];
    for(NSString *toAddress in to) {
        MCOAddress *newAddress = [MCOAddress addressWithMailbox:toAddress];
        [toma addObject:newAddress];
    }
    [[builder header] setTo:toma];
    NSMutableArray *ccma = [[NSMutableArray alloc] init];
    for(NSString *ccAddress in cc) {
        MCOAddress *newAddress = [MCOAddress addressWithMailbox:ccAddress];
        [ccma addObject:newAddress];
    }
    [[builder header] setCc:ccma];
    NSMutableArray *bccma = [[NSMutableArray alloc] init];
    for(NSString *bccAddress in bcc) {
        MCOAddress *newAddress = [MCOAddress addressWithMailbox:bccAddress];
        [bccma addObject:newAddress];
    }
    [[builder header] setBcc:bccma];
    [[builder header] setSubject:subject];
    [builder setHTMLBody:body];
    
    NSLog(@"Body: %@", body);
    
    /* Sending attachments */
    if ([attachments count] > 0){
        [builder setAttachments:attachments];
    }
    
    NSData * rfc822Data = [builder data];
    
    
    
    MCOSMTPSendOperation *sendOperation = [smtpSession sendOperationWithData:rfc822Data];
    [sendOperation start:^(NSError *error) {
        if(error) {
            NSLog(@"%@ Error sending email:%@", username, error);
        } else {
            NSLog(@"%@ Successfully sent email!", username);
        }
    }];
    
    [smtpSession setConnectionLogger:^(void * connectionID, MCOConnectionLogType type, NSData * data) {
        NSLog(@"Logger sent data: %@", [NSString stringWithUTF8String:[data bytes]]);
    }];
}

#pragma -mark UITextView Delegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"邮件内容"]) {
        textView.textColor=[UIColor colorWithHexString:@"#000000" andAlpha:1.0];
        textView.text = @"";
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length<1) {
        messageBox.textColor=[UIColor colorWithHexString:@"#999999" andAlpha:1.0];
        textView.text = @"邮件内容";
    }
}

// 隐藏键盘.
- (IBAction)TextField_DidEndOnExit:(id)sender {
    [sender resignFirstResponder];
}

#pragma mark - CoreData Methods
- (void)insertToSQLite:(NSString*)totext CCText:(NSString*)cctext MessageBody:(NSString *)messageBody SubjectText:(NSString*)subjectText Attachments:(NSMutableArray *)AttachmentArray TableName:(NSString*)tableText
{
    //写入sqlite
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:tableText inManagedObjectContext:context];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];

    //发件人
    [newManagedObject setValue:totext forKey:@"totext"];
    //抄送
    [newManagedObject setValue:cctext forKey:@"cctext"];
    //主题
    [newManagedObject setValue:subjectText forKey:@"subjecttext"];
    //存储邮件体
    [newManagedObject setValue:messageBody forKey:@"messagebody"];
    //邮件创建时间
    [newManagedObject setValue:[NSDate date] forKey:@"messagedate"];

    //将附件以NSData存入数据库中
    if ([_attachmentsArray count] > 0)
    {
        NSMutableDictionary * ConverDict = [[NSMutableDictionary alloc] init];
        for (MCOAttachment* OneAttachment in _attachmentsArray)
        {
            [ConverDict setObject:[OneAttachment data] forKey:[OneAttachment filename]];
            
        }
        
        NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:ConverDict];
        [newManagedObject setValue:arrayData forKey:@"attachment"];
    }
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    //添加附件
    if ([[segue identifier] isEqualToString:@"AddAttachment"])
    {
        FBFilesTableViewController *controller = (FBFilesTableViewController *)[[segue destinationViewController] topViewController];
        controller.delegate = self;
        NSString *StoragePath = [FCFileManager pathForDocumentsDirectory];
        StoragePath = [StoragePath stringByAppendingString:@"/存储区域"];
        [controller initPath:StoragePath SelectFunction:@"AddAttachment"];
    }
}

#pragma mark - FileManagerDelegate Methods
-(void)FinishAddAttachment:(NSDictionary *)theAttachmentFiles
{
    //快速枚举遍历所有KEY的值
    NSEnumerator * enumeratorKey = [theAttachmentFiles keyEnumerator];
    for (NSString *object in enumeratorKey) {
        NSString * filename = object;
        NSString * filePath = [theAttachmentFiles objectForKey:filename];
        MCOAttachment * Attachmentfile = [MCOAttachment attachmentWithContentsOfFile:filePath];
        if (!_attachmentsArray)
        {
            _attachmentsArray = [NSMutableArray new];
        }
        [_attachmentsArray addObject:Attachmentfile];
    }
    
    //移除附件视图所有附件
    [_AttachmentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _AttachmentViewHeight.constant = 1;
    
    //重新绘制附件视图
    [self configureViewForAttachments];
    
}

@end
