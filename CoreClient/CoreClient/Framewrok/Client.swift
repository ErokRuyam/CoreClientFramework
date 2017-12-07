//
//  Client.swift
//  CoreClient
//
//  Created by Mayur on 03/10/17.
//  Copyright © 2017 Odocon. All rights reserved.
//

import Foundation

/**
 Notes for subclassing:
 ======================
 By the time initWithConfiguration.... method has finished execution, it's guranteed that:
 - all the queues including serviceDelegateQueue & taskQueue are setup
 - if the callback queue is passed, then callbackQueue has the requisite value else refers to Main Operation Queue.
 
 Subclasses can choose to override this init method by:
 - Overriding it completely thereby overwritting the state set by parent's init method
 - Overriding just part of it by providing an instance of client+version specifc Service implementation, Credential Store, Persistent
 Store (if these are not provided by the client configuration instance passed to the method) leaving other state intact.
 */
open class Client : NSObject, ClientProtocol, ServiceDelegate {
    private static let dataRequestQueueIdentifier: String =     "com.CoreClient.Client.dataRequestQueue"
    private static let uploadRequestQueueIdentifier: String =   "com.CoreClient.Client.uploadRequestQueue"
    private static let downloadRequestQueueIdentifier: String = "com.CoreClient.Client.downloadRequestQueue"
    private static let houseKeepingQueueIdentifier: String =    "com.CoreClient.Client.housekeepingQueue"
    private static let serviceDelegateQueueIdentifier: String = "com.CoreClient.Client.serviceDelegateQueue"
    
    public var clientConfiguration: ClientConfiguration?
    ///The callbackQueue can be either an instance of NSOperationQueue or dispatch_queue_t i.e. GCD queue.
    public var callbackQueue: AnyObject?
    public var service: ServiceProtocol?
    public var credentialStore: CredentialStoreProvider?
    public var persistentStore: PersistentStoreProvider?
    
    ///The queues being used to perform the web service operations, long running tasks on background thread.
    ///This queue will be exclusively used to schedule the web service operations that deal with metadata.
    public var dataRequestQueue: OperationQueue?
    
    ///This queue will be exclusively used to schedule the web service operations that deal with upload/download of the files i.e. Sync.
    public var uploadRequestQueue: OperationQueue?
    public var downloadRequestQueue: OperationQueue?

    /**
     This queue will be exclusively used to schedule operations which are non-web service ones but are required to be performed on
     background thread as those are long runnning ones or CPU intensive or do some heavy lifting (like Cryptographic functions,
     Disk/DB access etc.). The operations scheduled on this queue MUST not perform web operations/data transfer over the wire; if
     that's the case, use metadataRequestQueue or syncRequestQueue.
     */
    public var housekeepingQueue: OperationQueue?
    
    /**
     The queue designated for receiving the ServiceDelegate callbacks. This is the same queue which needs to be passed
     while creating an instance of ServiceConfiguration.
     */
    public var serviceDelegateQueue: OperationQueue?
    
    /**
     Holds instances of Task or it's subclasses each of which wraps the Operation or it's subclass instance.
     The tasks are added to this queue but the contained operations can be executed on different operation queues like
     sync or metadata request queue.
     */
    public var taskQueue: NSMutableArray?      //__kindof means allow ClientTask or any if it's subclass instances.
    public var dataDelegate: ClientDataDelegate?
    public var configDelegate: ClientConfigurationDelegate?
    
    
    ///This initializer creates a document with a nil name value
    override init() {
        super.init()
    }
    
    /**
     Subclasses can choose to override this init method by:
     - Overriding it completely thereby overwritting the state set by parent's init method
     - Overriding just part of it by providing an instance of client+version specifc Service implementation, Credential Store,
     Persistent Store (if these are not provided by the client configuration instance passed to the method) leaving other
     state intact.
     */
    public init(aClientConfiguration: ClientConfiguration?, theCallbackQueue: AnyObject?) {
        super.init()
        self.clientConfiguration = aClientConfiguration
        
        //Setup Client's callbackQueue.
        if let callbackQueue = theCallbackQueue {
            self.callbackQueue = callbackQueue
        } else {
            self.callbackQueue = OperationQueue.main
        }
        /**
         Note: As this is an abstract class, what all components are needed can't be determined at this level.
         Also, it's worth noting that this same client is being inherited by the Client.
         vDRM Client is not in need of using Peristent Store whereas, the Client does need it.
         Therefore, the decision to use default implementation of below components (because Client Configuration doesn't provide one)
         is left to the specific implementor:
         - The default implementation of the Credential Store Provider
         - The default implementation of the Persistent Store Provider
         - The default implementation of the Service. Version specific concrete classes will instantiate their version specific
         Service implementations.
         */
        //Setup operation queues.
        self.initQueues()
    }
    
