//
//  ServiceConfiguration.swift
//  CoreClient
//
//  Created by Mayur on 03/10/17.
//  Copyright © 2017 Odocon. All rights reserved.
//

import Foundation

open class ServiceConfiguration {
    public var baseURL: URL?
    //Needs to be an instance of either dispatch queue or NSOperationQueue.
    public var callbackQueue: OperationQueue?
    //Disabled by default; so default value is NO
    public var allowsSelfSignedServerCertificates: Bool = false
    //Disabled by default; so default value is NO
    public var shallAttachRunLoop: Bool = false
    
    init() {
        allowsSelfSignedServerCertificates = false
        shallAttachRunLoop = false
    }
}
