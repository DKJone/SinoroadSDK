//
//  Provider+Defaults.swift
//  Network
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import Foundation
import Moya
import Alamofire

/// 自定义参数编码格式
public struct CustomEncoding:  Alamofire.ParameterEncoding {

    public init() {}

    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        if urlRequest.urlRequest?.httpMethod == HTTPMethod.get.rawValue {
            return try URLEncoding.default.encode(urlRequest, with: parameters)
        } else {
            return try JSONEncoding.default.encode(urlRequest, with: parameters)
        }
    }
}

/// 分页
public protocol Pageable {
    /// The page parameters to be incoded in the request.
    var pageParams: [String: Any]? { get }
}

// MARK: - Default implementation
extension TargetType {
    public var baseURL: URL { return HTTPConfig.apiURL }
    public var parameterEncoding: Moya.ParameterEncoding { return JSONEncoding.default }
    public var sampleData: Data { return Data() }
    public var task: Task { return .requestPlain }
}

// 日志输出
func loggerOutput(items: Any..., separator _: String, terminator _: String) {
    print(items)
}
