//
//  SignController.swift
//  HanWeiPlatform
//
//  Created by hanwei on 15/3/9.
//  Copyright (c) 2015年 hanwei. All rights reserved.
//

import UIKit

class ReInputGestureController : UIViewController,PSetSelectedValue {

    let titleHeight:CGFloat = 60
    let topHeight:CGFloat = 100
    var smallNineView:NineCellLockView!
    var nineCellView:NineCellLockView!
    var count:Int = 0
    var dynamicShow = true
    var firstPWD:String!
    var secondPWD:String!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //application.statusBarStyle = UIStatusBarStyle.LightContent;
        super.view.backgroundColor = UIColor(red: 35/255.0, green: 39/255.0, blue: 54/255.0, alpha: 1)
        //super.view.backgroundColor = UIColor.greenColor()
        
        let rect1 = CGRect(x: 0, y: titleHeight, width: self.view.frame.width, height: topHeight)
        smallNineView = NineCellLockView(frame: rect1)
        smallNineView.RefreshView(10,centerDistance:30)
        super.view.addSubview(smallNineView)
        
        let rect2 = CGRect(x: 0,y: topHeight+titleHeight,width: self.view.frame.width,height: self.view.frame.height-topHeight-titleHeight)
        nineCellView = NineCellLockView(frame: rect2)
        nineCellView.parentViewController = self
        super.view.addSubview(nineCellView)
        
        //var btnReturn = UIButton(frame: CGRect(x: <#Int#>, y: <#Int#>, width: <#Int#>, height: <#Int#>))
    }

    //通知小九格 添加元素
    func addElement(point:Int){
        if dynamicShow{
        smallNineView.selectPointIndexCollection.append(point)
        smallNineView.setNeedsDisplay()
        }
    }
    
    //绘制完成
    func overGestrue(){
        if dynamicShow == true{
            dynamicShow = false
            firstPWD = nineCellView.PrintPWD()
            lblTitle.text = "请再次输入密码！"
            nineCellView.selectPointIndexCollection.removeAll(keepCapacity: false)
        }
        else{
            secondPWD = nineCellView .PrintPWD()
            if firstPWD == secondPWD{
                
                //保存
                let usrName1 = userDataManager.userData.objectForKey(userNameKey) as? String
                userDataManager.userData.setObject(firstPWD, forKey: usrName1!)
                userDataManager.SaveUserDataFile()
                
                //跳转
                let anotherView1:UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("browser") 
                self.presentViewController(anotherView1, animated: true, completion: nil)
            }
            else{
                lblTitle.text = "密码输入错误，请重新输入！"
                nineCellView.selectPointIndexCollection.removeAll(keepCapacity: false)
            }
        }
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)

        //UINavigationBar.appearance().barStyle = UIBarStyle.Black
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnReturn(sender: AnyObject) {
        let anotherView1:UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("SecondView")
        self.presentViewController(anotherView1, animated: true, completion: nil)
    }
    
    /*
    /**
    隐藏状态栏
    */
    override func prefersStatusBarHidden() -> Bool {
        //return true;
        return false
    }
    */
    
    /**
    设置状态栏风格
    */
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    
}