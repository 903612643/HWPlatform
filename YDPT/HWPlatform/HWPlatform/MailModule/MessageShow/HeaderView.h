//
//  HeaderView.h
//  ThatInbox
//
//  Created by Liyan David Chang on 8/4/13.
//  Copyright (c) 2013 Ink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MailCore/MailCore.h>
#import "FCFileManager.h"

@protocol HeaderViewDelegate;

@interface HeaderView : UIView <UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) UIDocumentInteractionController *docController;
@property (nonatomic, weak) id<HeaderViewDelegate> delegate;

//- (id)initWithFrame:(CGRect)frame message:(MCOIMAPMessage*)message delayedAttachments:(NSArray*)attachments;
//Fit POP3
- (id)initWithFrame:(CGRect)frame message:(MCOMessageParser*)message Attachments:(NSArray*)attachments;
- (void)render;

@end


@protocol HeaderViewDelegate <NSObject>

- (NSString *) msgContent;
- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)())completion;

@end