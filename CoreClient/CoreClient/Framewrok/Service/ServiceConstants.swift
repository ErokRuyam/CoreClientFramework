//
//  ServiceConstants.swift
//  CoreClient
//
//  Created by Mayur on 09/10/17.
//  Copyright © 2017 Odocon. All rights reserved.
//

import Foundation

public struct ServiceConstants {
    
    //Keys to be used in service layer.
    public static let SCServiceDomain = "ServiceDomain"
    
    public static let SCServiceRequestIDKey = "ServiceRequestID"
    public static let SCServiceProgressDictionaryKey = "ServiceProgressDictionary"
    public static let SCServiceFilenameKey = "ServiceFilename"
    public static let SCServiceLocalFileURLKey = "localFileURL"
    public static let SCServiceFileInPathKey = "fileInPath"
    public static let SCServiceTemporaryFilePathKey = "tempFilePath"
    public static let SCServiceFileKey = "file"
    
    public static let SCServiceResponseData = "ServiceResponseData"

    public static let SCHTTP = "http"
    public static let SCHTTPS = "https"
    
    public static let SCHTTPSEnabled = true
    
    public static let SCURLSeparator = "/"
    
    //HTTP header constants
    public static let SCHTTPHeaderMethodGet = "GET"
    public static let SCHTTPHeaderMethodPost = "POST"
    public static let SCHTTPHeaderContentType = "Content-Type"
    public static let SCHTTPHeaderUserAgent = "User-Agent"
    public static let SCHTTPHeaderCookie = "Cookie"
    public static let SCHTTPHeaderContentDisposition = "Content-Disposition"
    public static let SCContentDispositionFileName = "filename*=UTF-8''"
    public static let SCHTTPHeaderContentDispositionFormData = "form-data"
    public static let SCHTTPHeaderContentTypeValueUrlEncoded = "application/x-www-form-urlencoded"
    public static let SCHTTPHeaderContentTypeJson = "application/json"
    public static let SCHTTPHeaderContentTypeMultipartFormData = "multipart/form-data"
    public static let SCHTTPName = "name"
    public static let SCHTTPType = "type"
    public static let SCHTTPMultipartBoundary = "boundary"
    public static let SCContentLength = "Content-Length"
    
    //Miscellaneous constants
    public static let SCHttpQueryStringSeparator = "?"
    public static let SCHttpQueryParamSeparator = "&"
    public static let SCHttpQueryParamKeyValueSeparator = "="
    
    
    /*** The time intervals for various endpoints or operations ***/
    public static let SCDefaultRequestTimeInterval = 30

}
