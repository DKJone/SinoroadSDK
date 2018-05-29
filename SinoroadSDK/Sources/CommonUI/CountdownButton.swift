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
    public var bgColor : UIColor!
    public var titleStyle : ((Int)->String)!
    public var unUseColor:UIColor!
    private let timerIdentifier = "timer.CountdownButton"
    private var elapsedSeconds = 0
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
        bgColor = bgColor ?? backgroundColor
        unUseColor = unUseColor ?? backgroundColor
    }
    
    /// 开始倒计时操作
    public func start() {
        if titleStyle == nil {
            titleStyle = { (sec) in
                return "\(sec)秒"
            }
        }
        self.isUserInteractionEnabled = false
        self.elapsedSeconds = seconds
        self.backgroundColor = unUseColor
        setTitle(titleStyle(seconds), for: [])
        GCDTimer.shared.scheduled(with: timerIdentifier, interval: .seconds(1)) {
            self.elapsedSeconds -= 1
            
            if self.elapsedSeconds == 0 {
                self.stop()
            } else {
                UIView.animate(withDuration: 0.5, animations: {[unowned self] in
                    self.setTitle(self.titleStyle(self.elapsedSeconds), for: .normal)
                })
                
            }
        }
    }
    
    /// 终止倒计时操作
    public func stop() {
        GCDTimer.shared.cancelTimer(for: timerIdentifier)
        self.backgroundColor = bgColor
        self.isUserInteractionEnabled = true
        self.setTitle(text, for: .normal)
    }
}
