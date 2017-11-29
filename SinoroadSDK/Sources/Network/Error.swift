//
//  Error.swift
//  Network
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import Moya

/// 网络请求相关错误
public enum AppNetworkError: Swift.Error {
    case requestFailed(JSONResponse) // 请求错误，如：服务器内部错误、请求超时
    case apiInvokeFailed(JSONResponse) // 协议处理错误，如：服务端无法处理客户端的请求
    case invalidResponse(Response) // 服务器返回的数据格式错误
}

extension AppNetworkError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .requestFailed:
            return "请求错误"
        case .apiInvokeFailed:
            return "API调用失败"
        case .invalidResponse:
            return "服务器返回的数据格式错误"
        }
    }
    public var failureReason: String? {
        switch self {
        case let .requestFailed(resp):
            return resp.errorMsg
        case let .apiInvokeFailed(resp):
            return resp.errorMsg
        case .invalidResponse:
            return "服务器返回的数据格式错误"
        }
    }
}
