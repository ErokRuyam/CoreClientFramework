//
//  ServiceTests.swift
//  CoreClientTests
//
//  Created by Mayur on 10/10/17.
//  Copyright © 2017 Odocon. All rights reserved.
//

import XCTest
@testable import CoreClient

class ServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let serviceConfig = ServiceConfiguration.init()
        serviceConfig.baseURL = URL.init(string: "http://203.122.58.147/Nominatim-2.4.0/website/reverse.php?format=json&lat=\(18.508673))&lon=\(73.822659))&zoom=18&addressdetails=1&accept-language=en")
        serviceConfig.callbackQueue = nil
        let service = RESTService.init(theServiceConfiguration: serviceConfig)
        
        let clientConfig = ClientConfiguration.init()
        clientConfig.credentialStore = KeychainManager.init(theSharedAccessGroupID: "")
        clientConfig.persistentStore = SQLiteManager.init()
        clientConfig.service = service
        
        let client = Client.init(aClientConfiguration: clientConfig)
        
        service.delegate = client
        let addressesOperation: WebOperation = WebOperation.init(theService: service as Service)
        let addressTask: ClientTask = ClientTask.init(operation: addressesOperation)
        addressTask.taskType = ClientTaskType.webOpData
        addressesOperation.wrapperTask = addressTask
        
        addressTask.executeWithCompletionHandler { (result, error) in
            print("Result = \(String(describing: result)), \n Error = \(String(describing: error))")
        }

        let addressURL: URL = (serviceConfig.baseURL!.appendingPathComponent(""))
        Log.sharedInstance.logInfo(fileComponent(#file), message: "API Settings URL:\(addressURL)")
        
        let request: NSMutableURLRequest = NSMutableURLRequest.init(url: addressURL)
        request.httpShouldHandleCookies = false
        request.httpMethod = ServiceConstants.SCHTTPHeaderMethodGet
        request.setValue(ServiceConstants.SCHTTPHeaderContentTypeJson, forHTTPHeaderField: ServiceConstants.SCHTTPHeaderContentType)
        let status = service.prepareRequest(request, errorHandler:nil)
        if status {
            let addressServiceTask: URLSessionDataTask = (service.defaultSession?.dataTask(with: request as URLRequest))!
            let taskDictionary: NSMutableDictionary = NSMutableDictionary.init()
            taskDictionary[ServiceConstants.SCServiceResponseData] = NSMutableData.init()
            taskDictionary[ServiceConstants.SCServiceRequestIDKey] = NSNumber.init(value: 1)
            service.wTaskTable?.setObject(taskDictionary, forKey: addressServiceTask)
            
            addressServiceTask.taskDescription = addressesOperation.operationID
            addressServiceTask.resume()
        }
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
