//
//  LocationDetails.swift
//  CoreClientTests
//
//  Created by Mayur on 10/10/17.
//  Copyright © 2017 Odocon. All rights reserved.
//

import Foundation
@testable import CoreClient

struct LocationDetails {
    var place_id : String?
    var licence : String?
    var osm_type : String?
    var osm_id : String?
    var lat : String?
    var lon : String?
    var display_name : String?
    var address : Address?
    
    init(place_id : String?, licence : String?, osm_type : String?, osm_id : String?, lat : String?, lon : String?, display_name : String?, address : Address?) {
        self.place_id = place_id
        self.licence = licence
        self.osm_type = osm_type
        self.osm_id = osm_id
        self.lat = lat
        self.lon = lon
        self.display_name = display_name
        self.address = address
    }
}

extension LocationDetails: JSONDecodable {
    static func decode(json: JSON) -> LocationDetails? {
        return LocationDetails(
            place_id: json <| "place_id",
            licence: json <| "licence",
            osm_type: json <| "osm_type",
            osm_id: json <| "osm_id",
            lat: json <| "lat",
            lon: json <| "lon",
            display_name: json <| "display_name",
            address: (json <| "address" >>> Address.decode)!)
    }
}
