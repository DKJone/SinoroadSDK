//
//  UILabelExt.swift
//  CommonUtil
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import UIKit

extension UILabel {
    
    /// Required height for a label.
    public var requiredHeight: CGFloat {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.attributedText = attributedText
        label.sizeToFit()
        return label.frame.height
    }
    
    /// 获取字符串尺寸
    ///
    /// - Returns: 字符串尺寸
    public func labelSize() -> CGSize {
        guard let text = text else { return .zero }
        
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.leastNormalMagnitude)
        let attributes = [NSAttributedStringKey.font: font] as [NSAttributedStringKey: Any]
        
        return NSString(string: text).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size
    }
}
