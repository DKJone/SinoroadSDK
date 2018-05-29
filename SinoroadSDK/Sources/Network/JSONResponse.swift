//
//  JSONResponse.swift
//  sdyd
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import SwiftyJSON
import Moya

extension JSON {

    public init?(_ response: Response) {
        if let json = try? response.mapJSON() {
            self.init(json)
        } else {
            return nil
        }
    }
}

/// 对请求结果进一步封装以便数据处理
public struct JSONResponse {
    public let resultCode: String
    public let result: JSON
    public let errorMsg: String

    // FIXME: 返回的数据格式需要统一
    public var isSuccess: Bool {
        return resultCode.uppercased() == "SUCCESS" || resultCode == "noData" || resultCode == "1000"
    }

    public init?(_ response: Response) {
        guard let json = JSON(response) else { return nil }

        resultCode = json["errorCode"].stringValue
        result = json["obj"]
        errorMsg = json["message"].stringValue
    }
}
