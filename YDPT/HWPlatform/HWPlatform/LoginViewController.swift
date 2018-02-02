//
//  LoginViewController.swift
//  HWPlatform
//
//  Created by cmp on 15/4/14.
//  Copyright (c) 2015年 HanWei. All rights reserved.
//

import UIKit

let userNameKey = "UserName"
let userPwdKey = "UserPwd"
let nineCellsKey = "NineCells"
let UsingThirdAuth = "YES"
//KeyChain存储名字
let TegKeychain_keyID = "HanWeiPlatform_ID"
var userDataManager = UserDataManager()
var VpnConnecter : VPNConnector = VPNConnector()
//弹窗定时器
var timer:NSTimer!
//检测网络连通性
//var Netreachability = Reachability.reachabilityForInternetConnection()
//var NetConnected = true
//var WIFIConnected = true
//运行环境IOS固件版本号
var iosVerion : Double = 0

class LoginViewController: UIViewController,UIActionSheetDelegate,UIAlertViewDelegate, DFUpdateCheckerDelegate, VPNConnectorDelegate {
    
    @IBOutlet weak var txtUser: UITextField!
    @IBOutlet weak var txtPwd: UITextField!
    @IBOutlet weak var swcRecordPwd: UISwitch!
    @IBOutlet weak var swcSetGestrue: UISwitch!
    @IBOutlet weak var swcUsingVPN: UISwitch!
    @IBOutlet weak var tableUsers: UITableView!
    @IBOutlet weak var ErrorMsg: UILabel!
    @IBOutlet weak var AppVersion: UILabel!
    
    var verses:NSArray = [NSArray]()
    var ModuleTransitId:NSString = ""
    var Login_result:NSString = ""
    var isFinishLogin = false
    var VPNLoginState = false
    var indicator:WActivityIndicator!

    var VPN_IP = ""
    var VPN_Port = ""
    var VPN_User = ""
    var VPN_Pwd = ""
    
/*
    func versionCheck(){
        let infoDictionary = NSBundle.mainBundle().infoDictionary
        let appDisplayName = infoDictionary!["CFBundleName"] as! String
        let majorVersion  = infoDictionary! ["CFBundleShortVersionString"] as! String
        let minorVersion  = infoDictionary! ["CFBundleVersion"] as! String
        let iosversion : NSString = UIDevice.currentDevice().systemVersion;
        let appversion = majorVersion as! String
        print(appversion)
    }
*/
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //获取当前运行环境IOS固件的版本号
        let device : UIDevice = UIDevice.currentDevice()
        let systemVersion = device.systemVersion
        //获取当前App版本号，同步登陆界面显示
        let infoDictionary = NSBundle.mainBundle().infoDictionary
        let majorVersion : AnyObject? = infoDictionary! ["CFBundleShortVersionString"] as! String
        let appversion = majorVersion as! String
        AppVersion.text = "版本:  V" + appversion
        //此方法或许存在问题
        iosVerion = (systemVersion as NSString).doubleValue
    	txtUser.text = userDataManager.userData.objectForKey(userNameKey) as? String
        txtPwd.text = userDataManager.userData.objectForKey(userPwdKey) as? String
        VPN_IP = (userDataManager.userData.objectForKey("VPN_IP") as? String)!
        VPN_Port = (userDataManager.userData.objectForKey("VPN_Port") as? String)!
        let swcVPN = (userDataManager.userData.objectForKey("SwitchVPN") as? String)!
        let swcRecord = (userDataManager.userData.objectForKey("SwitchRecord") as? String)!
        let swcGesture = (userDataManager.userData.objectForKey("SwitchGesture") as? String)!
        
//针对已发布的APP，修改其服务器地址
//        let currentServerAddr = userDataManager.userData.objectForKey("MainUrl") as? String
//        if currentServerAddr != "http://10.84.0.231:9009/webptframe"
//        {
//            userDataManager.userData.setValue("http://10.84.0.231:9009/webptframe", forKey:"MainUrl")
//            userDataManager.userData.setValue("http://10.84.0.231:9009/PTInterface/PtInterface.asmx", forKey:"LoginUrl")
//            userDataManager.SaveUserDataFile()
//        }
        
