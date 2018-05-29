//
//  StringExt.swift
//  CommonUtil
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import Foundation

// MARK: - 加/解密

extension String {

    /// md5
//    public var md5: String {
//         let digestLen = Int(CC_MD5_DIGEST_LENGTH)
//         var digest = [UInt8](repeating: 0, count: digestLen)
//        
//         if let data = self.data(using: .utf8) {
//             _ = data.withUnsafeBytes { CC_MD5($0, CC_LONG(data.count), &digest) }
//         }
//        
//         return (0..<digestLen).reduce("") { $0 + String(format: "%02x", digest[$1]) }

//        return CryptoUtil.md5(self)
//    }

    public var base64Encoded: String {
        let data = self.data(using: .utf8, allowLossyConversion: true)!
        return data.base64EncodedString()
    }

    public var base64Decoded: String? {
        guard let decodedData = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: decodedData, encoding: .utf8)
    }
}

// MARK: - 格式验证

private let letterAndNumbersPattern = "^\\w+$"
private let phonePattern = "^(13[0-9]|15[0-9]|17[0-9]|18[0-9]|19[0-9])\\d{8}$"
private let idCardNum16Pattern = "^[1-9]\\d{7}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}$"
private let idCardNum18Pattern = "^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}([0-9]|X)$"

extension String {

    /// 手机号码验证，支持13、15、17、18、19开头的手机号码
    ///
    /// - Returns: true表示号码合法
    public func isValidPhoneNumber() -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", argumentArray: [phonePattern]).evaluate(with: self)
    }

    /// 身份证号码验证，分为16位与18位两种
    ///
    /// - Returns: true表示号码合法
    public func isValidIdCardNum() -> Bool {
        let pattern = self.utf8.count == 16 ? idCardNum16Pattern : idCardNum18Pattern
        return NSPredicate(format: "SELF MATCHES %@", argumentArray: [pattern]).evaluate(with: self)
    }

    /// 验证文本是否只包含数字和字母
    ///
    /// - Returns: true表示文本只包含数字和字母
    public func isValidText() -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", argumentArray: [letterAndNumbersPattern]).evaluate(with: self)
    }

    /// 获取拼音首字母
    ///
    /// - Returns: 大写形式的拼音首字母
    public func firstCharacterInPinYin() -> String {
        let str = NSMutableString(string: self)
        CFStringTransform(str, nil, kCFStringTransformMandarinLatin, false)
        CFStringTransform(str, nil, kCFStringTransformStripDiacritics, false)
        let pinYin = str.capitalized
        return String(pinYin[pinYin.startIndex..<pinYin.index(startIndex, offsetBy: 1)])
    }
}

// 用于处理日期格式
private let dateFormatter = DateFormatter()

extension Date {

    /// 从日期字符串创建Date对象
    ///
    /// - Parameters:
    ///   - date: 日期字符串
    ///   - format: 日期格式
    /// - Returns: 日期字符串不合法，返回nil
    public static func date(from dateString: String, format: String = "YYYY/MM/dd") -> Date? {
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: dateString)
    }

    /// 将给定的Date对象按照相应的日期格式转化为字符串
    ///
    /// - Parameter format: 日期格式
    /// - Returns: 字符串形式的日期
    public func toString(withFormat format: String = "YYYY/MM/dd") -> String {
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

    /// 根据当前日期生成文件名
    ///
    /// - Returns: 生成的文件名
    public func toFilename() -> String {
        dateFormatter.dateFormat = "YYYYMMddHHmmss"
        return dateFormatter.string(from: self)
    }
}

extension String{
    //移除小数点后结尾多余0和小数点
    public var removeEndZero:String{
        let tempStr = replacingOccurrences(of: "[0]+$", with: "", options: [.regularExpression,.caseInsensitive])
        return tempStr.replacingOccurrences(of: "[.]$", with: "",options: [.regularExpression,.caseInsensitive])
        
    }
}
