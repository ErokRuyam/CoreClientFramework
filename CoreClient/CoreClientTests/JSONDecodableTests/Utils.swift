//
//  Utils.swift
//  LiteJSONConvertible
//
//  Created by Andrea Prearo on 4/5/16.
//  Copyright © 2016 Andrea Prearo
//

import Foundation
import CoreClient
import XCTest

class Utils {
    
    class func loadJsonFrom(baseFileName: String) throws -> AnyObject? {
        var responseDict: AnyObject?
        if let fileURL = Bundle(for: self).url(forResource: baseFileName, withExtension: "json") {
            if let jsonData = NSData(contentsOf: fileURL) {
                responseDict = try! JSONSerialization.jsonObject(with: jsonData as Data, options: .allowFragments) as AnyObject
            }
        }
        return responseDict
    }
    
    class func loadJsonData(data: NSData) throws -> AnyObject? {
        return try! JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as AnyObject
    }
    
    class func comparePhone(phones: [Phone?]?, json: [JSON]?) {
        if let phones = phones,
            let json = json {
                for i in 0 ..< phones.count {
                    let json = json[i]
                    if let phone = phones[i] {
                        if let label = phone.label {
                            XCTAssertEqual(label, json <| "label")
                        } else {
                            XCTAssertNil(json <| "label")
                        }
                        if let number = phone.number {
                            XCTAssertEqual(number, json <| "number")
                        } else {
                            XCTAssertNil(json <| "number")
                        }
                    } else {
                        XCTFail("Phone comparison failed")
                    }
                }
        } else {
            XCTFail("Phone parsing failed")
        }
    }
    
    class func compareEmail(emails: [Email?]?, json: [JSON]?) {
        if let emails = emails,
            let json = json {
                for i in 0 ..< emails.count {
                    let json = json[i]
                    if let email = emails[i] {
                        if let label = email.label {
                            XCTAssertEqual(label, json <| "label")
                        } else {
                            XCTAssertNil(json <| "label")
                        }
                        if let address = email.address {
                            XCTAssertEqual(address, json <| "address")
                        } else {
                            XCTAssertNil(json <| "address")
                        }
                    } else {
                        XCTFail("Email comparison failed")
                    }
                }
        } else {
            XCTFail("Email parsing failed")
        }
    }
    
    class func compareLocation(locations: [Location?]?, json: [JSON]?) {
        if let locations = locations,
            let json = json {
                for i in 0 ..< locations.count {
                    let json = json[i]
                    if let location = locations[i] {
                        if let label = location.label {
                            XCTAssertEqual(label, json <| "label")
                        } else {
                            XCTAssertNil(json <| "label")
                        }
                        if let data = location.data {
                            compareLocationData(locationData: data, json: json <| "data")
                        } else {
                            XCTAssertNil(json <| "data")
                        }
                    } else {
                        XCTFail("Location comparison failed")
                    }
                }
        } else {
            XCTFail("Location parsing failed")
        }
    }
    
    class func compareLocationData(locationData: LocationData?, json: JSON?) {
        if let locationData = locationData,
            let json = json {
                if let address = locationData.address {
                    XCTAssertEqual(address, json <| "address")
                } else {
                    XCTAssertNil(json <| "address")
                }
                if let city = locationData.city {
                    XCTAssertEqual(city, json <| "city")
                } else {
                    XCTAssertNil(json <| "city")
                }
                if let state = locationData.state {
                    XCTAssertEqual(state, json <| "state")
                } else {
                    XCTAssertNil(json <| "state")
                }
                if let country = locationData.country {
                    XCTAssertEqual(country, json <| "country")
                } else {
                    XCTAssertNil(json <| "country")
                }
        } else {
            XCTFail("LocationData comparison failed")
        }
    }

    class func compareLocationDetails(locationDetails: LocationDetails?, json: JSON?) {
        if let locationDetails = locationDetails,
            let json = json {
            if let address = locationDetails.address {
                compareAddress(address: address, json: json <| "address")
            } else {
                XCTAssertNil(json <| "address")
            }
            if let licence = locationDetails.licence {
                XCTAssertEqual(licence, json <| "licence")
            } else {
                XCTAssertNil(json <| "licence")
            }
            if let osm_type = locationDetails.osm_type {
                XCTAssertEqual(osm_type, json <| "osm_type")
            } else {
                XCTAssertNil(json <| "osm_type")
            }
            if let osm_id = locationDetails.osm_id {
                XCTAssertEqual(osm_id, json <| "osm_id")
            } else {
                XCTAssertNil(json <| "osm_id")
            }
            if let place_id = locationDetails.place_id {
                XCTAssertEqual(place_id, json <| "place_id")
            } else {
                XCTAssertNil(json <| "place_id")
            }

        } else {
            XCTFail("LocationDetails comparison failed")
        }
    }

    class func compareAddress(address: Address?, json: JSON?) {
        if let address = address,
            let json = json {
            if let city = address.city {
                XCTAssertEqual(city, json <| "city")
            } else {
                XCTAssertNil(json <| "city")
            }
            if let state = address.state {
                XCTAssertEqual(state, json <| "state")
            } else {
                XCTAssertNil(json <| "state")
            }
            if let country = address.country {
                XCTAssertEqual(country, json <| "country")
            } else {
                XCTAssertNil(json <| "country")
            }
        } else {
            XCTFail("Address comparison failed")
        }
    }

}
