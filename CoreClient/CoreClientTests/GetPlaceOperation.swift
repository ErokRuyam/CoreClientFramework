//
//  TestOperation.swift
//  CoreClientTests
//
//  Created by Mayur on 10/10/17.
//  Copyright © 2017 Odocon. All rights reserved.
//

import Foundation
import XCTest
@testable import CoreClient

class GetPlaceOperation: WebOperation {
    
    var getPlaceTask: URLSessionTask? = nil
    
    init(theService: TestService) {
        super.init(theService: theService)
    }
    
    override func main() {
        super.main()
        
        getPlaceTask = (service as? TestService)?.getPlaceWithErrorHandler(errorHandler: { (error: NSError?) in
            self.client?.clientTaskDidFinishWithResult(self.wrapperTask, data: nil, error: error)
        })
        getPlaceTask?.taskDescription = operationID
        getPlaceTask?.resume()
    }
    
    override func processResponse(_ data: AnyObject?, error: Error?, callbackQueue: AnyObject?) {
        if data != nil && error == nil {
            print("data : \(String(describing: data)) \n \(String(describing: error))")
            do {
                let json = try JSONSerialization.jsonObject(with: data as! Data, options: JSONSerialization.ReadingOptions.mutableContainers) as JSON
                print("\(json)")
                let locationDetails = json >>> LocationDetails.decode
                print("\(String(describing: locationDetails))")
                Utils.compareLocationDetails(locationDetails: locationDetails, json: json)
                client?.clientTaskDidFinishWithResult(wrapperTask, data: locationDetails as AnyObject, error: nil)
            } catch {
                
            }
        }
    }
}
