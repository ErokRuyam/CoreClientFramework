//
//  CoreOperation.swift
//  CoreClient
//
//  Created by Mayur on 03/10/17.
//  Copyright © 2017 Odocon. All rights reserved.
//

import Foundation

/**
 An abstract class which helps encpasulate the work to be performed asychronously i.e. on differnet thread.
 Most of the times, it will be used with the NSOperationQueue but it's possible to start it manually - in which case,
 the onus is on the implementor of the subclass to override the -start() method and spawn a new thread or submit it to
 dispatch queue.
 NOTE: In context of the Client framework, the Operation instances are exclusivly used with NSOperationQueue. As such,
 the implementation is non-concurrent (because operation queue takes the responsibility to spawn a thread & execute opeeration's
 main method on that secondary thread.) and both the properties - asynchronous, concurrent have their default values viz. NO.
 
 VRMClient or it's version specific subclass will generally instantiate the Operation instances which are encapsulated/contained
 in the instance of ClientTask.
 
 This class is abstract and as such shall not be instantiated. It only provides a basic implementation of -main() method whereby
 it only checks for the cancelled flag & returns immediately (obviously by performing the necessary cleanup) upon detecting it to be YES.
 */
//TODO: I think, this needs to be moved to OperationPrivate; review thoroughly once.
open class CoreOperation: Operation, OperationProtocol {
    //An identifier that uniquely identifies a given operation instance.
    public var operationID: String?
    /*
     The data associated with the operation. It can be anything for e.g. if the request is regarding fetching subfolders or file versions
     then this can a File instance. If the request is for login, this can be an array comprising username, password, serverUrl in that order.
     */
    public var opData: AnyObject?
    //The timestamp when the reuest is being submitted to the DataStore for the execution.
    public var timestamp: TimeInterval = -1
    public var serviceMethod: Selector?
    public var completionHandler: ClientCompletionHandler?
    public var progressHandler: ClientProgressHandler?
    public var secondaryCompletionHandlers: NSMutableArray?
    public var secondaryProgressHandlers: NSMutableArray?
    public var client: Client?
    public var wrapperTask: ClientTask?   //The task instance which wraps this operation.
    
    override public init() {
        super.init()
        operationID = String.init(format: "%s@%ld@%f", object_getClassName(self), self.hash, Date(timeIntervalSinceReferenceDate: NSTimeIntervalSince1970) as CVarArg)
        secondaryProgressHandlers = NSMutableArray()
        secondaryCompletionHandlers = NSMutableArray()
    }
    
    override open func main() {
        if self.isCancelled {
            self.cleanup()
        }
    }
    
    //Does nothing; only concrete subclasses are in position to determine the exact cleanup needed to be carried out.
    func cleanup() {
        //Do nothing.
    }
    
    func addCompletionHandler(_ aCompletionHandler: ClientCompletionHandler?) {
        if aCompletionHandler != nil {
            secondaryCompletionHandlers!.add(aCompletionHandler as AnyObject)
        }
    }
    
    func addProgressHandler(_ aProgressHandler: ClientProgressHandler?) {
        if aProgressHandler != nil {
            secondaryProgressHandlers!.add(aProgressHandler as AnyObject)
        }
    }
    
    func removeCompletionHandler(_ aCompletionHandler: ClientCompletionHandler?) {
        if aCompletionHandler != nil {
            secondaryCompletionHandlers!.remove(aCompletionHandler as AnyObject)
        }
    }
    
    func removeProgressHandler(_ aProgressHandler: ClientProgressHandler?) {
        if aProgressHandler != nil {
            secondaryProgressHandlers!.remove(aProgressHandler as AnyObject)
        }
    }
    
    func removeAllCompletionHandlers() {
        secondaryCompletionHandlers!.removeAllObjects()
    }
    
    func removeAllProgressHandlers() {
        secondaryProgressHandlers!.removeAllObjects()
    }
    
    //MARK: - ClientTaskAttributeDelegate methods
    func objectForClientTaskAttributeKey(_ clientTaskAttributeKey: AnyObject?) -> AnyObject? {
        NSException(name: NSExceptionName(rawValue: "InvalidSelectorException"), reason: "Invalid method call: -objectForClientTaskAttributeKey: can't be executed on abstract Operation instance!", userInfo: nil).raise()
        return nil
    }
}
