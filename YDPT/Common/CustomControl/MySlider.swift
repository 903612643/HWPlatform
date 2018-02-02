//
//  MySlider.swift
//  HanWei045
//
//  Created by hanwei on 15/3/20.
//  Copyright (c) 2015年 HanWei. All rights reserved.
//

import UIKit

//圆角矩形
class RoundedRect: UIView {

    var scale:CGFloat = 0.7
    var upColor :UIColor
    var downColor : UIColor

    /*
    required init(coder aDecoder: NSCoder) {
        
        //上半个颜色
        upColor = UIColor.blackColor()
        //下半个颜色
        downColor = UIColor.grayColor()
        //初始化
        super.init(coder: aDecoder)
        //默认大小
        self.frame = CGRect(x: 0, y: 0, width: 100, height: 5)
        //圆角
        self.layer.cornerRadius = 5
        //限定边界
        self.layer.masksToBounds = true
        //无边框
        self.layer.borderWidth = 0
    }
    */
    
    override init(frame: CGRect) {
        //上半个颜色
        upColor = UIColor.blackColor()
        //下半个颜色
        downColor = UIColor.grayColor()
        //初始化
        super.init(frame: frame)
        ////默认大小
        //self.frame = CGRect(x: 0, y: 0, width: 100, height: 5)
        //圆角
        self.layer.cornerRadius = 5
        //限定边界
        self.layer.masksToBounds = true
        //无边框
        self.layer.borderWidth = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawRect(rect: CGRect) {
        
        let  context = UIGraphicsGetCurrentContext()
        
        let rect1 = CGRectMake(0, 0, rect.width, rect.height * scale)
        CGContextAddRect(context, rect1)
        CGContextSetFillColorWithColor(context, upColor.CGColor)
        CGContextFillPath(context)
        
        let rect2 = CGRectMake(0,rect.height * scale ,rect.width, rect.height * (1-scale))
        CGContextAddRect(context, rect2)
        CGContextSetFillColorWithColor(context, downColor.CGColor)
        
        CGContextFillPath(context)
    }
}

//滑块组件，由滑杆和滑块组成
class Slider:UIView{

    private  var timer:NSTimer
    //滑杆
    private  var staff:RoundedRect
    //滑块
    private  var block:RoundedRect
    //状态
    private  var _sliderState = SliderState.left
    
    //当前状态
    var sliderState :SliderState{
        get{
            return _sliderState
        }
        set{
            if _sliderState == newValue{
                return
            }

            _sliderState = newValue
            timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "timerMethods", userInfo: nil, repeats: true)
        }
    }
    
    var parent:UIView

    var hei:CGFloat = 5
    let offset:CGFloat = 3.0

/*
    required init(coder aDecoder: NSCoder) {

        staff = RoundedRect(coder: aDecoder)
        var staffRect = CGRect(x:0,y:0,width:300,height:hei)
        staff.frame = staffRect
        staff.alpha = 0.5
        
        block = RoundedRect(coder: aDecoder)
        var staffRect2 = CGRect(x:0,y:0+1,width:300/2,height:hei-offset)
        block.frame = staffRect2
        block.upColor = UIColor.blackColor()
        block.downColor = UIColor.whiteColor()
        block.scale = 0
        block.alpha = 1

        
        timer = NSTimer()

        self.parent = UIView()
        super.init(coder: aDecoder)
        
        
        self.layer.masksToBounds = true
        self.addSubview(staff)
        self.addSubview(block)
        
        /*约束
        staff.frame = CGRect(x: self.frame.origin.x,    y: self.frame.origin.y,                 width: self.frame.width,    height: self.frame.height)
        block.frame = CGRect(x: self.frame.origin.x+1,  y: self.frame.origin.y+self.offset/2,   width: self.frame.width/2,  height: self.frame.height-self.offset)

        //block.frame = CGRect(x: self.frame.origin.x,    y: self.frame.origin.y,                 width: self.frame.width,    height: self.frame.height)
        
        var constraintTop       = NSLayoutConstraint(item: staff, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        var constraintBottom    = NSLayoutConstraint(item: staff, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        var constraintLeading   = NSLayoutConstraint(item: staff, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
        var constraintTrailing  = NSLayoutConstraint(item: staff, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0)
        
        var constraints:[NSLayoutConstraint]=[constraintTop,constraintBottom,constraintLeading,constraintTrailing]
        //staff.addConstraints(constraints)
        //staff.addConstraint(constraintTop)
        //self.addConstraint(constraintTop)
        self.addConstraints(constraints)
        */
        
