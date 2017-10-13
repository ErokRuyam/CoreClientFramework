//
//  ServiceProtocol.swift
//  CoreClient
//
//  Created by Mayur on 03/10/17.
//  Copyright © 2017 Odocon. All rights reserved.
//

import Foundation

/**
 The delegate specifies the methods that need to be implemented by the class interested in receving response related callbacks from the
 concrete instances of the ServiceProtocol.
 
 The delegate methods provide the response and/or error received from the service as well as the progress update for operations
 like, say- upload/download.
 */
public protocol ServiceDelegate {
    /**
     Asks the delegate if the service can proceed with the given request. This method gives chance to
     the delegate to check scenarios like - exceeding the auto-wipe time fence.
     */
    func serviceCanProceed() -> Bool
    
    func serviceShallUseAuthInfo() -> Bool
    
    func serviceAuthInfo() -> AnyObject?
    
    ///Informs the delegate that the response was received by the Service.
    func serviceDidReceiveResponseForRequest(_ service: ServiceProtocol, data: AnyObject?, error: Error?, uniqueRequestIdentifier: String?)
    
    /**
     This method informs the delegate of the service about the number of bytes uploaded or donwloaded so far over the network.
     This is particulary handy to show/inform about the progress of the large data uploads/downloads.
     */
    func serviceDidTransferDataForRequest(_ service: ServiceProtocol, progressDictionary: NSDictionary?, uniqueRequestIdentifier: String?)
}

/**
 The protocol lays down the contract for the class that needs to provide the implementation of the Web Service.
 
 No assumptions are made regarding the semantics or nature of the web service or it's internal implementation.
 The service might be a REST one or SOAP based (it's variants like XML/RPC, Message passing etc.); it might be using cookie
 based session semantics or signing the API requests using OAuth. All these are implementation details and it's upto the
 concrete subclasses to handle these.
 
 The framework provides the abstract implmentation of the protocol with Service class; inheritors can either start providing
 specific implementations based on this class or if one wants to write a class from grounds up, then it needs to implement this protocol.
 */
public protocol ServiceProtocol {
    var delegate: ServiceDelegate? {get set }
    
    ///Only possible to provide config at the time of init. Can't alter it later. So, read only.
    var serviceConfiguration: ServiceConfiguration { get set }
    
    func performRequest(_ request: URLRequest)
    
    /**
     Upon receiving this message, the Service instance shall immediately stop all the ongoing & pending requests followed by
     clearing of it's internal state.
     */
    func cleanup()
    
    func cancel(_ task: URLSessionTask)
}
