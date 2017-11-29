//
//  UINavigationControllerExt.swift
//  CommonUtil
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import UIKit

// MARK: - UINavigationController
public extension UINavigationController {
    
    /// Pop ViewController with completion handler.
    ///
    /// - Parameter completion: optional completion handler (default is nil).
    public func popViewController(completion: (() -> Void)? = nil) {
        // https://github.com/cotkjaer/UserInterface/blob/master/UserInterface/UIViewController.swift
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        popViewController(animated: true)
        CATransaction.commit()
    }
    
    /// Push ViewController with completion handler.
    ///
    /// - Parameters:
    ///   - viewController: viewController to push.
    /// - Parameter completion: optional completion handler (default is nil).
    public func pushViewController(viewController: UIViewController, completion: (() -> Void)? = nil) {
        // https://github.com/cotkjaer/UserInterface/blob/master/UserInterface/UIViewController.swift
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: true)
        CATransaction.commit()
    }
    
    /// Make navigation controller's navigation bar transparent.
    ///
    /// - Parameter withTint: tint color (default is white).
    public func makeTransparent(with tintColor: UIColor = .white) {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        navigationBar.tintColor = tintColor
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: tintColor]
    }
}

// MARK: - UINavigationBar
public extension UINavigationBar {
    
    /// Set Navigation Bar title, title color and font.
    ///
    /// - Parameters:
    ///   - font: title font
    ///   - color: title text color (default is .black).
    public func setTitleFont(_ font: UIFont, color: UIColor = UIColor.black) {
        var attrs = [NSAttributedStringKey: AnyObject]()
        attrs[NSAttributedStringKey.font] = font
        attrs[NSAttributedStringKey.foregroundColor] = color
        self.titleTextAttributes = attrs
    }
    
    /// Make navigation bar transparent.
    ///
    /// - Parameter withTint: tint color (default is .white).
    public func makeTransparent(with tintColor: UIColor = .white) {
        self.setBackgroundImage(UIImage(), for: .default)
        self.shadowImage = UIImage()
        self.isTranslucent = true
        self.tintColor = tintColor
        self.titleTextAttributes = [NSAttributedStringKey.foregroundColor: tintColor]
    }
    
    /// SwifterSwift: Set navigationBar background and text colors
    ///
    /// - Parameters:
    ///   - background: backgound color
    ///   - text: text color
    public func setColors(background: UIColor, text: UIColor) {
        self.isTranslucent = false
        self.backgroundColor = background
        self.barTintColor = background
        self.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.tintColor = text
        self.titleTextAttributes = [NSAttributedStringKey.foregroundColor: text]
    }
}

public extension UINavigationItem {
    
    /// Replace title label with an image in navigation item.
    ///
    /// - Parameter image: UIImage to replace title with.
    public func replaceTitle(with image: UIImage) {
        let logoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.image = image
        self.titleView = logoImageView
    }
}
