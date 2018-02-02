//
//  MCTMsgViewController.h
//  HWMail
//
//  Created by hanwei on 15/10/29.
//  Copyright © 2015年 HanWei. All rights reserved.
//

#include <MailCore/MailCore.h>
#import "HeaderView.h"
#import "MCOMessageView.h"

@class MCOMessageView;
@class MCOIMAPAsyncSession;
@class MCOMAPMessage;
@class MCOPOPMessageInfo;

@interface MCTMsgViewController : UIViewController <MCOMessageViewDelegate, HeaderViewDelegate, UIGestureRecognizerDelegate> {
    //邮件消息体类视图
    MCOMessageView * _messageView;
    //邮件消息头视图
    HeaderView *_headerView;
    //滚动视图
    UIScrollView * _scrollView;
    //邮件承载视图
    UIView * _messageContentsView;
}

- (IBAction)DeleteButtonOn:(id)sender;
@property (nonatomic, strong) MCOPOPSession * sessionPOP;
@property (nonatomic, strong) MCOMessageParser * messagePOP;
@property (nonatomic, strong) MCOPOPMessageInfo * messageInfo;
//邮件在服务器中的索引
@property (nonatomic, strong) NSNumber * messageIndex;
//邮件体数据
@property (nonatomic, strong) NSData * BodyData;
//缓存中是否包含邮件体
@property (nonatomic, strong) NSString * existbody;
//邮件发送者
@property (nonatomic, strong) NSString * fromtext;
//邮件主题
@property (nonatomic, strong) NSString * subjecttext;
//已读未读标识
@property (nonatomic, strong) NSString * readsign;
//邮件标识
@property (nonatomic, strong) NSString * uid;

- (NSString *) msgContent;

@end
