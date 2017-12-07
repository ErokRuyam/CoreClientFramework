//
//  ServiceConstants.swift
//  CoreClient
//
//  Created by Mayur on 09/10/17.
//  Copyright © 2017 Odocon. All rights reserved.
//

import Foundation

public struct CoreServiceConstants {
    
    //Keys to be used in service layer.
    public static let CSCServiceDomain = "ServiceDomain"
    
    public static let CSCServiceRequestIDKey = "ServiceRequestID"
    public static let CSCServiceProgressDictionaryKey = "ServiceProgressDictionary"
    public static let CSCServiceFilenameKey = "ServiceFilename"
    public static let CSCServiceLocalFileURLKey = "localFileURL"
    public static let CSCServiceFileInPathKey = "fileInPath"
    public static let CSCServiceTemporaryFilePathKey = "tempFilePath"
    public static let CSCServiceFileKey = "file"
    
    public static let CSCServiceResponseData = "ServiceResponseData"

    public static let CSCHTTP = "http"
    public static let CSCHTTPS = "https"
    
    public static let CSCHTTPSEnabled = true
    
    public static let CSCURLSeparator = "/"
    
    //HTTP header constants
    public static let CSCHTTPHeaderMethodGet = "GET"
    public static let CSCHTTPHeaderMethodPost = "POST"
    public static let CSCHTTPHeaderMethodPut = "PUT"
    public static let CSCHTTPHeaderMethodDelete = "DELETE"
    public static let CSCHTTPHeaderContentType = "Content-Type"
    public static let CSCHTTPHeaderUserAgent = "User-Agent"
    public static let CSCHTTPHeaderCookie = "Cookie"
    public static let CSCHTTPHeaderContentDisposition = "Content-Disposition"
    public static let CSCContentDispositionFileName = "filename*=UTF-8''"
    public static let CSCHTTPHeaderContentDispositionFormData = "form-data"
    public static let CSCHTTPHeaderContentTypeValueUrlEncoded = "application/x-www-form-urlencoded"
    public static let CSCHTTPHeaderContentTypeJson = "application/json"
    public static let CSCHTTPHeaderContentTypeMultipartFormData = "multipart/form-data"
    public static let CSCHTTPName = "name"
    public static let CSCHTTPType = "type"
    public static let CSCHTTPMultipartBoundary = "boundary"
    public static let CSCContentLength = "Content-Length"
    
    public static let CSCHTTPHeaderAuthorization = "Authorization"

    //Miscellaneous constants
    public static let CSCHttpQueryStringSeparator = "?"
    public static let CSCHttpQueryParamSeparator = "&"
    public static let CSCHttpQueryParamKeyValueSeparator = "="
    
    
    /*** The time intervals for various endpoints or operations ***/
    public static let CSCDefaultRequestTimeInterval = 30

}
