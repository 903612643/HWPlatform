//
//  MyPopViews.swift
//  HanWeiPlatform
//
//  Created by hanwei on 15/3/24.
//  Copyright (c) 2015年 hanwei. All rights reserved.
//

import Foundation
import UIKit

class MyPopView: UIView {

    //标题高度
    let titleHeight:CGFloat = 40.0
    //滑块高度
    let sliderHeight:CGFloat = 5.0
    //内部垂直间隔
    let inVertSpacing:CGFloat  = 5.0
    //内部水平间隔
    let inHoriSpacing:CGFloat = 5.0
    //外部水平间隔
    let outHoriSpacing:CGFloat = 10.0
    //共分成几块
    let blockCount:CGFloat = 4
    //每块宽度
    var blockWidth:CGFloat
    
    //ico图像边长
    let icoImageLength:CGFloat = 32
    //ico字高
    let icoFontHeight:CGFloat = 16
    //ico间距
    let icoPadding :CGFloat = 4
 
    
    //每块分成几段
    //let sectionPerBlock:CGFloat = 4
    //每段宽度
    //var sectionWidth :CGFloat

    //阴影视图层
    let shadowView:UIView
    //父视图控制器
    var parentViewController:UIViewController
    //弹出层
    var myPopLayer:CALayer
    //点数组
    var pointsAry:[CGPoint]
    
    //滑块
    var slider:Slider!
    var btnCommon:UIButton!
    var btnTool:UIButton!
    
    private  var timer:NSTimer!
    
    private var toolType = ""
    
    var scrollView1:MyPageView!
    var scrollView2:MyPageView!
    //默认状态为常用
    private var currentState = "常用"
    
     init(){
        //初始化元素
        self.shadowView = UIView()
        self.parentViewController = UIViewController()

        self.myPopLayer = CALayer()
        
        //内部每块宽度
        self.blockWidth = 10
        self.pointsAry = []
        
        //初始化类
        super.init(frame:UIScreen.mainScreen().bounds)
    }    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func ShowMyPopView(parentViewController:BrowserViewController){
        
        if self.parentViewController == parentViewController{
            if self.hidden{
                self.hidden = false
                self.shadowView.hidden = false
            }
            else{
                self.hidden = true
                self.shadowView.hidden = true
            }
        }
        else
        {
            //视图赋值
            self.parentViewController = parentViewController

            initShadowView()
            initContentView()
            addSubContentView()
            initContentControls()
            
            /// 监听设置方向变化
            NSNotificationCenter.defaultCenter().addObserver(self,
                selector: "rotate_Custom:",
                name: UIDeviceOrientationDidChangeNotification,
                object: nil)

        }
    }
    
    /// 设置方向变化通知处理
    func rotate_Custom(sender: NSNotification?) {
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
        
        
        self.frame = UIScreen.mainScreen().bounds
        self.shadowView.frame =  UIScreen.mainScreen().bounds

        //移除Layer
        myPopLayer.removeFromSuperlayer()
        //重新绘制
        initContentView()
        //移除上次绘制的内容
        removeSubContentControls()
        //重新绘制页面内容
        initContentControls()
        
        if currentState == "工具" {
            self.slider.setSliderRight()
            self.scrollView1.frame.origin.x = CGFloat(-1) * self.scrollView1.frame.size.width
            self.scrollView2.frame.origin.x = self.inHoriSpacing
        }

    }
    
    func handleTapGesture(sender: UITapGestureRecognizer){
        self.hidden = true
        self.shadowView.hidden = true
    }
    
    //初始化遮罩层
   private func initShadowView(){
        //调整阴影层
        self.shadowView.frame =  UIScreen.mainScreen().bounds
        self.shadowView.backgroundColor = UIColor.blackColor()
        self.shadowView.alpha = 0.1
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTapGesture:")
        //设置手势点击数,双击：点1下
        tapGesture.numberOfTapsRequired = 1
        self.shadowView.addGestureRecognizer(tapGesture)
    
        //添加视图
        self.parentViewController.view.addSubview(self.shadowView)
    
    }
    
    private  func initContentView(){
    
        let myParentViewController = self.parentViewController as! BrowserViewController
        //外部总块数
        //var outBlockCount = myParentViewController.toolbar.items?.count
        //println("外部总块数:\(myParentViewController.toolbar.items?.count)")
        //外部每块宽度
        let outBlockWidth:CGFloat = CGFloat(myParentViewController.view.bounds.width)/5
        //每段宽度
        let sectionWidth = outBlockWidth / 4

        //frame的尺寸
        let rectHeight:CGFloat = self.titleHeight + self.sliderHeight + (self.icoPadding+self.icoImageLength+self.icoPadding+self.icoFontHeight+self.icoPadding)+self.inVertSpacing
        print("矩形尺寸：\(rectHeight)")
    
        let frameHeight:CGFloat = rectHeight + sectionWidth
        let frameWidth: CGFloat = myParentViewController.view.bounds.width - self.outHoriSpacing*2
        let frameY:CGFloat = myParentViewController.toolbar.frame.origin.y - frameHeight
    
        pointsAry = [CGPoint]()
        pointsAry.append(CGPoint(x: 0, y: 0))
        pointsAry.append(CGPoint(x: 0, y: rectHeight))
        pointsAry.append(CGPoint(x: outBlockWidth*3+sectionWidth-self.outHoriSpacing, y: rectHeight))
        pointsAry.append(CGPoint(x: outBlockWidth*3+sectionWidth*2-self.outHoriSpacing, y: rectHeight+sectionWidth))
        pointsAry.append(CGPoint(x: outBlockWidth*4-sectionWidth-self.outHoriSpacing, y: rectHeight))
        pointsAry.append(CGPoint(x: frameWidth, y: rectHeight))
        pointsAry.append(CGPoint(x: frameWidth, y: 0))
        
        for pt in pointsAry{
            print("每个点是:\(pt)")
        }
        
        //内容界面
        self.frame = CGRectMake(self.outHoriSpacing , frameY, frameWidth, frameHeight)
        //内部每块宽度
        self.blockWidth = myParentViewController.view.bounds.width / self.blockCount
        
        //初始化层
        myPopLayer = MyPopLayer(pointsAry: pointsAry)
        myPopLayer.frame = CGRectMake(0 , 0, frameWidth, frameHeight)
        //myPopLayer.frame = CGRectMake(0, 0, frameWidth, frameHeight)
        print("矩形frame是:\(myPopLayer.frame)")
        myPopLayer.setNeedsDisplay()
    
        //添加层
        self.layer.addSublayer(myPopLayer)

    }
    
