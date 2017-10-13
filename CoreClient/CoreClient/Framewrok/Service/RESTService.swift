//
//  RESTService.swift
//  CoreClient
//
//  Created by Mayur on 09/10/17.
//  Copyright © 2017 Odocon. All rights reserved.
//

import Foundation

open class RESTService : Service, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, URLSessionDownloadDelegate {
    public var defaultSession: URLSession?
    public var backgroundSession: URLSession?
    public var wTaskTable: NSMapTable<URLSessionTask, AnyObject>?
    public var serviceError: NSError?
    
    required public init(theServiceConfiguration: ServiceConfiguration) {
        super.init(theServiceConfiguration: theServiceConfiguration)
        let defaultSessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default
        /*
         If needed, set the following params:
         cookie accept policy: HTTPCookieAcceptPolicy to - NSHTTPCookieAcceptPolicyAlways
         should set cookies: HTTPShouldSetCookies to - YES
         */
        defaultSession = Foundation.URLSession.init(configuration: defaultSessionConfiguration, delegate: self, delegateQueue: serviceConfiguration.callbackQueue)
        wTaskTable = NSMapTable<URLSessionTask, AnyObject>.weakToStrongObjects()
    }
    
    public func prepareRequest(_ request: NSMutableURLRequest?, errorHandler: ErrorHandler?) -> Bool {
        if !(delegate?.serviceCanProceed())! {
            if let errorHndlr = errorHandler {
                let error = NSError.init(domain: ServiceConstants.SCServiceDomain, code: 0, userInfo: nil)
                errorHndlr(error)
            }
            return false
        }

        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        request?.timeoutInterval = TimeInterval(ServiceConstants.SCDefaultRequestTimeInterval)
        isFinished = false
        return true
    }
    
