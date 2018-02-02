//
//  ComposerViewController.h
//  ThatInbox
//
//  Created by Liyan David Chang on 7/31/13.
//  Copyright (c) 2013 Ink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MailCore/MailCore.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreData/CoreData.h>
#import "MailBoxDataManager.h"
#import "FBFilesTableViewController.h"
#import "FCFileManager.h"


@interface ComposerViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, DFFileManagerDelegate>


@property(nonatomic, weak) IBOutlet UITextField *toField;
@property(nonatomic, weak) IBOutlet UITextField *ccField;
@property(nonatomic, weak) IBOutlet UITextField *bccField;
@property(nonatomic, weak) IBOutlet UITextField *subjectField;
@property(nonatomic, weak) IBOutlet UITextView *messageBox;
//ContentView 的高度， 用来控制滚动视图
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ContentViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *MailHeaderViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *AttachmentViewHeight;
@property (weak, nonatomic) IBOutlet UIView *AttachmentView;
@property (weak, nonatomic) IBOutlet UIView *MailHeaderView;
@property (weak, nonatomic) IBOutlet UIView *ContentView;


@property(nonatomic, copy) NSString *toString;
@property(nonatomic, copy) NSString *ccString;
@property(nonatomic, copy) NSString *bccString;
@property(nonatomic, copy) NSString *subjectString;
@property(nonatomic, copy) NSString *bodyString;
//草稿箱邮件编写时间
@property(nonatomic, copy) NSString *writeDate;
@property(nonatomic, copy) NSMutableArray *attachmentsArray;
@property(nonatomic, weak) NSArray *delayedAttachmentsArray;
//数据库操作
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (id)initWithMessage:(MCOMessageParser *)msg
               ofType:(NSString*)type
              content:(NSString*)content
          attachments:(NSArray *)attachments
   delayedAttachments:(NSArray *)delayedAttachments;

- (id)initWithTo:(NSArray *)to
              CC:(NSArray *)cc
             BCC:(NSArray *)bcc
         subject:(NSString *)subject
         message:(NSString *)message
     attachments:(NSArray *)attachments
delayedAttachments:(NSArray *)delayedAttachments;

- (id)initWithToNoAttachments:(NSString *)to
              CC:(NSString *)cc
             BCC:(NSString *)bcc
         subject:(NSString *)subject
         message:(NSString *)message
       wirteDate:(NSString *)writedate;

- (NSString*) emailStringFromArray:(NSArray*) emails;

@end
