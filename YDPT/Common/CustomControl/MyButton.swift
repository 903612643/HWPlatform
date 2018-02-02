//
//  MyButton.swift
//  HanWeiPlatform
//
//  Created by hanwei on 15/3/26.
//  Copyright (c) 2015年 hanwei. All rights reserved.
//

import UIKit

class MyICOButton: UIButton {
    
    //图片文件名
    var imageName = ""
    //图片图标
    var imageTitle = ""
    
    override func drawRect(rect: CGRect) {

        //super.drawRect(rect)
        let img = UIImage(named: imageName)
        img?.drawInRect(CGRect(x: (self.bounds.width-ICOData.imageLength)/2,y: ICOData.padding,width:ICOData.imageLength,height: ICOData.imageLength))
        
        let font = UIFont(name: "STHeitiSC-Light", size: 12)!
        let attributes = [
            NSForegroundColorAttributeName : UIColor.whiteColor() ,
            NSFontAttributeName : font,
            //NSTextEffectAttributeName : NSTextEffectLetterpressStyle
        ]
        
        let nsStr: NSString = self.imageTitle
        if imageTitle.characters.count >= 4{
            nsStr.drawAtPoint(CGPoint(x: ((self.bounds.width-ICOData.imageLength)/2 - 8), y: ICOData.fontY), withAttributes: attributes)
        }
        else
        {
            nsStr.drawAtPoint(CGPoint(x: ((self.bounds.width-ICOData.imageLength)/2 + 4), y: ICOData.fontY), withAttributes: attributes)
        }
    }
}