    //MARK:- URLSessionDelegate methods
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print("session error: \(String(describing: error?.localizedDescription)).")
    }
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        //Trust the self signed server certificate for SSL/TLS.
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) && serviceConfiguration.allowsSelfSignedServerCertificates {
            print("SSL/TLS handshake: Self signed certificate detected!")
            
            /*
             TODO: It's possible to indicate this event to the end user by propagating it to the Client.
             Also, check the possibility to add the exeception to the trust store or set the the self signed certitficate as
             the anchor certificate(because it's self signed, server itself is CA & chain starts and ends at same certificate) and
             add it to trust store.
             Refer: https://developer.apple.com/library/ios/technotes/tn2232/_index.html#//apple_ref/doc/uid/DTS40012884-CH1-SECNSURLSESSION
             */
            let serverTrustCredential: URLCredential? = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, serverTrustCredential);
        }
        completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        //NOP
    }

    //MARK:- URLSessionTaskDelegate methods
    //Always called irrespective of the task is Data task, Download task or Upload task.
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        do {
            Log.sharedInstance.logInfo(fileComponent(#file), message: "Task did complete with error:\(error.debugDescription) & \nresponse:\((task.response).debugDescription)")
            
            let taskDictionary = wTaskTable?.object(forKey: task)
            
            let tempFilepath = taskDictionary!.value(forKey: ServiceConstants.SCServiceTemporaryFilePathKey)
            if tempFilepath != nil {
                try FileManager.default.removeItem(atPath: tempFilepath as! String)
            }
            
            let responseData: NSMutableData? = taskDictionary!.value(forKey: ServiceConstants.SCServiceResponseData) as? NSMutableData
            
            Log.sharedInstance.logDebug(fileComponent(#file), message: "Received data = \((String.init(data: responseData! as Data, encoding:String.Encoding.utf8)).debugDescription)")
            
            if taskDictionary!.object(forKey: "error") != nil {
                let error = taskDictionary!.object(forKey: "error") as? Error
                delegate?.serviceDidReceiveResponseForRequest(self, data: nil, error: error, uniqueRequestIdentifier: task.taskDescription)
            } else if error != nil {
                //Form the Error from URLSession error using ErrorHandler.
                if (error! as NSError).code != NSURLErrorCancelled {
                    delegate?.serviceDidReceiveResponseForRequest(self, data: nil, error: error, uniqueRequestIdentifier: task.taskDescription)
                }
            } else {
                delegate?.serviceDidReceiveResponseForRequest(self, data: responseData, error: nil, uniqueRequestIdentifier: task.taskDescription)
            }
            //This is an end of Session request flow; so good place to remove the task related data from the task table.
            wTaskTable?.removeObject(forKey: task)
        } catch {
            Log.sharedInstance.logError(fileComponent(#file), message: "Error: \(error)")
        }
    }
    
    //MARK:- URLSessionDataDelegate methods
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        Log.sharedInstance.logDebug(fileComponent(#file), message: "Session received first response! \(response)")
        
        //It is necessary to call completionHandler, otherwise request will not progress one way or the other.
        completionHandler(Foundation.URLSession.ResponseDisposition.allow)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        //This means the status code is non 200; so we need to retrieve the error response in the form of JSON.
        let taskDictionary = wTaskTable?.object(forKey: dataTask)
        let responseData = taskDictionary?.value(forKey: ServiceConstants.SCServiceResponseData) as? NSMutableData
        if (dataTask.response as? HTTPURLResponse)?.statusCode != 200 {
            dataTask.cancel()
            return
        } else if responseData != nil {
            responseData!.append(data as Data)
            Log.sharedInstance.logDebug(fileComponent(#file), message: "Received data = \((String.init(data: responseData! as Data, encoding: String.Encoding.utf8)).debugDescription)")
        }
    }
    
    //MARK:- URLSessionDownloadDelegate methods
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if downloadTask.state == URLSessionTask.State.canceling {
            return
        }
        
        let _totalBytesExpectedToWrite = totalBytesExpectedToWrite
        
        //Check if the http response from the download task contains the http header with content disposition.
        let taskDictionary = wTaskTable?.object(forKey: downloadTask)
        let progressDictionary: NSMutableDictionary? = taskDictionary!.object(forKey: ServiceConstants.SCServiceProgressDictionaryKey) as? NSMutableDictionary
        var filename: NSString? = taskDictionary!.value(forKey: ClientFrameworkCommons.ClientTaskFilename) as? NSString
        if filename != nil {
            //This means the filename hasn't been populated yet; this is the 1st progress callback.
            //So, add it to the task dict.
            let response: HTTPURLResponse? = downloadTask.response as? HTTPURLResponse
            Log.sharedInstance.logError(fileComponent(#file), message: "[[Download Task did write data: response:\(response!)]]")
            
            filename = getFilenameFrom(string: (response!.allHeaderFields as NSDictionary).value(forKey: ServiceConstants.SCHTTPHeaderContentDisposition) as? String) as NSString?
            if filename != nil {
                filename = filename!.removingPercentEncoding as NSString?
                Log.sharedInstance.logError(fileComponent(#file), message: "[[Download Task did write data: filename:\(filename!)]]")
                (taskDictionary as! NSMutableDictionary)[ClientFrameworkCommons.ClientTaskFilename] = filename!
                progressDictionary?[ClientFrameworkCommons.ClientTaskFilename] = filename!
            } else {
                Log.sharedInstance.logError(fileComponent(#file), message: "Content-Disposition/Filename is missing!!!")
                Log.sharedInstance.logError(fileComponent(#file), message: "Erroneous Response:\(downloadTask.response!)")
            }
        }
        
        Log.sharedInstance.logDebug(fileComponent(#file), message: "Download Task did write data: bytesWritten:\(bytesWritten), totalBytesWritten:\(totalBytesWritten), totalBytesExpectedToWrite:\(_totalBytesExpectedToWrite)")
        
        progressDictionary?[ClientFrameworkCommons.ClientTaskCurrentBytesCount] = NSNumber.init(value: bytesWritten)
        progressDictionary?[ClientFrameworkCommons.ClientTaskCurrentProgressValue] = NSNumber.init(value: totalBytesWritten)
        progressDictionary?[ClientFrameworkCommons.ClientTaskMaxProgressValue] = NSNumber.init(value: _totalBytesExpectedToWrite)
        delegate?.serviceDidTransferDataForRequest(self, progressDictionary: progressDictionary, uniqueRequestIdentifier: downloadTask.taskDescription)
    }
    
    @available(iOS 7.0, *)
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        Log.sharedInstance.logDebug(fileComponent(#file), message: "Download task finished downloading file to URL:\(location)")
        
        let response: HTTPURLResponse? = downloadTask.response as? HTTPURLResponse
        Log.sharedInstance.logInfo(fileComponent(#file), message: "File download task finished with status:\(response!.statusCode)")
        
        let taskDictionary = wTaskTable?.object(forKey: downloadTask)
        var filename: NSString? = taskDictionary!.value(forKey: ClientFrameworkCommons.ClientTaskFilename) as? NSString
        if filename == nil {
            filename = getFilenameFrom(string: (response!.allHeaderFields as NSDictionary).value(forKey: ServiceConstants.SCHTTPHeaderContentDisposition) as? String) as NSString?
        }
        if filename == nil {
            Log.sharedInstance.logError(fileComponent(#file), message: "Content-Disposition/Filename is missing!!!")
            Log.sharedInstance.logError(fileComponent(#file), message: "Erroneous Response:\(downloadTask.response!)")
            let error: NSError = NSError.init(domain: ServiceConstants.SCServiceDomain, code: 1, userInfo: ["ErrorMessage" : "Proper filename not found. Seems like something is wrong."])
            (taskDictionary as! NSMutableDictionary)["error"] = error
            return
        }
        
        let localURL: NSURL? = taskDictionary!.object(forKey: ServiceConstants.SCServiceLocalFileURLKey) as? NSURL
        let localFilepath: String? = localURL!.path
        
        Log.sharedInstance.logDebug(fileComponent(#file), message: "Local filepath with filename received in the response:\(localFilepath.debugDescription)")
        do {
            if FileManager.default.fileExists(atPath: localFilepath!) {
                //If the file with same name already exists, then delete it as we want to overwrite it.
                try FileManager.default.removeItem(atPath: localFilepath!)
            }
            
            try FileManager.default.moveItem(atPath: location.path, toPath:localFilepath!)
            (taskDictionary as! NSMutableDictionary)[ServiceConstants.SCServiceLocalFileURLKey] = NSURL.fileURL(withPath: localFilepath!)
        } catch {
            Log.sharedInstance.logError(fileComponent(#file), message: "Error: \(error)")
        }
    }
    
    //MARK:- URLSessionUploadDelegate methods
    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let taskDictionary = wTaskTable?.object(forKey: task)
        if taskDictionary != nil {
            let progressDictionary: NSMutableDictionary? = taskDictionary!.object(forKey: ServiceConstants.SCServiceProgressDictionaryKey) as? NSMutableDictionary
            if progressDictionary != nil {
                Log.sharedInstance.logDebug(fileComponent(#file), message: "Upload Task did send data: bytesSent:\(bytesSent), totalBytesSent:\(totalBytesSent), totalBytesExpectedToSend:\(totalBytesExpectedToSend)")
                //progressDictionary?[ClientFrameworkCommons.ClientTaskFilename] = ""
                progressDictionary?[ClientFrameworkCommons.ClientTaskCurrentBytesCount] = NSNumber.init(value: bytesSent)
                progressDictionary?[ClientFrameworkCommons.ClientTaskCurrentProgressValue] = NSNumber.init(value: totalBytesSent)
                progressDictionary?[ClientFrameworkCommons.ClientTaskMaxProgressValue] = NSNumber.init(value: totalBytesExpectedToSend)
                delegate?.serviceDidTransferDataForRequest(self, progressDictionary: progressDictionary, uniqueRequestIdentifier: task.taskDescription)
            }
        }
    }
    
    func getFilenameFrom(string: String?) -> String? {
        if let _string: String = string {
            let fileNameString: NSString = _string as NSString
            let startRange: NSRange = fileNameString.range(of: ServiceConstants.SCContentDispositionFileName)
            if startRange.location != NSNotFound && startRange.length != NSNotFound {
                let filenameStart = startRange.location + startRange.length
                let endRange: NSRange = fileNameString.range(of: " ", options: NSString.CompareOptions.literal, range: NSMakeRange(filenameStart, (_string as NSString).length - filenameStart), locale: nil)
                var filenameLength = 0
                if endRange.location != NSNotFound && endRange.length != NSNotFound {
                    filenameLength = endRange.location - filenameStart
                } else {
                    filenameLength = fileNameString.length - filenameStart
                }
                return fileNameString.substring(with: NSMakeRange(filenameStart, filenameLength))
            }
        }
        return nil
    }
    
    //Override the method to avoid calling cleanup of abstract class i.e. Service which throws exception
    override public func cleanup() {
        for task in (wTaskTable?.keyEnumerator())! {
            (task as? URLSessionTask)?.cancel()
        }
    }

    override public func cancel(_ task: URLSessionTask) {
        
    }

}

