//
//  APIProvider.swift
//  Network
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import Moya
import PromiseKit

extension MoyaProvider {

    /// Used to return `Promise` instances when requests are made. Much better than using completion closures.
    ///
    /// **target -> Promise**
    ///
    /// - Parameter target: target
    /// - Returns: Promise
    public func request(_ target: Target) -> Promise<JSONResponse> {
        return Promise(resolvers: { [weak self] fulfill, reject in
            self?.request(target) { result in
                switch result {
                case let .success(response):
                    guard let resp = JSONResponse(response) else {
                        reject(AppNetworkError.invalidResponse(response))
                        return
                    }

                    if resp.isSuccess {
                        fulfill(resp)
                    } else {
                        reject(AppNetworkError.apiInvokeFailed(resp))
                    }
                case let .failure(error):
                    reject(error)
                }
            }
        })
    }
}
