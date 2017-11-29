//
//  AppInfo.swift
//  CommonUtil
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import UIKit
import ObjectiveC
public class AppInfo {
    
    /// 应用名称
    public static var appDisplayName: String {
        return Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String // swiftlint:disable:this force_cast
    }
    
    /// 应用版本
    public static var appVersion: String {
        return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String // swiftlint:disable:this force_cast
    }
    
    /// 应用Bundle版本
    public static var appBundleVersion: String {
        return Bundle.main.infoDictionary!["CFBundleVersion"] as! String // swiftlint:disable:this force_cast
    }
    
    /// 应用标识符
    public static var appBundleID: String {
        return Bundle.main.bundleIdentifier! // swiftlint:disable:this force_cast
    }
    
    // App Build Number
    public static var appBuild: String! {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String // swiftlint:disable:this force_cast
    }
}

public let currentWindow = AppInfo.keyWindow
public let screenSize = AppInfo.screenSize

// MARK: - Window/Screen
extension AppInfo {
    
    /// 当前窗口
    public static var keyWindow: UIWindow {
        return UIApplication.shared.keyWindow!
    }
    
    /// 当前屏幕尺寸
    public static var screenSize: CGSize {
        return UIScreen.main.bounds.size
    }
    
    /// 状态栏高度
    public static var statusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    
    /// 状态栏是否隐藏
    public static var isStatusBarHidden: Bool {
        return UIApplication.shared.isStatusBarHidden
    }
    
    /// 状态栏样式
    public static var statusBarStyle: UIStatusBarStyle? {
        return UIApplication.shared.statusBarStyle
    }
}

// MARK: - UIDevice
extension AppInfo {
    
    /// 电量信息
    public static var batteryLevel: Float {
        return UIDevice.current.batteryLevel
    }
    
    /// 当前设备型号
    public static var deviceModel: String {
        return UIDevice.current.model
    }
    
    /// 当前设备名称
    public static var deviceName: String {
        return UIDevice.current.name
    }
    
    /// 当前设备方向
    public static var deviceOrientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }
    
    /// 是否支持多任务模式
    public static var isMultitaskingSupported: Bool {
        return UIDevice.current.isMultitaskingSupported
    }
    
    /// 当前设备系统版本
    public static var systemVersion: String {
        return UIDevice.current.systemVersion
    }
}

extension AppInfo {
    
    /// Check if app is running in debug mode.
    public static var isInDebuggingMode: Bool {
        // http://stackoverflow.com/questions/9063100/xcode-ios-how-to-determine-whether-code-is-running-in-debug-release-build
        #if DEBUG
            return true
        #else
            return false
        #endif
    }
    
    /// Check if app is running in TestFlight mode.
    public static var isInTestFlight: Bool {
        // http://stackoverflow.com/questions/12431994/detect-testflight
        return Bundle.main.appStoreReceiptURL?.path.contains("sandboxReceipt") == true
    }
    
    public static func didTakeScreenShot(_ action: @escaping () -> ()) {
        // http://stackoverflow.com/questions/13484516/ios-detection-of-screenshot
        let mainQueue = OperationQueue.main
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationUserDidTakeScreenshot, object: nil, queue: mainQueue) { notification in
            action()
        }
    }
}
