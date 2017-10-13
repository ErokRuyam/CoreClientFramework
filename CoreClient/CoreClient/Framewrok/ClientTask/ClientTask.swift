//
//  ClientTask.swift
//  CoreClient
//
//  Created by Mayur on 03/10/17.
//  Copyright © 2017 Odocon. All rights reserved.
//

import Foundation

/**
 This is private interface of the ClientTask class and is mandated to be used ONLY by the implementors/inheritors/customizers
 of the framework. So, for example if someone wants to subclass this class, then (s)he shall import the Public header -
 Task.h in it's subclass header whereas the Private header in it's implementation file.
 Again, if the subclass wants to keep some of the interfaces private to framework, (s)he can follow the same pattern of adopting
 public & private headers for consumer & framework respectively.
 
 ====
 NOTE: This is a cool "Class Extension" feature of Objective C whereby the public interface can be declared in the public header
 file & private interface can be declared in the corresponding implementation file or in separate header file (like this one TaskPrivate).
 Every language has it's charm; learn to adopt in respective codebase.
 
 Refer: https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/CustomizingExistingClasses/CustomizingExistingClasses.html#//apple_ref/doc/uid/TP40011210-CH6-SW3
 
 "If you intend to make “private” methods or properties available to select other classes, such as related classes within a framework, you
 can declare the class extension in a separate header file and import it in the source files that need it. It’s not uncommon to have two
 header files for a class, for example, such as XYZPerson.h and XYZPersonPrivate.h. When you release the framework, you only release the
 public XYZPerson.h header file."
 ====
 */

/*
 Identifies the type of task; knowing the type of task helps client to schedule it on appropriate queue.
 */
public enum ClientTaskType: Int {
    case none = -1
    case webOpData = 0
    case webOpUpload
    case webOpDownload
    case housekeeping
}

open class ClientTask: NSObject {
    var operationToPerform: CoreOperation
    var taskType: ClientTaskType = ClientTaskType.none
    var isCancelled: Bool = false
    //A task is nothing but a wrapper around Operation; so it's identity is tied to it.
    override open var hashValue: Int {
        return operationToPerform.hash
    }
    
    init(operation: CoreOperation) {
        operationToPerform = operation
    }
    
    /*
     Every task MUST need to have a corresponding client set on it.
     Once a task is created but before it's submitted for execution, one MUST set the client using this method.
     */
    func setClient(_ client: Client) {
        operationToPerform.client = client
    }
    
    func client() -> Client {
        return operationToPerform.client!
    }
    
    func completionHandler() -> ClientCompletionHandler {
        return operationToPerform.completionHandler!
    }
    
    public func executeWithCompletionHandler(_ completionHandler: ClientCompletionHandler?) {
        operationToPerform.completionHandler = completionHandler
        operationToPerform.client?.submitTask(self)
    }
    
    public func addCompletionHandler(_ aCompletionHandler: ClientCompletionHandler?) {
        operationToPerform.addCompletionHandler(aCompletionHandler)
    }
    
    public func removeCompletionHandler(_ aCompletionHandler: ClientCompletionHandler?) {
        operationToPerform.removeCompletionHandler(aCompletionHandler)
    }
    
    public func removeAllCompletionHandlers() {
        operationToPerform.removeAllCompletionHandlers()
    }
    
    func removeAllHandlers() {
        removeAllCompletionHandlers()
    }
    
    public func objectForTaskAttributeKey(_ taskAttributeKey: AnyObject?) -> AnyObject? {
        if let attributKey = taskAttributeKey {
            return operationToPerform.objectForClientTaskAttributeKey(attributKey)
        } else {
            return nil
        }
    }
    
    func cancel() {
        //Logger.sharedInstance.logDebug(fileComponent(#file), message: "1. Client Task Cancelling...!!!")
        if !operationToPerform.isFinished && !operationToPerform.isCancelled {
            operationToPerform.cancel()
            isCancelled = true
            removeCompletionHandler(operationToPerform.completionHandler)
            //Logger.sharedInstance.logDebug(fileComponent(#file), message: "2. Client Task Cancelled!!!")
        }
    }
    
    override open func isEqual(_ object: Any?) -> Bool {
        if object == nil {
            return false
        } else if object as? ClientTask != nil {
            return true
        } else {
            let otherOperation: CoreOperation = object as! CoreOperation
            //If the 2 objets has same hash code i.e. same underlying Operation object, then those are equal.
            return otherOperation.hash == self.hash
        }
    }
}
