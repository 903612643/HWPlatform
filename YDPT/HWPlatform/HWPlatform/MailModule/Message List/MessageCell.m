//
//  MessageCell.m
//  ThatInbox
//
//  Created by Andrey Yastrebov on 20.09.13.
//  Copyright (c) 2013 com.inkmobility. All rights reserved.
//

#import "MessageCell.h"
#import <MailCore/MailCore.h>
#import <QuartzCore/QuartzCore.h>

@implementation MessageCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor grayColor];
        bgColorView.layer.masksToBounds = YES;
        [self setSelectedBackgroundView:bgColorView];

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



//邮件列表显示信息
- (void)setMessagePOP:(MCOMessageParser *)message
{
    self.fromTextField.text = message.header.from.displayName ? message.header.from.displayName : message.header.from.mailbox;
    self.subjectTextField.text = message.header.subject ? message.header.subject : @"No Subject";
    
    NSArray *attachments = [message attachments];
    
    if ([attachments count] > 0)
    {
        //MCOAttachment *firstAttachment = message.attachments[0];
        
        if (attachments.count == 1)
        {

        }
        else
        {

        }
    }
    else
    {
    }
}

//邮件头信息显示信息
- (void)setMessageHeader:(NSMutableDictionary *)object
{
    //TableCell显示信息
    self.fromTextField.text = [object valueForKey:@"fromtext"];
    self.subjectTextField.text = [object valueForKey:@"subjecttext"];
    self.receiveDate.text = [object valueForKey:@"maildate"];
    NSString * readsign = [object valueForKey:@"readsign"];
    if ([readsign isEqualToString:@"true"])
    {
        [_ReadSignImageView setImage:[UIImage imageNamed:@"Readed"]];
    }
    else
    {
        [_ReadSignImageView setImage:[UIImage imageNamed:@"UnRead"]];
    }
}


@end
