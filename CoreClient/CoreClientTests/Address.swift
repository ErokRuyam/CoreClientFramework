//
//  Address.swift
//  CoreClientTests
//
//  Created by Mayur on 10/10/17.
//  Copyright © 2017 Odocon. All rights reserved.
//

import Foundation
@testable import CoreClient

struct Address {
    var road : String?
    var suburb : String?
    var city : String?
    var county : String?
    var state_district : String?
    var state : String?
    var postcode : String?
    var country : String?
    var country_code : String?
}

extension Address: JSONDecodable {
    static func decode(json: JSON) -> Address? {
        return Address(
            road: json <| "road",
            suburb: json <| "suburb",
            city: json <| "city",
            county: json <| "country",
            state_district: json <| "state_district",
            state: json <| "state",
            postcode: json <| "postcode",
            country: json <| "country",
            country_code: json <| "country_code")
    }
}
