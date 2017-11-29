//
//  Destination.swift
//  Logger
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import Foundation

/// 日志等级
public enum LogLevel: Int {
    case verbose
    case debug
    case info
    case warning
    case error
}

/// 日志输出端
public protocol Destination: class {
    
    /// Customize the log format output.
    var format: String { get set }
    
    /// Runs on own serial background thread for better performance. Set to false during development for easier debugging.
    var asynchronously: Bool { get set }
    
    /// Any level with a priority lower than that level is not logged.
    var minLevel: LogLevel { get set }
    
    /// Send / store the formatted log message to the destination.
    ///
    /// - Parameters:
    ///   - level: Log Level
    ///   - msg: message
    ///   - thread: thread
    ///   - file: source file
    ///   - function: function
    ///   - line: line number
    /// - Returns: formated message
    func send(_ level: LogLevel, msg: String, thread: String, file: String, function: String, line: Int) -> String
}

/// 基类，负责提供相应功能的默认实现
open class BaseDestination: Destination {
    
    /// Customize the log format output, on default it shows every detail:
    ///
    /// **$DHH:mm:ss.SSS$d $L $N.$F:$l - $M**
    ///
    /// - **$D** - Datetime, followed by standard Swift datetime syntax
    /// - **$d** - Datetime format end
    /// - **$L** - Level, for example "VERBOSE"
    /// - **$N** - Name of file without suffix
    /// - **$n** - Name of file with suffix
    /// - **$F** - Function
    /// - **$l** - Line (lower-case l)
    /// - **$T** - Thread
    /// - **$M** - Message, for example the foo in log.debug("foo")
    open var format = "$DHH:mm:ss.SSS$d $L $N.$F:$l - $M"
    
    /// Runs on own serial background thread for better performance. Set to false during development for easier debugging.
    ///
    /// Default true.
    open var asynchronously = true
    
    /// Any level with a priority lower than that level is not logged.
    ///
    /// Default `LogLevel.verbose`.
    open var minLevel = LogLevel.verbose
    
    // Each destination instance must have an own serial queue to ensure serial output
    // GCD gives it a prioritization between `userInitiated` and `utility`.
    var queue: DispatchQueue?
    
    var filters = [FilterType]()
    
    // used to format datetime
    let formatter = DateFormatter()
    
    public init() {
        let queueLabel = "logger-queue-" + NSUUID().uuidString
        queue = DispatchQueue(label: queueLabel, target: queue)
    }
    
    open func send(_ level: LogLevel, msg: String, thread: String, file: String, function: String, line: Int) -> String {
        return formatMessage(format, level: level, msg: msg, thread: thread, file: file, function: function, line: line)
    }
    
    // MARK: - Format
    
    /// Returns the log message based on the format pattern.
    func formatMessage(_ format: String, level: LogLevel, msg: String, thread: String, file: String, function: String, line: Int) -> String {
        var text = ""
        let phrases = format.components(separatedBy: "$")
        
        for phrase in phrases where !phrase.isEmpty {
            let firstChar = phrase[phrase.startIndex]
            let rangeAfterFirstChar = phrase.index(phrase.startIndex, offsetBy: 1)..<phrase.endIndex
            let remainingPhrase = phrase[rangeAfterFirstChar]
            
            switch firstChar {
            case "L": // log level
                text += levelWord(level) + remainingPhrase
            case "M": // message
                text += msg + remainingPhrase
            case "T": // thread
                text += thread + remainingPhrase
            case "N": // name of file without suffix
                text += fileNameWithoutSuffix(file) + remainingPhrase
            case "n": // name of file with suffix
                text += fileNameOfFile(file) + remainingPhrase
            case "F": // function name
                text += function + remainingPhrase
            case "l": // code line
                text += String(line) + remainingPhrase
            case "D": // start of datetime format
                text += formatDate(String(remainingPhrase))
            case "d": // end of datetime format
                text += remainingPhrase
            case "Z": // start of datetime format in UTC timezone
                text += formatDate(String(remainingPhrase), timeZone: "UTC")
            case "z": // end of datetime format in UTC timezone
                text += remainingPhrase
            default:
                text += phrase
            }
        }
        return text
    }
    
    /// Returns the string of a level.
    func levelWord(_ level: LogLevel) -> String {
        switch level {
        case .verbose:
            return "VERBOSE"
        case .debug:
            return "DEBUG"
        case .info:
            return "INFO"
        case .warning:
            return "WARNING"
        case .error:
            return "ERROR"
        }
    }
    
