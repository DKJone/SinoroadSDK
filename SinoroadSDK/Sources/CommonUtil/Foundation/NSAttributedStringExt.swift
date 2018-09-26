//
//  NSAttributedStringExt.swift
//  CommonUtil
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import UIKit

// https://github.com/Raizlabs/BonMot
// https://github.com/malcommac/SwiftRichString

// MARK: - Properties
extension NSAttributedString {
    
    /// 粗体
    public var bolded: NSAttributedString {
        return apply(attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)])
    }
    
    /// 下划线
    public var underlined: NSAttributedString {
        return apply(attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
    }
    
    /// 斜体
    public var italicized: NSAttributedString {
        return apply(attributes: [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: UIFont.systemFontSize)])
    }
    
    /// 删除线
    public var strikethrough: NSAttributedString {
        return apply(attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue])
    }
}

// MARK: - Methods
extension NSAttributedString {
    
    /// Applies given attributes to the new instance of NSAttributedString initialized with self object.
    ///
    /// - Parameter attributes: Dictionary of attributes
    /// - Returns: NSAttributedString with applied attributes
    fileprivate func apply(attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let copy = NSMutableAttributedString(attributedString: self)
        let range = (self.string as NSString).range(of: self.string)
        copy.addAttributes(attributes, range: range)
        
        return copy
    }
    
    /// Add color to NSAttributedString.
    ///
    /// - Parameter color: text color.
    /// - Returns: a NSAttributedString colored with given color.
    public func colored(with color: UIColor) -> NSAttributedString {
        return apply(attributes: [NSAttributedString.Key.foregroundColor: color])
    }
}
