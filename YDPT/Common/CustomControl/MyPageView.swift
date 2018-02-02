//
//  pageView.swift
//  HanWeiPlatform
//
//  Created by hanwei on 15/3/26.
//  Copyright (c) 2015年 hanwei. All rights reserved.
//

import UIKit

class MyPageView: UIView {

    //var dictTitle:NSMutableDictionary!
    //var dictImage:NSMutableDictionary!
    //var nsArrTitle:NSArray!
    //var nsArrImage:NSArray!
    
    let maxButtons = 4

    private var buttonClickDelegate:ButtonClickDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //dictTitle = NSMutableDictionary()
        //dictImage = NSMutableDictionary()
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    func AddOneElement(imageName:String,title:String){
        dictTitle.setValue(title, forKey: String(dictTitle.count+1))
        dictImage.setValue(imageName, forKey: String(dictImage.count+1))
    }
    */
    
    func InitView(nsArrTitle:NSArray!,nsArrImage:NSArray,buttonClickDelegate:ButtonClickDelegate){
        
        if nsArrTitle.count<=0{
            return
        }
        
        self.buttonClickDelegate = buttonClickDelegate
        
        //按钮宽度
        //var btnWidth:CGFloat = self.bounds.width /  CGFloat(dictInfo.count)
        let btnWidth:CGFloat = self.bounds.width /  CGFloat( self.maxButtons)
        let count = nsArrTitle.count < self.maxButtons ? nsArrTitle.count : self.maxButtons
        
        for(var i=0;i<count;i++){
            let btn = MyICOButton()
            btn.frame = CGRect(x: CGFloat(i) * btnWidth, y: CGFloat(0), width: btnWidth, height: CGFloat(self.bounds.height))
            btn.imageName = nsArrImage[i] as! String
            btn.imageTitle = nsArrTitle[i] as! String
            
            print(btn.imageTitle)
            //btn.backgroundColor = UIColor.yellowColor()
            btn.addTarget(self, action: "btnTouchDown:", forControlEvents: UIControlEvents.TouchDown)
            btn.addTarget(self, action: "btnTouchUpInside:", forControlEvents: UIControlEvents.TouchUpInside)
            btn.addTarget(self, action: "btnTouchUpOutside:", forControlEvents: UIControlEvents.TouchUpOutside)
            self.addSubview(btn)
        }
    }
    
    func btnTouchDown(sender:MyICOButton){
        //var red1 = CGFloat(54)
        //var green1 = CGFloat(133)
        //var blue1 = CGFloat(250)
        //var alpha1 = CGFloat(1)
        
        let red1 = CGFloat(0.2)
        let green1 = CGFloat(0.6)
        let blue1 = CGFloat(1)
        let alpha1 = CGFloat(0.7)
        //sender.backgroundColor = UIColor.blueColor()
        sender.backgroundColor = UIColor(red: red1, green: green1, blue: blue1, alpha: alpha1) //UIColor.blueColor()
        //sender.alpha = 0.7
    }
    
    //鼠标在触击区内释放
    func btnTouchUpInside(sender:MyICOButton){
        sender.backgroundColor = self.backgroundColor
        sender.alpha = self.alpha
        
        /*
        if buttonClickDelegate == nil{
            return
        }
        buttonClickDelegate.buttonClickEvent(sender.imageTitle)
        */
        buttonClickDelegate.buttonClickEvent(sender.imageTitle)
    }
    
    //鼠标在触击区外释放
    func btnTouchUpOutside(sender:MyICOButton){
        sender.backgroundColor = self.backgroundColor
        sender.alpha = self.alpha
        
        /*
        if buttonClickDelegate == nil{
            return
        }
        buttonClickDelegate.buttonClickEvent(sender.imageTitle)
        */
    }

}
