//
//  CharacterExt.swift
//  CommonUtil
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

extension Character {
    
    /// Check if character is emoji.
    public var isEmoji: Bool {
        // http://stackoverflow.com/questions/30757193/find-out-if-character-in-string-is-emoji
        let scalarValue = String(self).unicodeScalars.first!.value
        switch scalarValue {
        case 0x3030, 0x00AE, 0x00A9, // Special Characters
             0x1D000...0x1F77F, // Emoticons
             0x2100...0x27BF, // Misc symbols and Dingbats
             0xFE00...0xFE0F, // Variation Selectors
             0x1F900...0x1F9FF: // Supplemental Symbols and Pictographs
            return true
        default:
            return false
        }
    }
    
    /// Check if character is number.
    public var isNumber: Bool {
        return Int(String(self)) != nil
    }
    
    /// Check if character is uppercased.
    public var isUppercased: Bool {
        return String(self) == String(self).uppercased()
    }
    
    /// Check if character is lowercased.
    public var isLowercased: Bool {
        return String(self) == String(self).lowercased()
    }
    
    /// Integer from character (if applicable).
    public var int: Int? {
        return Int(String(self))
    }
    
    /// String from character.
    public var string: String {
        return String(self)
    }
}
