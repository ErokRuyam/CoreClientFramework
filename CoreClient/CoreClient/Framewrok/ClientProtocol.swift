//
//  ClientProtocol.swift
//  CoreClient
//
//  Created by Mayur on 03/10/17.
//  Copyright © 2017 Odocon. All rights reserved.
//

import Foundation

/**
 The protocol lays down the basic contract for implementing the client functionality.
 'Client' is a generic term & it's generally a facade. The Client facade abstracts the tasks like:
 - Performing Web Service calls, handling the response and returning the domain specific objects to it's consumer.
 - Do the housekeeping operations like - updating the data/metadata locally. Client may or may not use the local DB;
 it depends upon the needs of the specific client.
 - Manage the security aspects of the application
 - Taking care of concurrency or thread pool managment in case it handles the tasks concurrently.
 
 The Client might internally use the helper or other infrastructure compoents like - Service, Security Manager, DB Manager etc.
 to meet it's objective.
 
 The client is constructed by providing it an appropriate ClientConfiguration instance.
 */
public protocol ClientProtocol {
    //Only possible to provide config at the time of init. Can't alter it later. So, read only.
    var clientConfiguration: ClientConfiguration? { get set }
    
    /**
     For a given domain name, this method finds out the list of IP addresses where the server identified by the
     given domain name is running/hosted.
     @domainName - the domain name for which to find out the list of IP addresses.
     @completionHandler - the completion handler block to execute; can be nil.
     */
    func lookupDomainWithServiceMethod(_ domainName: String?, serviceMethod: Selector?) -> ClientTask?
    
    /**
     Before making any meaningful API calls to the server (including login), client will need to do a handshake with server.
     By doing handshake, the client will come to know about the API versions supported by the server. The server, in it's response
     also sends the appropriate prefix to be appended for inoking versioned endpoints. The client shall settle down with the API version
     based on following guidelines:
     1. If the client is shipped with the highest API version amongst the list of versions returned by the server, then it shall be used.
     2. If the client is shipped with the most recent API version but server doesn't publish it in it's supported list, then the highest
     version of server shall be used.
     3. If by some mechanism or customer specific deployment scenarios, it happens that the server has most recent API version but client
     is not shipped with it, then client shall use it's highest version.
     4. In short, if we take the intersection of- list of API versions published by server & ones supported by client, from this intersection,
     always use the highest version numbe.
     @serverURL The URL of the server with which the client is supposed to make an API handshake, negotiate and, settle down with an
     approrpriate API version for further web service calls.
     @completionHandler - the completion handler block to execute; can be nil.
     */
    func doAPIHandshakeWithServiceMethod(_ serviceMethod: Selector?) -> ClientTask?
    
    /**
     Upon receiving this message, the Client instance shall immediately stop all it's pending tasks & clear it's internal state.
     */
    func cleanup()
    
    func cleanupQueue()
    
    /**
     The ClientTask & it's implementations shall make sure that they call this Client method to convey that they
     are done with the operation.Client can then send back the results to the consumer and update it's internal
     list of tasks etc.
     */
    func clientTaskDidFinishWithResult(_ clientTask: ClientTask?, data: AnyObject?, error: Error?)
    
    func clientTaskHasProgressUpdate(_ clientTask: ClientTask?, progressDictionary: NSDictionary?, error: Error?)
    
    /**
     It executes the completion handlers, secondary completion handlers and progress handlers of a task passed without checking the
     presence of it in task queue.
     It is useful mainly when instance of current client is replaced with the new instance and we need to execute the handlers of previous
     client.
     */
    func clientTaskFinishCompletionHandlerWithResult(_ clientTask: ClientTask?, data: AnyObject?, error: Error?)
}

extension ClientProtocol {
    public func clientTaskDidFinishWithResult(_ clientTask: ClientTask?, data: AnyObject?, error: Error?) {
        //Default implementation does nothing
    }
    
    public func clientTaskHasProgressUpdate(_ clientTask: ClientTask?, progressDictionary: NSDictionary?, error: Error?) {
        //Default implementation does nothing
    }
    
    public func clientTaskFinishCompletionHandlerWithResult(_ clientTask: ClientTask?, data: AnyObject?, error: Error?) {
        //Default implementation does nothing
    }
}
