//
//  SOAP.swift
//  HWPlatform
//
//  Created by hanwei on 15/5/14.
//  Copyright (c) 2015年 HanWei. All rights reserved.
//

import Foundation

class ApiManager : NSObject {
    
    var token: String
    
    class var sharedInstance: ApiManager {
        struct Static {
            static var instance: ApiManager?
            static var disptachToken: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.disptachToken) {
            Static.instance = ApiManager()
        }
        
        return Static.instance!
    }
    
    override init() {
        token = ""
        super.init()
    }
    
    func postSOAP(message: String, urlString: String, soapAction: String, completion: (result: NSData) -> Void) {
        
        let url = NSURL(string: urlString)
        
        let request = NSMutableURLRequest(URL: url!)
        
        let msgLength = String(message.characters.count)
        
        request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(msgLength, forHTTPHeaderField: "Content-Length")
        request.addValue(soapAction, forHTTPHeaderField: "SOAPAction")
        request.timeoutInterval = 10
        if (!token.isEmpty) {
            request.addValue(".CAAUSGEX=" + token, forHTTPHeaderField: "Cookie")
        }
        request.HTTPMethod = "POST"
        request.HTTPBody = message.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) // or false
        
        let queue:NSOperationQueue = NSOperationQueue()

        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            if (error != nil)
            {
                let StrErrData:NSString = "ErrorReturn"
                let ErrData = StrErrData.dataUsingEncoding(NSUTF8StringEncoding)
                completion(result: ErrData!)
                print("Request error !!!!!!!")
            }
            else
            {
                completion(result: data!)
            }
        })
    }
}

class ContentManager : NSObject {
    
    private let apiManager = ApiManager.sharedInstance
    
    class var sharedInstance: ContentManager {
        struct Static {
            static var instance: ContentManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = ContentManager()
        }
        
        return Static.instance!
    }
    
    override init() {
        super.init()
    }
    
    func login(SoapAction: String, SoapURL: String, SoapMessage: String, completion: (token: NSData) -> Void) {

        let urlString = SoapURL
        let soapAction = SoapAction
        
        ApiManager.sharedInstance.postSOAP(SoapMessage, urlString: urlString, soapAction: soapAction) {
            (result) -> Void in
            
            completion(token:result)
        }
    }
}