//
//  APIProvider.swift
//  Network
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

//import Moya
//import PromiseKit
//
///// Request provider class. In this app, requests should be made through this class only.
//public final class APIProvider<Target>: MoyaProvider<Target> where Target: TargetType {
//
//    /// Initializes a reactive provider.
//    public override init(endpointClosure: @escaping EndpointClosure = APIProvider.endpointMapping,
//                         requestClosure: @escaping RequestClosure = MoyaProvider.defaultRequestMapping,
//                         stubClosure: @escaping StubClosure = MoyaProvider.neverStub,
//                         manager: Manager = APIProvider.alamofireManager,
//                         plugins: [PluginType] = [],
//                         trackInflights: Bool = false) {
//        super.init(endpointClosure: endpointClosure,
//                   requestClosure: requestClosure,
//                   stubClosure: stubClosure,
//                   manager: manager,
//                   plugins: plugins,
//                   trackInflights: trackInflights)
//    }
//
//    /// Used to return Promise instances when requests are made. Much better than using completion closures.
//    ///
//    /// **target -> Promise**
//    ///
//    /// - Parameter target: target
//    /// - Returns: Promise
//    public func request(_ target: Target) -> Promise<JSONResponse> {
//        return Promise(resolvers: { [weak self] fulfill, reject in
//            self?.request(target) { result in
//                switch result {
//                case let .success(response):
//                    guard let resp = JSONResponse(response) else {
//                        reject(AppNetworkError.invalidResponse(response))
//                        return
//                    }
//
//                    if resp.isSuccess {
//                        fulfill(resp)
//                    } else {
//                        reject(AppNetworkError.apiInvokeFailed(resp))
//                    }
//                case let .failure(error):
//                    reject(error)
//                }
//            }
//        })
//    }
//}
//
//extension APIProvider {
//
//    /// default `Alamofire.SessionManager`
//    public static var alamofireManager: Manager {
//        let configuration = URLSessionConfiguration.default
//        configuration.httpAdditionalHeaders = Manager.defaultHTTPHeaders
//        configuration.timeoutIntervalForRequest = HTTPConfig.shared.timeout
//
//        let manager = Manager(configuration: configuration)
//        manager.startRequestsImmediately = false
//
//        return manager
//    }
//
//    /// Target -> Endpoint
//    public static func endpointMapping(for target: Target) -> Endpoint<Target> {
//        return Endpoint(url: url(for: target),
//                        sampleResponseClosure: { .networkResponse(200, target.sampleData) },
//                        method: target.method,
//                        parameters: target.parameters,
//                        parameterEncoding: CustomEncoding())
//    }
//
//    /// Target -> URL
//    private static func url(for route: TargetType) -> String {
//        return route.baseURL.appendingPathComponent(route.path).absoluteString
//    }
//}
