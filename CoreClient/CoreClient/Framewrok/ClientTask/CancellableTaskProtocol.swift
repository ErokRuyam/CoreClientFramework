//
//  CancellableTaskProtocol.swift
//  CoreClient
//
//  Created by Mayur on 03/10/17.
//  Copyright © 2017 Odocon. All rights reserved.
//

import Foundation

/**
     If the subclass of Task needs to provide the functionality to cancel a scheduled/submitted task, then
     it needs to conform to this protocol by implementing the -cancel() method.
 */
public protocol CancellableTaskProtocol {
    func cancel()
}

extension CancellableTaskProtocol {
    func cancel() {
        // Default implementation does nothing
    }
}
