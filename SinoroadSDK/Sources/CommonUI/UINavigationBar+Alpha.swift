//
//  UINavigationBar+Alpha.swift
//  CommonUI
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import UIKit

// MARK: - UINavigationBar+Alpha
extension UINavigationBar {
    
    private struct AssociatedKeys {
        static var kScrollView = "scrollView"
        static var kBarColor = "barColor"
    }
    
    public var barColor: UIColor? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.kBarColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.kBarColor) as? UIColor
        }
    }
    
    private var scrollView: UIScrollView? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.kScrollView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.kScrollView) as? UIScrollView
        }
    }
    
    private var distance: CGFloat {
        return scrollView!.contentInset.top
    }
    
    private func updateAlpha(_ alpha: CGFloat = 0.0) {
        let color = (barColor ?? tintColor).withAlphaComponent(alpha)
        let backgroundImage = UIImage(color: color, size: CGSize(width: 1, height: 1))
        setBackgroundImage(backgroundImage, for: .default)
    }
    
    /// 添加至指定的UIScrollView
    ///
    /// - Parameter scrollView: 指定的UIScrollView
    public func attach(to scrollView: UIScrollView) {
        self.scrollView = scrollView
        self.shadowImage = UIImage()
        // self.tintColor = UIColor.white
        self.barTintColor = .clear
        self.isTranslucent = true
        scrollView.addObserver(self, forKeyPath: kContentOffset, options: .new, context: nil)
    }
    
    /// 重置
    public func reset() {
        self.scrollView?.removeObserver(self, forKeyPath: kContentOffset)
        self.scrollView = nil
        self.shadowImage = nil
        // self.tintColor = nil
        // self.titleTextAttributes = nil
        self.barTintColor = Theme.themeColor
        self.isTranslucent = false
        // self.setBackgroundImage(nil, for: .default)
    }
    
    open override func observeValue(forKeyPath _: String?, of _: Any?, change _: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
        guard let scrollView = scrollView else { return }
        
        let offsetY = scrollView.contentOffset.y
        if offsetY > -distance {
            let alpha = min(1, 1 - ((-distance + 120 - offsetY) / 64))
            updateAlpha(alpha)
        } else {
            updateAlpha(0)
        }
    }
}