    /**
     @return the instance of Client initialized with given configuration. If no callback queue is provided, all the delegate callbacks and/or
     completion hanlders are executed on the mainQueue by default. If the delegate callbacks &/or completion handlers need to be executed on
     different queue, use - (instancetype) initWithConfiguration:(ClientConfiguration *) theClientConfiguration queue:(id) theCallbackQueue
     initializer.
     */
    convenience init(aClientConfiguration: ClientConfiguration?) {
        //Instance with default service implementation.
        self.init(aClientConfiguration: aClientConfiguration, theCallbackQueue: nil)
    }
    
    func initQueues() {
        //High QoS expectancy.
        dataRequestQueue = OperationQueue.init()
        dataRequestQueue?.name = Client.dataRequestQueueIdentifier
        dataRequestQueue?.qualityOfService = QualityOfService.userInitiated
        dataRequestQueue?.maxConcurrentOperationCount = 1//NSOperationQueueDefaultMaxConcurrentOperationCount//1
        
        //High QoS expectancy.
        uploadRequestQueue = OperationQueue.init()
        uploadRequestQueue?.name = Client.uploadRequestQueueIdentifier
        uploadRequestQueue?.qualityOfService = QualityOfService.userInitiated
        //Let the uploads happen concurrently. This means multiple uploads can take place concurrently.
        //TODO: Re-assess this if needed.
        uploadRequestQueue?.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
        
        downloadRequestQueue = OperationQueue.init()
        downloadRequestQueue?.name = Client.downloadRequestQueueIdentifier
        downloadRequestQueue?.qualityOfService = QualityOfService.userInitiated
        //Let the downloads happen concurrently. This means multiple downloads can take place concurrently.
        //TODO: Re-assess this if needed.
        downloadRequestQueue?.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount

        //High QoS expectancy.
        housekeepingQueue = OperationQueue.init()
        housekeepingQueue?.name = Client.houseKeepingQueueIdentifier
        housekeepingQueue?.qualityOfService = QualityOfService.userInitiated
        housekeepingQueue?.maxConcurrentOperationCount = 1//NSOperationQueueDefaultMaxConcurrentOperationCount//1
        
        //Average QoS expectancy.
        serviceDelegateQueue = OperationQueue.init()
        serviceDelegateQueue?.name = Client.serviceDelegateQueueIdentifier
        serviceDelegateQueue?.qualityOfService = QualityOfService.background
        serviceDelegateQueue?.maxConcurrentOperationCount = 1//NSOperationQueueDefaultMaxConcurrentOperationCount//1
        
        taskQueue = NSMutableArray.init()
    }
    
    ///Submit a task to queue for execution.
    ///Implemented by abstract Client class.
    func submitTask(_ task: ClientTask) {
        taskQueue?.add(task)
        if task.taskType == ClientTaskType.webOpUpload {
            uploadRequestQueue?.addOperation(task.operationToPerform)
        } else if task.taskType == ClientTaskType.webOpDownload {
            downloadRequestQueue?.addOperation(task.operationToPerform)
        } else if task.taskType == ClientTaskType.webOpData {
            dataRequestQueue?.addOperation(task.operationToPerform)
        } else if task.taskType == ClientTaskType.housekeeping {
            housekeepingQueue?.addOperation(task.operationToPerform)
        }
    }
    
