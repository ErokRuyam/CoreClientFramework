//
//  WebOperation.swift
//  CoreClient
//
//  Created by Mayur on 03/10/17.
//  Copyright © 2017 Odocon. All rights reserved.
//

import Foundation

public protocol WebOperationProtocol {
    /*
     Prepare the input needed for the given web service request from the internal state of the object.
     For example, in case of JSON based REST service, this method can return a JSON data or if it's SOAP based service,
     this method can return the SOAP XML envelope containing header & body.
     */
    func prepareRequest()
    
    /*
     Process the response received from the web service. For REST based service, the data to be processed can be a JSON Object/string
     whereas, in case of SOAP, the response to be processed may be SOAP XML envelope.
     @param data - the data received from the web service
     @param error - if a valid response is received, then error is NIL.
     //TODO: Probably, this method needs to have a non-void return type; generally this shall process the input JSON/XML etc.
     & come up with an appropriate domain/model object corresponding to the end point.
     */
    func processResponse(_ data: AnyObject?, error: Error?, callbackQueue: AnyObject?)
    
    /*
     Process the progress update as received from the Web Service.
     @param progressDictionary - the dictionary is specific to the concrete implementation of a particular web operation.
     */
    func processProgressUpdate(_ progressDictionary: NSDictionary?)
}


/**
 The abstract subclass of Operation encapsulates the web service request to be performed and the corresponding response to be
 processed.
 
 Each concrete subclass shall take care of:
 - invocation of a web service operation
 - response receveived as a result of performing web service operation
 The class doesn't assume any semantics of the web service like - whether it's REST endpoint or SOAP message/method call.
 The particular subclass shall handle these semantics & prepare the appropriate request or process the corresponding response.
 */
open class WebOperation: CoreOperation, WebOperationProtocol {
    /*
     The ivar is kept as weak intentionally: the framework is based on the fact that there's a client that abstracts the
     web service implementation from it's consumer. Internally, it creates & holds onto a single Service object.
     The Client achieves it's functionality by using service, tasks, operations etc.
     Because Client holds a service instance for it's lifetime, the operations are not needed to hold the strong reference of the same.
     */
    public var service: Service
    
    /*
     Uniquely identifies the web service request - be it REST endpoint or SOAP method.
     The reason it's type is kept as NSUInteger rather than VRMServiceRequestID is because - this is frameork level abstract class.
     We shall not presume that this can be only used in the context of VRMC app or endpoints specific to it.
     An implementor (which can choose to implement all the protocols & semantics of the framework from the grounds up) of
     the framework may choose to define different enum for it's specific endpoints.
     */
    public init(theService: Service) {
        service = theService
        super.init()
    }
    
    open func prepareRequest() {
        NSException(name: NSExceptionName(rawValue: "InvalidSelectorException"), reason: "Invalid method call: -prepareRequest: can't be executed on abstract WebOperation instance!", userInfo: nil).raise()
    }
    
    open func processResponse(_ data: AnyObject?, error: Error?, callbackQueue: AnyObject?) {
        NSException(name: NSExceptionName(rawValue: "InvalidSelectorException"), reason: "Invalid method call: -processResponse:error: can't be executed on abstract WebOperation instance!", userInfo: nil).raise()
    }
    
    open func processProgressUpdate(_ progressDictionary: NSDictionary?) {
        client!.clientTaskHasProgressUpdate(wrapperTask, progressDictionary: progressDictionary, error: nil)
    }
}

