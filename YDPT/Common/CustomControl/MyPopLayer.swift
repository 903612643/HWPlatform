//
//  MyPopLayer.swift
//  HanWeiPlatform
//
//  Created by hanwei on 15/3/24.
//  Copyright (c) 2015年 hanwei. All rights reserved.
//

import UIKit

class MyPopLayer: CALayer {
    
    var pointsAry:[CGPoint]
    init(pointsAry:[CGPoint]){
        self.pointsAry = pointsAry
        super.init()
        self.opacity = 0.8
        //self.backgroundColor = UIColor.greenColor().CGColor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //绘图
    override func drawInContext(ctx: CGContext) {
        
        var index :Int
        for index=0;index<self.pointsAry.count;index++ {
            //println("第几个序号：\(index)")
            if index == 0 {
                CGContextMoveToPoint(ctx, self.pointsAry[index].x, self.pointsAry[index].y)
            }
            else{
                CGContextAddLineToPoint(ctx, self.pointsAry[index].x, self.pointsAry[index].y)
            }
        }
        
        CGContextClosePath(ctx)
        CGContextFillPath(ctx)
    }
}
