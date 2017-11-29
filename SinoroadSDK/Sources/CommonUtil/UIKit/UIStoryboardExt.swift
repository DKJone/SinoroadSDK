//
//  UIStoryboardExt.swift
//  CommonUtil
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import Foundation
import UIKit

extension UIStoryboard {

    /// Get main storyboard for application.
    public static var main: UIStoryboard? {
        let bundle = Bundle.main
        guard let name = bundle.object(forInfoDictionaryKey: "UIMainStoryboardFile") as? String else { return nil }
        return UIStoryboard(name: name, bundle: bundle)
    }

    /// Instantiate a UIViewController using its type name.
    ///
    /// - Parameter name: UIViewController type
    /// - Returns: The view controller corresponding to specified class name
    public func instantiateViewController<T: UIViewController>(withType type: T.Type) -> T {
        return instantiateViewController(withIdentifier: String(describing: type)) as! T
    }

    /// 从Storyboard加载UIViewController对象
    ///
    /// - Parameters:
    ///   - identifier: controller对应的标识符
    ///   - name: storyboard文件名
    /// - Returns: 对应的`UIViewController`对象
    public static func controller<T: UIViewController>(withIdentifier identifier: String, inStoryboard name: String) -> T {
        return UIStoryboard(name: name, bundle: nil).instantiateViewController(withIdentifier: identifier) as! T // swiftlint:disable:this force_cast
    }
}
