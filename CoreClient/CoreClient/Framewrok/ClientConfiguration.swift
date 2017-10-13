//
//  ClientConfiguration.swift
//  CoreClient
//
//  Created by Mayur on 03/10/17.
//  Copyright © 2017 Odocon. All rights reserved.
//

import Foundation

/**
 It's totally possible to plug in the implementations for the Persistent Store Provider, Credential Store Provider, Service etc. into the
 "default" Client implementation using this configuration class. For it to be achieved, the class needs to contain the fields/ivars
 for the particular providers.
 
 NOTE: The plug-in/provider architecture makes sense only in the context of default implementation of Client (more precisely
 it's version specific variants.)
 Else, the consumer of the framework is free to implement the functionality from scratch by adhering to essential protocols of
 the framework viz. ServiceProtocol, ServiceDelegate, ClientProtocol.
 
 CAUTION:
 !!!!!  !!!!!  !!!!!  !!!!!  !!!!!  !!!!!  !!!!!  !!!!!  !!!!!  !!!!!  !!!!!  !!!!!  !!!!!  !!!!!  !!!!!  !!!!!
 - There's a possibility or risk of not able to identify which part needs to be pluggable & which need not be.
 Here DB/PersistentProvider, CredentialStoreProvider fit the plug-in case as they help provide the option to the
 consumer of the Client class to define ways in which data or credentials shall be persisted.
 
 - For all such providers, the Client & framework provides the default implementation as well.
 
 - But there are cases when we need to assess the feasibilty of adopting the plug-in/provider architecture.
 For e.g. does it make sense to have a API version specific persistence or DB operations provider?
 *Seems NO* because, what to do with domain objects is all together upto the specific Client implementation and framework can't
 impose a certain behaviour.
 But in case of API version specific Service Provider, it's okay to adopt the provider/plug-in architecture because
 we are imposing the Web Service Requests or Endpoints that must be supported by certain API version of Service Provider.
 Even in this case, there are less chances that consumer will choose to implement only a specific version of Service Protocol
 & rest of the functionality from the default implementation.
 
 ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ====
 Most of the times, Client framework will be used in following ways:
 - the default client implementation along with the default implementation of the DB, Service & Security
 - a user will prefer to provide implementations of DataPersistenceProvider,CredentialStoreProvider, Version Specific
 Service Provider to default implementation
 - design & implement the Client from grounds-up & hence is free to implent it whatever way it suits.
 */
open class ClientConfiguration {
    ///Service implementation
    public var service: ServiceProtocol?
    ///Credentials store implementation
    public var credentialStore: CredentialStoreProvider?
    ///Persistent store implementation
    public var persistentStore: PersistentStoreProvider?
    
    public var serverURL: String?
}
