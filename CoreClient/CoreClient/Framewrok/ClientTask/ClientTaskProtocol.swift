//
//  ClientTaskProtocol.swift
//  CoreClient
//
//  Created by Mayur on 03/10/17.
//  Copyright © 2017 Odocon. All rights reserved.
//

import Foundation

public protocol ClientTaskProtocol {
    //Starting the task execution.
    /**
     Start a task with given completion handler.
     @param - completionHandler to be executed upon completion of the given task.
     */
    func executeWithCompletionHandler(_ completionHandler: ClientCompletionHandler?)
    
    ///Obtaining the general task information
    func completionHandler() -> ClientCompletionHandler?
    
    ///Register & un-register secondary completion handlers.
    func addCompletionHandler(_ aCompletionHandler: ClientCompletionHandler?)
    
    func removeCompletionHandler(_ aCompletionHandler: ClientCompletionHandler?)
    
    func removeAllCompletionHandlers()
    
    func removeAllHandlers()
    
    ///Retrieving the data pertaining to the task
    func objectForTaskAttributeKey(_ taskAttributeKey: AnyObject?) -> AnyObject?
}

extension ClientTaskProtocol {
    func executeWithCompletionHandler(_ completionHandler: ClientCompletionHandler?) {
        //NOP
    }
    
    //Obtaining the general task information
    public func completionHandler() -> ClientCompletionHandler? {
        return nil
    }
    
    //Register & un-register secondary completion handlers.
    func addCompletionHandler(_ aCompletionHandler: ClientCompletionHandler?) {
        //NOP
    }
    
    func removeCompletionHandler(_ aCompletionHandler: ClientCompletionHandler?) {
        //NOP
    }
    
    func removeAllCompletionHandlers() {
        //NOP
    }
    
    func removeAllHandlers() {
        //NOP
    }
    
    //Retrieving the data pertaining to the task
    func objectForTaskAttributeKey(_ taskAttributeKey: AnyObject?) -> AnyObject? {
        return nil
    }
}
