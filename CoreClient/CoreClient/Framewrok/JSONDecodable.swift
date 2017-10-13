//
//  JSONDecodable.swift
//  JSONDecoder
//
//  Created by Mayur on 07/10/17.
//  Copyright © 2017 Mayur. All rights reserved.
//

import Foundation

// Functional operators code from:
// http://nshipster.com/swift-operators/
// https://www.raywenderlich.com/157556/overloading-custom-operators-swift
// https://robots.thoughtbot.com/efficient-json-in-swift-with-functional-concepts-and-generics

precedencegroup ComparisonPrecedence {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
}

infix operator >>> : ComparisonPrecedence // Swift version of bind (>>=)

public func >>><T,U>(t: T?, f: (T) -> U?) -> U? {
    if let x = t {
        return f(x)
    } else {
        return .none
    }
}

public typealias JSON = AnyObject

public func JSONParse<T,U>(object: T) -> U? {
    return object as? U
}

public func JSONArray(object: JSON) -> [JSON]? {
    return object as? [JSON]
}

// Decoding Operators
// https://robots.thoughtbot.com/real-world-json-parsing-with-swift

infix operator <| : ComparisonPrecedence
infix operator <|| : ComparisonPrecedence

public func <|<T>(json: JSON, key: String) -> T? {
    return json[key] >>> JSONParse
}

public func <||<T>(json: JSON, key: String) -> [T]? {
    return json <| key
}


public protocol JSONDecodable {
    associatedtype DecodableType
    static func decode(json: JSON) -> DecodableType?
    static func decode(json: JSON?) -> DecodableType?
    static func decode(json: [JSON]) -> [DecodableType?]
    static func decode(json: [JSON]?) -> [DecodableType?]
}

public extension JSONDecodable {
    static func decode(json: JSON?) -> DecodableType? {
        guard let json = json else { return nil }
        return decode(json: json)
    }
    static func decode(json: [JSON]) -> [DecodableType?] {
        return json.map(decode)
    }
    static func decode(json: [JSON]?) -> [DecodableType?] {
        guard let json = json else { return [] }
        return decode(json: json)
    }
}

extension String: JSONDecodable {
    public static func decode(json: JSON) -> String? {
        return json >>> JSONParse
    }
}

extension Bool: JSONDecodable {
    public static func decode(json: JSON) -> Bool? {
        return json >>> JSONParse
    }
}

extension Int: JSONDecodable {
    public static func decode(json: JSON) -> Int? {
        return json >>> JSONParse
    }
}

extension Float: JSONDecodable {
    public static func decode(json: JSON) -> Float? {
        return json >>> JSONParse
    }
}

extension Double: JSONDecodable {
    public static func decode(json: JSON) -> Double? {
        return json >>> JSONParse
    }
}

