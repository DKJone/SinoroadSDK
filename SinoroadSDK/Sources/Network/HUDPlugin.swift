//
//  HudPlugin.swift
//  Network
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import Foundation
import Moya
import Result
import SwiftyJSON

/// 用于请求执行成功时，自动处理HUD的显示问题
public final class HudPlugin: PluginType {
    /// 需要排除的`TargetType`，默认会对所有`TargetType`进行处理
    var excludeTargets = [TargetType]()

    public init() {}

    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        switch result {
        case let .success(response):
            guard let jsonObject = try? response.mapJSON(), JSON(jsonObject)["state"].stringValue.uppercased() == "ERROR" else {
                if !excludeTargets.contains(where: { $0.path == target.path && $0.method == target.method }) {
                    hideHud()
                }
                return
            }
            hideHud()
        case .failure:
            hideHud()
        }
    }
}
