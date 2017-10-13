//
//  Service.swift
//  CoreClient
//
//  Created by Mayur on 03/10/17.
//  Copyright © 2017 Odocon. All rights reserved.
//

import Foundation

/**
 The class provides the abstract implementation of the ServiceProtocol.
 
 Even at this level, the implementation details are abstract - the class makes no assumptions about the semantics of the
 web service.
 
 It just provides the bare minimal starting infrastructure for the concrete implementors & acts as a starting point.
 */
open class Service: NSObject, ServiceProtocol {
    public var serviceConfiguration: ServiceConfiguration
    
    //Only inherited classes supposed to use it internally; for clients of this class, need to access through properties or public accessible methods.
    public var delegate: ServiceDelegate?
    public var isFinished: Bool = false
    
    required public init(theServiceConfiguration: ServiceConfiguration) {
        serviceConfiguration = theServiceConfiguration
        super.init()
    }
    
    public func performRequest(_ request: URLRequest) {
        NSException(name: NSExceptionName(rawValue: "InvalidSelectorException"), reason: "Invalid method call: -performRequest: can't be executed on abstract RESTService instance!", userInfo: nil).raise()
    }
    
    //Because, we don't know any implementation details at this level, not possible to provide any generic cleanup code. Hence, throw an excpetion.
    public func cleanup() {
        NSException(name: NSExceptionName(rawValue: "InvalidSelectorException"), reason: "Invalid method call: -cleanup: can't be executed on abstract RESTService instance!", userInfo: nil).raise()
    }
    
    public func cancel(_ task: URLSessionTask) {
        NSException(name: NSExceptionName(rawValue: "InvalidSelectorException"), reason: "Invalid method call: -cancel: can't be executed on abstract RESTService instance!", userInfo: nil).raise()
    }
    
}
