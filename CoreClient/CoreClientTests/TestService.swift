//
//  TestService.swift
//  CoreClientTests
//
//  Created by Mayur on 10/10/17.
//  Copyright © 2017 Odocon. All rights reserved.
//

import Foundation
@testable import CoreClient

class TestService: RESTService {

    func getPlaceWithErrorHandler(errorHandler: ErrorHandler?) -> URLSessionDataTask? {
        let getPlaceURL: URL = serviceConfiguration.baseURL!
        
        let request: NSMutableURLRequest = NSMutableURLRequest.init(url: getPlaceURL)
        request.httpShouldHandleCookies = false
        request.httpMethod = CoreServiceConstants.CSCHTTPHeaderMethodGet
        request.setValue(CoreServiceConstants.CSCHTTPHeaderContentTypeJson, forHTTPHeaderField: CoreServiceConstants.CSCHTTPHeaderContentType)
        let status = prepareRequest(request, errorHandler:errorHandler)
        if !status {
            return nil
        }
        
        let getPlaceTask: URLSessionDataTask = (defaultSession?.dataTask(with: request as URLRequest))!
        let taskDictionary: NSMutableDictionary = NSMutableDictionary.init()
        taskDictionary[CoreServiceConstants.CSCServiceResponseData] = NSMutableData.init()
        taskDictionary[CoreServiceConstants.CSCServiceRequestIDKey] = NSNumber.init(value: 0)
        wTaskTable?.setObject(taskDictionary, forKey: getPlaceTask)
        return getPlaceTask
    }

}

