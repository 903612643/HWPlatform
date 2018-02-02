//
//  sdkheader.h
//  forwardSdk
//
//  Created by Huang Shounan on 12-9-6.
//  Copyright (c) 2012年 Huang Shounan. All rights reserved.
//

#ifndef __FORWARD_SDK_HEADER_H__
#define __FORWARD_SDK_HEADER_H__

#include <stdint.h>

#ifdef __cplusplus
extern "C"
{
#endif //__cplusplus

    //数字证书数据结构体,注意为X509结构
    typedef struct _identityData
    {
        void *data; //数字证书，数据
        int len; //数字证书数据的长度
    } IdentityData;

#define SSL_AUTH_TYPE_FIRSTAUTH  	-1000 	/** 第一个认证 */ 
#define SSL_AUTH_TYPE_CERTIFICATE  	0   	/** 证书认证 */
#define SSL_AUTH_TYPE_PASSWORD      1   	/** 用户名密码认证 */
#define SSL_AUTH_TYPE_SMS           2   	/** 短信认证 */
#define SSL_AUTH_TYPE_SMS1          3   	/**重新获取短信认证码 */
#define SSL_AUTH_TYPE_HARDID        4   	/** 硬件特征码 */
#define SSL_AUTH_TYPE_USBKEY        5   	/** USBKEY认证 */
#define SSL_AUTH_TYPE_RADIUS        6   	/** RADIUS挑战认证 */
#define SSL_AUTH_TYPE_TOKEN         7   	/** 令牌认证 */
#define SSL_AUTH_TYPE_TWF           16  	/** TWF认证 */
#define SSL_AUTH_TYPE_NONE          17  	/** 无认证 */

#define START_RECONNECT             0  //开始重新连接
#define END_RECONNECT               1  //结束重新连接
#define SUCCESS                    -1  //重新连接成功
#define FAILD                       0  //重新连接失败
    
#define PORPERTY_NamePasswordAuth_NAME      "NamePasswordAuth.name"
#define PORPERTY_NamePasswordAuth_PASSWORD  "NamePasswordAuth.password"
#define PORPERTY_HardIdAuth_HARDID          "HardIdAuth.hardid"
#define PORPERTY_Keychain_Identifier        "sangfor.keychain.identifier"

#define CERT_PASSWORD                       "CertAuth.Certs.PassWord"  //证书的密码
#define CERT_P12_FILE_NAME                  "CertAuth.Certs.P12File"   //P12证书路径
#define CERT_PEM_KEY_FILE_NAME              "CertAuth.Certs.PEM.KeyFile" //PEM key文件
#define CERT_PEM_CERT_FILE_NAME             "CertAuth.Certs.Cert.KeyFile" //PEM RTS私钥文件
#define CERT_PEM_KEY_CONTENT                "CertAuth.Certs.PEM.KeyConten" //PEM key内容编码
#define CERT_PEM_CERT_CONTENT               "CertAuth.Certs.Cert.KeyConten" //PEM RTS内容ASN1编码
#define SMS_AUTH_CODE                       "Message.Auth.Code"        //短信认证的code
#define ACCESS_GROUPS_SHARE_KEY             "IndentfyAccessGroups.Key" //keyChain共享的字符串
#define CERT_AUTH_SLECT_AUTH                "CertAuth.Whether.Chosse.Identity" //设置证书选择证书标记
#define SET_RND_IMAGE_AUTH                  "NamePasswordAuth.Set.Randcode" //开启图形校验码认证  
#define GET_RND_IMAGE                       "FirstAuth.RNDIMG"         //图形校验码
#define SET_RND_CODE_STR                    "NamePasswordAuth.svpn_rand_code" //图形校验码
#define AUTH_RND_CODE_CALL_BACK             "RNDCode.CallBack"         //获取图形校验码的callback
#define AUTH_WITH_RND_CODE                  "RNDCode.Enable"           //开启图形校验码
#define AUTH_CONNECT_TIME_OUT               "Auth.Connect.timeout"     //认证连接超时时间
#define KEYCHAIN_ACESS_KEY                  "Keychain.Access.Key"      
    //多个程序共享的keychain标识
    //关闭SDK自动登陆的选项，建议使用此选项，关闭自动登陆的功能，对数据传输进行了优化的处理
    //在不设置该关键字的时候默认是开启自动登陆的选项，兼容以前老版本的功能，建议关闭自动登陆，
    //支持IOS7的SDK对非自动登陆的情况下进行了数据传输进行了优化，数据传输传输更快了
#define AUTO_LOGIN_OFF_KEY                   "SangforSdk.AutoLogin.Off.Key"
#define AUTH_DEVICE_ID                       "Auth.Device.id"  //device id

    /** 调用VPN初始化和认证接口后的结果，如果想获取具体信息可通过vpn_geterr()获取 **/
    typedef enum
    {
		RESULT_VPN_L3VPN_FAIL = -3,		// L3VPN启动失败
        RESULT_VPN_INIT_FAIL = -2,  //初始化SVPN登陆失败
        RESULT_VPN_AUTH_FAIL = -1,  //认证失败
        RESULT_VPN_NONE = 0,  // 无效值
        RESULT_VPN_INIT_SUCCESS = 1,  //初始化VPN成功
        RESULT_VPN_AUTH_SUCCESS = 2,  //认证成功
        RESULT_VPN_AUTH_LOGOUT = 3,  //vpn注销了
		RESULT_VPN_AUTH_CANCEL = 4,		// vpn认证取消了
		RESULT_VPN_L3VPN_SUCCESS = 5,	// L3VPN启动成功
		RESULT_VPN_OTHER = 6,			// 其他返回状态
    } VPN_RESULT_NO;

	/** 其他返回状态，用作拓展 **/
	typedef enum
	{
		VPN_OTHER_RELOGIN_FAIL = 0,		// 网络问题导致重连失败
	} VPN_RESULT_OTHER_NO;

    /** VPN状态码 **/
    typedef enum
    {
        VPN_STATUS_UNSTART = 0,  // 未启动
        VPN_STATUS_INITING,  // 正在初始化
        VPN_STATUS_INIT_OK,  // 初始化完成
        VPN_STATUS_LOGINING,  // 正在进行认证
        VPN_STATUS_RELOGIN,  // 重新进行认证
        VPN_STATUS_OK,  // 也就是认证成功,正常运行中
        VPN_STATUS_EXITING,  // 正在退出VPN的状态
        VPN_STATUS_ERR_THREAD,  // 非主线程错误
        VPN_STATUS_LOGOUT,  // 用户已经注销
        VPN_STATUS_TIME_OUT,  // 查询VPN状态超时或者网络错误
        VPN_STATUS_QUERY_ERR  // vpn查询时出现错误
    } VPN_STATUS;

    /**
     * @功能 SDK的VPN回调函数，注意它函数在新建的线程中回调，请调用都关心线程安全和线程死锁的问题
     * @param vpnErrno vpn连接结果，成功返回ERROR_VPN_SUCCESS，失败返回对应的错误码，具体错误信息可通过获取错误信息接口获取
     * @param authType 成功返回认证类型，失败返回无效值0
     *
     * @return 无
     **/
    typedef void(*VPN_CALL_BACK)(const VPN_RESULT_NO result, const int authType);

    /**
     * @功能 证书认证时，证书内容匹配回调函数，注意此回调函数是在设置了keychain的key值时才会生效
     * @param identityVec 证书数组
     * @param len  证书数组中证书的个数
     * @return  < count 返回证书认证中选择证书的索引值，－1标示不选择，没有符合的证书
     */
    typedef int(*CERT_AUTH_CALL_BACK)(const IdentityData *identityVec, const int count);

    /**
     * 获取图形码的CallBack函数
     * @param addr 二进制图片
     * @param addrlen 二进制的长度
     **/
    typedef void(*RND_CODE_CALL_BACK)(const void *addr, uint32_t addrlen);
    
    typedef void(*RECONNECT_CALL_BACK)(const int status, int result);
    
#ifdef __cplusplus
}

#endif //__cplusplus

#endif // __FORWARD_SDK_HEADER_H__
