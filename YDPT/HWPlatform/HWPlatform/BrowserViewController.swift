//
//  BrowserViewController.swift
//  HWPlatform
//
//  Created by cmp on 15/4/14.
//  Copyright (c) 2015年 HanWei. All rights reserved.
//

import UIKit
import WebKit
import QuickLook

var appWebReturnButton = "false"

public protocol BrowserViewControllerDelegate:NSObjectProtocol
{
    func viewForProgressOverlay() -> UIView
}

class BrowserViewController: UIViewController, ButtonClickDelegate , UIAlertViewDelegate, DFUpdateCheckerDelegate, BubbleControlDelegate, WebJSInterfaceDelegate, QLPreviewControllerDataSource {

    var webView:EasyJSWebView!
    var myPopView:MyPopView!
    var bubble: BubbleControl!
    var JSInterface:WebJSInterface!
    var progressView:MRProgressOverlayView!
    //文档预览
    weak var dataSource:QLPreviewControllerDataSource!
    var FilePath:String!
   
    @IBOutlet weak var barBack: UIBarButtonItem!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var ShowDebug1: UILabel!
    @IBOutlet weak var ShowDebug2: UILabel!
    
    var barHidden:Bool = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.myPopView = MyPopView()
//        self.webView.delegate = self
        
        //创建可以进行JavaScript交互的 webView
        self.webView = EasyJSWebView()
        //创建交互接口对象
        self.JSInterface = WebJSInterface()
        self.JSInterface.downloadProgress = self
        //webView绑定交互接口，withName为Javascript对象
        self.webView.addJavascriptInterfaces(JSInterface, withName: "jsInterface")
        
        self.view.insertSubview(webView, belowSubview: progress)
        let mainFrame = UIScreen.mainScreen().applicationFrame
        self.webView.frame = CGRectMake(0, mainFrame.origin.y, mainFrame.size.width, mainFrame.size.height - toolbar.frame.height)

        self.progress.frame = CGRectMake(0, mainFrame.origin.y, mainFrame.size.width, progress.bounds.size.height)
        barHidden = false

        //colin will 查询
        //webView.setTranslatesAutoresizingMaskIntoConstraints(true)

//        let height = NSLayoutConstraint(item: webView, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 1, constant: -44)
//        let width = NSLayoutConstraint(item: webView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0)
//        view.addConstraints([height, width])

        
//        webView.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
//        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
        
        LoadHomePage()
        self.webView.backgroundColor = UIColor(red: CGFloat(0), green: CGFloat(0.6), blue: CGFloat(0.79), alpha: CGFloat(1))
        
        self.barBack.enabled = true
        progress.hidden = true
        
        // 监听设置方向变化
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "rotate:",
            name: UIDeviceOrientationDidChangeNotification,
            object: nil)
        //应用程序安装
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "showInstallController:",
            name: "InstallAPPNotification",
            object: nil)
        //应用程序更新
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "showUpdateController:",
            name: "UpdateAPPNotification",
            object: nil)
        //打开本地代码中的模块
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "showNativeMoudleController:",
            name: "UseNativeMoudleNotification",
            object: nil)
        
        //监听调试信息
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "showDebug:",
            name: "showDebugNotification",
            object: nil)
        //预览下载的文档
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "CallQuickLookDocument:",
            name: "OpenDocumentNotification",
            object: nil)
        
        setupBubble()
        self.bubble.hidden = true
        self.bubble.delegateSetBar = self
    }
    
    /// @brief 设置方向变化通知处理
    func rotate(sender: NSNotification?) {
//        switch UIApplication.sharedApplication().statusBarOrientation {
//        case UIInterfaceOrientation.Portrait:
//
//        case .PortraitUpsideDown:
//
//        case .LandscapeLeft:
//
//        case .LandscapeRight:
//
//        default:
//
//        }

        self.setNeedsStatusBarAppearanceUpdate()
        let mainFrame = UIScreen.mainScreen().applicationFrame
        if self.barHidden == false {
             //非全屏状态横竖屏切换
            self.webView.frame = CGRectMake(0, mainFrame.origin.y, mainFrame.size.width, mainFrame.size.height - toolbar.frame.height)
        }else {
            //全屏状态横竖屏切换
            self.webView.frame = CGRectMake(0, mainFrame.origin.y, mainFrame.size.width, mainFrame.size.height)
        }
        self.progress.frame = CGRectMake(0, mainFrame.origin.y, mainFrame.size.width, progress.bounds.height)
    }
    
    private func LoadHomePage()
    {
        var home_page = userDataManager.userData.objectForKey("MainUrl") as?String
        
        let ThirdToken = userDataManager.userData.objectForKey("Thirdtoken") as?String
        let ModuleTransitId = userDataManager.userData.objectForKey("ModuleTransitId") as?String
        
        home_page = home_page! + "?TransitID=" + ModuleTransitId! + "&token=" + ThirdToken!

        let urlStr = NSURL(string: home_page!)

        let urlStrRequest = NSURLRequest(URL:urlStr!)

        self.webView.loadRequest(urlStrRequest)

    }
   
