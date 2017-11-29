//
//  ConsoleDestination.swift
//  Logger
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import Foundation

/// 用于控制台日志输出
public class ConsoleDestination: BaseDestination {
    /// 是否使用`NSLog`输出日志，默认为`false`
    public var useNSLog = false
    
    public override func send(_ level: LogLevel, msg: String, thread: String, file: String, function: String, line: Int) -> String {
        let formattedString = super.send(level, msg: msg, thread: thread, file: file, function: function, line: line)
        
        if useNSLog {
            NSLog("%@", formattedString)
        } else {
            print(formattedString)
        }
        
        return formattedString
    }
}
