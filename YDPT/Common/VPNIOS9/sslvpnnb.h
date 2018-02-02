//
//  Company: Sangfor
//  libSagfor
//
//  Created by on 12-9-1.
//
//

#ifndef  _SSLAUTH_H_
#define  _SSLAUTH_H_

#import "sdkheader.h"

/*******************************************************************
    注意：以下接口调用有些操作必须在主线程中调用，否则会返回非主线程调用接口的错误
 *******************************************************************/

#ifdef __cplusplus
extern "C"
{
#endif //__cplusplus
    /**
     * @功能：初始化vpn信息，包括初始化的回调函数，VPN服务器IP地址，端口号
     * @param callBack 回调函数指针，初始化为nil时，表示不设置回调函数
     * @param host［in］VPN服务器Ipd地址，注意为网络序，一定为有效的地址和端口
     * @param port［in］VPN服务器端口，注意为网络序
     * return 0表示初始化成功，－1表示失败
     **/
    int ssl_vpn_init(VPN_CALL_BACK callback,uint32_t host,uint16_t port);

    /**
     *@功能：开始登陆VPN，开始循环认证一系列认证方式（认证顺序方式由服务端配置决定）
     *@param authType     ［in］ 当前认证的类型
     *@return 0表示当前认证预成功，注意并不表示认证成功，若要知道认证是否成功，
     *          需要查看回调函数中的认证类型认证错误码； 
     **/
    int ssl_vpn_login(const int authType);
    
    /**
     *@ 功能：注销登陆VPN服务器
     *return 0表示注销成功，－1表示失败
     **/
    int ssl_vpn_logout(void);


    /**
     * @ 功能：查询VPN当前状态，注意判断VPN认证是否成功可以调用此函数查询
     * return 返回的VPN状态码，可能情况有三大类：1.认证成功，2.正在认真过程当中，3.认证失败; 注意当认
     *        真失败时，可以调用ssl_vpn_get_err获取错误原因字符串，具体返回值查看与错误相关的宏定义
     **/
    VPN_STATUS ssl_vpn_query_auth_state(void);
    
    /**
     * @ 功能：设置错误字符串
     **/
    void vpn_seterr_nb(const char *err);

    /**
     * @功能 获取VPN错误字符串
     * return NULL表示获取失败，非NULL表示成功返回的错误提示字符串
     **/
    const char* ssl_vpn_get_err(void);

    /**
     * @功能 设置键值对
     * @param key   键名
     * @param value 键值
     **/
    int ssl_vpn_set_login_param(const char* key, char* value);
    
    /**
     * @清理vqpn登录的属性
     * @param key[in] 不能为空，为上边以PORPERTY_开头的宏
     **/
    void vpn_clear_login_param(const char* key);
    
    /**
     * @功能 获取vpn登录的属性
     * @param key[in] 不能为空，为上边以PORPERTY_开头的宏
     * @param value[out] 属性的值,
     * @param value_lenth[in/out] value 的长度,by Bytes。返回实际长度
	 *
	 * @return 如果不存在，memset(value,0,value_length) return NULL;
     *         如果存在但长度不够 strncpy(value,out_value,value_length) return NULL;
     *         如果正确，strncpy(value,out_value,value_length) return value;
     *         如果参数错误，return NULL;
     **/
	void* vpn_get_login_param(const char* key,void* value,uint32_t * value_length);
    
    /**
     * @功能 获取硬件特征码信息，以字符串的形式返回
     *
     * @return 硬件特征码，注意可能获取失败。失败时返回NULL
     **/
    const char* ssl_vpn_query_hardid();
    
    /**
     * @功能 设置获取图形验证码CALLBACK
     * @param callback
     **/
    void ssl_vpn_set_rnd_code_call_back(RND_CODE_CALL_BACK callback);
    
    /**
     * @功能 获取图形验证码
     **/
    int ssl_vpn_get_rnd_code();
	
    /**
     * @功能 取硬件特征码时不取网卡的值
     *
     * @return 成功0，失败－1
     **/
    int ssl_set_no_eth_hardid();

    /**
     * @功能 退出VPN
     **/
    int ssl_vpn_quit(void);
    
    /**
     * vpn重新登陆的接口,阻塞的接口
     * 
     * @return 0成功；－1，失败
     **/
    int ssl_vpn_relogin();

    /**
     * @功能 设置dns 服务器的IP地址
     * @dnsServer dnsServer服务器Ip地址字符串
     * 
     * @return void
     */
    void ssl_set_dns_server(const char *dnsServer);
    
    /**
     * @功能 获取SDK版本号
     * @return 返回SDK的版本号字符串
     */
    const char *ssl_get_version(void);
    
    /**
     * @功能 获取sessionid
     * @return 返回session字符串
     */
    const char *ssl_get_sessionid(char *buffer, int buffer_len);
    
    /**
     * 设置HOOK 勾子，多个filter之间用分号隔开
     * @param filter[in] 过滤的规则
     **/
    void ssl_vpn_addHookFilter(const char * filter);
    
    void set_reconnect_callback(RECONNECT_CALL_BACK callback);
    
    int get_proxy_port();
    
#ifdef __cplusplus
}
#endif //__cplusplus

#endif //_SSLAUTH_H_
