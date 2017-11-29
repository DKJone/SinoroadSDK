//
//  MBProgressHUDExt.swift
//  CommonUtil
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

/// 显示提示信息
import MBProgressHUD
@discardableResult
public func showMessage(_ msg: String, in view: UIView = currentWindow) -> MBProgressHUD {
    let hud = MBProgressHUD.showAdded(to: view, animated: true)
    hud.mode = .text
    hud.label.text = msg
    hud.hide(animated: true, afterDelay: 1.0)
    return hud
}

/// 显示加载进度框
@discardableResult
public func showLoadingHud(_ msg: String? = nil, in view: UIView = currentWindow) -> MBProgressHUD {
    let hud = MBProgressHUD.showAdded(to: view, animated: true)
    hud.mode = .indeterminate
    hud.label.text = msg
    return hud
}

/// 隐藏HUD View
public func hideHud(in view: UIView = currentWindow) {
    MBProgressHUD.hide(for: view, animated: true)
}
