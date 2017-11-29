//
//  FP.swift
//  MilanoSDK
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

// Java 8

/// Applies this function to the given argument.
public typealias Function<T, R> = (T) -> R

/// Represents a function that accepts two arguments and produces a result.
public typealias BiFunction<T, U, R> = (T, U) -> R

/// Represents a function that accepts three arguments and produces a result.
public typealias TriFunction<T, U, V, R> = (T, U, V) -> R

/// Represents a predicate (boolean-valued function) of one argument.
public typealias Predicate<T> = (T) -> Bool

/// Represents an operation that accepts a single input argument and returns no result.
public typealias Consumer<T> = (T) -> Void

/// Represents a supplier of results.
public typealias Supplier<T> = () -> T

/// Represents an operation on a single operand that produces a result of the same type as its operand.
///
/// ```
/// 1 = 1
/// ```
public typealias UnaryOperator<T> = (T) -> T

/// Represents an operation upon two operands of the same type, producing a result of the same type as the operands.
///
/// ```
/// 1 + 1 = 2
/// ```
public typealias BinaryOperator<T> = (T, T) -> T
