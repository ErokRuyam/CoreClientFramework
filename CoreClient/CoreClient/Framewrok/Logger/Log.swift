//
//  Log.swift
//  Logger
//
//  Created by Mayur on 29/09/17.
//  Copyright © 2017 Mayur. All rights reserved.
//

import Foundation
import UIKit

let CSHD = "_cshd"
let Empty = ""

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

typealias LoggerCompletionHandler = (_ result: AnyObject?, _ error:  NSError?) -> Void

/**
   returns function Starts string
 
 
   - Parameter functionName: Name for the function to log its starts.
*/
public func functionStarts(_ functionName: String) -> String {
    return "======= \(functionName) Starts ======="
}

/**
    returns function Ends string
 
 
     - Parameter functionName: Name for the function to log its ends.
 */
public func functionEnds(_ functionName: String) -> String {
    return "======= \(functionName) Ends ======="
}

/** returns files last path component from given fileName. You can pass **#file**.
*/
public func fileComponent(_ fileName: String) -> String {
    return (fileName as NSString).lastPathComponent
}

func registerUncaughtExceptionHandler() {
    NSSetUncaughtExceptionHandler(uncaughtExceptionHandler)
    signal(SIGABRT, signalHandler)
    signal(SIGILL, signalHandler)
    signal(SIGSEGV, signalHandler)
    signal(SIGFPE, signalHandler)
    signal(SIGBUS, signalHandler)
    signal(SIGPIPE, signalHandler)
}