        timer.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "timerMethods", userInfo: nil, repeats: true)
    }
*/
    
    override init(frame: CGRect) {

        staff = RoundedRect(frame: CGRect(x:0,y:0,width:frame.width,height:hei))
        staff.alpha = 0.5
        
        block = RoundedRect(frame: CGRect(x:0,y:0+1,width:frame.width/2,height:hei-offset))
        block.upColor = UIColor.blackColor()
        block.downColor = UIColor.whiteColor()
        block.scale = 0
        block.alpha = 0.5
        
        
        
        
        timer = NSTimer()
        
        self.parent = UIView()
        super.init(frame: frame)
        
        
        self.layer.masksToBounds = true
        self.addSubview(staff)
        self.addSubview(block)
        
        /*约束
        staff.frame = CGRect(x: self.frame.origin.x,    y: self.frame.origin.y,                 width: self.frame.width,    height: self.frame.height)
        block.frame = CGRect(x: self.frame.origin.x+1,  y: self.frame.origin.y+self.offset/2,   width: self.frame.width/2,  height: self.frame.height-self.offset)
        
        //block.frame = CGRect(x: self.frame.origin.x,    y: self.frame.origin.y,                 width: self.frame.width,    height: self.frame.height)
        
        var constraintTop       = NSLayoutConstraint(item: staff, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        var constraintBottom    = NSLayoutConstraint(item: staff, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        var constraintLeading   = NSLayoutConstraint(item: staff, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
        var constraintTrailing  = NSLayoutConstraint(item: staff, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0)
        
        var constraints:[NSLayoutConstraint]=[constraintTop,constraintBottom,constraintLeading,constraintTrailing]
        //staff.addConstraints(constraints)
        //staff.addConstraint(constraintTop)
        //self.addConstraint(constraintTop)
        self.addConstraints(constraints)
        */
        
        //timer.invalidate()
        //timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "timerMethods", userInfo: nil, repeats: true)
        setSliderLeft()
        
        self.alpha = 0.5

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //时钟方法
    func timerMethods(){
        UIView.animateWithDuration(0.2, animations: {
            if self._sliderState==SliderState.left {
                self.block.frame.origin.x = self.staff.frame.origin.x+1
            }
            else{
                self.block.frame.origin.x = self.staff.frame.origin.x + self.staff.frame.width/2-1
            }
            self.timer.invalidate()
        })
    }
    
    //设置滚动条居左
    func setSliderLeft(){
        self.block.frame.origin.x = self.staff.frame.origin.x+1
        self._sliderState = SliderState.left
    }
    
    //设置滚动条居右
    func setSliderRight(){
        self.block.frame.origin.x = self.staff.frame.origin.x + self.staff.frame.width/2-1
        self._sliderState = SliderState.right
    }
    
    //当前frame变化后，修改子控件的frame
    override func layoutSubviews() {
        super.layoutSubviews()
        staff.frame = CGRect(x: 0,y: 0,width: self.frame.width, height: self.frame.height)
        block.frame.size.height = self.frame.height - self.offset
        
        if self._sliderState==SliderState.left {
            self.block.frame.origin.x = self.staff.frame.origin.x+1
        }
        else{
            self.block.frame.origin.x = self.staff.frame.origin.x + self.staff.frame.width/2-1
        }

    }
    
}

enum SliderState{
   case  left
   case right
}