    private func addSubContentView()
    {
        //添加视图
        self.parentViewController.view.addSubview(self)
    }
    
    private func initContentControls(){
        
        //var btnWidth:CGFloat = 40
        //var btnHeight:CGFloat = 20
        
        btnCommon = UIButton()
        btnCommon.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btnCommon.setTitle("常用", forState: UIControlState.Normal)
        //btnCommon.frame = CGRect(x: (self.bounds.width/2)/2, y: (self.titleHeight-btnHeight)/2, width: btnWidth, height: btnHeight)
        btnCommon.frame = CGRect(x: 0, y: 0, width: self.bounds.width/2, height: titleHeight)
        btnCommon.addTarget(self, action: "btnClick:", forControlEvents: UIControlEvents.TouchDown)
        self.addSubview(btnCommon)
        
        
        btnTool = UIButton()
        btnTool.setTitle("工具", forState: UIControlState.Normal)
        btnTool.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        //btnTool.frame = CGRect(x: self.bounds.width/2+btnCommon.frame.origin.x, y: (self.titleHeight-btnHeight)/2, width: btnWidth, height: btnHeight)
        btnTool.frame = CGRect(x: self.bounds.width/2, y: 0, width: self.bounds.width/2, height: titleHeight)
        btnTool.addTarget(self, action: "btnClick:", forControlEvents: UIControlEvents.TouchDown)
        self.addSubview(btnTool)
        
        
        let rectSlider = CGRect(x: inHoriSpacing, y: titleHeight, width: self.bounds.width - inHoriSpacing*2, height: 5)
        self.slider = Slider(frame:rectSlider)
        self.addSubview(slider)
        
        let scrollHeight = self.icoPadding+self.icoImageLength+self.icoPadding+self.icoFontHeight+self.icoPadding
        print("滚动视图宽度:\(scrollHeight)")
        
        scrollView1 = MyPageView(frame:CGRect(x: inHoriSpacing, y: self.slider.frame.origin.y+self.slider.frame.height, width: self.slider.frame.width, height: scrollHeight))
        self.addSubview(scrollView1)
        scrollView1.layer.masksToBounds = true
        //scrollView1.backgroundColor = UIColor.greenColor()
        
        scrollView2 = MyPageView(frame:CGRect(x: self.bounds.width, y: self.slider.frame.origin.y+self.slider.frame.height, width: self.slider.frame.width, height: scrollHeight))
        self.addSubview(scrollView2)
        scrollView2.layer.masksToBounds = true
        //scrollView2.backgroundColor = UIColor.redColor()
        
        //控制一下可见边界
        self.layer.masksToBounds = true
        
        let nsArrTitle1:NSArray = [ButtonTitle.Back,ButtonTitle.Forward,ButtonTitle.Refresh,ButtonTitle.ClearCache]
        let nsArrImage1:NSArray = ["back288.png","forward288.png","refresh288.png","clearCache288.png"]
        scrollView1.InitView(nsArrTitle1, nsArrImage: nsArrImage1, buttonClickDelegate: self.parentViewController as! ButtonClickDelegate)
        
        let nsArrTitle2:NSArray = [ButtonTitle.ShortCut,ButtonTitle.CheckUpdate,ButtonTitle.ServerSet,ButtonTitle.FileManager]
        let nsArrImage2:NSArray = ["shortcut288.png","checkUpdate288.png","serverSet288.png", "FileManager288"]
        scrollView2.InitView(nsArrTitle2, nsArrImage: nsArrImage2, buttonClickDelegate: self.parentViewController as! ButtonClickDelegate)


    }
    
    //适用于旋转屏幕
    private func removeSubContentControls()
    {
        btnCommon.removeFromSuperview()
        btnTool.removeFromSuperview()
        slider.removeFromSuperview()
        scrollView1.removeFromSuperview()
        scrollView2.removeFromSuperview()
    }

    //按钮单击事件
    func btnClick(sender:UIButton){
        toolType = sender.currentTitle!
        if sender.currentTitle == "常用" && self.slider.sliderState == SliderState.left{
            return
        }
        else if sender.currentTitle == "工具" && self.slider.sliderState == SliderState.right{
            return
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "timerMethods", userInfo: nil, repeats: true)
        
    }
    
    //时钟方法
    func timerMethods(){
        UIView.animateWithDuration(0.2, animations: {
            if self.slider.sliderState==SliderState.left {
                self.slider.setSliderRight()
                self.scrollView1.frame.origin.x = CGFloat(-1) * self.scrollView1.frame.size.width
                self.scrollView2.frame.origin.x = self.inHoriSpacing
                self.currentState="工具"
            }
            else{
                self.slider.setSliderLeft()
                self.scrollView1.frame.origin.x = self.inHoriSpacing
                self.scrollView2.frame.origin.x = self.bounds.width
                self.currentState="常用"
            }
        })
        timer.invalidate()
    }
    
}