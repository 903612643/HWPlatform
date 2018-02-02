
//
//  Core.swift
//  HanWeiPlatform
//
//  Created by hanwei on 15/3/27.
//  Copyright (c) 2015年 hanwei. All rights reserved.
//

import Foundation
import UIKit

//协议
@objc protocol ButtonClickDelegate{
   @objc func buttonClickEvent(buttonTitle:String)
}


protocol PSetSelectedValue{
    //func SetSelectedValue(selectPointIndexCollection:Array<Int>)
    //func setNeedDisplay()
    func addElement(point:Int)
    func overGestrue()
}



struct ICOData {
    //ico边长
    static let imageLength:CGFloat = 32
    //ico字高
    static let fontHeight:CGFloat = 16
    //ico间距
    static let padding:CGFloat = 4
    //四个字宽度
    static let fourFontWidth:CGFloat = 60
    //两个字宽度
    static let twoFontWidth:CGFloat = 30
    
    //总高度
    static var height:CGFloat{
        return padding+imageLength+padding+fontHeight+padding;
    }
    
    //字体位置Y
    static var fontY:CGFloat{
        return padding+imageLength+padding;
    }
}

enum ButtonType {
    case Back
    case Forward
    case Refresh
    case Clear
    case ShortCut
    case CheckUpdate
    case ServerSet
    case FileManager
}

struct ButtonTitle {
    static let  Back = "后退"
    static let  Forward = "前进"
    static let  Refresh = "刷新"
    static let  ClearCache = "清空缓存"
    static let  ShortCut = "快捷方式"
    static let  CheckUpdate = "检查更新"
    static let  ServerSet = "服务设置"
    static let  FileManager = "存储管理"
}