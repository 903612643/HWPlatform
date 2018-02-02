//
//  WebJSInterface.swift
//  HWPlatform
//
//  Created by hanwei on 15/6/30.
//  Copyright (c) 2015年 HanWei. All rights reserved.
//

import Foundation

public protocol WebJSInterfaceDelegate:NSObjectProtocol
{
    func showDownLoadProgress()
    func ChangeProgress(percentage:Double)
    func RemoveProgress()
}

class WebJSInterface: NSObject, DownloadManagerDelegate{
    var indicator:WActivityIndicator!
    
    var progressView:MRProgressOverlayView!
    var downloadProgress:WebJSInterfaceDelegate!
    
    //给平台返回系统信息
    func GetSysVersion() -> String {
        
        return "IOS"
    }
    
    func PopMessage(alertMessage:String)
    {
        //移除活动指示器
        let alertBox = UIAlertView()
        alertBox.title = "提示"
        alertBox.message = alertMessage
        alertBox.delegate = self
        alertBox.addButtonWithTitle("取消")
        alertBox.show()
    }
    
    //传递视频播放地址
    func playRTMP(RTMPURL:String) -> String {
        let url = NSURL(string:RTMPURL)
        
//独立播放器应用
//        let Scheme = "HanWeiRTMPPlayer://"
//        let Host = url?.host
//        let Path = url?.path
        
//        var RtmpURL = Scheme + Host! + Path!
//        let PostRtmpURL = NSURL(string:RtmpURL)


//        if (UIApplication.sharedApplication().canOpenURL(PostRtmpURL!))
//        {
//            UIApplication.sharedApplication().openURL(PostRtmpURL!)
//        }
//        else
//        {
//            var PostDIC = Dictionary<String, String>()
//            PostDIC["InstallURL"] = "itms-services://?action=download-manifest&url=https://ydptxz.jhpa.com.cn/player/RtmpPlayer.plist"
//            PostDIC["Message"] = "江汉多功能会议播放应用安装"
//            NSNotificationCenter.defaultCenter().postNotificationName("InstallAPPNotification",
//                object: nil, userInfo: PostDIC)
//        }
        
        //Native RtmpPlayer
        var PostDIC = Dictionary<String, String>()
        PostDIC["RtmpURL"] = url!.absoluteString
        NSNotificationCenter.defaultCenter().postNotificationName("PlayRtmpNotification",
            object: nil, userInfo: PostDIC)
        
        return "调用playRTMP成功"
    }
    
    //打开应用接口
    func openapplication(appname : String, AndParam2 PlistUrl : String) {
        
        if appname == "JHMail"
        {
            //打开本地代码应用，非挂接第三方应用
            var PostDIC = Dictionary<String, String>()
            PostDIC["MoudleName"] = appname
            PostDIC["Message"] = "本地代码模块"
            NSNotificationCenter.defaultCenter().postNotificationName("UseNativeMoudleNotification",
                object: nil, userInfo: PostDIC)
        }
        else
        {
            let username = userDataManager.userData.objectForKey(userNameKey) as? String
            let pwd = userDataManager.userData.objectForKey(userNameKey) as? String
            let ThirdToken = userDataManager.userData.objectForKey("Thirdtoken") as?String
            let ModuleTransitId = userDataManager.userData.objectForKey("ModuleTransitId") as?String
            let DeviceId = userDataManager.userData.objectForKey("Device_identifier") as? String!
            let VPNuse = userDataManager.userData.objectForKey("SwitchVPN") as? String!
            
            let OpenStr = appname + "://XXXXXX?UserName=" + username! + "&pwd=" + pwd! + "&Token="
                + ThirdToken! + "&TransitId=" + ModuleTransitId! + "&DeviceID=" + DeviceId! + "&VPNuse=" + VPNuse! + "&State=true"
            
            let PostOpenURL = NSURL(string:OpenStr)
            
            if (UIApplication.sharedApplication().canOpenURL(PostOpenURL!))
            {
                UIApplication.sharedApplication().openURL(PostOpenURL!)
            }
            else
            {
                var PostDIC = Dictionary<String, String>()
                PostDIC["InstallURL"] = PlistUrl
                PostDIC["Message"] = "江汉移动平台应用安装"
                NSNotificationCenter.defaultCenter().postNotificationName("InstallAPPNotification",
                    object: nil, userInfo: PostDIC)
            }
        }
    }
    
    //下载文件接口
    func downloadfile(name:String, AndParam2 downloadurl:String) {
        let infoDictionary = NSBundle.mainBundle().infoDictionary
        let appDisplayName = infoDictionary!["CFBundleName"] as! String

        if appDisplayName == "江汉移动测试" || appDisplayName == "江汉移动平台"
        {
            //江汉移动平台，下载文件到平台存储目录
            let testFileExists = FCFileManager.existsItemAtPath("/存储区域/平台存储区域")
            if (!testFileExists)
            {
                FCFileManager.createDirectoriesForPath("/存储区域/平台存储区域")
            }
            
            //let downloadDirectory = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString)//.stringByAppendingPathComponent("Downloads")
            let documentsDirectory = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString).stringByAppendingPathComponent("/存储区域/平台存储区域/")
            
            let webStringURL = downloadurl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)

