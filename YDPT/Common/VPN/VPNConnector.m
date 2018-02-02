//
//  VPNConnector.m
//  HWPlatform
//
//  Created by hanwei on 15/5/19.
//  Copyright (c) 2015年 HanWei. All rights reserved.
//

#import "VPNConnector.h"

@implementation VPNConnector
@synthesize delegate;

// 以下是认证可能会用到的认证信息
NSString *certName = @"sangfor.p12";     //导入证书名字，如果服务端没有设置证书认证可以不设置
NSString *certPwd =  @"123456";          //证书密码，如果服务端没有设置证书       

-(void) onCallBack:(const VPN_RESULT_NO)vpnErrno authType:(const int)authType
{
    switch (vpnErrno)
    {
        case RESULT_VPN_INIT_FAIL:
            say_err("Vpn Init failed!");
            break;
            
        case RESULT_VPN_AUTH_FAIL:
        {
            [helper clearAuthParam:@SET_RND_CODE_STR];
            say_err("Vpn auth failed!");
            NSString * ErrorMsg;
            ErrorMsg = [[NSString alloc] initWithUTF8String:get_err()];
            ErrorMsg = [@"VPN " stringByAppendingString: ErrorMsg];
            [self.delegate VPNReturn:ErrorMsg type:@"Error"];
            break;
        }

            
        case RESULT_VPN_INIT_SUCCESS:
            say_log("Vpn init success!");
            break;
        case RESULT_VPN_AUTH_SUCCESS:
            [self startOtherAuth:authType];
            break;
        case RESULT_VPN_AUTH_LOGOUT:
            say_log("Vpn logout success!");
            break;
        case RESULT_VPN_OTHER:
            if (VPN_OTHER_RELOGIN_FAIL == (VPN_RESULT_OTHER_NO)authType) {
                say_log("Vpn relogin failed, maybe network error");
            }
            break;
            
        case RESULT_VPN_NONE:
            break;
            
        default:
            break;
    }
}

-(void) onReloginCallback:(const int)status result:(const int)result
{
    switch (status) {
        case START_RECONNECT:
            NSLog(@"vpn relogin start reconnect ...");
            break;
        case END_RECONNECT:
            NSLog(@"vpn relogin end ...");
            if (result == SUCCESS) {
                NSLog(@"Vpn relogin success!");
            } else {
                NSLog(@"Vpn relogin failed");
            }
            break;
        default:
            break;
    }
}

-(void) startOtherAuth:(const int)authType
{
    NSArray *paths = nil;
    switch (authType)
    {
        case SSL_AUTH_TYPE_CERTIFICATE:
            paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                        NSUserDomainMask, YES);
            
            if (nil != paths && [paths count] > 0)
            {
                NSString *dirPaths = [paths objectAtIndex:0];
                NSString *authPaths = [dirPaths stringByAppendingPathComponent:certName];
                NSLog(@"PATH = %@",authPaths);
                [helper setAuthParam:@CERT_P12_FILE_NAME param:authPaths];
                [helper setAuthParam:@CERT_PASSWORD param:certPwd];
            }
            say_log("Start Cert Auth!!!");
            break;
            
        case SSL_AUTH_TYPE_PASSWORD:
            say_log("Start Password Name Auth!!!");
            [helper setAuthParam:@PORPERTY_NamePasswordAuth_NAME param:self.userName];
            [helper setAuthParam:@PORPERTY_NamePasswordAuth_PASSWORD param:self.password];
            
            break;
        case SSL_AUTH_TYPE_NONE:
            say_log("Auth success!!!");
            [self.delegate VPNReturn:@"" type:@"True"];
            return;
        default:
            say_err("Other failed!!!");
            return;
    }
    [helper loginVpn:authType];
}

-(void)login
{
    //设置认证参数 用户名和密码以数值map的形式传入
    [helper setAuthParam:@PORPERTY_NamePasswordAuth_NAME param:self.userName];
    [helper setAuthParam:@PORPERTY_NamePasswordAuth_PASSWORD param:self.password];
    //开始用户名密码认证
    [helper loginVpn:SSL_AUTH_TYPE_PASSWORD];
}

-(void)logout
{
    //注销用户登陆
    [helper logoutVpn];
}

-(void)autoLogin
{
    //如果svpn已经注销了，就重新登陆
    if ([helper queryVpnStatus] == VPN_STATUS_LOGOUT)
    {
        NSLog(@"Svpn is logout!");
        [helper relogin];
    }
}

-(void)init_VPN
{
   	// Do any additional setup after loading the view, typically from a nib.
    self->helper = [[AuthHelper alloc] initWithHostAndPort:self.vpnIp port:self.port delegate:self];
    [helper setAuthParam:@AUTH_CONNECT_TIME_OUT param:self.authTimeout];
    //关闭自动登陆的选项，建议设置为关闭的状态，自动登陆的选项开启的情况下，每次有网络请求的时候
    //都会探测用户是不是处于在线的状态，网络速度有所下降，支持IOS7的新版本的SDK对此做了优化，建议
    //显示的关闭该选项，用户可以调用vpn_query_status来查询状态，如果发现用户掉线可以调用vpn_relogin
    //来完成自动登陆
    // [helper setAuthParam:@AUTO_LOGIN_OFF_KEY param:@"true"];
}


@end