    ///Submit a new task to queue for execution by replacing the existing task.
    func submitTask(_ task: ClientTask, byReplacingExistingTask existingTask: ClientTask) {
        if let taskQ = taskQueue {
            for task in taskQ {
                if let aTask = task as? ClientTask {
                    if aTask.operationToPerform.operationID == existingTask.operationToPerform.operationID {
                        let taskIndex: Int = taskQ.index(of: existingTask)
                        taskQueue?.replaceObject(at: taskIndex, with: task)
                        
                        if aTask.taskType == ClientTaskType.webOpUpload {
                            uploadRequestQueue?.addOperation(aTask.operationToPerform)
                        } else if aTask.taskType == ClientTaskType.webOpDownload {
                            downloadRequestQueue?.addOperation(aTask.operationToPerform)
                        } else if aTask.taskType == ClientTaskType.webOpData {
                            dataRequestQueue?.addOperation(aTask.operationToPerform)
                        } else if aTask.taskType == ClientTaskType.housekeeping {
                            housekeepingQueue?.addOperation(aTask.operationToPerform)
                        }
                        break
                    }
                }
            }
        }
    }
    
    public func cleanupQueue() {
        if let dataRequestQ = dataRequestQueue {
            dataRequestQ.cancelAllOperations()
        }
        if let uploadRequestQ = uploadRequestQueue {
            uploadRequestQ.cancelAllOperations()
        }
        if let downloadRequestQ = downloadRequestQueue {
            downloadRequestQ.cancelAllOperations()
        }
        if let housekeepingQ = housekeepingQueue {
            housekeepingQ.cancelAllOperations()
        }
        if let serviceDelegateQ = serviceDelegateQueue {
            serviceDelegateQ.cancelAllOperations()
        }
    }
    
    public func cleanup() {
        cleanupQueue()
        service?.cleanup()
    }
    
    public func clientTaskDidFinishWithResult(_ clientTask: ClientTask?, data: AnyObject?, error: Error?) {
        if let taskQ = taskQueue {
            for task in taskQ {
                if let aTask = task as? ClientTask {
                    if aTask.operationToPerform.operationID == clientTask?.operationToPerform.operationID {
                        taskQueue?.removeObject(identicalTo: clientTask!)
                        
                        executeClientCompletionHandler(clientTask!.operationToPerform.completionHandler, data: data, error: error)
                        
                        //Execute the secondary completion handlers & also remove them once done.
                        if let secondaryCompletionHandlers = clientTask!.operationToPerform.secondaryCompletionHandlers {
                            for aCompletionHandler in secondaryCompletionHandlers {
                                executeClientCompletionHandler((aCompletionHandler as! ClientCompletionHandler), data: data, error: error)
                            }
                        }
                        clientTask!.removeAllCompletionHandlers()
                        if clientTask is ClientProgressTask {
                            (clientTask as! ClientProgressTask).removeAllProgressHandlers()
                        }
                        break
                    }
                }
            }
        }
        for task in taskQueue! {
            if (task as! ClientTask).operationToPerform.operationID == clientTask?.operationToPerform.operationID {
                taskQueue?.removeObject(identicalTo: clientTask!)
                
                executeClientCompletionHandler(clientTask?.operationToPerform.completionHandler, data: data, error: error)
                
                //Execute the secondary completion handlers & also remove them once done.
                for aCompletionHandler in (clientTask?.operationToPerform)!.secondaryCompletionHandlers! {
                    executeClientCompletionHandler((aCompletionHandler as! ClientCompletionHandler), data: data, error: error)
                }
                clientTask?.removeAllCompletionHandlers()
                if clientTask is ClientProgressTask {
                    (clientTask as! ClientProgressTask).removeAllProgressHandlers()
                }
                break
            }
        }
    }
    
    public func clientTaskHasProgressUpdate(_ clientTask: ClientTask?, progressDictionary: NSDictionary?, error: Error?) {
        for task in taskQueue! {
            if (task as! ClientTask).operationToPerform.operationID == clientTask?.operationToPerform.operationID {
                if let progressHandler = (task as! ClientTask).operationToPerform.progressHandler {
                    executeClientProgressHandler(progressHandler, progressDictionary: progressDictionary!)
                    //Execute the secondary completion handlers & also remove them once done.
                    for aProgressHandler in (clientTask?.operationToPerform.secondaryProgressHandlers)! {
                        self.executeClientProgressHandler(aProgressHandler as! ClientProgressHandler, progressDictionary: progressDictionary!)
                    }
                }
                break
            }
        }
    }
    
