//
//  NSCoderExt.swift
//  CommonUtil
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import Foundation

extension NSCoder {

    open func decodeObject<T>(forKey key: String) -> T? {
        return decodeObject(forKey: key) as? T
    }
}
