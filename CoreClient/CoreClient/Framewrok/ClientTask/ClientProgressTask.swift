//
//  ClientProgressTask.swift
//  CoreClient
//
//  Created by Mayur on 03/10/17.
//  Copyright © 2017 Odocon. All rights reserved.
//

import Foundation

open class ClientProgressTask: ClientTask, ClientProgressTaskProtocol {
    override init(operation: CoreOperation) {
        super.init(operation: operation)
    }
    
    //Start a task with given completion handler and progress handler. Use this method to receive the periodic task progress updates.
    public func execute(_ completionHandler: ClientCompletionHandler?, progressHandler: ClientProgressHandler?) {
        operationToPerform.progressHandler = progressHandler
        executeWithCompletionHandler(completionHandler!)
    }
    
    //Obtaining the general task information
    public func progressHandler() -> ClientProgressHandler? {
        return operationToPerform.progressHandler
    }
    
    //Register & un-register secondary progress handlers.
    public func addProgressHandler(_ aProgressHandler: ClientProgressHandler?) {
        operationToPerform.addProgressHandler(aProgressHandler)
    }
    
    public func removeProgressHandler(_ aProgressHandler: ClientProgressHandler?) {
        operationToPerform.removeProgressHandler(aProgressHandler)
    }
    
    public func removeAllProgressHandlers() {
        operationToPerform.removeAllProgressHandlers()
    }
    
    override public func removeAllHandlers() {
        super.removeAllHandlers()
        removeAllProgressHandlers()
    }
    
    override public func cancel() {
//        Logger.sharedInstance.logDebug(fileComponent(#file), message: "1. Client Task Cancelled!!!")
        if !operationToPerform.isFinished && !operationToPerform.isCancelled {
            operationToPerform.cancel()
            isCancelled = true
            removeProgressHandler(operationToPerform.progressHandler)
            removeCompletionHandler(operationToPerform.completionHandler)
//            Logger.sharedInstance.logDebug(fileComponent(#file), message: "2. Client Task Cancelled!!!")
        }
    }
}