    func clientTaskFinishCompletionHandlerWithResult(_ clientTask: ClientTask?, data: AnyObject?, error: Error) {
        executeClientCompletionHandler(clientTask?.operationToPerform.completionHandler, data: data, error: error)
        //Execute the Secondary completion handlers & also remove them once done.
        for aCompletionHandler in (clientTask?.operationToPerform.secondaryCompletionHandlers)! {
            executeClientCompletionHandler(aCompletionHandler as? ClientCompletionHandler, data: data, error: error)
        }
        clientTask?.removeAllCompletionHandlers()
        if clientTask is ClientProgressTask {
            (clientTask as! ClientProgressTask).removeAllProgressHandlers()
        }
    }
    
    
    public func executeClientCompletionHandler(_ completionHandler: ClientCompletionHandler?, data: AnyObject?, error: Error?) {
        if callbackQueue is OperationQueue {
            callbackQueue?.addOperation({
                completionHandler!(data, error)
            })
        } else {
            (callbackQueue as! DispatchQueue).async(execute: {
                completionHandler!(data, error)
            })
        }
    }
    
    func executeClientProgressHandler(_ progressHandler: @escaping ClientProgressHandler, progressDictionary: NSDictionary) {
        if callbackQueue is OperationQueue {
            callbackQueue?.addOperation({
                progressHandler(progressDictionary)
            })
        } else {
            (callbackQueue as! DispatchQueue).async(execute: {
                progressHandler(progressDictionary)
            })
        }
    }
    
    open func lookupDomain(_ domainName: String?, WithServiceMethod serviceMethod: Selector?) -> ClientTask? {
        return nil
    }

    open func doAPIHandshakeWithServiceMethod(_ serviceMethod: Selector?) -> ClientTask? {
        return nil
    }
    
    //MARK: - ServiceDelegate methods
    public func serviceCanProceed() -> Bool {
        return true
    }
    
    public func serviceShallUseAuthInfo() -> Bool {
        return false
    }
    
    public func serviceAuthInfo() -> AnyObject? {
        return nil
    }
    
    /**
     Informs the delegate that the response was received by the Service.
     Need to pass the Task Identifier to this callback so that the Client is able to know which task object
     to retrieve from the taskQueue, call it's completion handler/progress handler & later remove it from taskQueue.
     For this, one needs to iterate over the array, compare the hash/task.operation.ID of each client & then remove the one matches.
     Also, possible to use NSMapTable where key is task ID & value is task object. The Value will be weak i.e. task values will
     be not be strongly retained un-necessarily; once removed from the queue, will be removed from table as well.
     */
    public func serviceDidReceiveResponseForRequest(_ service: ServiceProtocol, data: AnyObject?, error: Error?, uniqueRequestIdentifier: String?) {
//        Logger.sharedInstance.logDebug(fileComponent(#file), message: "Client did receive response:\(data.debugDescription)  error:\(error.debugDescription)")
        for case let task as ClientTask in taskQueue! {
            if task.operationToPerform.operationID == uniqueRequestIdentifier {
                (task.operationToPerform as! WebOperation).processResponse(data, error: error, callbackQueue: callbackQueue)
                return
            }
        }
    }
    
    func serviceDidTransferDataForRequest(_ service: Service?, progressDictionary: NSDictionary?, uniqueRequestIdentifier: String?) {
        for task in taskQueue! {
            if (task as! ClientTask).operationToPerform.operationID == uniqueRequestIdentifier {
                ((task as! ClientTask).operationToPerform as! WebOperation).processProgressUpdate(progressDictionary!)
                break
            }
        }
    }
    
    public func serviceDidTransferDataForRequest(_ service: ServiceProtocol, progressDictionary: NSDictionary?, uniqueRequestIdentifier: String?) {
        for case let task as ClientTask in taskQueue! {
            if task.operationToPerform.operationID == uniqueRequestIdentifier {
                (task.operationToPerform as! WebOperation).processProgressUpdate(progressDictionary)
                return
            }
        }
    }
}