    /// Returns the filename of a path.
    func fileNameOfFile(_ file: String) -> String {
        return file.components(separatedBy: "/").last!
    }
    
    /// Returns the filename without suffix (= file ending) of a path.
    func fileNameWithoutSuffix(_ file: String) -> String {
        return fileNameOfFile(file).components(separatedBy: ".").first!
    }
    
    /// Returns a formatted date string and optionally in a given abbreviated timezone like "UTC".
    func formatDate(_ dateFormat: String, timeZone: String = "") -> String {
        if !timeZone.isEmpty {
            formatter.timeZone = TimeZone(abbreviation: timeZone)
        }
        formatter.dateFormat = dateFormat
        return formatter.string(from: Date())
    }
    
    // MARK: - Filters
    
    /// Add a filter that determines whether or not a particular message will be logged to this destination.
    public func addFilter(_ filter: FilterType) {
        filters.append(filter)
    }
    
    /// Remove a filter from the list of filters.
    public func removeFilter(_ filter: FilterType) {
        if let filterIndex = filters.index(where: { $0 === filter }) {
            filters.remove(at: filterIndex)
        }
    }
    
    /// Answer whether the destination has any message filters
    /// returns boolean and is used to decide whether to resolve the message before invoking shouldLevelBeLogged
    func hasMessageFilters() -> Bool {
        let target = Filter.TargetType.message(.equals([], true))
        return !filters.filter { $0.getTarget() == target }.isEmpty
    }
    
    /// checks if level is at least minLevel or if a minLevel filter for that path does exist
    /// returns boolean and can be used to decide if a message should be logged or not
    func shouldLevelBeLogged(_ level: LogLevel, path: String, function: String, message: String? = nil) -> Bool {
        if filters.isEmpty {
            return level.rawValue >= minLevel.rawValue
        }
        
        let (matchedExclude, allExclude) = passedExcludedFilters(level, path: path, function: function, message: message)
        if allExclude > 0 && matchedExclude != allExclude {
            return false
        }
        
        let (matchedRequired, allRequired) = passedRequiredFilters(level, path: path, function: function, message: message)
        let (matchedNonRequired, allNonRequired) = passedNonRequiredFilters(level, path: path, function: function, message: message)
        if allRequired > 0 {
            if matchedRequired == allRequired {
                return true
            }
        } else {
            // no required filters are existing so at least 1 optional needs to match
            if allNonRequired > 0 {
                if matchedNonRequired > 0 {
                    return true
                }
            } else if allExclude == 0 {
                // no optional is existing, so all is good
                return true
            }
        }
        
        if level.rawValue < minLevel.rawValue {
            return false
        }
        
        return false
    }
    
    /// Returns a tuple of matched and all filters.
    func passedRequiredFilters(_ level: LogLevel, path: String, function: String, message: String?) -> (Int, Int) {
        let requiredFilters = self.filters.filter { $0.isRequired() && !$0.isExcluded() }
        let matchingFilters = applyFilters(requiredFilters, level: level, path: path, function: function, message: message)
        return (matchingFilters, requiredFilters.count)
    }
    
    /// Returns a tuple of matched and all filters.
    func passedNonRequiredFilters(_ level: LogLevel, path: String, function: String, message: String?) -> (Int, Int) {
        let nonRequiredFilters = self.filters.filter { !$0.isRequired() && !$0.isExcluded() }
        let matchingFilters = applyFilters(nonRequiredFilters, level: level, path: path, function: function, message: message)
        return (matchingFilters, nonRequiredFilters.count)
    }
    
    /// Returns a tuple of matched and all exclude filters.
    func passedExcludedFilters(_ level: LogLevel, path: String, function: String, message: String?) -> (Int, Int) {
        let excludeFilters = self.filters.filter { $0.isExcluded() }
        let matchingFilters = applyFilters(excludeFilters, level: level, path: path, function: function, message: message)
        return (matchingFilters, excludeFilters.count)
    }
    
    func applyFilters(_ targetFilters: [FilterType], level: LogLevel, path: String, function: String, message: String?) -> Int {
        return targetFilters.filter { filter in
            guard filter.reachedMinLevel(level) else {
                return false
            }
            
            let passes: Bool
            switch filter.getTarget() {
            case .path:
                passes = filter.apply(path)
            case .function:
                passes = filter.apply(function)
            case .message:
                guard let message = message else { return false }
                passes = filter.apply(message)
            }
            return passes
        }.count
    }
}

extension BaseDestination: Equatable {
    
    public static func == (lhs: BaseDestination, rhs: BaseDestination) -> Bool {
        return lhs === rhs
    }
}
