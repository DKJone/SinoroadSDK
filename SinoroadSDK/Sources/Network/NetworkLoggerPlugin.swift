//
//  NetworkLoggerPlugin.swift
//  Network
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import Foundation
import Moya
import Result

/// 用于处理通信日志
public final class NetworkLoggerPlugin: PluginType {
    
    public init() {}
    
    public func willSend(_ request: RequestType, target _: TargetType) {
        if let request = request.request {
            logNetworkRequest(request).forEach(output)
        }
    }
    
    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        if case let .success(response) = result {
            logNetworkResponse(response.response, data: response.data, target: target).forEach(output)
        } else {
            logNetworkResponse(nil, data: nil, target: target).forEach(output)
        }
    }
    
    private func output(_ message: Any) {
        Log.verbose(message)
    }
    
    private func logNetworkRequest(_ request: URLRequest) -> [String] {
        var output = [String]()
        
        // URL
        output += [format("Request URL", message: request.url?.absoluteString ?? "(invalid request)")]
        
        // HTTP Method
        request.httpMethod.map({ output += [format("Request Method", message: $0)] })
        
        // HTTP Header
        request.allHTTPHeaderFields
            .flatMap({ try? JSONSerialization.data(withJSONObject: $0, options: .prettyPrinted) })
            .flatMap({ String(data: $0, encoding: String.Encoding.utf8) })
            .map({ output += [format("Request Headers", message: $0)] })
        
        // HTTP Body
        request.httpBody
            .flatMap({ String(data: $0, encoding: String.Encoding.utf8) })
            .map({ output += [format("Request Body", message: $0)] })
        
        return output
    }
    
    private func logNetworkResponse(_ response: HTTPURLResponse?, data: Data?, target: TargetType) -> [String] {
        var output = [String]()
        
        guard let response = response else {
            Log.error(format("Response", message: "Received empty network response for \(target)."))
            return output
        }
        
        output += [format("Response Status", message: "\(response.statusCode) - \(HTTPURLResponse.localizedString(forStatusCode: response.statusCode))")]
        
        (try? JSONSerialization.data(withJSONObject: response.allHeaderFields, options: .prettyPrinted))
            .flatMap({ String(data: $0, encoding: String.Encoding.utf8) })
            .map({ output += [format("Response Headers", message: $0)] })
        
        data.flatMap({ String(data: JSONResponseDataFormatter(data: $0), encoding: String.Encoding.utf8) })
            .map({ output += [format("Response Body", message: $0)] })
        
        return output
    }
    
    private func format(_ identifier: String, message: String) -> String {
        return "\(identifier): \(message)"
    }
    
    private func JSONResponseDataFormatter(data: Data) -> Data {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            let prettyData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            return prettyData
        } catch {
            Log.error(error.localizedDescription)
            
            return data // fallback to original data if it cant not be serialized
        }
    }
}
