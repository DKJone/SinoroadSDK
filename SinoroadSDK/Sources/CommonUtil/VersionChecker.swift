//
//  VersionChecker.swift
//  CommonUtil
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import Foundation
import SwiftyJSON

/// 版本信息
public struct VersionInfo {
    public let versionStr: String
    public let allowBuildNumber: Int
    public let buildNumber: Int
    public let content: String
    public let url: String
    
    public init(json: JSON) {
        self.versionStr = json["versionStr"].stringValue
        self.allowBuildNumber = json["allowBuildNumber"].intValue
        self.buildNumber = json["buildNumber"].intValue
        self.content = json["content"].stringValue
        self.url = json["url"].stringValue
    }
}

/// 版本检查工具
public class VersionChecker: NSObject {
    public static let sharedInstance = VersionChecker()
    
    private override init() {
        super.init()
    }
    
    public func checkUpdate() {
        // CommonProvider.request(.checkUpdate).then { response in self.promptUser(VersionInfo(json: response.result)) }
    }
    
    public func promptUser(version: VersionInfo) {
        guard version.buildNumber > Int(AppInfo.appBundleVersion)! else { return }
        
        let alertController = UIAlertController(title: "版本更新 \(version.versionStr)", message: version.content, preferredStyle: .alert)
        alertController.addAction(title: "立即更新", style: .default) { _ in
            let appURL = URL(string: version.url)!
            if #available(iOS 10, *) {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(appURL)
            }
        }
        alertController.addAction(title: "稍后再说", style: .cancel)
        currentWindow.rootViewController!.present(alertController, animated: true)
    }
}
