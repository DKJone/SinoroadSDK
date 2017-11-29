//
//  QRScanView.swift
//  CommonUI
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import UIKit

// TODO: 横竖屏切换、顶部多余线条
/// 二维码扫描
public class QRScanView: UIView {
    private let transparentAreaSize = CGSize(width: 200, height: 200)

    private var scanLineView: UIImageView!
    private var scanLineViewY: CGFloat!
    private var timer: Timer!

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        addScanLine()
        addTipLabel()
        timer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(animateScanLine), userInfo: nil, repeats: true)
        timer.fire()
    }

    /// 释放相关资源
    public func destroy() {
        timer.invalidate()
    }

    func addScanLine() {
        scanLineView = UIImageView(frame: CGRect(x: (width - transparentAreaSize.width) / 2, y: (height - transparentAreaSize.height) / 2, width: transparentAreaSize.width, height: 2))
        scanLineView.backgroundColor = Theme.themeColor
        scanLineView.contentMode = .scaleAspectFill
        addSubview(scanLineView)
        scanLineViewY = scanLineView.frame.origin.y
    }

    func addTipLabel() {
        let label = UILabel(frame: CGRect(x: 0, y: (height + transparentAreaSize.height) / 2 + 10, width: width, height: 30))
        label.text = "将二维码放入框内，即可自动扫描"
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        addSubview(label)
    }

    @objc func animateScanLine() {
        UIView.animate(withDuration: 0.02,
                       animations: {
                           var rect = self.scanLineView.frame
                           rect.origin.y = self.scanLineViewY
                           self.scanLineView.frame = rect
                       },
                       completion: { _ in
                           let maxBorder = self.frame.size.height / 2 + self.transparentAreaSize.height / 2 - 4
                           if self.scanLineViewY > maxBorder {
                               self.scanLineViewY = (self.frame.height - self.transparentAreaSize.height) / 2
                           }
                           self.scanLineViewY = self.scanLineViewY + 1 // swiftlint:disable:this shorthand_operator
        })
    }

    public override func draw(_ rect: CGRect) {
        let screenSize = UIScreen.main.bounds.size
        let screenDrawRect = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)

        let originX = (screenDrawRect.width - transparentAreaSize.width) / 2
        let originY = (screenDrawRect.height - transparentAreaSize.height) / 2
        let clearDrawRect = CGRect(x: originX, y: originY, width: transparentAreaSize.width, height: transparentAreaSize.height)

        addScreenFillRect(screenDrawRect)
        addCenterClearRect(clearDrawRect)
        addWhiteRect(clearDrawRect)
        addCornerLine(clearDrawRect)
    }

    private func addScreenFillRect(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.setFillColor(red: 40 / 255.0, green: 40 / 255.0, blue: 40 / 255.0, alpha: 0.5)
        ctx.fill(rect)
    }

    private func addCenterClearRect(_ rect: CGRect) {
        UIGraphicsGetCurrentContext()!.clear(rect)
    }

    private func addWhiteRect(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.setStrokeColor(red: 1, green: 1, blue: 1, alpha: 1)
        ctx.stroke(rect, width: 0.8)
    }

    private func addCornerLine(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.setLineWidth(5)
        ctx.setStrokeColor(red: 83 / 255, green: 239 / 255, blue: 111 / 255, alpha: 1)

        // 左上角
        let leftTopPoints = [
            CGPoint(x: rect.origin.x, y: rect.origin.y),
            CGPoint(x: rect.origin.x, y: rect.origin.y + 15),
            CGPoint(x: rect.origin.x, y: rect.origin.y),
            CGPoint(x: rect.origin.x + 15, y: rect.origin.y)
        ]
        ctx.strokeLineSegments(between: leftTopPoints)
        // 左下角
        let leftBottomPoints = [
            CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height - 15),
            CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height),
            CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height),
            CGPoint(x: rect.origin.x + 15, y: rect.origin.y + rect.size.height)
        ]
        ctx.strokeLineSegments(between: leftBottomPoints)
        // 右上角
        let rightTopPoints = [
            CGPoint(x: rect.origin.x + rect.size.width - 15, y: rect.origin.y),
            CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y),
            CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y),
            CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + 15)
        ]
        ctx.strokeLineSegments(between: rightTopPoints)
        // 右下角
        let rightBottomPoints = [
            CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height + -15),
            CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height),
            CGPoint(x: rect.origin.x + rect.size.width - 15, y: rect.origin.y + rect.size.height),
            CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height)
        ]
        ctx.strokeLineSegments(between: rightBottomPoints)
    }
}
