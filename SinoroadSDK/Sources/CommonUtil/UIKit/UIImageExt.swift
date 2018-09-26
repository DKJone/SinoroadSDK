//
//  ImageExt.swift
//  CommonUtil
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Properties

public extension UIImage {
    /// Size in bytes of UIImage
    public var bytesSize: Int {
        return self.jpegData(compressionQuality: 1)?.count ?? 0
    }

    /// Size in kilo bytes of UIImage
    public var kilobytesSize: Int {
        return self.bytesSize / 1024
    }

    /// UIImage with .alwaysOriginal rendering mode.
    public var original: UIImage {
        return withRenderingMode(.alwaysOriginal)
    }

    /// UIImage with .alwaysTemplate rendering mode.
    public var template: UIImage {
        return withRenderingMode(.alwaysTemplate)
    }

    /// Create UIImage from color and size.
    ///
    /// - Parameters:
    ///   - color: image fill color.
    ///   - size: image size.
    public convenience init(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        color.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.init(cgImage: image.cgImage!)
    }
}

// MARK: - Methods

public extension UIImage {
    /// Compress UIImage from original UIImage.
    ///
    /// - Parameter quality: The quality of the resulting JPEG image, expressed as a value from 0.0 to 1.0. The value 0.0 represents the maximum compression (or lowest quality) while the value 1.0 represents the least compression (or best quality), (default is 0.5).
    /// - Returns: optional UIImage (if applicable).
    public func compress(quality: CGFloat = 0.5) -> UIImage? {
        guard let data = self.jpegData(compressionQuality: quality) else {
            return nil
        }
        return UIImage(data: data)
    }

    /// Crop UIImage to specified CGRect.
    public func crop(to rect: CGRect) -> UIImage {
        guard rect.size.height < size.height && rect.size.height < size.height else {
            return self
        }
        guard let image: CGImage = cgImage?.cropping(to: rect) else {
            return self
        }
        return UIImage(cgImage: image)
    }

    /// 按照给定的尺寸对图片进行缩放处理
    ///
    /// - Parameter size: 指定的尺寸
    /// - Returns: 缩放后的图片
    public func scale(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }

        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

        return UIGraphicsGetImageFromCurrentImageContext()!
    }

    /// 按照给定的缩放比例缩放图片
    ///
    /// - Parameter scale: 缩放比例
    /// - Returns: 缩放后的图片
    public func scale(with ratio: CGFloat) -> UIImage {
        let size = CGSize(width: self.size.width * ratio, height: self.size.height * ratio)
        return self.scale(to: size)
    }

    /// 修正图片方向
    ///
    /// - Returns: 修正后的图片
    public func fixOrientation() -> UIImage {
        // No-op if the orientation is already correct
        if self.imageOrientation == .up { return self }

        let width = self.size.width
        let height = self.size.height

        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform = CGAffineTransform.identity
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: width, y: height).rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: width, y: 0).rotated(by: CGFloat.pi / 2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: height).rotated(by: -CGFloat.pi / 2)
        default: ()
        }

        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: width, y: 0).scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: height, y: 0).scaledBy(x: -1, y: 1)
        default: ()
        }

        // Now we draw the underlying CGImage into a new context, applying the transform calculated above.
        let ctx = CGContext(data: nil,
                            width: Int(width),
                            height: Int(height),
                            bitsPerComponent: self.cgImage!.bitsPerComponent,
                            bytesPerRow: 0,
                            space: self.cgImage!.colorSpace!,
                            bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx!.concatenate(transform)

        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx!.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: height, height: width))
        default:
            ctx!.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: width, height: height))
        }

        // And now we just create a new UIImage from the drawing context
        return UIImage(cgImage: ctx!.makeImage()!)
    }
}
