//
//  TestClient.swift
//  CoreClientTests
//
//  Created by Mayur on 10/10/17.
//  Copyright © 2017 Odocon. All rights reserved.
//

import Foundation
@testable import CoreClient

class TestClient: Client {
    
    override init(aClientConfiguration: ClientConfiguration?, theCallbackQueue: AnyObject?) {
        super.init(aClientConfiguration: aClientConfiguration, theCallbackQueue: theCallbackQueue)
        
        if (clientConfiguration?.credentialStore == nil) {
            //Use the default credential storage provider implementation which is based on Keychain.
            credentialStore = KeychainManager.init(theSharedAccessGroupID: "")
        }

        let serviceConfiguration = ServiceConfiguration.init()
        serviceConfiguration.allowsSelfSignedServerCertificates = false
        serviceConfiguration.shallAttachRunLoop = false
        //Makes sure that the service has a valid URL if the app is re-launched & has the PIN set to it previously.
        if clientConfiguration?.serverURL == nil {
            serviceConfiguration.baseURL = URL.init(string: "http://203.122.58.147/Nominatim-2.4.0/website/reverse.php?format=json&lat=18.508673&lon=73.822659&zoom=18&addressdetails=1&accept-language=en")
        }
        serviceConfiguration.callbackQueue = serviceDelegateQueue
        service = TestService.init(theServiceConfiguration: serviceConfiguration)
        service?.delegate = self
    }
    
    
    func getLocationInfo() -> ClientTask? {
        let getPlaceOperation: GetPlaceOperation = GetPlaceOperation.init(theService: service as! TestService)
        let getPlaceTask: ClientTask = ClientTask.init(operation: getPlaceOperation)
        getPlaceTask.taskType = ClientTaskType.webOpData
        getPlaceTask.setClient(self)
        getPlaceOperation.wrapperTask = getPlaceTask
        return getPlaceTask
    }

}
