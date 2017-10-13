//
//  ClientProgressTaskProtocol.swift
//  CoreClient
//
//  Created by Mayur on 03/10/17.
//  Copyright © 2017 Odocon. All rights reserved.
//

import Foundation

public protocol ClientProgressTaskProtocol: ClientTaskProtocol {
    //Start a task with given completion handler and progress handler. Use this method to receive the periodic task progress updates.
    func execute(_ completionHandler: ClientCompletionHandler?, progressHandler: ClientProgressHandler?)
    
    //Obtaining the general task information
    func progressHandler() -> ClientProgressHandler?
    
    //Register & un-register secondary progress handlers.
    func addProgressHandler(_ aProgressHandler: ClientProgressHandler?)
    
    func removeProgressHandler(_ aProgressHandler: ClientProgressHandler?)
    
    func removeAllProgressHandlers()
}

extension ClientProgressTaskProtocol {
    func execute(_ completionHandler: ClientCompletionHandler?, progressHandler: ClientProgressHandler?) {
        //Default implementation does nothing
    }
    
    //Obtaining the general task information
    func progressHandler() -> ClientProgressHandler? {
        return nil
    }
    
    //Register & un-register secondary progress handlers.
    func addProgressHandler(_ aProgressHandler: ClientProgressHandler?) {
        //Default implementation does nothing
    }
    
    func removeProgressHandler(_ aProgressHandler: ClientProgressHandler?) {
        //Default implementation does nothing
    }
    
    func removeAllProgressHandlers() {
        //Default implementation does nothing
    }
}
