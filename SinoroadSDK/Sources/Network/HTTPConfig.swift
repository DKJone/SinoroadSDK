//
//  HTTPConfig.swift
//  Network
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import Foundation
/// HTTP配置
/// 更改配置信息必须在执行任何网络请求之前
public final class HTTPConfig {
    public static let `default` = HTTPConfig()
    
    /// 主机地址，默认为127.0.0.1
    public static var host = "127.0.0.1"
    
    /// 端口，默认为8080
    public static var port = ""
    
    /// 是否采用HTTPS，默认为false
    public static var isSecure = false

    
    /// 请求超时时间，默认时间为30妙
    public static var timeout: Double = 30
    
    /// API地址，如：`https://127.0.0.1:8080/api`
    public static var apiURL: URL {
        return URL(string: "\(isSecure ? "https" : "http")://\(host)\(port)/sinoroad-api/app")!
    }
}
