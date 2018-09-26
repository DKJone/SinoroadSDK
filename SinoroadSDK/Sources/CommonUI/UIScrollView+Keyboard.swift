//
//  UIScrollView+Keyboard.swift
//  CommonUI
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import UIKit
import SnapKit
// MARK: - Keyboard

extension UIScrollView {

    private struct AssociatedKeys {
        static var kCurrentResponder = "currentResponder"
        static var kOriginalOffset = "originalOffset"
        static var kLastOffset = "lastOffset"
    }

    var currentResponder: UITextField? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.kCurrentResponder, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.kCurrentResponder) as? UITextField
        }
    }
    var originalOffset: CGPoint? {
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.kOriginalOffset, NSValue(cgPoint: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
                objc_setAssociatedObject(self, &AssociatedKeys.kOriginalOffset, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        get {
            if let value = objc_getAssociatedObject(self, &AssociatedKeys.kOriginalOffset) as? NSValue {
                return value.cgPointValue
            } else {
                return nil
            }
        }
    }
    var lastOffset: CGPoint? {
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.kLastOffset, NSValue(cgPoint: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
                objc_setAssociatedObject(self, &AssociatedKeys.kLastOffset, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        get {
            if let value = objc_getAssociatedObject(self, &AssociatedKeys.kLastOffset) as? NSValue {
                return value.cgPointValue
            } else {
                return nil
            }
        }
    }

    public func observerKeyboard() {
        // UITextField
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldBeginEditing(_:)), name: UITextField.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldEndEditing(_:)), name: UITextField.textDidEndEditingNotification, object: nil)
        // UIKeyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    public func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func textFieldBeginEditing(_ notification: NSNotification) {
        currentResponder = notification.object as? UITextField
    }

    @objc func textFieldEndEditing(_ notification: NSNotification) {
        currentResponder = nil
    }

    @objc func keyboardWillShow(_ notification: NSNotification) {
        guard let firstResponder = currentResponder else { return }

        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue // swiftlint:disable:this force_cast
        let keyboardHeight = keyboardFrame.height
        let firstResponderY = firstResponder.convert(firstResponder.frame, to: window).maxY
        let offsetY = keyboardHeight - (screenSize.height - firstResponderY)
        if offsetY > 0 {
            if originalOffset == nil {
                originalOffset = contentOffset
            }
            lastOffset = contentOffset
            setContentOffset(CGPoint(x: 0, y: contentOffset.y + offsetY), animated: true)
        }
    }

    @objc func keyboardWillHide(_: NSNotification) {
        if let originalOffset = originalOffset {
            DispatchQueue.main.async {
                if !self.deepResponderViews().map({ $0.isFirstResponder }).contains(true) {
                    self.setContentOffset(originalOffset, animated: true)
                }
            }
        }
    }
}

// MARK: - Keyboard ToolBar

public class KeyboardToolbar: UIView {
    private var prevButton: UIButton!
    private var nextButton: UIButton!
    private var doneButton: UIButton!

    lazy var responderViews: [UIView] = {
        switch currentWindow.rootViewController {
        case let controller as UINavigationController:
            return controller.topViewController!.view.deepResponderViews() // swiftlint:disable:this force_cast
        default:
            return []
        }
    }()

    var currentResponder: UITextField! {
        didSet {
            guard currentResponder != nil else { return }

            if let index = responderViews.index(of: currentResponder) {
                nextButton.isEnabled = responderViews.count - 1 > index
                prevButton.isEnabled = index > 0
            }
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()

        NotificationCenter.default.addObserver(self, selector: #selector(textFieldBeginEditing(_:)), name: UITextField.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldEndEditing(_:)), name: UITextField.textDidEndEditingNotification, object: nil)
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func initViews() {
        backgroundColor = UIColor(hexString: "#F1F1F1")
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 0.5

        prevButton = UIButton(type: .system)
        prevButton.setImage(UIImage(named: "IQButtonBarArrowLeft"), for: .normal)
        prevButton.addTarget(self, action: #selector(prev), for: .touchUpInside)
        addSubview(prevButton)
        prevButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalTo(40)
            make.centerY.equalToSuperview()
        }
        nextButton = UIButton(type: .system)
        nextButton.setImage(UIImage(named: "IQButtonBarArrowRight"), for: .normal)
        nextButton.addTarget(self, action: #selector(getter: next), for: .touchUpInside)
        addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.leading.equalTo(prevButton.snp.trailing)
            make.width.equalTo(40)
            make.centerY.equalToSuperview()
        }
        doneButton = UIButton(type: .system)
        doneButton.setTitle("完成", for: .normal)
        doneButton.addTarget(self, action: #selector(done), for: .touchUpInside)
        addSubview(doneButton)
        doneButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
    }

    @objc func textFieldBeginEditing(_ notification: NSNotification) {
        currentResponder = notification.object as? UITextField
    }

    @objc func textFieldEndEditing(_: NSNotification) {
        currentResponder = nil
    }

    @objc func prev() {
        if let index = responderViews.index(of: currentResponder), index > 0 {
            currentResponder.resignFirstResponder()
            responderViews[index - 1].becomeFirstResponder()
        }
    }

    func next() {
        if let index = responderViews.index(of: currentResponder), index < responderViews.count - 1 {
            currentResponder.resignFirstResponder()
            responderViews[index + 1].becomeFirstResponder()
        }
    }

    @objc func done() {
        currentWindow.rootViewController!.view.endEditing(true)
    }
}

// MARK: - Responder Views

extension UIView {

    public func deepResponderViews() -> [UIView] {
        // subviews are returning in opposite order. So I sorted it according the frames 'y'.
        let subViews = self.subviews.sorted(by: { (view1: UIView, view2: UIView) -> Bool in
            let x1 = view1.frame.minX
            let y1 = view1.frame.minY
            let x2 = view2.frame.minX
            let y2 = view2.frame.minY

            if y1 != y2 {
                return y1 < y2
            } else {
                return x1 < x2
            }
        })

        // UITextField/UITextView
        var textfields = [UIView]()
        for textField in subViews {
            if textField.canBecomeFirstResponder == true {
                textfields.append(textField)
            } else if textField.subviews.count != 0 && isUserInteractionEnabled == true && isHidden == false && alpha != 0.0 {
                for deepView in textField.deepResponderViews() {
                    textfields.append(deepView)
                }
            }
        }

        return textfields
    }
}
