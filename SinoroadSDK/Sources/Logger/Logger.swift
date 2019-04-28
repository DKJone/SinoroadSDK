//
//  Logger.swift
//  Logger
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import Foundation

/// alias for `Logger`
public typealias Log = Logger

/// 日志工具
public final class Logger {
    /// version string of framework
    public static let version = "0.0.1" // UPDATE ON RELEASE!
    /// build number of framework
    public static let build = 1 // version 0.0.1 -> 1, UPDATE ON RELEASE!
    
    // a set of active destinations
    private(set) public static var destinations = [BaseDestination]()
    
    // MARK: - Destination Handling
    
    /// returns boolean about success
    @discardableResult
    public static func addDestination(_ destination: BaseDestination) -> Bool {
        if destinations.contains(destination) {
            return false
        }
        destinations.append(destination)
        return true
    }
    
    /// returns boolean about success
    @discardableResult
    public static func removeDestination(_ destination: BaseDestination) -> Bool {
        guard let index = destinations.index(where: { $0 == destination }) else {
            return false
        }
        destinations.remove(at: index)
        return true
    }
    
    /// if you need to start fresh
    public static func removeAllDestinations() {
        destinations.removeAll()
    }
    
    /// returns the amount of destinations
    public static func countDestinations() -> Int {
        return destinations.count
    }
    
    /// returns the current thread name
    static func threadName() -> String {
        if Thread.isMainThread {
            return "main"
        } else {
            if let threadName = Thread.current.name, !threadName.isEmpty {
                return threadName
            } else {
                return String(format: "%p", Thread.current)
            }
        }
    }
    
    // MARK: - Levels
    
    /// log something generally unimportant (lowest priority)
    public static func verbose(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, line: Int = #line) {
        custom(level: .verbose, message: message(), file: file, function: function, line: line)
    }
    
    /// log something which help during debugging (low priority)
    public static func debug(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, line: Int = #line) {
        custom(level: .debug, message: message(), file: file, function: function, line: line)
    }
    
    /// log something which you are really interested but which is not an issue or error (normal priority)
    public static func info(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, line: Int = #line) {
        custom(level: .info, message: message(), file: file, function: function, line: line)
    }
    
    /// log something which may cause big trouble soon (high priority)
    public static func warning(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, line: Int = #line) {
        custom(level: .warning, message: message(), file: file, function: function, line: line)
    }
    
    /// log something which will keep you awake at night (highest priority)
    public static func error(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, line: Int = #line) {
        custom(level: .error, message: message(), file: file, function: function, line: line)
    }
    
    /// custom logging to manually adjust values, should just be used by other frameworks
    public static func custom(level: LogLevel, message: @autoclosure () -> Any, file: String = #file, function: String = #function, line: Int = #line) {
        dispatch_send(level: level, message: message(), thread: threadName(), file: file, function: function, line: line)
    }
    
    /// internal helper which dispatches send to dedicated queue if minLevel is ok
    static func dispatch_send(level: LogLevel, message: @autoclosure () -> Any, thread: String, file: String, function: String, line: Int) {
        var resolvedMessage: String?
        
        for dest in destinations {
            guard let queue = dest.queue else {
                continue
            }
            
            resolvedMessage = resolvedMessage == nil && dest.hasMessageFilters() ? "\(message())" : nil
            if dest.shouldLevelBeLogged(level, path: file, function: function, message: resolvedMessage) {
                // try to convert msg object to String and put it on queue
                let msgStr = resolvedMessage == nil ? "\(message())" : resolvedMessage!
                let f = stripParams(function: function)
                
                if dest.asynchronously {
                    queue.async {
                        _ = dest.send(level, msg: msgStr, thread: thread, file: file, function: f, line: line)
                    }
                } else {
                    queue.sync {
                        _ = dest.send(level, msg: msgStr, thread: thread, file: file, function: f, line: line)
                    }
                }
            }
        }
    }
    
    /// removes the parameters from a function because it looks weird with a single param
    class func stripParams(function: String) -> String {
        var f = function
        if let indexOfBrace = f.firstIndex(of: "(") {
            f = String(f[..<indexOfBrace])
        }
        f += "()"
        return f
    }
}
