//
//  UserData.swift
//  HanWeiPlatform
//
//  Created by hanwei on 15/3/11.
//  Copyright (c) 2015年 hanwei. All rights reserved.
//

import Foundation

let userDataFileName = "UserData"

class UserDataManager {
    //获取当前项目bundle下的资源文件userData.plist的全路径
    //let bundlePath = NSBundle.mainBundle().pathForResource(userDataFileName, ofType: ".plist")
    var bundlePath:String = ""
    //private var uData : NSDictionary = []'
    
    private var _userData : NSMutableDictionary? = nil
    //用户数据
    var userData : NSMutableDictionary {
        //return loadUserDataFile()
        get{
            if _userData == nil {
                _userData = self.loadUserDataFile()
            }
            return _userData!
        }
        set{
            self._userData = newValue
        }
    }
    
    func ContainKey(keyStr:String)->Bool{
        
        for key in userData.allKeys{
            if key as! String == keyStr{
                return true
            }
        }
        
        return false
    }
 
    //加载用户数据文件
    func loadUserDataFile() -> NSMutableDictionary {

        // Do any additional setup after loading the view, typically from a nib.
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as! NSString
        //用户Document目录(能持久化存储数据，但第一次无文件)
        bundlePath = documentsDirectory.stringByAppendingPathComponent("UserData.plist")
        
        let isExist1 = NSFileManager.defaultManager().fileExistsAtPath(bundlePath)
        
        //如果用户Document目录下无此文件的话
        if isExist1==false{
            //当前用户文件所在路径（第一次时可以从这儿取初始值）
            let boundlePath2 = NSBundle.mainBundle().pathForResource("UserData", ofType: ".plist")
            let tmpDict = NSMutableDictionary(contentsOfFile: boundlePath2!)
            tmpDict!.writeToFile(bundlePath, atomically: true)
        }
        else
        {
            //同步安装包中的.plist文件中的值到安装目录
            let boundlePathPackage = NSBundle.mainBundle().pathForResource("UserData", ofType: ".plist")
            let tmpDict = NSMutableDictionary(contentsOfFile: boundlePathPackage!)!
            let dict  = NSMutableDictionary(contentsOfFile: bundlePath)!
            
            var foundSameKey:Bool
            for keytmp in tmpDict.allKeys{
                foundSameKey = false
                for keydict in dict.allKeys{
                    if keydict as! String == keytmp as! String{
                        foundSameKey = true
                        break
                    }
                }
                
                if !foundSameKey {
                    let key = keytmp as! String
                    let value = tmpDict.objectForKey(key) as! String
                    
                    dict.setValue(value, forKey:key)
                }
            }
            dict.writeToFile(bundlePath, atomically: false)
        }
        
        let dict  = NSMutableDictionary(contentsOfFile: bundlePath)!
        let resultDictionary = NSMutableDictionary(contentsOfFile: bundlePath)!
        print("读文件时，用户的数据文件内容： --> \(resultDictionary.description)")

        
        return dict
    }
    
    //保存用户数据文件
    func SaveUserDataFile(){
        //let bundlePath = NSBundle.mainBundle().pathForResource(userDataFileName, ofType: ".plist")
        userData.writeToFile(bundlePath, atomically: false)
        
        //var vartmpp1 = userData.count
        print("写文件时，用户的数据文件内容： --> \(userData.count)")
        let resultDictionary = NSMutableDictionary(contentsOfFile: bundlePath)
        print("写文件时，用户的数据文件内容： --> \(resultDictionary?.description)")
    }
}