//
//  AuthDelegate.m
//  Auth
//
//  Created by Huang Shounan on 12-11-13.
//
//
#include <netdb.h>
#include <sys/socket.h>
#import <netinet/in.h>
#import <sys/socket.h>
#import <arpa/inet.h>

#import "AuthHelper.h"
#import "sslvpnnb.h"

static void g_callBack(const VPN_RESULT_NO result, const int authType)
{
    id<SangforSDKDelegate> delegate = [AuthHelper getGlobalDelegate];
    
    if (delegate!=nil && [delegate respondsToSelector:@selector(onCallBack:authType:)])
    {
        [delegate onCallBack:result authType:authType];
    }
}

static void g_reloginCallback(const int status, const int result)
{
    id<SangforSDKDelegate> delegate = [AuthHelper getGlobalDelegate];
    
    if (delegate!=nil && [delegate respondsToSelector:@selector(onReloginCallback:result:)])
    {
        [delegate onReloginCallback:status result:result];
    }
}

static int g_selectCertCallBack(const IdentityData *identityVec, const int count)
{
    id<SangforSDKDelegate> delegate = [AuthHelper getGlobalDelegate];
    if (delegate!=nil && [delegate respondsToSelector:@selector(onSelectIdentity:count:)]) {
        return [delegate onSelectIdentity:identityVec count:count];
    }
    return -1;
}

static void g_RndCodeCallBack(const void* addr,uint32_t addrlen)
{
    id<SangforSDKDelegate> delegate = [AuthHelper getGlobalDelegate];
    if (delegate!=nil && [delegate respondsToSelector:@selector(onRndCodeCallBack:)]) {
        NSData* data = [[NSData alloc]initWithBytes:addr length:addrlen];
        [delegate onRndCodeCallBack:data];
        [data release];
    }
}

static int detect_ip_and_port(char *server_ip, short port)
{
    int fd = -1;
    struct sockaddr_in addr;
    struct timeval time_out = {5, 0}; //time out set 5 seconds
    if ((fd = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        NSLog(@"create socket failed!");
        return -1;
    }
    setsockopt(fd, SOL_SOCKET, SO_SNDTIMEO, &time_out, sizeof(time_out));
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    addr.sin_addr.s_addr = inet_addr(server_ip);
    if (connect(fd, &addr, sizeof(addr)) < 0) {
        NSLog(@"connect %@ failed!", [NSString stringWithUTF8String:server_ip]);
        close(fd);
        return -1;
    } else {
        close(fd);
        return 0;
    }
}

@implementation AuthHelper

static id<SangforSDKDelegate> shareDelegate = nil;

+ (AuthHelper *)getInstance
{
    static AuthHelper *_instance = nil;
    if (_instance == nil) {
        _instance = [[AuthHelper alloc] init];
    }
    return _instance;
}

+ (id<SangforSDKDelegate>)getGlobalDelegate
{
    if (shareDelegate != nil)
    {
        return shareDelegate;
    }
    return nil;
}

- (id)initWithHostAndPort:(NSString *)host port:(short)port delegate:(id) delegate
{
    self = [super init];
    const char *host_name = [host UTF8String];
    shareDelegate = delegate;
    
    struct hostent *addrs = NULL;
    uint32_t vpnAddr = INADDR_NONE;
    uint16_t vpnPort = htons(port);
    addrs =gethostbyname(host_name);
    if (addrs != NULL)
    {
        char ip[24] = {0};
        for (int i = 0; addrs->h_addr_list[i] != NULL; i++) {
            memset(ip, 0, sizeof(ip));
            if (*(addrs->h_addr_list[i]) != 0) {
                inet_ntop(AF_INET, addrs->h_addr_list[i], ip, sizeof(ip));
                vpnAddr = inet_addr(ip);
                NSLog(@"host ip ======= %@", [NSString stringWithUTF8String:ip]);
            }
        }
    }
    
    if (vpnAddr == INADDR_NONE) {
        vpn_seterr_nb("vpn address is NULL");
        g_callBack(RESULT_VPN_INIT_FAIL, 0);
        return self;
    }
    
    
    //设置回调函数
    set_reconnect_callback(g_reloginCallback);
    
    ssl_vpn_init(g_callBack,vpnAddr,vpnPort);
    
    mInit = YES;
    return self;
}

- (void)initWithHostAndPort1:(NSString *)host port:(short)port delegate:(id) delegate
{
    shareDelegate = delegate;
    
    uint32_t vpnAddr = inet_addr([host UTF8String]);
    uint16_t vpnPort = htons(port);
    
    //设置回调函数
    set_reconnect_callback(g_reloginCallback);
    
    ssl_vpn_init(g_callBack,vpnAddr,vpnPort);
    mInit = YES;
}

- (int) loginVpn:(const int )authType
{
    return ssl_vpn_login(authType);
}

- (int) setUserNamePassword:(NSString *)userName password:(NSString *)password
{
    const char *name = [userName UTF8String];
    const char *pwd = [password UTF8String];
    
    if (ssl_vpn_set_login_param(PORPERTY_NamePasswordAuth_NAME,(char*)name) < 0)
    {
        return -1;
    }
    if (ssl_vpn_set_login_param(PORPERTY_NamePasswordAuth_PASSWORD,(char*)pwd) < 0)
    {
        return -1;
    }
    return 0;
}

- (void) setDnsServer:(NSString *)server
{
    return ssl_set_dns_server([server UTF8String]);
}

-(int) setAuthParam:(NSString *)key param:(NSString*)value
{
    const char *charKey = [key UTF8String];
    const char *charValue = NULL;
    char tmp[20] = {0};
    
    if (!strncmp(charKey,CERT_AUTH_SLECT_AUTH,sizeof(CERT_AUTH_SLECT_AUTH))) {
        snprintf(tmp,sizeof(tmp),"%d",(int)g_selectCertCallBack);
        charValue = tmp;
    } else {
        charValue = [value UTF8String];
    }    
    return ssl_vpn_set_login_param(charKey,(char*)charValue);
}

- (NSData*) getAuthParam:(NSString *)key
{
    const char *charKey = [key UTF8String];
    char outValue[2048] = {0};
    uint32_t  outLen = sizeof(outValue);
    void* ret = vpn_get_login_param(charKey,outValue, &outLen);
    if(!ret || outLen > sizeof(outValue))
    {
        return nil;
    }
    NSData* data = [[[NSData alloc] initWithBytes:outValue length:outLen] autorelease];
    return data;
}

- (void) clearAuthParam:(NSString *)key
{
    vpn_clear_login_param([key UTF8String]);
}

- (int) getRndCode
{
    ssl_vpn_set_rnd_code_call_back(g_RndCodeCallBack);
    return ssl_vpn_get_rnd_code();
}

- (int) logoutVpn
{
    return ssl_vpn_logout();
}

- (int) quitLogin
{
    shareDelegate = nil;
    return ssl_vpn_quit();
}

- (int) relogin
{
    return ssl_vpn_relogin();
}

- (VPN_STATUS) queryVpnStatus
{
    return ssl_vpn_query_auth_state();
}

- (void) setDelegate:(id<SangforSDKDelegate>)delegate
{
    assert(delegate);
    shareDelegate = delegate;
}

- (int) getProxyPort
{
    return get_proxy_port();
}

@end
