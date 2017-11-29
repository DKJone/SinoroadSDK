//
//  CountdownButton.swift
//  CommonUI
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import UIKit

/// 用于倒计时显示的按钮
public class CountdownButton: UIButton {
    /// 显示文本
    public var text = ""
    /// 倒计时时间
    public var seconds = 0
    
    private let timerIdentifier = "timer.CountdownButton"
    private var elapsedSeconds = 0
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 5
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
    }
    
    /// 开始倒计时操作
    public func start() {
        self.isUserInteractionEnabled = false
        self.elapsedSeconds = seconds
        
        GCDTimer.shared.scheduled(with: timerIdentifier, interval: .seconds(1)) {
            self.elapsedSeconds -= 1
            
            if self.elapsedSeconds == 0 {
                self.stop()
            } else {
                self.setTitle(String(format: "%lu秒", self.elapsedSeconds), for: .normal)
            }
        }
    }
    
    /// 终止倒计时操作
    public func stop() {
        GCDTimer.shared.cancelTimer(for: timerIdentifier)
        
        self.isUserInteractionEnabled = true
        self.setTitle(text, for: .normal)
    }
}
