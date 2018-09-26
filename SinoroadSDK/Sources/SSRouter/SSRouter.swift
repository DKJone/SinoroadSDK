//
//  URLRouter.swift
//  URLRouter
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import UIKit

/// 路由规则
///
/// - native: 打开本地界面
/// - web: 打开Web界面
/// - disabled: 禁用路由
public enum RouteRule {
    case native
    case web(url: String)
    case disabled(cause: String)
}

/// Router
public final class SSRouter {
    /// 路由参数
    public typealias RouteParameters = [String: Any]
    
    /// 用于URL注册
    public typealias RouteHandler = Consumer<RouteParameters>
    
    /// 用于处理URL匹配失败
    public typealias RouteResolveErrorHandler = Consumer<RouteParameters?>
    
    /// 获取用于显示Web内容的UIViewController
    public typealias WebContentSupplier = Function<String, UIViewController>
    
    /// 获取用于显示禁用页面的UIViewController
    public typealias DisabledPageSupplier = Function<String, UIViewController>
    
    public static let kRouteScheme = "_scheme"
    public static let kRouteTarget = "_target"
    public static let kRoutePath = "_path"
    
    /// Shared SSRouter
    public static let shared = SSRouter()
    
    // MARK: - Scheme
    
    public static let appScheme = "SSRouter"
    public static let httpScheme = "http"
    public static let httpsScheme = "https"
    
    /// 支持的Scheme，默认支持：SSRouter、http、https
    public var schemes = [String]()
    
    /// 路由信息
    public let routes = NSMutableDictionary()
    
    /// 路由规则 - 获取时请根据当前应用的版本号，避免版本兼容问题
    public var rules = [String: RouteRule]()
    
    /// 导航控制器
    public var navController: UINavigationController?
    
    /// 在路径解析错误时调用
    public var globalErrorHandler: RouteResolveErrorHandler?
    /// 提供用于显示Web内容的界面
    public var webContentSupplier: WebContentSupplier?
    /// 提供用于路由被禁用时需要跳转的界面
    public var disabledPageSupplier: DisabledPageSupplier?
    
    private init() {
        schemes.append(contentsOf: [SSRouter.appScheme, SSRouter.httpScheme, SSRouter.httpsScheme])
    }
    
    public func map(_ url: String, handler:@escaping RouteHandler) {
        let dict = parse(url)
        dict.setValue(handler, forKey: SSRouter.kRouteTarget)
    }
    
    public func map(_ url: String, controller: UIViewController.Type) {
        let dict = parse(url)
        dict.setValue(controller, forKey: SSRouter.kRouteTarget)
    }
    
    // TODO: - 类型擦除问题
    public func map(_ url: String, target: Any) {
        let dict = parse(url)
        dict.setValue(target, forKey: SSRouter.kRouteTarget)
    }
    
    /// 匹配指定的URL
    ///
    /// - Parameter url: 需要匹配的URL
    /// - Returns: URL匹配到的路由信息，匹配失败返回nil
    public func match(_ url: String) -> [String: Any]? {
        guard let urlComponents = URLComponents(string: url) else {
            return nil
        }
        
        // 过滤非法的Scheme
        if let scheme = urlComponents.scheme, !schemes.contains(scheme) {
            return nil
        }
        
        var subRoutes = routes
        var parameters = [String: Any]()
        
        var found = false
        for path in urlComponents.url!.pathComponents where path != "/" /* 过滤空路径 */ {
            found = false
            // swiftlint:disable:next force_cast
            for key in (subRoutes.allKeys as! [String]) where validatePath(path, expectedPath: key) {
                subRoutes = subRoutes.object(forKey: key) as! NSMutableDictionary // swiftlint:disable:this force_cast
                // 处理参数
                if key.hasPrefix(":") {
                    let paramName = key.substring(from: key.index(after: key.startIndex))
                    parameters[paramName] = path
                }
                found = true
            }
        }
        
        if found {
            parameters[SSRouter.kRouteScheme] = urlComponents.scheme ?? SSRouter.appScheme
            parameters[SSRouter.kRoutePath] = url
            parameters[SSRouter.kRouteTarget] = subRoutes.object(forKey: SSRouter.kRouteTarget)
            // 添加URL的查询参数，如：'...?key=value'
            for queryItem in urlComponents.queryItems ?? [] {
                parameters[queryItem.name] = queryItem.value ?? ""
            }
        }
        
        return found ? parameters : nil
    }
    
    /// 执行URL对应的操作，如果匹配失败，则执行RouteResolveErrorHandler
    ///
    /// - Parameters:
    ///   - url: 需要匹配的URL
    ///   - errorHandler: 用于处理解析失败的情况
    /// - Returns: 执行成功返回true
    public func open(_ url: String, errorHandler: RouteResolveErrorHandler? = nil) -> Bool {
        let result = match(url)
        guard let params = result, let target = params[SSRouter.kRouteTarget] else { // 匹配失败
            if let errorHandler = errorHandler {
                errorHandler(result)
            } else {
                globalErrorHandler?(result)
            }
            return false
        }
        
        if let status = rules[params[SSRouter.kRoutePath] as! String] {
            switch status {
            case .disabled(let cause):
                if (disabledPageSupplier?(cause)) != nil {
                    return true
                }
                return false
            case .web(let url):
                if (webContentSupplier?(url)) != nil {
                    return true
                }
                return false
            case .native: ()
            }
        }
        
        var resolved = false
        switch target {
        case let controllerType as UIViewController.Type:
            _ = controllerType.init(nibName: "", bundle: nil)
            resolved = true
        case let target as RouteHandler:
            target(params)
            resolved = true
        default: // TODO: support Any type?
            print("unknown target")
        }
        
        return resolved
    }
    
    /// 解析URL
    func parse(_ url: String) -> NSMutableDictionary {
        var subRoutes = routes
        for path in URL(string: url)!.pathComponents where path != "/" {
            if let dict = subRoutes.object(forKey: path) as? NSMutableDictionary {
                subRoutes = dict
                continue
            }
            let dict = NSMutableDictionary()
            subRoutes[path] = dict
            subRoutes = dict
        }
        return subRoutes
    }
    
    /// 验证路径是否匹配，如：`\user\123` -> `\user\:id` 或 `\user\123`
    /// - Returns: true表示路径匹配
    func validatePath(_ path: String, expectedPath: String) -> Bool {
        return path == expectedPath || expectedPath.hasPrefix(":")
    }
}
