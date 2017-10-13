//
//  LogConfiguration.swift
//  Logger
//
//  Created by Mayur on 29/09/17.
//  Copyright © 2017 Mayur. All rights reserved.
//

import Foundation

let LCLogMessageDateFormat: String = "yyyy-MM-dd hh:mm:ss a"
let LCLogFileDefaultName = "AppLogFile"
let LCLogFileDefaultDirectoryName = "AppLogs"
//For now it is 4MB.
let LGDefaultLogFileSizeLimit = 4194304
let LGDefaultLogFileRotateCount = 5
let LGDefaultLogFileMaxRotateCount = 20

/**
     Configuration class which is required in initializer of Log class.
*/
public class LogConfiguration {
    var logDirectory: String
    var logFilename: String
    var logMessageDateFormat: String
    var logLevel: Log.Level
    var logFileSize: Int
    var rotationCount: Int
    
    /**
         This Initializes the LogConfinguration which is useful in creating shared instance of Log class.
     
     
         - Parameter logDirectory: Directory path where you want to keep your log files. If not specified then default directory is DocumentDirectory/AppLogs.
         - Parameter logFilename: Name for the log file. If not specified default name is **AppLogFile**.
         - Parameter logMessageDateFormat: Date format for the prefix to the every log message.
         - Parameter logLevel: Levels of the logs you want to write in log file. Like Error, Warning, Info and Debug (by Defualt).
         - Parameter logFileSize: file size for each log file. Default is 4194304.(4 MB)
         - Parameter logFileRotateCount: File rotation is supported by default and files count is 5. Max rotaion files supported is 20. You can specify how many you wnat to rotate. After total rotation files fullfilled with logs then first file gets deleted and new file generated on his place. :)
    */
    public init(logDirectory: String?, logFilename: String?, logMessageDateFormat: String?, logLevel: Log.Level?, logFileSize: Int?, logFileRotateCount: Int?) {
        if let logDir = logDirectory {
            self.logDirectory = logDir
        } else {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let logDir = documentsDirectory.appendingPathComponent(LCLogFileDefaultDirectoryName).path
            do {
                try FileManager.default.createDirectory(atPath: logDir, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                print("Error creating directory: \(error.localizedDescription)")
            }
            self.logDirectory  = logDir
        }
        
        if let fileName = logFilename {
            self.logFilename = fileName
        } else {
            self.logFilename = LCLogFileDefaultName
        }
        
        if let dateFormat = logMessageDateFormat {
            self.logMessageDateFormat = dateFormat
        } else {
            self.logMessageDateFormat = LCLogMessageDateFormat
        }
        
        if let ll = logLevel {
            self.logLevel = ll
        } else {
            self.logLevel = Log.Level.debug
        }
        
        if let fileSize = logFileSize {
            self.logFileSize = fileSize
        } else {
            self.logFileSize = LGDefaultLogFileSizeLimit
        }
        
        if let rotationCount = logFileRotateCount {
            if rotationCount < LGDefaultLogFileMaxRotateCount {
                self.rotationCount = rotationCount
            } else {
                self.rotationCount = LGDefaultLogFileMaxRotateCount
            }
        } else {
            self.rotationCount = LGDefaultLogFileRotateCount
        }
    }
}
