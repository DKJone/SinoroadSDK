//
//  Filter.swift
//  SwiftyBeaver
//
//  Created by Jeff Roberts on 5/31/16.
//  Copyright © 2015 Sebastian Kreutzberger
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import Foundation

/// FilterType is a protocol that describes something that determines
/// whether or not a message gets logged. A filter answers a Bool when it
/// is applied to a value. If the filter passes, it shall return true,
/// false otherwise.
///
/// A filter must contain a target, which identifies what it filters against
/// A filter can be required meaning that all required filters against a specific
/// target must pass in order for the message to be logged. At least one non-required
/// filter must pass in order for the message to be logged
public protocol FilterType: class {
    /// 判断当前`Filter`是否用于当前log
    func apply(_ value: Any) -> Bool
    
    func getTarget() -> Filter.TargetType
    
    /// 在`Destination`包含多个`Filter`的时候，该`Filter`是否是必须的
    func isRequired() -> Bool
    
    /// 是否属于排除类型的`Filter`，如：文件名不包含`foo`的文件
    func isExcluded() -> Bool
    
    /// 判断`LogLevel`的优先级是否高于该`Filter`的优先级
    func reachedMinLevel(_ level: LogLevel) -> Bool
}

/// Filters is syntactic sugar used to easily construct filters
public final class Filters {
    /// filter by path or filename
    public static let path = PathFilterFactory.self
    /// filter by function name
    public static let function = FunctionFilterFactory.self
    /// filter by log message
    public static let message = MessageFilterFactory.self
}

/// Filter is an abstract base class for other filters
public class Filter {
    
    /// `Filter`作用的目标类型
    ///
    /// - path: 基于文件路径或文件名
    /// - function: 基于调用函数
    /// - message: 基于日志内容
    public enum TargetType {
        case path(ComparisonType)
        case function(ComparisonType)
        case message(ComparisonType)
    }
    
    /// Filter Matching Functions
    ///
    /// - startsWith: does the filter start with the string?
    /// - contains: does the filter contain the string?
    /// - excludes: does the filter NOT contain the string?
    /// - endsWith: does the filter end with the string?
    /// - equals: does the filter equal the string?
    public enum ComparisonType {
        case startsWith([String], Bool)
        case contains([String], Bool)
        case excludes([String], Bool)
        case endsWith([String], Bool)
        case equals([String], Bool)
    }
    
    let targetType: TargetType
    let required: Bool
    let minLevel: LogLevel
    
    public init(_ target: TargetType, required: Bool, minLevel: LogLevel) {
        self.targetType = target
        self.required = required
        self.minLevel = minLevel
    }
    
    public func getTarget() -> Filter.TargetType {
        return self.targetType
    }
    
    /// 在`Destination`包含多个`Filter`的时候，该`Filter`是否是必须的
    public func isRequired() -> Bool {
        return self.required
    }
    
    /// 是否属于排除类型的`Filter`，如：文件名不包含`foo`的文件
    public func isExcluded() -> Bool {
        return false
    }
    
    /// 判断`LogLevel`的优先级是否高于该`Filter`的优先级
    public func reachedMinLevel(_ level: LogLevel) -> Bool {
        return level.rawValue >= minLevel.rawValue
    }
}

/// CompareFilter is a FilterType that can filter based upon whether a target starts with, contains or ends with a specific string.
/// CompareFilters can be case sensitive.
public class CompareFilter: Filter, FilterType {
    /// 匹配类型
    private let filterComparisonType: ComparisonType
    
    public override init(_ target: TargetType, required: Bool, minLevel: LogLevel) {
        switch target {
        case let .function(comparison):
            self.filterComparisonType = comparison
        case let .path(comparison):
            self.filterComparisonType = comparison
        case let .message(comparison):
            self.filterComparisonType = comparison
        }
        
        super.init(target, required: required, minLevel: minLevel)
    }
    
    public func apply(_ value: Any) -> Bool {
        guard let value = value as? String else { return false }
        
        let matches: Bool
        switch filterComparisonType {
        case let .contains(strings, caseSensitive):
            matches = !strings.filter { caseSensitive ? value.contains($0) : value.lowercased().contains($0.lowercased()) }.isEmpty
        case let .excludes(strings, caseSensitive):
            matches = !strings.filter { caseSensitive ? !value.contains($0) : !value.lowercased().contains($0.lowercased()) }.isEmpty
        case let .startsWith(strings, caseSensitive):
            matches = !strings.filter { caseSensitive ? value.hasPrefix($0) : value.lowercased().hasPrefix($0.lowercased()) }.isEmpty
        case let .endsWith(strings, caseSensitive):
            matches = !strings.filter { caseSensitive ? value.hasSuffix($0) : value.lowercased().hasSuffix($0.lowercased()) }.isEmpty
        case let .equals(strings, caseSensitive):
            matches = !strings.filter { caseSensitive ? value == $0 : value.lowercased() == $0.lowercased() }.isEmpty
        }
        return matches
    }
    
    public override func isExcluded() -> Bool {
        if case ComparisonType.excludes = filterComparisonType {
            return true
        }
        return false
    }
}

// Syntactic sugar for creating a function comparison filter
public class FunctionFilterFactory {
    