func signalHandler(signal: Int32) {
    let messageString1 = "Log _SOS_  \n=========\n" + UIDevice.current.name + "\n"
    let messageString2 = messageString1 + UIDevice.current.model + "\n" + UIDevice.current.systemName + "\n"
    let messageString = messageString2 + UIDevice.current.systemVersion + "\n" + (UIDevice.current.identifierForVendor?.uuidString)! + "\n"
    Log.sharedInstance.logError(fileComponent(#file), message: messageString + "\n\(signal) \n \(Thread.callStackSymbols)")
    UserDefaults.standard.setValue(NSNumber.init(value: true), forKey: CSHD)
    UserDefaults.standard.synchronize()
    exit(signal)
}

func uncaughtExceptionHandler(exception : NSException) {
    let messageString1 = "Log _SOS_  \n=========\n" + UIDevice.current.name + "\n"
    let messageString2 = messageString1 + UIDevice.current.model + "\n" + UIDevice.current.systemName + "\n"
    let messageString = messageString2 + UIDevice.current.systemVersion + "\n" + (UIDevice.current.identifierForVendor?.uuidString)! + "\n"
    Log.sharedInstance.logError(fileComponent(#file), message: messageString + "\n\(exception) \n\(exception.callStackSymbols)")
    UserDefaults.standard.setValue(NSNumber.init(value: true), forKey: CSHD)
    UserDefaults.standard.synchronize()
}


public class Log {
    /** Creates the singleton instance for class Log.
     */
    public static let sharedInstance = Log()
    
    /** Log Level
     ````
     case error
     case warning
     case info
     case debug
     ````
     */
    public enum Level : Int {
        ///Something has failed.
        case error = 0
        
        ///Something is amiss and might fail if not corrected.
        case warning
        
        ///Generally, logged in production but shall be used judiciously as too much logs can affect the performance.
        case info
        
        ///The lowest priority, and normally not logged in production.
        case debug
    }

    fileprivate var logConfiguration: LogConfiguration? = nil
    fileprivate var loggerDispatchQueue: DispatchQueue? = nil
    fileprivate var outputStream: OutputStream? = nil //File output stream to write the log file.
    fileprivate var currentLogFilepath: String? = nil
    fileprivate var logDirectoryZipFilepath: String? = nil
    fileprivate var dateFormatter: DateFormatter? = nil

    fileprivate let LGLogFileExtension = ".log"

    fileprivate let LGSerialDispatchQueueID = "com.mayur.Logger.Logger.SerialQueue"
    
    /**
         Creates the Log instance and registers for uncaught exceptions if any found in future.
     
     
         - parameter loggerConfig: Instance of LogConfiguration. Uses it properties to create log files.
     */
    public func initializeWithConfiguration(_ loggerConfig: LogConfiguration) {
        loggerDispatchQueue = DispatchQueue(label: LGSerialDispatchQueueID)
        logConfiguration = loggerConfig
        dateFormatter = DateFormatter.init()
        dateFormatter?.dateFormat = logConfiguration?.logMessageDateFormat != nil ? logConfiguration!.logMessageDateFormat : LCLogMessageDateFormat
        let logFilePath: String = ((logConfiguration!.logDirectory as NSString).appendingPathComponent(logConfiguration!.logFilename + LGLogFileExtension))
        
        if FileManager.default.fileExists(atPath: logFilePath) != true {
            FileManager.default.createFile(atPath: logFilePath, contents: nil, attributes: nil)
        }
        currentLogFilepath = logFilePath
        
        registerUncaughtExceptionHandler()
    }
    
    //MARK: Log methods, log file rotation, log message formatter methods.
    /**
         Logs the message at Error level and above.

     
         - Parameter component: Name of the File/Class/Function to Log.
         - Parameter message: Message to log.
     */
    public func logError(_ component: String, message: String) {
        if logConfiguration?.logLevel.rawValue < Level.error.rawValue {
            return
        }
        log(component, message: message, logLevel: Level.error)
    }
    
    /**
         Logs the message at Warning level and above.
     
     
         - Parameter component: Name of the File/Class/Function to Log.
         - Parameter message: Message to log.
     */
    public func logWarning(_ component: String, message: String) {
        if logConfiguration?.logLevel.rawValue < Level.warning.rawValue {
            return
        }
        log(component, message: message, logLevel: Level.warning)
    }
    
    /**
         Logs the message at Info level and above.
     
     
         - Parameter component: Name of the File/Class/Function to Log.
         - Parameter message: Message to log.
     */
    public func logInfo(_ component: String, message: String) {
        if logConfiguration?.logLevel.rawValue < Level.info.rawValue {
            return
        }
        log(component, message: message, logLevel: Level.info)
    }
    
    /**
         Logs the message at Debug level and above.
     
     
         - Parameter component: Name of the File/Class/Function to Log.
         - Parameter message: Message to log.
     */
    public func logDebug(_ component: String, message: String) {
        if logConfiguration?.logLevel.rawValue < Level.debug.rawValue {
            return
        }
        log(component, message: message, logLevel: Level.debug)
    }
    
    /**
         Logs the component at Debug levels and above.
     
         
         - Parameter component: Name of the File/Class/Function to Log.
     */
    public func logFunction(_ component: String) {
        if logConfiguration?.logLevel.rawValue < Level.debug.rawValue {
            return
        }
        log(component, message: "", logLevel: Level.debug)
    }
    
    func log(_ component: String, message: String, logLevel: Level) {
        autoreleasepool {
            let logMessage: String = formattedLogMessage(component, message: message, logLevel: logLevel)
            if logConfiguration?.logLevel == Level.debug {
                print(String(format: "Log: %@", logMessage))
            }
            self.writeData(logMessage.data(using: String.Encoding.utf8)!)
        }
    }
    
    func formattedLogMessage(_ componentName: String, message: String, logLevel: Level) -> String {
        var logLevelString: String = Empty
        switch logLevel {
        case .debug:
            logLevelString = "DEBUG"
        case .info:
            logLevelString = "INFO"
        case .warning:
            logLevelString = "WARNING"
        case .error:
            logLevelString = "ERROR"
        }
        
        let dateString = (dateFormatter?.string(from: Date()))!
        var logMessage = Empty
        if message != Empty {
            logMessage = String(format: "[%@] %@ %@: %@\n", logLevelString, dateString, componentName, message)
        } else {
            logMessage = String(format: "[%@] %@ %@\n", logLevelString, dateString, componentName)
        }
        
        return logMessage
    }

    func writeData(_ data: Data) {
        loggerDispatchQueue!.async {
            autoreleasepool(invoking: { () in
                do {
                    let fileAttributes = try FileManager.default.attributesOfItem(atPath: self.currentLogFilepath!)
                    let fileSize = fileAttributes[FileAttributeKey.size] as? Int
                    if fileSize >= self.logConfiguration?.logFileSize {
                        //If file size exceeded the log file size limit then create another log file.
                        self.rotateLogFile()
                    }
                    self.outputStream = OutputStream.init(toFileAtPath: self.currentLogFilepath!, append: true)
                    self.outputStream?.open()
                    self.outputStream?.write((data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count), maxLength: data.count)
                } catch {
                    print("Log: Exception while writing file \(error)")
                    self.logError(fileComponent(#file), message: "\(error)")
                }
                defer {
                    self.outputStream?.close()
                    self.outputStream = nil
                }
            })
        }
    }
    
    func rotateLogFile() {
        let currentFilePath = (logConfiguration!.logDirectory as NSString).appendingPathComponent(((logConfiguration?.logFilename)! + LGLogFileExtension))
        do {
            let dirContents: NSArray = try FileManager.default.contentsOfDirectory(at: URL.init(fileURLWithPath: (logConfiguration?.logDirectory)!), includingPropertiesForKeys: [URLResourceKey.contentModificationDateKey], options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles) as NSArray

            let sortedDirContents = dirContents.sorted {
                do {
                    let values1 = try ($0 as? URL)?.resourceValues(forKeys: [.creationDateKey, .contentModificationDateKey])
                    let values2 = try ($1 as? URL)?.resourceValues(forKeys: [.creationDateKey, .contentModificationDateKey])
                    
                    //          if let date1 = values1.creationDate, let date2 = values2.creationDate {
                    if let date1 = values1?.contentModificationDate, let date2 = values2?.contentModificationDate {
                        return date1.compare(date2) == ComparisonResult.orderedAscending
                    }
                } catch _{
                    //Log.sharedInstance.logError(fileComponent(#file), message: "Error: \(error)")
                }
                
                return true
            } as NSArray
            
            if sortedDirContents.count == self.logConfiguration?.rotationCount {
                do{
                    try FileManager.default.removeItem(atPath: (sortedDirContents.object(at: 0) as! URL).path)
                } catch {
                    Log.sharedInstance.logError(fileComponent(#file), message: "Error: \(error)")
                }
            }
            let dateString: String = (dateFormatter?.string(from: Date()))!
            let newFileName = String(format: "%@_%@%@", (logConfiguration?.logFilename)!, dateString, self.LGLogFileExtension)
            
            let sourceUrl: URL = URL(fileURLWithPath: currentFilePath)
            let destinationUrl: URL = (sourceUrl.deletingLastPathComponent().appendingPathComponent(newFileName, isDirectory: false))
            
            var writtingError: NSError? = nil
            
            let coordinator = NSFileCoordinator.init(filePresenter: nil)
            coordinator.coordinate(writingItemAt: sourceUrl, options: NSFileCoordinator.WritingOptions.forMoving, writingItemAt: destinationUrl, options: NSFileCoordinator.WritingOptions.forReplacing, error: &writtingError, byAccessor: { (newURL1: URL, newURL2: URL) in
                let fileManager = FileManager.default
                coordinator .item(at: sourceUrl, willMoveTo: destinationUrl)
                do {
                    try fileManager.moveItem(at: newURL1, to: newURL2)
                    coordinator.item(at: newURL1, didMoveTo: newURL2)
                } catch {
                    Log.sharedInstance.logError(fileComponent(#file), message: "Error: \(error)")
                }
            })
        } catch {
            Log.sharedInstance.logError(fileComponent(#file), message: "Error: \(error)")
        }
    }
    
    ///Checks for app crash status and returns true/false.
    public func appDidCrashLastTime() -> Bool {
        let value = UserDefaults.standard.value(forKey: CSHD)
        if let didCrash = value {
            return didCrash as! Bool
        }
        return false
    }

    ///To clear the app crash flag if any crash happenes earlier.
    public func clearCrashFlag() {
        UserDefaults.standard.removeObject(forKey: CSHD)
    }
    
    //MARK: Getting the log zip file or directory.
    ///Returns path for the logs directory.
    public func getLogDirectory() -> String {
//        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//        let documentDirectory = paths[0]
//        let logsDirectory = (documentDirectory as NSString).appendingPathComponent((self.logConfiguration?.logDirectory)!)
        return (self.logConfiguration?.logDirectory)!
    }
    
//    func getLogDirectoryZipFile(_ completionHandler: @escaping LoggerCompletionHandler) {
//        loggerDispatchQueue!.async {
//            let dateString = self.dateFormatter?.string(from: Date())
//            var zipFilename: String? = nil
//            if self.appDidCrashLastTime() {
//                zipFilename = String(format: "%@-iOS-Crash-Log-%@.zip", Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String, dateString!)
//            } else {
//                zipFilename = String(format: "%@-iOS-Debug-Log-%@.zip", Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String, dateString!)
//            }
//            self.logDirectoryZipFilepath = (self.logConfiguration!.zipFileDirectory as NSString).appendingPathComponent(zipFilename!)
//            let zipCreated: Bool = ZipArchive.createZipFile(atPath: self.logDirectoryZipFilepath, withContentsOfDirectory: self.logConfiguration?.logDirectory, keepParentDirectory: true)
//            print("Zip File Created: \(zipCreated)")
//            DispatchQueue.main.async(execute: {
//                completionHandler(self.logDirectoryZipFilepath as AnyObject?, nil)
//            })
//        }
//    }
//
//    func removeLogDirectoryZipFile() {
//        do {
//            try FileManager.default.removeItem(atPath: self.logDirectoryZipFilepath!)
//        } catch {
//            self.logDirectoryZipFilepath = nil
//            Log.sharedInstance.logError(fileComponent(#file), message: "Error: \(error)")
//        }
//    }
}