            let url  = NSURL(string: webStringURL!)
            var path = (documentsDirectory as String) + "/"
            path = path + name
            
            //下载进度条显示
            downloadProgress.showDownLoadProgress()

            //开始下载
            DownloadManager.sharedInstance.subscribe(self)
            DownloadManager.sharedInstance.download(url!, filePath: path)
        }
        else
        {
            //下载文件到系统tmp目录
            let downloadDirectory = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString)//.stringByAppendingPathComponent("Downloads")
            let url  = NSURL(string: downloadurl)
            var path = (downloadDirectory as String) + "/"
            path = path + name + ".pdf"
            
            DownloadManager.sharedInstance.subscribe(self)
            DownloadManager.sharedInstance.download(url!, filePath: path)
        }

    }
    
    //第三方应用更新接口
    func updateApplication(appname:String, AndParam2 PlistUrl:String, AndParam3 deviceid:String, AndParam4 appid:String, AndParam5 loginid:String, AndParam6 version:String, AndParam7 info:String) {
        
        var PostDIC = Dictionary<String, String>()
        PostDIC["InstallURL"] = PlistUrl
        PostDIC["Message"] = "应用更新!"
        PostDIC["deviceid"] = deviceid
        PostDIC["appid"] = appid
        PostDIC["loginid"] = loginid
        PostDIC["version"] = version
        
        NSNotificationCenter.defaultCenter().postNotificationName("UpdateAPPNotification",
            object: nil, userInfo: PostDIC)
    }
    
    //卸载
    func uninstallApplication(appname:String) {
        
    }
    
    //获取设备ID
    func GetDevicedID() -> String {
        return (userDataManager.userData.objectForKey("Device_identifier") as? String!)!
    }
    
    //获取APP版本号
    func GetAppVersion() -> String {
        return (userDataManager.userData.objectForKey("Device_identifier") as? String!)!
    }
    
    //获应用程序ID
    func GetAppID() -> String {
        return (userDataManager.userData.objectForKey("App_identifier") as? String!)!
    }
    
    //Web页面返回应用于多功能会议系统
    func GetReturnButtonUsed() -> String {
        let rtnvalue = appWebReturnButton
        appWebReturnButton = "false"
        return rtnvalue
    }
    
    //获取当前网络的链接方式
    func getConnectWay() -> String {
        
        return ""
    }
}

extension WebJSInterface {
    
    func downloadManager(downloadManager: DownloadManager, downloadDidFail url: NSURL, filepath:String, error: NSError) {
        print("Failed to download: \(url.absoluteString)")
        
        let infoDictionary = NSBundle.mainBundle().infoDictionary
        let appDisplayName = infoDictionary!["CFBundleName"] as! String
        if appDisplayName == "江汉移动测试" || appDisplayName == "江汉移动平台"
        {
            //下载进度条移除
            downloadProgress.RemoveProgress()
            ProgressHUD.showSuccess("下载文件失败！")
            FCFileManager.removeItemAtPath(filepath)
        }
    }
    
    func downloadManager(downloadManager: DownloadManager, downloadDidStart url: NSURL, resumed: Bool) {
        print("Started to download: \(url.absoluteString)")
    }
    
    func downloadManager(downloadManager: DownloadManager, downloadDidFinish url: String) {
        print("Finished downloading: \(url)")
        
        let infoDictionary = NSBundle.mainBundle().infoDictionary
        let appDisplayName = infoDictionary!["CFBundleName"] as! String
        
        if appDisplayName == "江汉移动测试" || appDisplayName == "江汉移动平台"
        {
            //下载进度条移除
            downloadProgress.RemoveProgress()
            
        }
        else
        {
        }
        
        //调用打开文档文件，智能会议调用PDF打开工具，移动平台调用预览工具
        var PostDIC = Dictionary<String, String>()
        PostDIC["FilePath"] = url
        
        let filepath:NSString = url
        let filename = filepath.lastPathComponent
        PostDIC["FileName"] = filename
        NSNotificationCenter.defaultCenter().postNotificationName("OpenDocumentNotification",
            object: nil, userInfo: PostDIC)
    }
    
    func downloadManager(downloadManager: DownloadManager, downloadDidProgress url: NSURL, totalSize: UInt64, downloadedSize: UInt64, percentage: Double, averageDownloadSpeedInBytes: UInt64, timeRemaining: NSTimeInterval)
    {
        print("Downloading \(url.absoluteString) (Percentage: \(percentage))")
        let infoDictionary = NSBundle.mainBundle().infoDictionary
        let appDisplayName = infoDictionary!["CFBundleName"] as! String
        
        if appDisplayName == "江汉移动测试" || appDisplayName == "江汉移动平台"
        {
            //更新下载进度
            downloadProgress.ChangeProgress(percentage)
        }
        
    }
}