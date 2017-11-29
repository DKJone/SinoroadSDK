//
//  UIColorExt.swift
//  CommonUtil
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import UIKit

// MARK: - CGColor
extension CGColor {
    
    public var uiColor: UIColor? {
        return UIColor(cgColor: self)
    }
}

// MARK: - UIColor + Property
extension UIColor {
    
    /// Red component of UIColor.
    public var redComponent: Int {
        var red: CGFloat = 0.0
        getRed(&red, green: nil, blue: nil, alpha: nil)
        return Int(red * 255)
    }
    
    /// Green component of UIColor.
    public var greenComponent: Int {
        var green: CGFloat = 0.0
        getRed(nil, green: &green, blue: nil, alpha: nil)
        return Int(green * 255)
    }
    
    /// blue component of UIColor.
    public var blueComponent: Int {
        var blue: CGFloat = 0.0
        getRed(nil, green: nil, blue: &blue, alpha: nil)
        return Int(blue * 255)
    }
    
    /// Alpha of UIColor.
    public var alpha: CGFloat {
        var a: CGFloat = 0.0
        getRed(nil, green: nil, blue: nil, alpha: &a)
        return a
    }
    
    /// Hexadecimal value string.
    public var hexString: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let rgb: Int = Int(red * 255) << 16 | Int(green * 255) << 8 | Int(blue * 255) << 0
        return NSString(format: "#%06x", rgb).uppercased as String
    }
    
    /// Random color.
    public static var random: UIColor {
        let r = Int(arc4random_uniform(255))
        let g = Int(arc4random_uniform(255))
        let b = Int(arc4random_uniform(255))
        return UIColor(red: r, green: g, blue: b)
    }
}

// MARK: - UIColor + Initializer
extension UIColor {
    
    /// supported format: EDE7F6, 0xEDE7F6, #EDE7F6, #0ff, 0xF0F
    public convenience init(hexString: String, alpha: CGFloat = 1) {
        var hex = hexString.hasPrefix("#") ? String(hexString.characters.dropFirst()) : hexString
        
        if !(hex.characters.count == 3 || hex.characters.count == 6) { // 格式非法，默认设为白色
            self.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        } else {
            if hex.characters.count == 3 {
                for (index, char) in hex.characters.enumerated() {
                    hex.insert(char, at: hex.index(hex.startIndex, offsetBy: index * 2))
                }
            }
            
            let r = CGFloat((Int(hex, radix: 16)! >> 16) & 0xFF) / 255.0
            let g = CGFloat((Int(hex, radix: 16)! >> 8) & 0xFF) / 255.0
            let b = CGFloat((Int(hex, radix: 16)!) & 0xFF) / 255.0
            
            self.init(red: r, green: g, blue: b, alpha: alpha)
        }
    }
    
    /// e.g. 0xFFFFFF
    public convenience init(hex: Int, alpha: CGFloat = 1) {
        var transparency: CGFloat {
            if alpha > 1 {
                return 1
            } else if alpha < 0 {
                return 0
            } else {
                return alpha
            }
        }
        self.init(red: (hex >> 16) & 0xFF, green: (hex >> 8) & 0xFF, blue: hex & 0xFF, transparency: transparency)
    }
    
    /// e.g.
    ///
    /// ```
    /// let color = UIColor(red: 255, green: 255, black: 255, transparency: 0.5)
    /// ```
    public convenience init(red: Int, green: Int, blue: Int, transparency: CGFloat = 1) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        var alpha: CGFloat {
            if transparency > 1 {
                return 1
            } else if transparency < 0 {
                return 0
            } else {
                return transparency
            }
        }
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
}
