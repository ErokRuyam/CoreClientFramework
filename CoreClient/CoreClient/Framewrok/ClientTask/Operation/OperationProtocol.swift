//
//  OperationProtocol.swift
//  CoreClient
//
//  Created by Mayur on 03/10/17.
//  Copyright © 2017 Odocon. All rights reserved.
//

import Foundation

/**
 The ClientTask will consult this delegate when it needs an appropriate value/object for a given attribute key.
 Typically, the ClientTask exposes the task specific attributes/data to it's consumers using a key/value lookup method.
 The task may or may not maintain an internal map/dictionary to hold this data; it will consult it's underlying implementation
 viz. in this case is Operation and ask to return an appropriate object corresponding to the key passed in.
 */
protocol ClientTaskAttributeDelegate {
    func objectForClientTaskAttributeKey(_ clientTaskAttributeKey: AnyObject?) throws -> AnyObject?
}


/**
 The protocol enforces the basic contract to be adhered by the implementors.
 The Operation class implents this protocol; the protocol is also extended from ClientTaskAttributeDelegate to make
 sure that the operation responds to the it's wrapper task demands for supplying attribute specific values.
 */
protocol OperationProtocol : ClientTaskAttributeDelegate {
    /*
     Perform the necessary cleanup upon completion or cancellation of the operation. Most of the times, it will be used
     when the operation is cancelled or an error/excpetion occures and the internal state/data of the object needs to be
     left in sane state.
     */
    func cleanup()
    
    //Register & un-register secondary completion and/or progress handlers.
    func addCompletionHandler(_ aCompletionHandler: ClientCompletionHandler?)
    
    func addProgressHandler(_ aProgressHandler: ClientProgressHandler?)
    
    func removeCompletionHandler(_ aCompletionHandler: ClientCompletionHandler?)
    
    func removeProgressHandler(_ aProgressHandler: ClientProgressHandler?)
    
    func removeAllCompletionHandlers()
    
    func removeAllProgressHandlers()
}

extension OperationProtocol {
    func removeAllCompletionHandlers() {
        
    }
    
    func removeAllProgressHandlers() {
        
    }
}
