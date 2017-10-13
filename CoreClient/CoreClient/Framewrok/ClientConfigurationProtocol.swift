//
//  ClientConfigurationProtocol.swift
//  CoreClient
//
//  Created by Mayur on 03/10/17.
//  Copyright © 2017 Odocon. All rights reserved.
//

import Foundation

public enum ClientConfigurationEvent: Int {
    case sandboxWipe = 0
    case userLogout
    case apiVersionStatus
}

/**
 This protocol specifies a contract for the delegate to get informed when the client configuration changes.
 Any component interested in receiving client configuration changes events shall implement this protocol & register itself
 with DataStore.
 
 The events are:
 - The user/device is blocked/wiped/purged and as such, user's data in sandbox needs to be wiped out.
 - user logs out.
 - The API versions list received from server during periodic mobility call has one or more higher version(s) available and
 as such, need to upgrate to newer API version suite OR though exceptional/infrequent, the older API version than current one
 is available and as such need to fallback to an older API suite.
 
 **** Note that the delegate methods will always be invoked on main thread. ****
 */
public protocol ClientConfigurationDelegate {
    func clientDidDiscoverClientConfigurationEventWithEventObject(_ clientConfigurationEvent: ClientConfigurationEvent, eventObject: AnyObject?)
}
