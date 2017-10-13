//
//  ClientDataDelegate.swift
//  CoreClient
//
//  Created by Mayur on 03/10/17.
//  Copyright © 2017 Odocon. All rights reserved.
//

import Foundation

/**
 This protocol lays down the contract for the delegate of Client.
 Whenever a given Client operation is finished, the delegate method - @didProvideData is invoked by passing to it:
 @clientResponse - a valid, non-nil response corresponding to a given Client operation (if no error is encountered)
 @clientError - if an error is encountered while performing a given Client operation, this contains a valid, non-nil Error object
 */
public protocol ClientDataDelegate {
    func clientDidProvideResponseWithError(_ clientResponse: AnyObject?, clientError: Error?)
}

extension ClientDataDelegate {
    public func clientDidProvideResponseWithError(_ clientResponse: AnyObject?, clientError: Error?) {
        //Default implementation does nothing
    }
}
