//
//  Theme.swift
//  CommonUI
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//
import UIKit

// MARK: - Appearance

public final class Theme {
    public static var themeColor = UIColor(hexString: "#5BADE3")
    public static var navTintColor = Theme.themeColor
    public static var navBarTintColor = Theme.themeColor
    public static var tabTintColor = Theme.themeColor
    public static var backgroundColor = UIColor(hexString: "#F5F5F5")
    
    /// 配置App主题风格
    public static func configureAppearance() {
        let navBarTitleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
        UINavigationBar.appearance().titleTextAttributes = navBarTitleTextAttributes
        UINavigationBar.appearance().tintColor = navTintColor
        //        UINavigationBar.appearance().barTintColor = navBarTintColor
        //        UINavigationBar.appearance().isTranslucent = false
        
        let barButtonItemTitleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]
        UIBarButtonItem.appearance().setTitleTextAttributes(barButtonItemTitleTextAttributes, for: .normal)
        
        UITabBar.appearance().barTintColor = UIColor.white
        UITabBar.appearance().tintColor = tabTintColor
        
        UITableViewCell.appearance().tintColor = themeColor
        
        UIButton.appearance().tintColor = themeColor
    }
}

// MARK: - Widget

extension Theme {
    
    /// UILabel
    ///
    /// - Parameters:
    ///   - text: 文本
    ///   - fontSize: 字体大小，默认为14
    ///   - textColor: 字体颜色，默认为黑色
    /// - Returns: UILabel
    public static func label(text: String? = nil, fontSize: CGFloat = 14, textColor: UIColor = UIColor.black) -> UILabel {
        return view(for: UILabel.self) { label in
            label.text = text
            label.font = UIFont.systemFont(ofSize: fontSize)
            label.textColor = textColor
        }
    }
    
    /// UITextField
    ///
    /// - Parameters:
    ///   - text: 文本
    ///   - placeholder: 字体大下，默认为15
    ///   - fontSize: 占位符
    /// - Returns: UITextField
    public static func textField(text: String? = nil, placeholder: String? = nil, fontSize: CGFloat = 15) -> UITextField {
        return view(for: UITextField.self) { textField in
            textField.text = text
            textField.placeholder = placeholder
            textField.font = UIFont.systemFont(ofSize: fontSize)
            textField.clearButtonMode = .whileEditing
        }
    }
    
    private static func view<T: UIView>(for _: T.Type, _ maker: (T) -> Void) -> T {
        let view = T()
        maker(view)
        return view
    }
    
    /// UIButton
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - titleColor: 标题色，默认为白色
    ///   - backgroundColor: 背景色，默认为主题色
    ///   - cornerRadius: 圆角，默认为5
    /// - Returns: UIButton
    public static func button(title: String? = nil, titleColor: UIColor = UIColor.white, backgroundColor: UIColor = Theme.themeColor, cornerRadius: CGFloat = 5) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = cornerRadius
        return button
    }
    
    /// 键盘工具栏
    ///
    /// - Returns: UIView
    public static func inputAccessoryView() -> UIView {
        return KeyboardToolbar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 40))
    }
    
    /// 表格底部空视图
    ///
    /// - Returns: UIView
    public static func emptyTableFooterView() -> UIView {
        return UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 0.01))
    }
}
