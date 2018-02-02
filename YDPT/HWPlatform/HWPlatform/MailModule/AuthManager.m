//
//  AuthManager.m
//  HWMail
//
//  Created by hanwei on 15/10/30.
//  Copyright © 2015年 HanWei. All rights reserved.
//

#import "AuthManager.h"
#import "HWPlatformTest-Swift.h"
#include <netdb.h>
#include <sys/socket.h>
#import <netinet/in.h>
#import <sys/socket.h>
#import <arpa/inet.h>

NSString * const SmtpHostnameKey = @"smtphostname";
NSString * const PopHostNameKey = @"pophostname";

@implementation AuthManager
+ (id)sharedManager
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
        UserDataManager * userDataManager = [[UserDataManager alloc] init];
        NSString * POPAddress = [userDataManager.userData objectForKey:@"POPAddress"];
        NSString * SmtpAddress = [userDataManager.userData objectForKey:@"SmtpAddress"];
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{ PopHostNameKey: POPAddress }];
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{ SmtpHostnameKey: SmtpAddress }];
    });
    return _sharedObject;
}

- (void)logout
{
    self.popSession = nil;
    self.smtpSession = nil;
    NSLog(@"logout");
}

#pragma mark - Mail Services

- (MCOSMTPSession *) getSmtpSession {
    if (!self.smtpSession){
        
        MCOSMTPSession* smtpSession = [[MCOSMTPSession alloc] init];
        
        NSString *smtphostname = [[NSUserDefaults standardUserDefaults] objectForKey:SmtpHostnameKey];
        NSString * IPAddress = [self GetHostByName:smtphostname];
        if (![IPAddress isEqualToString:@"Error"]) {
            //DNS解析获得邮箱服务器的地址
            smtpSession.hostname = IPAddress;
        }
        else
        {
            //未解析成功，传递
            smtpSession.hostname = smtphostname;
        }
        
        //获取用户名密码
        UserDataManager * userDataManager = [[UserDataManager alloc] init];
        NSString * UserName = [userDataManager.userData objectForKey:@"UserName"];
        NSString * PassWord = [userDataManager.userData objectForKey:@"UserPwd"];
        NSString * MailLastName = [userDataManager.userData objectForKey:@"MailLastName"];
        NSString * SmtpPort = [userDataManager.userData objectForKey:@"SmtpPort"];
        
        NSString *FullMailUserName = [NSString stringWithFormat:@"%@%@",UserName,MailLastName];
        //不使用SSL端口号
        smtpSession.port = [SmtpPort intValue];
        smtpSession.username = FullMailUserName;
        smtpSession.password = PassWord;
        //明文传输
        smtpSession.authType = MCOAuthTypeSASLLogin;
        smtpSession.connectionType = MCOConnectionTypeClear;
        self.smtpSession = smtpSession;
    }
    return self.smtpSession;
}

- (MCOPOPSession *) getPopSession {
    if (!self.popSession){
        
        MCOPOPSession *popSession = [[MCOPOPSession alloc] init];
        
        NSString *hostname = [[NSUserDefaults standardUserDefaults] objectForKey:PopHostNameKey];
        NSString * IPAddress = [self GetHostByName:hostname];
        if (![IPAddress isEqualToString:@"Error"]) {
            //DNS解析获得邮箱服务器的地址
            popSession.hostname = IPAddress;
        }
        else
        {
            //未解析成功，传递
            popSession.hostname = hostname;
        }
        
        //获取用户名密码
        UserDataManager * userDataManager = [[UserDataManager alloc] init];
        NSString * UserName = [userDataManager.userData objectForKey:@"UserName"];
        NSString * PassWord = [userDataManager.userData objectForKey:@"UserPwd"];
        NSString * MailLastName = [userDataManager.userData objectForKey:@"MailLastName"];
        NSString * POPPort = [userDataManager.userData objectForKey:@"POPPort"];
        
        NSString *FullMailUserName = [NSString stringWithFormat:@"%@%@",UserName,MailLastName];
        //不使用SSL端口号
        popSession.port = [POPPort intValue];
        popSession.username = FullMailUserName;
        popSession.password = PassWord;
        //明文传输
        popSession.connectionType = MCOConnectionTypeClear;
        self.popSession = popSession;
    }
    return self.popSession;
}

-(NSString *) GetHostByName:(NSString *)URLAddress {

    const char *host_name = [URLAddress UTF8String];
    
    struct hostent *addrs = NULL;
    addrs =gethostbyname(host_name);
    NSString * rtn;
    if (addrs != NULL)
    {
        char ip[24] = {0};
        for (int i = 0; addrs->h_addr_list[i] != NULL; i++) {
            memset(ip, 0, sizeof(ip));
            if (*(addrs->h_addr_list[i]) != 0) {
                inet_ntop(AF_INET, addrs->h_addr_list[i], ip, sizeof(ip));
                NSLog(@"host ip ======= %@", [NSString stringWithUTF8String:ip]);
                rtn = [NSString stringWithUTF8String:ip];
            }
        }
    }
    else
    {
        rtn = @"Error";
    }

    return rtn;
}

@end
