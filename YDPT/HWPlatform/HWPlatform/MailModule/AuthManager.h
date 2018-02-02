//
//  AuthManager.h
//  HWMail
//
//  Created by hanwei on 15/10/30.
//  Copyright © 2015年 HanWei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MailCore/MailCore.h>

@interface AuthManager : NSObject

@property (nonatomic, strong) MCOPOPSession *popSession;
@property (nonatomic, strong) MCOSMTPSession *smtpSession;

+ (id)sharedManager;

- (void)logout;

- (MCOSMTPSession *) getSmtpSession;
- (MCOPOPSession *) getPopSession;


@end
