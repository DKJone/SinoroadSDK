//
//  PaddingTextField.swift
//  CommonUI
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import UIKit

/// 带有内边距的输入框
public class PaddingTextField: UITextField {
    /// 内边距，默认为10
    public var padding: CGFloat = 10

    public override init(frame: CGRect) {
        super.init(frame: frame)
        addLeftView()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addLeftView()
    }

    private func addLeftView() {
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: padding))
        self.leftViewMode = .always
    }
}
