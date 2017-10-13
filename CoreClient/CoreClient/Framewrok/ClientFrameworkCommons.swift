//
//  ClientFrameworkCommons.swift
//  CoreClient
//
//  Created by Mayur on 03/10/17.
//  Copyright © 2017 Odocon. All rights reserved.
//

import Foundation

/**
 The signature of the completion block that shall be used by the consumer(e.g. UI/view controller) of the Client API to receive the
 result/error for the requested Client operation. Upon finishing the operation, Client will execute this block.
 */
public typealias ClientCompletionHandler = (_ result: AnyObject?, _ error: Error?) -> Void

/**
 The signature of the progress handler block that shall be used by the consumer(e.g. UI/view controller) of the Client API to receive
 the progress updates (like upload/download of the file) for the requested Client operation. This block will be executed on each
 progress update and as such API consumer shall update it's own state accordingly like - updating the progress dialog.
 */
public typealias ClientProgressHandler = (NSDictionary?) -> Void

/**
 The signature of the task replacement handler block that shall be used by the consumer(e.g. UI/view controller) of the Client API to receive
 the new task object after replacing existing one. So it will be helpful to do operations with that task.(eg. cancel/resume/pause the task etc.)
 */
public typealias ClientTaskReplacementHandler = (_ newTask: ClientTask?) -> Void

/**
 The signature of the error handler that shall be used by the consumer(e.g. Service) of the Client API to receive error while parsing service request/respone.
 */
public typealias ErrorHandler = (_ error: NSError?) -> Void

open class ClientFrameworkCommons: NSObject {
    ///Keys pertaining to the progress dictionary.
    static let ClientTaskCurrentBytesCount = "ClientTaskCurrentBytesCount"
    static let ClientTaskCurrentProgressValue = "ClientTaskCurrentProgressValue"
    static let ClientTaskMaxProgressValue = "ClientTaskMaxProgressValue"
    static let ClientTaskFilename = "ClientTaskFilename"
}