        if swcVPN == "true" { swcUsingVPN.on = true }
        else { swcUsingVPN.on = false }
        if swcRecord == "true" { swcRecordPwd.on = true }
        else { swcRecordPwd.on = false }
        if swcGesture == "true" { swcSetGestrue.on = true }
        else { swcSetGestrue.on = false }
        
        //初始化VPN
        VpnConnecter.vpnIp = VPN_IP  //vpn设备IP地址
        VpnConnecter.port = 443 //VPN端口号
        VpnConnecter.init_VPN()
        
        swcUsingVPN.addTarget(self, action: Selector("stateChangedVPN:"), forControlEvents: UIControlEvents.ValueChanged)
        swcRecordPwd.addTarget(self, action: Selector("stateChangeRecord:"), forControlEvents: UIControlEvents.ValueChanged)
        swcSetGestrue.addTarget(self, action: Selector("stateChangeGestrue:"), forControlEvents: UIControlEvents.ValueChanged)
        //tableUsers.hidden = true
        
        //检查KeyChain标识
        if let value = KeychainSwift.get(TegKeychain_keyID) {
            userDataManager.userData.setValue(value, forKey:"Device_identifier")
            userDataManager.SaveUserDataFile()
            
        } else {
            //首次安装不存在唯一标识
            let beaconUUID:NSUUID = NSUUID()
            let UUDIString:String = beaconUUID.UUIDString
            KeychainSwift.set(UUDIString, forKey: TegKeychain_keyID)
            userDataManager.userData.setValue(UUDIString, forKey:"Device_identifier")
            userDataManager.SaveUserDataFile()
        }
//        //检查网络状态
//        Netreachability.whenReachable = { Netreachability in
//            self.updateWhenReachable(Netreachability)
//        }
//        Netreachability.whenUnreachable = { Netreachability in
//            self.updateWhenNotReachable(Netreachability)
//        }
//        
//        Netreachability.startNotifier()
//        // Initial reachability check
//        if Netreachability.isReachable() {
//            updateWhenReachable(Netreachability)
//        } else {
//            updateWhenNotReachable(Netreachability)
//        }
    }
    
