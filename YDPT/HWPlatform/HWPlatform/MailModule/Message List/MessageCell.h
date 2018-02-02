//
//  MessageCell.h
//  ThatInbox
//
//  Created by Andrey Yastrebov on 20.09.13.
//  Copyright (c) 2013 com.inkmobility. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCOIMAPMessage;
@class MCOPOPMessageInfo;
@class MCOMessageParser;
@class MCOMessageHeader;
@class NSManagedObject;

@interface MessageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *fromTextField;
@property (weak, nonatomic) IBOutlet UILabel *subjectTextField;
@property (weak, nonatomic) IBOutlet UIImageView *ReadSignImageView;
@property (weak, nonatomic) IBOutlet UILabel *receiveDate;
//assign 非Object类型使用  copy NSString类型使用
@property (nonatomic,assign) NSInteger *index;
@property (nonatomic,strong) NSString *UID;
@property (nonatomic,assign) NSInteger *messagesize;
@property (nonatomic,strong) NSDate *messagedate;

- (void)setMessagePOP:(MCOMessageParser *)message;
- (void)setMessageHeader:(NSMutableDictionary *)messageHeader;

@end
