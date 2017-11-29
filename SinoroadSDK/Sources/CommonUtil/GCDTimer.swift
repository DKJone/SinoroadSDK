//
//  GCDTimer.swift
//  CommonUtil
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import Foundation

/// GCD定时器
public final class GCDTimer {
    public static let shared = GCDTimer()
    
    private var timers = [String: DispatchSourceTimer]()
    
    private init() {}
    
    public func scheduled(with timerName: String, interval: DispatchTimeInterval, queue: DispatchQueue = DispatchQueue.main, repeats: Bool = true, action: @escaping () -> Void) {
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.setEventHandler(handler: action)
        if repeats {
            timer.scheduleRepeating(deadline: .now() + interval, interval: interval)
        } else {
            timer.scheduleOneshot(deadline: .now() + interval)
        }
        timer.resume()
        
        timers[timerName] = timer
    }
    
    public func cancelTimer(for timerName: String) {
        if let timer = timers.removeValue(forKey: timerName) {
            // 事实上，不需要手动cancel，DispatchSourceTimer在销毁时会自动cancel
            timer.cancel()
        }
    }
}