//    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<()>) {
//        if (keyPath == "loading") {
//            barBack.enabled = webView.canGoBack
//        }
//        if (keyPath == "estimatedProgress") {
//            progress.hidden = webView.estimatedProgress == 1
//            progress.setProgress(Float(webView.estimatedProgress), animated: true)
//        }
//    }
    
//    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
//        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
//        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
//        presentViewController(alert, animated: true, completion: nil)
//    }
//    
//    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
//        self.view.backgroundColor = UIColor(red: CGFloat(0), green: CGFloat(0.6), blue: CGFloat(0.79), alpha: CGFloat(1))
//        progress.setProgress(0.0, animated: false)
//    }
    
    @IBAction func btnBack(sender: AnyObject) {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    //点击全屏按钮，直接全屏
    @IBAction func btnFull(sender: AnyObject) {
        
        //隐藏工具条， 显示悬浮按钮
        self.barHidden = true
        self.toolbar.hidden = true
        self.bubble.hidden = false

        //设置WebView全屏
        self.setNeedsStatusBarAppearanceUpdate()
        let mainFrame = UIScreen.mainScreen().applicationFrame
        self.webView.frame = CGRect(x: 0, y: mainFrame.origin.y, width: mainFrame.size.width, height: mainFrame.size.height)
        self.progress.frame = CGRect(x: 0, y: mainFrame.origin.y, width: mainFrame.width, height: progress.bounds.height)
    }
    
    //bubble 委托方法， 实现系统状态栏隐藏
    func setHiddenBar() {
        
        self.barHidden = false
        self.toolbar.hidden = false
        self.bubble.hidden = true
        //设置WebView取消全屏
        self.setNeedsStatusBarAppearanceUpdate()
        let mainFrame = UIScreen.mainScreen().applicationFrame
        self.webView.frame = CGRect(x: 0, y: mainFrame.origin.y, width: mainFrame.size.width, height: mainFrame.size.height - toolbar.frame.height)
        self.progress.frame = CGRect(x: 0, y: mainFrame.origin.y, width: mainFrame.size.width, height: progress.bounds.height)
    }
    
    @IBAction func btnListSet(sender: AnyObject) {
        //再添加弹出主窗体
        self.myPopView.ShowMyPopView(self)
    }
    
    @IBAction func btnQuitApp(sender: AnyObject) {
        let alertView = UIAlertView(title: "警告", message: "您确定要退出程序", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
        alertView.show()
    }
    
    @IBAction func btnHome(sender: AnyObject) {
        LoadHomePage()
    }
    
//设置状态栏风格
//    override func preferredStatusBarStyle() -> UIStatusBarStyle {
//        return UIStatusBarStyle.LightContent;
//    }
    
    /*
    隐藏状态栏
    */
    override func prefersStatusBarHidden() -> Bool {
        return self.barHidden
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        if buttonIndex == 1{
            exit(0)
        }
    }
    
    //DFUpdateChecker  Delegate
    func checkFinishedWithNewVersion(theNewVersion: String!, newThing theNewThing: String!)
    {
        if theNewVersion=="Newest"
        {
            let alert = UIAlertView()
            alert.title = "软件更新"
            alert.message = "您的应用是最新版本！"
            alert.addButtonWithTitle("确定")
            alert.delegate = self
            alert.show()
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
    
    func CheckUpdate()
    {
        var checker : DFUpdateChecker!
        checker = DFUpdateChecker()
        checker.delegate = self
        checker.checkNew("https://ydptxz.jhpa.com.cn/CheckUpdate.asp?type=%@")
    }
    
    func removeCache()
    {
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        
        let alert = UIAlertView()
        alert.title = "清空缓存"
        alert.message = "软件缓存已被清理！"
        alert.addButtonWithTitle("确定")
        alert.delegate = self
        alert.show()
    }
    
    func FileManager()
    {
        var StoragePath = FCFileManager.pathForDocumentsDirectory()
        StoragePath = StoragePath + "/存储区域"
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "host", bundle: nil)
        let FileManagerView = mainStoryboard.instantiateViewControllerWithIdentifier("FileManager") as! FBFilesTableViewController
        FileManagerView.initPath(StoragePath, selectFunction: "FileManager")
        let nav = UINavigationController(rootViewController: FileManagerView)

        self.presentViewController(nav,animated:true,completion:nil)
    }
    
    func ServerSet()
    {
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
            userDataManager.userData.setValue(Server_Adress.text, forKey:"MainUrl")
            userDataManager.userData.setValue(Auth_Adress.text, forKey:"LoginUrl")
            userDataManager.SaveUserDataFile()
        }
        alert.showCustom("服务器设置", subTitle:"请设置服务器地址和验证地址", closeButtonTitle:"取消")
    }
    
    func buttonClickEvent(buttonTitle: String) {
//        var var1:Int
        switch buttonTitle{
        case ButtonTitle.Back:
            self.webView.goBack()
        case ButtonTitle.Forward:
            self.webView.goForward()
        case ButtonTitle.Refresh:
            self.webView.reload()
        case ButtonTitle.ClearCache:
            self.removeCache()
        case ButtonTitle.CheckUpdate:
            self.CheckUpdate()
        case ButtonTitle.ServerSet:
            self.ServerSet()
        case ButtonTitle.FileManager:
            self.FileManager()

        default: break
//            var1 = 1
        }
    }
    
    // MARK: Bubble
    func setupBubble () {
        let win = APPDELEGATE.window!
        
        bubble = BubbleControl (size: CGSizeMake(60, 60))
        bubble.image = UIImage (named: "hanwei.png")
        
        bubble.didNavigationBarButtonPressed = {
            print("pressed in nav bar", terminator: "")
            self.bubble!.popFromNavBar()
        }
        
        bubble.setOpenAnimation = { content, background in
            self.bubble.contentView!.bottom = win.bottom
            if (self.bubble.center.x > win.center.x) {
                self.bubble.contentView!.left = win.right
                self.bubble.contentView!.spring({ () -> Void in
                    self.bubble.contentView!.right = win.right
                    }, completion: nil)
            } else {
                self.bubble.contentView!.right = win.left
                self.bubble.contentView!.spring({ () -> Void in
                    self.bubble.contentView!.left = win.left
                    }, completion: nil)
            }
        }
        
//        let min: CGFloat = 50
//        let max: CGFloat = win.h - 250
//        let randH = min + CGFloat(random()%Int(max-min))
//        
//        let v = UIView (frame: CGRect (x: 0, y: 0, width: win.w, height: max))
//        v.backgroundColor = UIColor.grayColor()
//        
//        let label = UILabel (frame: CGRect (x: 10, y: 10, width: v.w, height: 20))
//        label.text = "test text"
//        v.addSubview(label)
        
        bubble.contentView = toolbar
        
        win.addSubview(bubble)
    }
    
    // MARK: Animation
    var animateIcon: Bool = false {
        didSet {
            if animateIcon {
                bubble.didToggle = { on in
                    if let _ = self.bubble.imageView?.layer.sublayers?[0] as? CAShapeLayer {
                        self.animateBubbleIcon(on)
                    }
                    else {
                        self.bubble.imageView?.image = nil
                        
                        let shapeLayer = CAShapeLayer ()
                        shapeLayer.lineWidth = 0.25
                        shapeLayer.strokeColor = UIColor.blackColor().CGColor
                        shapeLayer.fillMode = kCAFillModeForwards
                        
                        self.bubble.imageView?.layer.addSublayer(shapeLayer)
                        self.animateBubbleIcon(on)
                    }
                }
            } else {
                bubble.didToggle = nil
                bubble.imageView?.layer.sublayers = nil
                bubble.imageView?.image = bubble.image!
            }
        }
    }
    
    func animateBubbleIcon (on: Bool) {
        let shapeLayer = self.bubble.imageView!.layer.sublayers![0] as! CAShapeLayer
        let from = on ? self.basketBezier().CGPath: self.arrowBezier().CGPath
        let to = on ? self.arrowBezier().CGPath: self.basketBezier().CGPath
        
        let anim = CABasicAnimation (keyPath: "path")
        anim.fromValue = from
        anim.toValue = to
        anim.duration = 0.5
        anim.fillMode = kCAFillModeForwards
        anim.removedOnCompletion = false
        
        shapeLayer.addAnimation (anim, forKey:"bezier")
    }
    
    func arrowBezier () -> UIBezierPath {
        
        let color0 = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
        
        let bezier2Path = UIBezierPath()
        bezier2Path.moveToPoint(CGPointMake(21.22, 2.89))
        bezier2Path.addCurveToPoint(CGPointMake(19.87, 6.72), controlPoint1: CGPointMake(21.22, 6.12), controlPoint2: CGPointMake(20.99, 6.72))
        bezier2Path.addCurveToPoint(CGPointMake(14.54, 7.92), controlPoint1: CGPointMake(19.12, 6.72), controlPoint2: CGPointMake(16.72, 7.24))
        bezier2Path.addCurveToPoint(CGPointMake(0.44, 25.84), controlPoint1: CGPointMake(7.27, 10.09), controlPoint2: CGPointMake(1.64, 17.14))
        bezier2Path.addCurveToPoint(CGPointMake(2.39, 26.97), controlPoint1: CGPointMake(-0.08, 29.74), controlPoint2: CGPointMake(1.12, 30.49))
        bezier2Path.addCurveToPoint(CGPointMake(17.62, 16.09), controlPoint1: CGPointMake(4.34, 21.19), controlPoint2: CGPointMake(10.12, 17.14))
        bezier2Path.addLineToPoint(CGPointMake(21.14, 15.64))
        bezier2Path.addLineToPoint(CGPointMake(21.37, 19.47))
        bezier2Path.addLineToPoint(CGPointMake(21.59, 23.29))
        bezier2Path.addLineToPoint(CGPointMake(29.09, 17.52))
        bezier2Path.addCurveToPoint(CGPointMake(36.59, 11.22), controlPoint1: CGPointMake(33.22, 14.37), controlPoint2: CGPointMake(36.59, 11.52))
        bezier2Path.addCurveToPoint(CGPointMake(22.12, -0.33), controlPoint1: CGPointMake(36.59, 10.69), controlPoint2: CGPointMake(24.89, 1.39))
        bezier2Path.addCurveToPoint(CGPointMake(21.22, 2.89), controlPoint1: CGPointMake(21.44, -0.71), controlPoint2: CGPointMake(21.22, 0.19))
        bezier2Path.closePath()
        bezier2Path.moveToPoint(CGPointMake(31.87, 8.82))
        bezier2Path.addCurveToPoint(CGPointMake(34.64, 11.22), controlPoint1: CGPointMake(33.44, 9.94), controlPoint2: CGPointMake(34.72, 10.99))
        bezier2Path.addCurveToPoint(CGPointMake(28.87, 15.87), controlPoint1: CGPointMake(34.64, 11.44), controlPoint2: CGPointMake(32.09, 13.54))
        bezier2Path.addLineToPoint(CGPointMake(23.09, 20.14))
        bezier2Path.addLineToPoint(CGPointMake(22.87, 17.07))
        bezier2Path.addLineToPoint(CGPointMake(22.64, 13.99))
        bezier2Path.addLineToPoint(CGPointMake(18.97, 14.44))
        bezier2Path.addCurveToPoint(CGPointMake(6.22, 19.24), controlPoint1: CGPointMake(13.04, 15.12), controlPoint2: CGPointMake(9.44, 16.54))
        bezier2Path.addCurveToPoint(CGPointMake(5.09, 16.84), controlPoint1: CGPointMake(2.77, 22.24), controlPoint2: CGPointMake(2.39, 21.49))
        bezier2Path.addCurveToPoint(CGPointMake(20.69, 8.22), controlPoint1: CGPointMake(8.09, 11.82), controlPoint2: CGPointMake(14.54, 8.22))
        bezier2Path.addCurveToPoint(CGPointMake(22.72, 5.14), controlPoint1: CGPointMake(22.57, 8.22), controlPoint2: CGPointMake(22.72, 7.99))
        bezier2Path.addLineToPoint(CGPointMake(22.72, 2.07))
        bezier2Path.addLineToPoint(CGPointMake(25.94, 4.47))
        bezier2Path.addCurveToPoint(CGPointMake(31.87, 8.82), controlPoint1: CGPointMake(27.67, 5.74), controlPoint2: CGPointMake(30.37, 7.77))
        bezier2Path.closePath()
        bezier2Path.miterLimit = 4;
        
        color0.setFill()
        bezier2Path.fill()
        return bezier2Path
    }
    
    func basketBezier () -> UIBezierPath {
        
        let color0 = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
        
        let bezier2Path = UIBezierPath()
        bezier2Path.moveToPoint(CGPointMake(0.86, 0.36))
        bezier2Path.addCurveToPoint(CGPointMake(3.41, 6.21), controlPoint1: CGPointMake(-0.27, 1.41), controlPoint2: CGPointMake(0.48, 2.98))
        bezier2Path.addLineToPoint(CGPointMake(6.41, 9.51))
        bezier2Path.addLineToPoint(CGPointMake(3.18, 9.73))
        bezier2Path.addCurveToPoint(CGPointMake(-0.27, 12.96), controlPoint1: CGPointMake(0.03, 9.96), controlPoint2: CGPointMake(-0.04, 10.03))
        bezier2Path.addCurveToPoint(CGPointMake(0.48, 16.71), controlPoint1: CGPointMake(-0.42, 14.83), controlPoint2: CGPointMake(-0.12, 16.18))
        bezier2Path.addCurveToPoint(CGPointMake(3.26, 23.46), controlPoint1: CGPointMake(1.08, 17.08), controlPoint2: CGPointMake(2.28, 20.16))
        bezier2Path.addCurveToPoint(CGPointMake(18.33, 32.08), controlPoint1: CGPointMake(6.03, 32.91), controlPoint2: CGPointMake(4.61, 32.08))
        bezier2Path.addCurveToPoint(CGPointMake(33.41, 23.46), controlPoint1: CGPointMake(32.06, 32.08), controlPoint2: CGPointMake(30.63, 32.91))
        bezier2Path.addCurveToPoint(CGPointMake(36.18, 16.71), controlPoint1: CGPointMake(34.38, 20.16), controlPoint2: CGPointMake(35.58, 17.08))
        bezier2Path.addCurveToPoint(CGPointMake(36.93, 12.96), controlPoint1: CGPointMake(36.78, 16.18), controlPoint2: CGPointMake(37.08, 14.83))
        bezier2Path.addCurveToPoint(CGPointMake(33.48, 9.73), controlPoint1: CGPointMake(36.71, 10.03), controlPoint2: CGPointMake(36.63, 9.96))
        bezier2Path.addLineToPoint(CGPointMake(30.26, 9.51))
        bezier2Path.addLineToPoint(CGPointMake(33.33, 6.13))
        bezier2Path.addCurveToPoint(CGPointMake(36.18, 1.48), controlPoint1: CGPointMake(35.06, 4.26), controlPoint2: CGPointMake(36.33, 2.16))
        bezier2Path.addCurveToPoint(CGPointMake(28.23, 4.63), controlPoint1: CGPointMake(35.66, -1.22), controlPoint2: CGPointMake(33.26, -0.24))
        bezier2Path.addLineToPoint(CGPointMake(23.06, 9.58))
        bezier2Path.addLineToPoint(CGPointMake(18.33, 9.58))
        bezier2Path.addLineToPoint(CGPointMake(13.61, 9.58))
        bezier2Path.addLineToPoint(CGPointMake(8.51, 4.71))
        bezier2Path.addCurveToPoint(CGPointMake(0.86, 0.36), controlPoint1: CGPointMake(3.78, 0.13), controlPoint2: CGPointMake(2.06, -0.84))
        bezier2Path.closePath()
        bezier2Path.moveToPoint(CGPointMake(10.08, 12.66))
        bezier2Path.addCurveToPoint(CGPointMake(14.58, 12.21), controlPoint1: CGPointMake(12.33, 14.38), controlPoint2: CGPointMake(14.58, 14.16))
        bezier2Path.addCurveToPoint(CGPointMake(18.33, 11.08), controlPoint1: CGPointMake(14.58, 11.38), controlPoint2: CGPointMake(15.48, 11.08))
        bezier2Path.addCurveToPoint(CGPointMake(22.08, 12.21), controlPoint1: CGPointMake(21.18, 11.08), controlPoint2: CGPointMake(22.08, 11.38))
        bezier2Path.addCurveToPoint(CGPointMake(26.58, 12.66), controlPoint1: CGPointMake(22.08, 14.16), controlPoint2: CGPointMake(24.33, 14.38))
        bezier2Path.addCurveToPoint(CGPointMake(32.21, 11.08), controlPoint1: CGPointMake(28.08, 11.61), controlPoint2: CGPointMake(29.88, 11.08))
        bezier2Path.addCurveToPoint(CGPointMake(35.58, 13.33), controlPoint1: CGPointMake(35.43, 11.08), controlPoint2: CGPointMake(35.58, 11.16))
        bezier2Path.addLineToPoint(CGPointMake(35.58, 15.58))
        bezier2Path.addLineToPoint(CGPointMake(18.33, 15.58))
        bezier2Path.addLineToPoint(CGPointMake(1.08, 15.58))
        bezier2Path.addLineToPoint(CGPointMake(1.08, 13.33))
        bezier2Path.addCurveToPoint(CGPointMake(4.46, 11.08), controlPoint1: CGPointMake(1.08, 11.16), controlPoint2: CGPointMake(1.23, 11.08))
        bezier2Path.addCurveToPoint(CGPointMake(10.08, 12.66), controlPoint1: CGPointMake(6.78, 11.08), controlPoint2: CGPointMake(8.58, 11.61))
        bezier2Path.closePath()
        bezier2Path.moveToPoint(CGPointMake(11.21, 22.86))
        bezier2Path.addCurveToPoint(CGPointMake(12.71, 28.71), controlPoint1: CGPointMake(11.21, 28.18), controlPoint2: CGPointMake(11.36, 28.71))
        bezier2Path.addCurveToPoint(CGPointMake(14.43, 22.86), controlPoint1: CGPointMake(14.06, 28.71), controlPoint2: CGPointMake(14.21, 28.11))
        bezier2Path.addCurveToPoint(CGPointMake(15.56, 17.08), controlPoint1: CGPointMake(14.58, 18.96), controlPoint2: CGPointMake(14.96, 17.08))
        bezier2Path.addCurveToPoint(CGPointMake(16.23, 21.21), controlPoint1: CGPointMake(16.16, 17.08), controlPoint2: CGPointMake(16.38, 18.36))
        bezier2Path.addCurveToPoint(CGPointMake(18.56, 28.93), controlPoint1: CGPointMake(15.86, 27.13), controlPoint2: CGPointMake(16.46, 29.23))
        bezier2Path.addCurveToPoint(CGPointMake(20.21, 22.86), controlPoint1: CGPointMake(20.13, 28.71), controlPoint2: CGPointMake(20.21, 28.33))
        bezier2Path.addCurveToPoint(CGPointMake(21.11, 17.08), controlPoint1: CGPointMake(20.21, 18.88), controlPoint2: CGPointMake(20.51, 17.08))
        bezier2Path.addCurveToPoint(CGPointMake(22.23, 22.86), controlPoint1: CGPointMake(21.71, 17.08), controlPoint2: CGPointMake(22.08, 18.96))
        bezier2Path.addCurveToPoint(CGPointMake(23.96, 28.71), controlPoint1: CGPointMake(22.46, 28.11), controlPoint2: CGPointMake(22.61, 28.71))
        bezier2Path.addCurveToPoint(CGPointMake(25.46, 22.86), controlPoint1: CGPointMake(25.31, 28.71), controlPoint2: CGPointMake(25.46, 28.18))
        bezier2Path.addLineToPoint(CGPointMake(25.46, 17.08))
        bezier2Path.addLineToPoint(CGPointMake(29.43, 17.08))
        bezier2Path.addCurveToPoint(CGPointMake(31.53, 24.58), controlPoint1: CGPointMake(33.93, 17.08), controlPoint2: CGPointMake(33.86, 16.78))
        bezier2Path.addLineToPoint(CGPointMake(29.88, 30.21))
        bezier2Path.addLineToPoint(CGPointMake(18.33, 30.21))
        bezier2Path.addLineToPoint(CGPointMake(6.78, 30.21))
        bezier2Path.addLineToPoint(CGPointMake(5.13, 24.58))
        bezier2Path.addCurveToPoint(CGPointMake(7.31, 17.08), controlPoint1: CGPointMake(2.81, 16.78), controlPoint2: CGPointMake(2.73, 17.08))
        bezier2Path.addLineToPoint(CGPointMake(11.21, 17.08))
        bezier2Path.addLineToPoint(CGPointMake(11.21, 22.86))
        bezier2Path.closePath()
        bezier2Path.miterLimit = 4;
        
        color0.setFill()
        bezier2Path.fill()
        return bezier2Path
    }
    
    func showInstallController(sender: NSNotification?){
        
        let userInfo:Dictionary<String,String> = sender!.userInfo as! Dictionary<String,String>
        
        let msgTitle:String = "软件安装"
        let msgMessage:String = userInfo["Message"]!
        let InstallURL:String = userInfo["InstallURL"]!
        
        let btnNo:String = "取消"
        let btnYes: String = "安装"
        
        let btnLeft = btnNo
        let btnRight = btnYes

        //比较当前系统版本小于区别使用SDK接口
        if(iosVerion < 8.0) {
            UIApplication.sharedApplication().openURL(NSURL(string : InstallURL)!)
        } else {
        
            let alertController = UIAlertController(title: msgTitle, message: msgMessage, preferredStyle: .Alert)
            let actionLeft = UIAlertAction(title:btnLeft, style: .Cancel) { action in
                
            }
            let actionRight = UIAlertAction(title:btnRight, style: .Default) { action in
                UIApplication.sharedApplication().openURL(NSURL(string : InstallURL)!)
                
                //exit(0)
            }
            
            alertController.addAction(actionLeft)
            alertController.addAction(actionRight)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func showUpdateController(sender: NSNotification?){
        
        let userInfo:Dictionary<String,String> = sender!.userInfo as! Dictionary<String,String>
        
        let msgTitle:String = "软件安装"
        let msgMessage:String = userInfo["Message"]!
        let InstallURL:String = userInfo["InstallURL"]!
        let deviceid:String = userInfo["deviceid"]!
        let appid:String = userInfo["appid"]!
        let loginid:String = userInfo["loginid"]!
        let version:String = userInfo["version"]!
        
        let btnNo:String = "取消"
        let btnYes: String = "安装"
        
        let btnLeft = btnNo
        let btnRight = btnYes
        
        //比较当前系统版本小于区别使用SDK接口
        if(iosVerion < 8.0) {
            UIApplication.sharedApplication().openURL(NSURL(string : InstallURL)!)
            self.insertUpdateInfo(deviceid, appid: appid, loginid: loginid, version: version)
        } else {
            let alertController = UIAlertController(title: msgTitle, message: msgMessage, preferredStyle: .Alert)
            let actionLeft = UIAlertAction(title:btnLeft, style: .Cancel) { action in
                
            }
            let actionRight = UIAlertAction(title:btnRight, style: .Default) { action in
                UIApplication.sharedApplication().openURL(NSURL(string : InstallURL)!)
                
                self.insertUpdateInfo(deviceid, appid: appid, loginid: loginid, version: version)
                //exit(0)
            }
            
            alertController.addAction(actionLeft)
            alertController.addAction(actionRight)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    //监听调试信息 并显示
    func showDebug(sender: NSNotification?)
    {
        let userInfo:Dictionary<String,String> = sender!.userInfo as! Dictionary<String,String>
        let MoudleName = userInfo["TouchMode"]!
        
        
        if MoudleName != ""
        {
            ShowDebug2.text = MoudleName
        }
        
    }
    
    // MARK: 本地组件调用
    func showNativeMoudleController(sender: NSNotification?)
    {
        let userInfo:Dictionary<String,String> = sender!.userInfo as! Dictionary<String,String>
        let MoudleName = userInfo["MoudleName"]!
        
        if MoudleName == "JHMail"
        {
            //邮箱应用
            let board = UIStoryboard(name:"MailModule", bundle: nil)
            let next = board.instantiateViewControllerWithIdentifier("HostView")
            self.presentViewController(next, animated: true, completion: nil)
        }
    }

    // MARK: 第三方应用更新
    func insertUpdateInfo(deviceid:String, appid:String, loginid:String, version:String)
    {
        let soapMessage = "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/' ><soap:Header></soap:Header><soap:Body><UpdateAppVersion xmlns='http://tempuri.org/'><deviceId>" + deviceid + "</deviceId><appId>" + appid + "</appId><loginId>" + loginid + "</loginId><version>" + version + "</version></UpdateAppVersion></soap:Body></soap:Envelope>"
        
//        let insertUpdateInfoURL = "http://10.84.0.231:9009/webptframe/HWPTWeb.asmx"
//        let insertUpdateInfoSoapAction = "http://tempuri.org/UpdateAppVersion"
        let insertUpdateInfoURL = (userDataManager.userData.objectForKey("insertUpdateInfo")as?String!)
        let insertUpdateInfoSoapAction = (userDataManager.userData.objectForKey("insertUpdateInfo_soapAction")as?String!)
        let soap = ContentManager()
        soap.login(insertUpdateInfoSoapAction!, SoapURL:insertUpdateInfoURL!, SoapMessage:soapMessage) {
            (result) -> Void in
            var error: NSError?
            let rtnStr:String = NSString(data: result, encoding:NSUTF8StringEncoding) as! String
            if rtnStr != "ErrorReturn"
            {
                if let rtnstr = AEXMLDocument(xmlData: result, error: &error) {
                    // prints the same XML structure as original
                    print(rtnstr.xmlString)
                } else {
                    print("description: \(error?.localizedDescription)\ninfo: \(error?.userInfo)")
                }
            }
        }
    }
    
    // MARK: 下载进度
    func showDownLoadProgress()
    {
        progressView = MRProgressOverlayView.showOverlayAddedTo(self.view, title:"下载中", mode:.DeterminateHorizontalBar, animated:true)
    }
    
    func ChangeProgress(percentage:Double)
    {
        let ConvertString = NSString(format: "%f" , percentage)
        let ConvertFloat = ConvertString.floatValue
        progressView.setProgress(ConvertFloat ,animated:true)
    }
    
    func RemoveProgress()
    {
        MRProgressOverlayView.dismissOverlayForView(self.view, animated:true)
    }
    
    // MARK: 文档预览
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int
    {
        return 1
    }

    func previewController(controller: QLPreviewController,
        previewItemAtIndex index: Int) -> QLPreviewItem
    {
        return NSURL.fileURLWithPath(self.FilePath)
    }
    
    func CallQuickLookDocument(sender: NSNotification?)
    {
        let userInfo:Dictionary<String,String> = sender!.userInfo as! Dictionary<String,String>
        //let FileName = userInfo["FileName"]!
        let FilePath = userInfo["FilePath"]!
        self.FilePath = FilePath
        //        let mainStoryboard: UIStoryboard = UIStoryboard(name: "host", bundle: nil)
        //        let QuickView = mainStoryboard.instantiateViewControllerWithIdentifier("QuickLookView") as! QuickLookViewController
        //        QuickView.path = FilePath
        //        let nav = UINavigationController(rootViewController: QuickView)
        //        self.presentViewController(nav,animated:true,completion:nil)
        
        let ql = QLPreviewController()
        //ql.navigationController!.navigationBarHidden = true;
        ql.dataSource = self
        
        let backButton = UIBarButtonItem(title: "返回", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("closeQuickLookAction"))
        ql.navigationItem.leftBarButtonItem = backButton;
        
        
        //
        let navigationController = UINavigationController(rootViewController:ql)
        navigationController.navigationBar.barTintColor = UIColor(red: 0.18, green: 0.54, blue: 1, alpha: 1)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        self.presentViewController(navigationController,animated:true, completion: nil)
    }
    
    func closeQuickLookAction()
    {
        self.dismissViewControllerAnimated(true, completion:nil)
    }

}
