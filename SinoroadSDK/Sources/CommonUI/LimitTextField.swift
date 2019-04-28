//
//  LimitTextField.swift
//  CommonUI
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import UIKit

/// 限制文本长度的输入框
public class LimitTextField: UITextField, UITextFieldDelegate {
    /// 文本的最大输入长度，默认为10个字符
    @IBInspectable
    public var maxLength: Int = 10

    private weak var textFieldDelegate: UITextFieldDelegate?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
        addTarget(self, action: #selector(textFieldTextDidChange), for: .editingChanged)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
        addTarget(self, action: #selector(textFieldTextDidChange), for: .editingChanged)
    }

    @objc func textFieldTextDidChange() {
        guard let text = self.text else { return }

        if text.count > maxLength {
            self.text = text.substring(to: text.index(text.startIndex, offsetBy: maxLength))
        }
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if self.text!.count == maxLength && string != "" {
            return false
        }
        return textFieldDelegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textFieldDelegate?.textFieldShouldReturn?(textField) ?? true
    }

    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)) || action == #selector(select(_:)) || action == #selector(selectAll(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}