    /// Create Filter
    ///
    /// - Parameters:
    ///   - prefixes: the string pattern
    ///   - caseSensitive: case-sensitive must be met, false on default
    ///   - required: must be met if the destination has multiple filters, false on default
    ///   - minLevel: the level the filter must at least have, .verbose on default
    /// - Returns: Filter
    public static func startsWith(_ prefixes: String..., caseSensitive: Bool = false,
                                  required: Bool = false, minLevel: LogLevel = .verbose) -> FilterType {
        return CompareFilter(.function(.startsWith(prefixes, caseSensitive)), required: required, minLevel: minLevel)
    }
    
    public static func contains(_ strings: String..., caseSensitive: Bool = false,
                                required: Bool = false, minLevel: LogLevel = .verbose) -> FilterType {
        return CompareFilter(.function(.contains(strings, caseSensitive)), required: required, minLevel: minLevel)
    }
    
    public static func excludes(_ strings: String..., caseSensitive: Bool = false,
                                required: Bool = false, minLevel: LogLevel = .verbose) -> FilterType {
        return CompareFilter(.function(.excludes(strings, caseSensitive)), required: required, minLevel: minLevel)
    }
    
    public static func endsWith(_ suffixes: String..., caseSensitive: Bool = false,
                                required: Bool = false, minLevel: LogLevel = .verbose) -> FilterType {
        return CompareFilter(.function(.endsWith(suffixes, caseSensitive)), required: required, minLevel: minLevel)
    }
    
    public static func equals(_ strings: String..., caseSensitive: Bool = false,
                              required: Bool = false, minLevel: LogLevel = .verbose) -> FilterType {
        return CompareFilter(.function(.equals(strings, caseSensitive)), required: required, minLevel: minLevel)
    }
}

// Syntactic sugar for creating a message comparison filter
public class MessageFilterFactory {
    
    public static func startsWith(_ prefixes: String..., caseSensitive: Bool = false,
                                  required: Bool = false, minLevel: LogLevel = .verbose) -> FilterType {
        return CompareFilter(.message(.startsWith(prefixes, caseSensitive)), required: required, minLevel: minLevel)
    }
    
    public static func contains(_ strings: String..., caseSensitive: Bool = false,
                                required: Bool = false, minLevel: LogLevel = .verbose) -> FilterType {
        return CompareFilter(.message(.contains(strings, caseSensitive)), required: required, minLevel: minLevel)
    }
    
    public static func excludes(_ strings: String..., caseSensitive: Bool = false,
                                required: Bool = false, minLevel: LogLevel = .verbose) -> FilterType {
        return CompareFilter(.message(.excludes(strings, caseSensitive)), required: required, minLevel: minLevel)
    }
    
    public static func endsWith(_ suffixes: String..., caseSensitive: Bool = false,
                                required: Bool = false, minLevel: LogLevel = .verbose) -> FilterType {
        return CompareFilter(.message(.endsWith(suffixes, caseSensitive)), required: required, minLevel: minLevel)
    }
    
    public static func equals(_ strings: String..., caseSensitive: Bool = false,
                              required: Bool = false, minLevel: LogLevel = .verbose) -> FilterType {
        return CompareFilter(.message(.equals(strings, caseSensitive)), required: required, minLevel: minLevel)
    }
}

// Syntactic sugar for creating a path comparison filter
public class PathFilterFactory {
    
    public static func startsWith(_ prefixes: String..., caseSensitive: Bool = false,
                                  required: Bool = false, minLevel: LogLevel = .verbose) -> FilterType {
        return CompareFilter(.path(.startsWith(prefixes, caseSensitive)), required: required, minLevel: minLevel)
    }
    
    public static func contains(_ strings: String..., caseSensitive: Bool = false,
                                required: Bool = false, minLevel: LogLevel = .verbose) -> FilterType {
        return CompareFilter(.path(.contains(strings, caseSensitive)), required: required, minLevel: minLevel)
    }
    
    public static func excludes(_ strings: String..., caseSensitive: Bool = false,
                                required: Bool = false, minLevel: LogLevel = .verbose) -> FilterType {
        return CompareFilter(.path(.excludes(strings, caseSensitive)), required: required, minLevel: minLevel)
    }
    
    public static func endsWith(_ suffixes: String..., caseSensitive: Bool = false,
                                required: Bool = false, minLevel: LogLevel = .verbose) -> FilterType {
        return CompareFilter(.path(.endsWith(suffixes, caseSensitive)), required: required, minLevel: minLevel)
    }
    
    public static func equals(_ strings: String..., caseSensitive: Bool = false,
                              required: Bool = false, minLevel: LogLevel = .verbose) -> FilterType {
        return CompareFilter(.path(.equals(strings, caseSensitive)), required: required, minLevel: minLevel)
    }
}

extension Filter.TargetType: Equatable {
    
    // The == does not compare associated values for each enum. Instead == evaluates to true
    // if both enums are the same "types", ignoring the associated values of each enum
    public static func == (lhs: Filter.TargetType, rhs: Filter.TargetType) -> Bool {
        switch (lhs, rhs) {
        case (.path, .path):
            return true
        case (.function, .function):
            return true
        case (.message, .message):
            return true
        default:
            return false
        }
    }
}
