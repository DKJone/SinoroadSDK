//
//  FilterParamsTranslationPlugin.swift
//  MilanoSDK
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import Foundation
import Moya

/// 对分页、过滤参数进行处理
public class FilterParamsTranslationPlugin: PluginType {

    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        if let target = target as? Pageable, let pageParams = target.pageParams {
            if let pageData = try? JSONSerialization.data(withJSONObject: pageParams, options: .init(rawValue: 0)) {
                request.addValue(pageData.base64EncodedString(options: .init(rawValue: 0)), forHTTPHeaderField: "pageInfo")
            } else {
                Log.error("JSON serialization error: \(pageParams)")
            }
        }
        return request
    }
}
