//
//  PasswordView.swift
//  CommonUI
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import UIKit

public class PasswordField: UITextField {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.keyboardType = .numberPad
        self.textColor = UIColor.clear
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)) || action == #selector(select(_:)) || action == #selector(selectAll(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

public class PasswordLabel: UILabel {

    public convenience init() {
        self.init(frame: CGRect.zero)
        self.font = UIFont.boldSystemFont(ofSize: 60)
        self.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        self.layer.borderWidth = 0.5
        self.textAlignment = .center
        self.backgroundColor = UIColor.white
    }
}

/// 密码输入框
public class PasswordView: UIView, UITextFieldDelegate {
    private var textField: PasswordField!
    private var labels = [
        PasswordLabel(),
        PasswordLabel(),
        PasswordLabel(),
        PasswordLabel(),
        PasswordLabel(),
        PasswordLabel()
    ]

    public var handler: ((String) -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }

    private func initView() {
        textField = PasswordField(frame: bounds)
        textField.delegate = self
        addSubview(textField)

        labels.forEach { addSubview($0) }

        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: .UITextFieldTextDidChange, object: textField)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public func clearPassword() {
        textField.text = nil
        textDidChange()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        let labelWidth = bounds.size.width / 6
        let labelHeight = bounds.size.height
        for (index, subview) in subviews.enumerated() where subview is PasswordLabel {
            subview.frame = CGRect(x: CGFloat(index - 1) * labelWidth, y: 0, width: labelWidth, height: labelHeight)
        }
    }

    @objc func textDidChange() {
        labels.enumerated().forEach { index, label in
            label.text = index < textField.text!.utf8.count ? "·" : nil
        }
        if textField.text!.utf8.count == 6 {
            handler?(textField.text!)
        }
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn _: NSRange, replacementString string: String) -> Bool {
        if string.utf8.count == 0 {
            return true
        }
        return textField.text!.utf8.count < 6
    }
}
