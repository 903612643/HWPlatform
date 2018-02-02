//
//  extension.swift
//  JHMeeting
//
//  Created by hanwei on 15/8/12.
//  Copyright (c) 2015年 HanWei. All rights reserved.
//

import Foundation

//扩展URL query 解析适用于IOS 8 and later
public extension NSURL {
    /*
    Set an array with all the query items
    */
    var allQueryItems: [NSURLQueryItem] {
        get {
            let components = NSURLComponents(URL: self, resolvingAgainstBaseURL: false)!
            if let allQueryItems = components.queryItems {
                //return allQueryItems as! [NSURLQueryItem]
                return allQueryItems
            } else {
                return []
            }
        }
    }
    
    /**
    Get a query item form the URL query
    
    :param: key The parameter to fetch from the URL query
    
    :returns: `NSURLQueryItem` the query item
    */
    public func queryItemForKey(key: String) -> NSURLQueryItem? {
        let filteredArray = allQueryItems.filter { $0.name == key }
        
        if filteredArray.count > 0 {
            return filteredArray.first
        } else {
            return nil
        }
    }
}

//扩展URL query 解析适用于IOS 8 以上
extension NSURL {
    
    /**
    * URL query string as dictionary. Empty dictionary if query string is nil.
    */
    public var queryValues : [String:String] {
        get {
            if let q = self.query {
                return q.characters.split { (qSeparator) in
                    qSeparator == "&"
                    }.map { (queries) in
                        queries.split { (valueSeparator) in valueSeparator == "=" }
                    }.reduce([:]) { (var dict: [String:String], p) in
                        dict[String(p[0])] = String(p[1])
                        return dict
                }
            } else {
                return [:]
            }
        }
    }
    
}