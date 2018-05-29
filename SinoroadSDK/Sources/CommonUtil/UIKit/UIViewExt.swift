//
//  UIViewExt.swift
//  CommonUtil
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import UIKit

// MARK: - Geometry
extension UIView {
    
    public var width: CGFloat {
        return self.bounds.size.width
    }
    
    public var height: CGFloat {
        return self.bounds.size.height
    }
}

// MARK: - Inspectable
extension UIView {
    
    /// The color of the layer’s border.
    @IBInspectable
    public var borderColor: UIColor? {
        get {
            return layer.borderColor?.uiColor
        }
        set {
            guard let color = newValue else {
                layer.borderColor = nil
                return
            }
            layer.borderColor = color.cgColor
        }
    }
    
    /// The width of the layer’s border.
    @IBInspectable
    public var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    /// The radius to use when drawing rounded corners for the layer’s background.
    @IBInspectable
    public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.masksToBounds = true
            layer.cornerRadius = abs(CGFloat(Int(newValue * 100)) / 100)
        }
    }
    
    /// The color of the layer’s shadow.
    @IBInspectable
    public var shadowColor: UIColor? {
        get {
            return layer.shadowColor?.uiColor
        }
        set {
            layer.shadowColor = newValue?.cgColor
        }
    }
    
    /// The offset (in points) of the layer’s shadow.
    @IBInspectable
    public var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    /// The opacity of the layer’s shadow.
    @IBInspectable
    public var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    /// The blur radius (in points) used to render the layer’s shadow.
    @IBInspectable
    public var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
}

// MARK: - Util
extension UIView {
    
    /// Get first responder of the current view and its subviews.
    public var firstResponder: UIView? {
        guard !isFirstResponder else {
            return self
        }
        for subView in subviews {
            if subView.isFirstResponder {
                return subView
            }
        }
        return nil
    }
    
    /// Take screenshot of view (if applicable).
    public var screenshot: UIImage? {
        UIGraphicsBeginImageContextWithOptions(layer.bounds.size, false, 0.0)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// Load view from nib.
    ///
    /// - Parameters:
    ///   - named: nib name.
    ///   - bundle: bundle of nib (default is nil).
    /// - Returns: optional UIView (if applicable).
    public static func loadFromNib(named: String, bundle: Bundle? = nil) -> UIView? {
        return UINib(nibName: named, bundle: bundle).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }
    
    /// Set some or all corners radiuses of view.
    ///
    /// - Parameters:
    ///   - corners: array of corners to change (example: [.bottomLeft, .topRight]).
    ///   - radius: radius for selected corners.
    public func roundCorners(_ corners: UIRectCorner = UIRectCorner.allCorners, radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius))
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
    }
    
    /// Add shadow to view.
    ///
    /// - Parameters:
    ///   - color: shadow color (default is #137992).
    ///   - radius: shadow radius (default is 3).
    ///   - offset: shadow offset (default is .zero).
    ///   - opacity: shadow opacity (default is 0.5).
    public func addShadow(ofColor color: UIColor = UIColor(hex: 0x137992), radius: CGFloat = 3, offset: CGSize = .zero, opacity: Float = 0.5) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.masksToBounds = true
    }
    
    public func addSubviews(_ subviews: [UIView]) {
        subviews.forEach({ self.addSubview($0) })
    }
    
    /// Remove all subviews.
    public func removeSubviews() {
        subviews.forEach({ $0.removeFromSuperview() })
    }
    
    /// Remove all gesture recognizers.
    public func removeGestureRecognizers() {
        gestureRecognizers?.forEach(removeGestureRecognizer)
    }
    
    /// remove all autolayout Constraint
    public func removeAllAutoLayout(){
        self.removeConstraints(self.constraints)
        guard let suV = self.superview else{return}
        suV.removeConstraints(suV.constraints.filter{($0.firstItem as? UIView) == self})
    }
}
