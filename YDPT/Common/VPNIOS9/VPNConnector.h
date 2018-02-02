//
//  VPNConnector.h
//  HWPlatform
//
//  Created by hanwei on 15/5/19.
//  Copyright (c) 2015年 HanWei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AuthHelper.h"
#import "sslvpnnb.h"

#define say_log(str) printf("[log]:%s,%s,%d:%s\n",__FILE__,__FUNCTION__,__LINE__,str)
#define say_err(err) printf("[log]:%s,%s,%d:%s,%s\n",__FILE__,__FUNCTION__,__LINE__,err,get_err())
#define get_err() ssl_vpn_get_err()

@protocol VPNConnectorDelegate <NSObject>

-(void) VPNReturn:(NSString *)rtnMsg type:(NSString *)retType;

@end

@interface VPNConnector : NSObject<SangforSDKDelegate>
{
    AuthHelper *helper;
//    id<VPNConnectorDelegate> delegate;
    NSString *_vpnIp;        //vpn设备IP地址
    short _port;             //vpn设备端口号，一般为443
    NSString *_userName;     //用户名认证的用户名
    NSString *_password;     //用户名认证的密码
    NSString *_authTimeout;  //认证时候连接vpn的超时时间
}
@property(retain,nonatomic)id<VPNConnectorDelegate> delegate;
@property (nonatomic, retain) NSString *vpnIp;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *authTimeout;
@property (nonatomic, nonatomic) short port;


-(void)init_VPN;
-(void)login;
-(void)logout;
-(void)autoLogin;
@end
