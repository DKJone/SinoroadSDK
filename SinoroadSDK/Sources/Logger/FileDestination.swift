//
//  FileDestination.swift
//  Logger
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import Foundation

/// 用于文件日志输出
public class FileDestination: BaseDestination {
    /// The default filename is *logger.log* and it is stored in the app’s Caches Directory.
    ///
    /// During development it is recommended to change that logfileURL to `/tmp/logger.log`
    /// so that the file can be tailed by a Terminal app using the CLI command **tail -f /tmp/logger.log**.
    public var logFileURL: URL?
    
    let fileManager = FileManager.default
    var fileHandle: FileHandle?
    
    public override init() {
        // iOS, watchOS, etc. are using the caches directory
        if let baseURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            logFileURL = baseURL.appendingPathComponent("logger.log", isDirectory: false)
        }
        super.init()
    }
    
    // append to file. uses full base class functionality
    public override func send(_ level: LogLevel, msg: String, thread: String, file: String, function: String, line: Int) -> String {
        let formattedString = super.send(level, msg: msg, thread: thread, file: file, function: function, line: line)
        
        _ = saveToFile(str: formattedString)
        
        return formattedString
    }
    
    deinit {
        // close file handle if set
        fileHandle?.closeFile()
    }
    
    /// appends a string as line to a file.
    /// returns boolean about success
    func saveToFile(str: String) -> Bool {
        guard let url = logFileURL else { return false }
        
        do {
            if !fileManager.fileExists(atPath: url.path) {
                // create file if not existing
                let line = str + "\n"
                try line.write(to: url, atomically: true, encoding: .utf8)
            } else {
                // append to end of file
                if fileHandle == nil {
                    // initial setting of file handle
                    fileHandle = try FileHandle(forWritingTo: url as URL)
                }
                
                fileHandle!.seekToEndOfFile()
                let line = str + "\n"
                if let data = line.data(using: .utf8) {
                    fileHandle!.write(data)
                }
            }
            return true
        } catch {
            print("Logger File Destination could not write to file \(url).")
            return false
        }
    }
    
    /// deletes log file.
    /// returns true if file was removed or does not exist, false otherwise
    public func deleteLogFile() -> Bool {
        guard let url = logFileURL, fileManager.fileExists(atPath: url.path) else { return true }
        do {
            try fileManager.removeItem(at: url)
            fileHandle = nil
            return true
        } catch {
            print("SwiftyBeaver File Destination could not remove file \(url).")
            return false
        }
    }
}
