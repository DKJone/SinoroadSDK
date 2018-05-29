//
//  EventBus.swift
//  CommonUtil
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import Foundation

/// A wrapper for NotificationCenter.
public final class EventBus {
    
    private struct Static {
        static let instance = EventBus()
        static let queue = DispatchQueue(label: "com.sinoroad.sdk" + UUID().uuidString)
    }
    
    private struct NamedObserver {
        let observer: NSObjectProtocol
        let name: String
    }
    
    private var cache = [ObjectIdentifier: [NamedObserver]]()
    
    // MARK: - Publish
    
    /// Creates a notification with a given name, sender, and information and posts it to the receiver on main thread.
    ///
    /// - Parameters:
    ///   - name: The name of the notification.
    ///   - sender: The object posting the notification. Default is nil.
    ///   - userInfo: Information about the the notification. Default is nil.
    public static func postToMainThread(name: String, sender: Any? = nil, userInfo: [AnyHashable: Any]? = nil) {
        postToMainThread(name: Notification.Name(rawValue: name), sender: sender, userInfo: userInfo)
    }
    
    /// Creates a notification with a given name, sender, and information and posts it to the receiver.
    ///
    /// - Parameters:
    ///   - name: The name of the notification.
    ///   - sender: The object posting the notification. Default is nil.
    ///   - userInfo: Information about the the notification. Default is nil.
    public static func post(name: String, sender: Any? = nil, userInfo: [AnyHashable: Any]? = nil) {
        post(name: Notification.Name(rawValue: name), sender: sender, userInfo: userInfo)
    }
    
    public static func postToMainThread(name: Notification.Name, sender: Any? = nil, userInfo: [AnyHashable: Any]? = nil) {
        DispatchQueue.main.async {
            post(name: name, sender: sender, userInfo: userInfo)
        }
    }
    
    public static func post(name: Notification.Name, sender: Any? = nil, userInfo: [AnyHashable: Any]? = nil) {
        NotificationCenter.default.post(name: name, object: sender, userInfo: userInfo)
    }
    
    // MARK: - Subscribe
    
    public typealias NotificationHandler = (Notification) -> Void
    
    @discardableResult
    public static func onMainThread(target: AnyObject, name: String, sender: Any? = nil, handler: @escaping NotificationHandler) -> NSObjectProtocol {
        return on(target: target, name: name, sender: sender, queue: OperationQueue.main, handler: handler)
    }
    
    @discardableResult
    public static func onBackgroundThread(target: AnyObject, name: String, sender: Any? = nil, handler: @escaping NotificationHandler) -> NSObjectProtocol {
        return on(target: target, name: name, sender: sender, queue: OperationQueue(), handler: handler)
    }
    
    @discardableResult
    public static func on(target: AnyObject, name: String, sender: Any?, queue: OperationQueue?, handler: @escaping NotificationHandler) -> NSObjectProtocol {
        return on(target: target, name: NSNotification.Name(rawValue: name), sender: sender, queue: queue, handler: handler)
    }
    
    @discardableResult
    public static func onMainThread(target: AnyObject, name: Notification.Name, sender: Any? = nil, handler: @escaping NotificationHandler) -> NSObjectProtocol {
        return on(target: target, name: name, sender: sender, queue: OperationQueue.main, handler: handler)
    }
    
    @discardableResult
    public static func onBackgroundThread(target: AnyObject, name: Notification.Name, sender: Any? = nil, handler: @escaping NotificationHandler) -> NSObjectProtocol {
        return on(target: target, name: name, sender: sender, queue: OperationQueue(), handler: handler)
    }
    
    @discardableResult
    public static func on(target: AnyObject, name: Notification.Name, sender: Any?, queue: OperationQueue?, handler: @escaping NotificationHandler) -> NSObjectProtocol {
        let id = ObjectIdentifier(target)
        let observer = NotificationCenter.default.addObserver(forName: name, object: sender, queue: queue, using: handler)
        let namedObserver = NamedObserver(observer: observer, name: name.rawValue)
        
        Static.queue.sync {
            if let namedObservers = Static.instance.cache[id] {
                Static.instance.cache[id] = namedObservers + [namedObserver]
            } else {
                Static.instance.cache[id] = [namedObserver]
            }
        }
        
        return observer
    }
    
    // MARK: - Unregister
    
    /// Removes all the entries specifying a given observer from the receiver’s dispatch table.
    ///
    /// - Parameter target: The observer to remove.
    public static func unregister(target: AnyObject) {
        let id = ObjectIdentifier(target)
        
        Static.queue.sync {
            if let namedObservers = Static.instance.cache.removeValue(forKey: id) {
                for namedObserver in namedObservers {
                    NotificationCenter.default.removeObserver(namedObserver.observer)
                }
            }
        }
    }
    
    /// Remove the entry specifying a given observer from the receiver’s dispatch table.
    ///
    /// - Parameters:
    ///   - target: The observer to remove.
    ///   - name: Name of the notification to remove from dispatch table.
    public static func unregister(target: AnyObject, name: String) {
        let id = ObjectIdentifier(target)
        
        Static.queue.sync {
            if let namedObservers = Static.instance.cache[id] {
                Static.instance.cache[id] = namedObservers.filter { (namedObserver: NamedObserver) -> Bool in
                    if namedObserver.name == name {
                        NotificationCenter.default.removeObserver(namedObserver.observer)
                        return false
                    } else {
                        return true
                    }
                }
            }
        }
    }
}
