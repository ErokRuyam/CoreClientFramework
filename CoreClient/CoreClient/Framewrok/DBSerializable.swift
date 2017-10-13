//
//  DBSerializable.swift
//  CoreClient
//
//  Created by Mayur on 04/10/17.
//  Copyright © 2017 Odocon. All rights reserved.
//

import Foundation

protocol DBSerializable {
    
    func read(fromArray dbRowArray: [Any]?)
    
    func read(fromDictionary dbRowDictionary: [String:Any]?)
    
    func toArray() -> [Any]
    
    func toDictionary() -> [String:Any]
}

extension DBSerializable {
    func read(fromArray dbRowArray: [Any]?) {
        //Default implementation does nothing
    }
    
    func read(fromDictionary dbRowDictionary: [String:Any]?) {
        //Default implementation does nothing
    }
    
    func toArray() -> [Any] {
        return []
    }
    
    func toDictionary() -> [String:Any] {
        var dict = [String:Any]()
        let otherSelf = Mirror(reflecting: self)
        for child in otherSelf.children {
            if let key = child.label {
                dict[key] = child.value
            }
        }
        return dict
    }
}