//    //检查网络状态,有链接
//    func updateWhenReachable(reachability: Reachability) {
//        if reachability.isReachableViaWiFi() {
//            WIFIConnected = true
//        } else {
//            WIFIConnected = false
//        }
//        
//        //self.networkStatus.text = reachability.currentReachabilityString
//    }
//    
//    //检查网络状态,无链接
//    func updateWhenNotReachable(reachability: Reachability) {
//        //当前无可用网络
//        NetConnected = false
//        
//        timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "timerMethods", userInfo: nil, repeats: true)
//    }
    
    func timerMethods(){
        dispatch_async(dispatch_get_main_queue(), {
            self.PopMessage("网络不可用，如果继续，请先设置网络！")
        })
        UIApplication.sharedApplication().openURL(NSURL(fileURLWithPath: "prefs:root=WIFI"))
        timer.invalidate()
    }
    
    // 针对Iphone设备隐藏键盘.
    @IBAction func TextField_DidEndOnExit(sender: AnyObject){
    
        sender.resignFirstResponder
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnForgetPWD(sender: AnyObject) {
//        let acctiveSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: "短信验证" ,otherButtonTitles : "邮箱验证")
//        //,moreButtonTitles : "分享到微博"
//        acctiveSheet.showInView(self.view)
    }

    @IBAction func btnServerSet(sender: AnyObject) {

        let MainUrl = (userDataManager.userData.objectForKey("MainUrl")as?String!)
        let LoginUrl = (userDataManager.userData.objectForKey("LoginUrl")as?String!)
        let alert = SCLAlertView()
        alert.addLable("服务器地址:")
        let Server_Adress = alert.addTextField("请输入服务器地址")
        Server_Adress.text = MainUrl
        alert.addLable("登陆验证地址:")
        let Auth_Adress = alert.addTextField("请输入登陆验证地址")
        Auth_Adress.text = LoginUrl
        
        alert.addButton("确定") {
            //println("Text value: \(txt.text)")
            userDataManager.userData.setValue(Server_Adress.text, forKey:"MainUrl")
            userDataManager.userData.setValue(Auth_Adress.text, forKey:"LoginUrl")
            userDataManager.SaveUserDataFile()
        }
        //alert.showEdit("服务器设置", subTitle:"", closeButtonTitle:"取消")
        alert.showCustom("服务器设置", subTitle:"请设置服务器地址和验证地址", closeButtonTitle:"取消")
    }
    
    @IBAction func btnVPNSet(sender: AnyObject) {
        
        let VPN_IP = (userDataManager.userData.objectForKey("VPN_IP")as?String!)
        let VPN_Port = (userDataManager.userData.objectForKey("VPN_Port")as?String!)
        let VPN_User = (userDataManager.userData.objectForKey("VPN_User")as?String!)
        let VPN_Pwd = (userDataManager.userData.objectForKey("VPN_Pwd")as?String!)
        let alert = SCLAlertView()
        alert.addLable("服务器地址:")
        let Server_Adress = alert.addTextField("请输入服务器地址")
        Server_Adress.text = VPN_IP
        alert.addLable("服务器端口号:")
        let Port_Adress = alert.addTextField("请输入服务器端口号")
        Port_Adress.text = VPN_Port
        alert.addLable("VPN用户名:")
        let UserName = alert.addTextField("请输入VPN用户名")
        UserName.text = VPN_User
        alert.addLable("VPN密码:")
        let UserPwd = alert.addTextField("请输入VPN密码")
        UserPwd.text = VPN_Pwd
        
        alert.addButton("确定") {
            //println("Text value: \(txt.text)")
            userDataManager.userData.setValue(Server_Adress.text, forKey:"VPN_IP")
            userDataManager.userData.setValue(Port_Adress.text, forKey:"VPN_Port")
            userDataManager.userData.setValue(UserName.text, forKey:"VPN_User")
            userDataManager.userData.setValue(UserPwd.text, forKey:"VPN_Pwd")
            userDataManager.SaveUserDataFile()
        }
        //alert.showEdit("服务器设置", subTitle:"", closeButtonTitle:"取消")
        alert.showCustom("VPN设置", subTitle:"请设置VPN服务相关信息", closeButtonTitle:"取消")
    }
    
    @IBAction func reloadData()
    {
    }
    
    func stateChangedVPN(switchState: UISwitch) {
        if switchState.on {
            userDataManager.userData.setValue("true", forKey:"SwitchVPN")
            WIndicator.showMsgInView(self.view, text: "将启动VPN方式登陆系统！！！", timeOut: 1.0)
        } else {
            userDataManager.userData.setValue("false", forKey:"SwitchVPN")
            WIndicator.showMsgInView(self.view, text: "将启动局域网登陆系统", timeOut: 1.0)
        }
        userDataManager.SaveUserDataFile()
    }
    
    func stateChangeRecord(switchState: UISwitch) {
        if switchState.on {
            userDataManager.userData.setValue("true", forKey:"SwitchRecord")
            WIndicator.showMsgInView(self.view, text: "如果登陆成功，保存用户名密码", timeOut: 1.0)
        } else {
            userDataManager.userData.setValue("false", forKey:"SwitchRecord")
            WIndicator.showMsgInView(self.view, text: "取消保存用户名密码", timeOut: 1.0)
        }
        userDataManager.SaveUserDataFile()
    }
    
    func stateChangeGestrue(switchState: UISwitch) {
        if switchState.on {
            userDataManager.userData.setValue("true", forKey:"SwitchGesture")
            //var indicatortext = WIndicator.showMsgInView(self.view, text: "如果登陆成功，保存用户名密码", timeOut: 1.0)
        } else {
            userDataManager.userData.setValue("false", forKey:"SwitchGesture")
            //var indicatortext = WIndicator.showMsgInView(self.view, text: "取消保存用户名密码", timeOut: 1.0)
        }
        userDataManager.SaveUserDataFile()
    }

    func Auth_third(User:UITextField, pwd:UITextField)
    {
        //获取程序第三方验证登陆验证地址
        let LoginUrl = (userDataManager.userData.objectForKey("LoginUrl")as?String!)
        let third_LoginUrl = (userDataManager.userData.objectForKey("third_LoginUrl")as?String!)
        let third_SoapAction = (userDataManager.userData.objectForKey("thired_soapAction") as?String!)
        
        let soapMessage = "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/' ><soap:Header></soap:Header><soap:Body><login xmlns='urn:sso.combest.com/'><appkey>1034</appkey><appSecrect>ydpt_1034</appSecrect><userName>" + User.text! + "</userName><pwd>" + pwd.text! + "</pwd></login></soap:Body></soap:Envelope>"
        
        let soap = ContentManager()
        soap.login(third_SoapAction!, SoapURL:third_LoginUrl!, SoapMessage:soapMessage) {
            (result) -> Void in
            
            let rtnStr:String = NSString(data: result, encoding:NSUTF8StringEncoding) as! String
            if rtnStr != "ErrorReturn"
            {
                var error: NSError?
                if let rtnstr = AEXMLDocument(xmlData: result, error: &error) {
                    
                    // prints the same XML structure as original
                    print(rtnstr.xmlString)
                    //取出返回XML中的Body
//                    var account = rtnstr.root["soapenv:Body"]["multiRef"]["account"].stringValue
                    let token = rtnstr.root["soapenv:Body"]["multiRef"]["token"].stringValue
                    let errMsg = rtnstr.root["soapenv:Body"]["multiRef"]["errMsg"].stringValue
                    if errMsg != ""
                    {
                        var errmessage = ""
                        switch errMsg
                        {
                        case "-1":
                            errmessage = "应用标识不存在"
                        case "-2":
                            errmessage = "应用标识与密匙不匹配"
                        case "-3":
                            errmessage = "验证的用户在单点登录系统中不存在"
                        case "-4":
                            errmessage = "非AD用户密码校验失败"
                        case "-5":
                            errmessage = "AD用户密码校验失败"
                        case "-6":
                            errmessage = "读取系统配置错误"
                        case "-7":
                            errmessage = "无效的Token."
                        case "-8":
                            errmessage = "Token与应用标识不匹配"
                        case "-9":
                            errmessage = "服务器不在可信列表中"
                        case "-10":
                            errmessage = "验证的部门在单点登录系统中不存在"
                        case "-999":
                            errmessage = "其他错误"
                        default:
                            errmessage = "未知的错误返回值"
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), {

                            self.indicator.text = "第三方验证失败，即将进行本地验证！！"
                            self.ErrorMsg.text = "第三方验证错误信息：" + errmessage

                        })
                        
                        sleep(1)
                        self.Auth_local(User.text!, pwd: pwd.text!) {
                            ()->Void in
                            //返回主线程继续执行
                            dispatch_async(dispatch_get_main_queue(), {
                                self.After_Auth()
                            })
                        }
                    }
                    else
                    {
                        userDataManager.userData.setValue(token as String, forKey:"Thirdtoken")
                        userDataManager.SaveUserDataFile()
                        
                        self.Local_insertUser(Usebr.text!, pwd: pwd.text!, insertUserURL:LoginUrl!){
                            () -> Void in
                            //返回主线程继续执行
                            dispatch_async(dispatch_get_main_queue(), {
                                self.After_Auth()
                            })
                        }
                    }
                    
                } else {
                    print("description: \(error?.localizedDescription)\ninfo: \(error?.userInfo)")
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), {
                    self.AlertMessage("请检查网络连接及服务器设置是否正确")
                })
            }
        }
    }
    
    func Local_insertUser(User:String, pwd:String, insertUserURL:String, completion: () -> Void)
    {
        let soapMessage =
        "<?xml version='1.0' encoding='utf-8'?>"
        "<soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/' >"
        "<soap:Header></soap:Header>"
        "<soap:Body>"
        "<InsertUserPwdAndReturnTransitId xmlns='http://www.hanweikeji.com/Pt4Interface/'>"
        "<Login>" + User + "</Login>"
        "<PwdStr>" + pwd + "</PwdStr>"
        "<AppKey>1034</AppKey>"
        "<appSecrect>ydpt_1034</appSecrect>"
        "<UserIp>192.168.1.1</UserIp>"
        "<Dwdm>31400000</Dwdm>"
        "<rolename>系统默认角色</rolename>"
        "</InsertUserPwdAndReturnTransitId>"
        "</soap:Body>"
        "</soap:Envelope>"
        
        //获取程序WebService 登陆验证地址
        //var insertUserURL = (userDataManager.userData.objectForKey("insertUserURL")as?String!)
        let insertUser_soapAction = (userDataManager.userData.objectForKey("insertUser_soapAction")as?String!)
        
        let soap = ContentManager()
        soap.login(insertUser_soapAction!, SoapURL:insertUserURL, SoapMessage:soapMessage) {
            (result) -> Void in
            var error: NSError?
            let rtnStr:String = NSString(data: result, encoding:NSUTF8StringEncoding) as! String
            if rtnStr != "ErrorReturn"
            {
                if let rtnstr = AEXMLDocument(xmlData: result, error: &error) {
                    
                    // prints the same XML structure as original
                    print(rtnstr.xmlString)
                    //取出返回XML中的Body
                    let token = rtnstr.root["soap:Body"]["InsertUserPwdAndReturnTransitIdResponse"]["InsertUserPwdAndReturnTransitIdResult"].stringValue
                    let NStoken:NSString = token
                    self.Login_result = NStoken.substringWithRange(NSMakeRange(11,4))
                    self.ModuleTransitId = NStoken.substringWithRange(NSMakeRange(36,36))
                    userDataManager.userData.setValue(self.Login_result as String, forKey:"Login_result")
                    userDataManager.userData.setValue(self.ModuleTransitId as String, forKey:"ModuleTransitId")
                    userDataManager.SaveUserDataFile()
                    
                    //启用回调
                    completion()
                    
                } else {
                    print("description: \(error?.localizedDescription)\ninfo: \(error?.userInfo)")
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), {
                    self.AlertMessage("请检查网络连接及服务器设置是否正确")
                })
            }
        }
    }

    func Auth_local(User:String, pwd:String, completion: () -> Void)
    {
        let soapMessage =
        "<?xml version='1.0' encoding='utf-8'?>"
        "<soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/' >"
        "<soap:Header></soap:Header>"
        "<soap:Body>"
        "<CheckUserPwdEx xmlns='http://www.hanweikeji.com/Pt4Interface/'>"
        "<Login>" + User + "</Login>"
        "<PwdStr>" + pwd + "</PwdStr>"
        "<UserIp>192.168.1.1</UserIp>"
        "</CheckUserPwdEx>"
        "</soap:Body>"
        "</soap:Envelope>"
        
        //获取程序WebService 登陆验证地址
        let LoginUrl = (userDataManager.userData.objectForKey("LoginUrl")as?String!)
        let Login_SoapAction = (userDataManager.userData.objectForKey("Login_soapAction")as?String!)
        
        let soap = ContentManager()
        VpnConnecter.autoLogin()
        soap.login(Login_SoapAction!, SoapURL:LoginUrl!, SoapMessage:soapMessage) {
            (result) -> Void in
            let rtnStr:String = NSString(data: result, encoding:NSUTF8StringEncoding) as! String
            if rtnStr != "ErrorReturn"
            {
                var error: NSError?
                if let rtnstr = AEXMLDocument(xmlData: result, error: &error) {
                    
                    // prints the same XML structure as original
                    print(rtnstr.xmlString)
                    //取出返回XML中的Body
                    let token = rtnstr.root["soap:Body"]["CheckUserPwdExResponse"]["CheckUserPwdExResult"].stringValue
                    let NStoken:NSString = token
                    self.Login_result = NStoken.substringWithRange(NSMakeRange(11,4))
                    print(self.Login_result)
                    if self.Login_result == "true"
                    {
                        self.ModuleTransitId = NStoken.substringWithRange(NSMakeRange(36,36))
                        userDataManager.userData.setValue(self.Login_result as String, forKey:"Login_result")
                        userDataManager.userData.setValue(self.ModuleTransitId as String, forKey:"ModuleTransitId")
                        userDataManager.SaveUserDataFile()
                        
                        //启用回调
                        completion()
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.AlertMessage("登陆失败，请检查用户名密码")
                        })
                    }
                } else {
                    print("description: \(error?.localizedDescription)\ninfo: \(error?.userInfo)")
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), {
                    self.AlertMessage("请检查网络连接及服务器设置是否正确")
                })
            }
        }
    }
    
    func After_Auth()
    {
        self.indicator.text = "系统登录中，请稍后！！"
        dispatch_async(dispatch_get_global_queue(0,0), { () -> Void in
            sleep(1)
            dispatch_async(dispatch_get_main_queue(), {
                WIndicator.removeIndicatorFrom(self.view, animation: true,completion:{ () -> Void in
                    //若是记录密码 bn
                    if self.swcRecordPwd.on {
                        userDataManager.userData.setValue(self.txtUser.text, forKey:userNameKey)
                        userDataManager.userData.setValue(self.txtPwd.text, forKey:userPwdKey)
                    }
                        //否则，移除记录的密码
                    else
                    {
                        userDataManager.userData.removeObjectForKey(userNameKey)
                        userDataManager.userData.removeObjectForKey(userPwdKey)
                        userDataManager.userData.removeObjectForKey(self.txtUser.text!)
                    }
                    //写入文件
                    userDataManager.SaveUserDataFile()
                    
                    //println(userDataManager.userData.count)
                    
                    let myStoryBoard = self.storyboard
                    var anotherView1:UIViewController
                    //若是记录了密码，且 要开启手势 且 没有记录当前手势
                    if self.swcRecordPwd.on && self.swcSetGestrue.on && !userDataManager.ContainKey(self.txtUser.text!) {
                        anotherView1 = myStoryBoard!.instantiateViewControllerWithIdentifier("reInputGesture") 
                    }
                    else{
                        anotherView1 = myStoryBoard!.instantiateViewControllerWithIdentifier("browser") 
                    }

                    sleep(1)
                    self.presentViewController(anotherView1, animated: true, completion: nil)
                })
            })
        })
    }
    
    func do_Login()
    {
        let User = self.txtUser
        let pwd = self.txtPwd

        if (User.text) == "" || (pwd.text) == ""
        {
            dispatch_async(dispatch_get_main_queue(), {
                self.AlertMessage("用户名及密码不为空")
            })
        }
        else
        {
            //Master， Slave Server select
            indicator.text = "检查服务器是否在线!!!"
            platformServerSelect()
            
            //存在第三方登陆，使用第三方登陆
            if UsingThirdAuth == "YES"
            {
                if swcUsingVPN.on
                {
                    indicator.text = "VPN认证成功，进行第三方认证"
                }
                else
                {
                    indicator.text = "进行第三方认证操作!!!"
                }
                
                self.Auth_third(User, pwd: pwd)
            }
            else
            {
                if swcUsingVPN.on
                {
                    indicator.text = "VPN认证成功，进行本地认证"
                }
                else
                {
                    indicator.text = "进行本地认证操作!!!"
                }
                
                Auth_local(User.text!, pwd: pwd.text!) {
                    () -> Void in
                    dispatch_async(dispatch_get_main_queue(), {
                        self.After_Auth()
                    })
                }
            }
        }
    }
    
    //选择主从服务器
    func platformServerSelect()
    {
        //检测主服务器的服务状态
        let baseUrl = NSURL(string: "http://10.84.11.60:8008/ApkVersion/checkMainServer.html")
        let request = NSMutableURLRequest(URL: baseUrl!)
        request.HTTPMethod = "GET"
        request.timeoutInterval = 2
        let response : AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        
        do {
            let rtndata = try NSURLConnection.sendSynchronousRequest(request, returningResponse: response)

            let rtnString = NSString(data: rtndata, encoding: NSUTF8StringEncoding)
            
            //访问页面存在
            if rtnString != nil
            {
                if  rtnString!.componentsSeparatedByString("Hello World").count > 1
                {
                    userDataManager.userData.setValue("http://10.84.11.60:8008/webptframe/Home/Index", forKey:"MainUrl")
                    userDataManager.userData.setValue("http://10.84.11.60:8008/Ptinterface/PtInterface.asmx", forKey:"LoginUrl")
                    userDataManager.userData.setValue("http://10.84.11.60:8008/webptframe/HWPTWeb.asmx", forKey:"insertUpdateInfo")
                    userDataManager.SaveUserDataFile()
                }
            }
            else //访问页面不存在
            {
                userDataManager.userData.setValue("http://10.84.11.87:8008/webptframe/Home/Index", forKey:"MainUrl")
                userDataManager.userData.setValue("http://10.84.11.87:8008/Ptinterface/PtInterface.asmx", forKey:"LoginUrl")
                userDataManager.userData.setValue("http://10.84.11.87:8008/webptframe/HWPTWeb.asmx", forKey:"insertUpdateInfo")
                userDataManager.SaveUserDataFile()
            }
        } catch (let e) {
            print(e)
            userDataManager.userData.setValue("http://10.84.11.87:8008/webptframe/Home/Index", forKey:"MainUrl")
            userDataManager.userData.setValue("http://10.84.11.87:8008/Ptinterface/PtInterface.asmx", forKey:"LoginUrl")
            userDataManager.userData.setValue("http://10.84.11.87:8008/webptframe/HWPTWeb.asmx", forKey:"insertUpdateInfo")
            userDataManager.SaveUserDataFile()
        }
    }

    //VPNConnector delegate
    func VPNReturn(rtnMsg : String!, type retType : String)
    {
        if retType ==  "Error"
        {
            dispatch_async(dispatch_get_main_queue(), {
                self.AlertMessage(rtnMsg)
            })
        }
        else
        {
            self.VPNLoginState = true
            self.do_Login()
        }
    }
    
    func do_VPN()
    {
        VPN_User = (userDataManager.userData.objectForKey("VPN_User") as? String)!
        VPN_Pwd = (userDataManager.userData.objectForKey("VPN_Pwd") as? String)!
        //VPN用户名密码为空，使用登陆的用户名密码
        if VPN_User == "" && VPN_Pwd == ""
        {
            VPN_User = txtUser.text!
            VPN_Pwd = txtPwd.text!
        }
        
        VpnConnecter.delegate = self;
        VpnConnecter.userName = VPN_User //VPN用户名
        VpnConnecter.password = VPN_Pwd //VPN密码
        VpnConnecter.authTimeout = "5" //超时时间

        VpnConnecter.login()
    }
    
    //DFUpdateChecker  Delegate
    func checkFinishedWithNewVersion(theNewVersion: String!, newThing theNewThing: String!)
    {
        self.indicator = WIndicator.showIndicatorAddedTo(self.view, animation: true)
        if theNewVersion=="Newest"
        {
            if swcUsingVPN.on
            {
                if !self.VPNLoginState
                {
                    self.indicator.text = "初始化VPN成功，进行认证操作"
                    self.do_VPN()
                }
                else
                {
                    self.do_Login()
                }
            }
            else
            {
                self.do_Login()
            }
        }
        else
        {
            let text = "有新的版本\(theNewVersion)可供使用\n此版本有如下新特性：\n\(theNewThing)"
            showAlertController(text)
        }
    }
    
    func showAlertController(text:String){

        let msgTitle:String = "软件更新"
        let msgMessage:String = text
        let btnNo:String = "以后再说"
        let btnYes: String = "立即下载"
        
        let title = msgTitle
        let message = msgMessage
        let btnLeft = btnNo
        let btnRight = btnYes
        
        if(iosVerion < 8.0) {
            UIApplication.sharedApplication().openURL(NSURL(string : "itms-services://?action=download-manifest&url=https://ydptxz.jhpa.com.cn/jhydpt.plist")!)
        } else {
            let alertController = UIAlertController(title: title, message: message,
                preferredStyle: .Alert)
            let actionLeft = UIAlertAction(title:btnLeft, style: .Cancel) { action in
                if self.swcUsingVPN.on {
                    
                    if !self.VPNLoginState
                    {
                        self.indicator.text = "初始化VPN成功，进行认证操作"
                        self.do_VPN()
                    }
                    else
                    {
                        self.do_Login()
                    }
                }
                else
                {
                    self.do_Login()
                }
            }
            
            let actionRight = UIAlertAction(title:btnRight, style: .Default) { action in
                UIApplication.sharedApplication().openURL(NSURL(string : "itms-services://?action=download-manifest&url=https://ydptxz.jhpa.com.cn/jhydpt.plist")!)

                exit(0)
            }
            
            alertController.addAction(actionLeft)
            alertController.addAction(actionRight)
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func do_checkUpdate()
    {
        var checker : DFUpdateChecker!
        checker = DFUpdateChecker()
        checker.delegate=self
        checker.checkNew("https://ydptxz.jhpa.com.cn/CheckUpdate.asp?type=%@")
    }
    
    //登陆逻辑中弹窗提示信息
    func AlertMessage(alertMessage:String)
    {
        //移除活动指示器
        WIndicator.removeIndicatorFrom(self.view, animation: true,completion:{ () -> Void in
            self.isFinishLogin = false
            let alertBox = UIAlertView()
            alertBox.title = "提示"
            alertBox.message = alertMessage
            alertBox.delegate = self
            alertBox.addButtonWithTitle("确定")
            alertBox.show()
        })
    }
    
    //弹窗信息
    func PopMessage(alertMessage:String)
    {
        let alertBox = UIAlertView()
        alertBox.title = "提示"
        alertBox.message = alertMessage
        alertBox.delegate = self
        alertBox.addButtonWithTitle("确定")
        alertBox.show()
    }
    
    //登录接口
    @IBAction func btnLogin(sender: AnyObject) {
        
        //清空历史Token & TransitID
        userDataManager.userData.setValue("", forKey:"Thirdtoken")
        userDataManager.userData.setValue("", forKey:"ModuleTransitId")
        userDataManager.SaveUserDataFile()
        
        if isFinishLogin == false
        {
            isFinishLogin = true
            do_checkUpdate()
        }
    }
    
    @IBAction func btnDropDown(sender: AnyObject) {
        
//        if tableUsers.hidden == true
//        {
//            tableUsers.hidden = false
//        }
//        else
//        {
//            tableUsers.hidden = true
//        }
        
    }
}
